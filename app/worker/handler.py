"""orders-worker: async path, consumes the SQS queue in batches.

Event source mapping must set function_response_types = ["ReportBatchItemFailures"],
so only failed messages are retried. After maxReceiveCount (3) they go to the DLQ.

A message whose order has "poison": true always fails -> lands in the DLQ.
"""
import json
import os
import time

SERVICE = os.environ.get("SERVICE_NAME", "orders")


def log(level, **fields):
    print(json.dumps({"level": level, "service": SERVICE, **fields}, default=str))


def process(order):
    if order.get("poison"):
        raise ValueError("poison")
    # Stand-in for real work (send email, charge card, ...)
    time.sleep(0.05)


def handler(event, context):
    failures = []
    for record in event.get("Records", []):
        message_id = record["messageId"]
        receive_count = int(record["attributes"].get("ApproximateReceiveCount", "1"))
        try:
            order = json.loads(record["body"])
            process(order)
            log("INFO", event="order_processed", messageId=message_id,
                orderId=order.get("orderId"), receiveCount=receive_count)
        except Exception as exc:  # noqa: BLE001 - report every failure back to SQS
            log("ERROR", event="order_failed", messageId=message_id,
                reason=str(exc), receiveCount=receive_count,
                message=f"Failed to process message: {exc}")
            failures.append({"itemIdentifier": message_id})

    return {"batchItemFailures": failures}
