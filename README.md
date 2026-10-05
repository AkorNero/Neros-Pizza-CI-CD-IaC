# Nero's Pizza — CI/CD & IaC

Production-style AWS observability built with Terraform: a serverless order API (API Gateway, Lambda, SQS, DynamoDB) instrumented with CloudWatch logs, metric filters, EMF custom metrics, alarms, dashboards and KMS-encrypted SNS alerting.

The app itself is tiny on purpose (two short Lambda handlers), so most of the work is in the layer around it. It also has two "failure knobs" (`failure_rate` and `extra_latency_ms`) that I can change from Terraform, so I can break it on purpose and watch what the monitoring picks up.

> **Status:** work in progress. The workload, logging and alerting modules are done. Alarms, dashboards, the Synthetics canary and the GitHub Actions pipeline are what I'm working on next.

## Architecture

```
                 ┌─────────────┐     ┌────────────┐     ┌──────────┐
  client ──────► │ API Gateway │ ──► │ orders-api │ ──► │ DynamoDB │
                 │  (HTTP API) │     │   Lambda   │     └──────────┘
                 └─────────────┘     └─────┬──────┘
                                           ▼
                 ┌─────────────┐     ┌────────────┐     ┌───────────────┐
                 │     DLQ     │ ◄── │ SQS queue  │ ──► │ orders-worker │
                 │ (3 retries) │     └────────────┘     │    Lambda     │
                 └─────────────┘                        └───────────────┘

  Logs + metrics from all of the above ──► CloudWatch ──► SNS (critical / warning) ──► email
```

- **Sync path:** `POST /orders` writes the order to DynamoDB and pushes it to SQS. `GET /health` just returns 200.
- **Async path:** the worker consumes the queue in batches. A message with `"poison": true` always fails, gets retried 3 times and ends up in the dead-letter queue.

## Tech

- **Terraform** (1.10+ for S3 native state locking), AWS provider `~> 5.0`
- **AWS:** API Gateway (HTTP API), Lambda, DynamoDB, SQS, CloudWatch Logs, SNS, KMS, S3 (state)
- **Python 3** for the two Lambda handlers
- **GitHub Actions** for CI/CD (planned)
- Region: `eu-west-1`

## Folder structure

```
app/
  api/handler.py          orders-api: writes the order, sends to SQS, logs JSON + EMF
  worker/handler.py       orders-worker: consumes SQS, reports partial batch failures
backend/                  S3 bucket for remote state (versioned, encrypted)
envs/
  test/                   root module that wires all the modules together
  testsns/                small root module to test the alerting module on its own
modules/
  workload/               API Gateway, Lambdas, DynamoDB, SQS + DLQ, IAM
  logging/                log groups, metric filters, saved queries, data protection
  alerting/               KMS key, SNS topics, topic policies, email subscriptions
```

The workload is kept separate from the observability modules. `workload` only exposes names and ARNs as outputs, and the other modules take those as inputs instead of reaching inside it.

## What's built so far

**Workload**
- HTTP API with two routes, access logging in JSON and detailed per-route metrics
- One IAM role per Lambda, with only the permissions each one needs
- SQS queue with a redrive policy to the DLQ and partial batch responses on the worker

**Logging**
- Three log groups owned by Terraform with 14-day retention (API Lambda, worker Lambda, API Gateway access logs)
- Metric filters in the `NerosPizza/Orders` namespace: application errors, Lambda timeouts, gateway 5xx, poison messages and order value
- Saved Logs Insights queries: top errors, slowest requests, latency percentiles per route, cold starts and memory
- Data protection policy that masks customer emails in the API logs
- Log anomaly detector on the access logs

**Custom metrics**
- `OrdersPlaced` and `OrderValue` published from the API Lambda using Embedded Metric Format, so there's no `PutMetricData` call

**Alerting**
- Two SNS topics split by severity (critical and warning), both encrypted with a customer-managed KMS key
- Key policy and topic policies that let CloudWatch alarms publish, scoped to this account
- Email subscription on each topic

## Still to do

- [ ] Alarms: static, percentile, metric math, anomaly detection, and one composite alarm that is the only thing that pages
- [ ] Synthetics canary hitting `/health` and `/orders` from the outside
- [ ] Dashboards as code: service overview, async pipeline, business metrics
- [ ] CI/CD with GitHub Actions: `fmt`, `validate` and `plan` on pull requests, `apply` on merge
- [ ] Game days: flip the failure knobs and check that the right alarms fire
- [ ] Optional: EC2 host with the CloudWatch agent for memory and disk metrics

## The process

I started with the state backend, then built the workload first so there was something real to monitor. After that I worked outwards one module at a time: logging, then alerting. I did alerting before alarms because every alarm needs a topic ARN to send to.

For each module I wrote the resources, applied them in the `test` environment, sent a few requests with `curl` and checked in the console that the logs, metrics and emails showed up as expected before moving on.

## What I learned

- **State locking doesn't need DynamoDB anymore.** `use_lockfile = true` locks with an object in the same S3 bucket. Also, the `backend` block can't use variables, and it doesn't use the provider's credentials.
- **Create the log groups yourself.** If Lambda creates them, they get infinite retention and survive `terraform destroy`.
- **Metric filters only count new log events.** They never backfill, so I have to send traffic after applying them. `default_value = "0"` is what stops graphs from having gaps.
- **Keeping the Lambda log format as `Text` matters.** A JSON line I print reaches CloudWatch untouched, which is what makes JSON filter patterns and EMF work.
- **The AWS-managed SNS key doesn't work for alarms.** CloudWatch can't be granted access to `alias/aws/sns`, so the alarm fails to publish without any obvious error. It needs a customer-managed key, and both the key policy and the topic policy have to allow CloudWatch.
- **The visibility timeout should be about 6× the worker timeout**, otherwise a message can come back while it's still being processed.
- **Partial batch responses** mean one bad message doesn't force the whole batch to be retried.
- **Dimensions are part of a metric's identity.** `OrderValue` from EMF (by `Service`) and from the metric filter (by `Route`) are two different metrics, even with the same name and namespace.

## Running the project

You need Terraform, the AWS CLI, and an AWS account you're fine experimenting in.

**1. Clone the repo and create the state bucket** (one time)

```bash
git clone https://github.com/AkorNero/Neros-Pizza-CI-CD-IaC.git
cd Neros-Pizza-CI-CD-IaC/backend
terraform init
terraform apply -var-file=creds.tfvars
```

This outputs the bucket name. Put it in the `backend "s3"` block of `envs/test/main.tf`, since the one in the repo points to my account.

**2. Add a `creds.tfvars` in `envs/test/`** (it's gitignored)

```hcl
access_key  = "..."
secret_key  = "..."
alert_email = "you@example.com"
```

**3. Deploy**

```bash
cd envs/test
terraform init
terraform apply -var-file=creds.tfvars
```

`terraform init` talks to the S3 backend with your normal AWS CLI credentials, not the keys in the tfvars file. After the apply, confirm the two SNS subscription emails or nothing will be delivered.

**4. Try it**

```bash
terraform output test_commands     # ready-made curl commands
curl -X POST <api_url>/orders -H "Content-Type: application/json" -d '{"amount": 42}'
curl -X POST <api_url>/orders -H "Content-Type: application/json" -d '{"amount": 1, "poison": true}'
```

To inject faults, change `failure_rate` (0 to 1) or `extra_latency_ms` on the `workload` module in `envs/test/main.tf` and apply again.

**5. Clean up**

```bash
terraform destroy -var-file=creds.tfvars
```

The KMS key stays in "pending deletion" for 7 days before it's actually gone.
