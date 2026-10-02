"""orders-api: sync path behind API Gateway (HTTP API, payload format 2.0).

Env vars (set from Terraform):
  TABLE_NAME, QUEUE_URL, SERVICE_NAME
  FAILURE_RATE      0.0-1.0, chance a POST /orders raises (-> 500)
  EXTRA_LATENCY_MS  added sleep per request
"""
import base64
import json
import os
import random
import time
import uuid
from decimal import Decimal

import boto3

TABLE = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])
SQS = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]
SERVICE = os.environ.get("SERVICE_NAME", "orders")


def log(level, **fields):
    """One structured JSON line per call -> metric filters + Logs Insights."""
    print(json.dumps({"level": level, "service": SERVICE, **fields}, default=str))


def emf(order_value):
    """Embedded Metric Format line -> "NerosPizza/Orders" custom metrics."""
    print(json.dumps({
        "_aws": {
            "Timestamp": int(time.time() * 1000),
            "CloudWatchMetrics": [{
                "Namespace": "NerosPizza/Orders",
                "Dimensions": [["Service"]],
                "Metrics": [
                    {"Name": "OrdersPlaced", "Unit": "Count"},
                    {"Name": "OrderValue", "Unit": "None"},
                ],
            }],
        },
        "Service": SERVICE,
        "OrdersPlaced": 1,
        "OrderValue": order_value,
    }))


def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def handler(event, context):
    started = time.time()
    route = event.get("routeKey", "unknown")
    request_id = context.aws_request_id

    if route == "GET /health":
        return response(200, {"status": "ok"})

    # Fault knobs
    time.sleep(int(os.environ.get("EXTRA_LATENCY_MS", "0")) / 1000)
    if random.random() < float(os.environ.get("FAILURE_RATE", "0")):
        log("ERROR", requestId=request_id, route=route,
            message="Injected failure", reason="injected")
        raise RuntimeError("Injected failure")  # counts in AWS/Lambda Errors, API returns 500

    raw = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        raw = base64.b64decode(raw).decode()
    try:
        payload = json.loads(raw)
        amount = float(payload.get("amount", 0))
    except (ValueError, TypeError):
        log("WARN", requestId=request_id, route=route, message="Bad request body")
        return response(400, {"error": "body must be JSON with a numeric amount"})

    order = {
        "orderId": str(uuid.uuid4()),
        "amount": amount,
        "customerEmail": payload.get("customerEmail", "test.user@example.com"),
        "poison": bool(payload.get("poison", False)),
        "createdAt": int(time.time()),
    }

    TABLE.put_item(Item={**order, "amount": Decimal(str(amount))})
    SQS.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(order))

    log("INFO", event="order_placed", requestId=request_id, route=route,
        orderId=order["orderId"], amount=amount,
        customerEmail=order["customerEmail"],  # masked by the data protection policy
        latencyMs=round((time.time() - started) * 1000))
    emf(amount)

    return response(200, {"orderId": order["orderId"]})
