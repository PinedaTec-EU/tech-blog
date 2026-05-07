---
title: SphereIntegrationHub: A Deterministic API Workflow Engine
description: How Sphere Integration Hub defines and executes API workflows deterministically.
image: assets/images/sphere-integration-hub/SIH.png
---

# SphereIntegrationHub: A Deterministic API Workflow Engine

A way to define and execute API workflows deterministically.

Compatibility: Sphere Integration Hub `v1.7.20.278`, commit `c99028ab931c2b213573377382dc7855715af3ec`.

## The Real Problem: Lack of Deterministic Execution

Most teams do not struggle with calling APIs.

They struggle with:

- environments that cannot be reliably recreated
- workflows that behave differently across dev, staging and production
- implicit logic hidden in scripts or manual steps
- validation happening too late

This is not a testing problem.

It is a  **determinism problem**.

## The Daily Pain (What Actually Happens)

### Scenario 1: The Production 400

You deploy an endpoint. Everything passed locally and in Postman.

Production fails.

Why?

Because:

- your test input!= real consumer input
- your API contract!= what you actually validated

The mismatch is discovered at runtime.

### Scenario 2: DB Snapshot Hell

You seed staging from a snapshot.

Tests pass.

But:

- validation logic never runs
- domain events never fire
- integrations are never triggered

You are not testing the system. You are testing a static dataset.

### Scenario 3: Manual Workflow Testing

You test a flow manually:

- login
- copy JWT
- create entity
- copy ID
- reuse it

This is:

- manual
- error-prone
- non-reproducible

And impossible to scale in CI.

## Why Current Approaches Break Down

Typical tools focus on interaction, not execution.

- Postman / Bruno -> interactive exploration
- DB snapshots -> state injection
- scripts -> implicit logic

What is missing:

> A way to define and execute API workflows deterministically.

## What SphereIntegrationHub Is

SphereIntegrationHub (SIH) is a  **deterministic API workflow engine**.

It enables teams to define, execute, and reproduce API-driven workflows with predictable behavior.

It is designed to:

- execute workflows deterministically
- validate against contracts before execution
- propagate context automatically
- bootstrap environments via APIs
- generate reproducible artifacts

## What It Is Not

- Not Postman, Bruno, Apidog -> no interactive exploration focus
- Not a request collection runner -> workflows contain logic
- Not a load testing tool
- Not a distributed orchestration engine

SIH focuses on  **execution, not interaction**.

## How SIH Solves These Problems

### 1. Contract Validation Before Execution

Instead of discovering issues at runtime:

```bash
sih --workflow create-order.workflow --env dev --dry-run
```

You validate against OpenAPI before execution.

Result:

- mismatches caught early
- faster feedback loop

### 2. API-First State Creation

Instead of DB snapshots:
```yaml
    forEach: "{{input.userCount}}"
parallel: true
body: |
  {
    "id": "{{rand:guid()}}",
    "email": "user_{{rand:text(8)}}@test.com"
  }
ensure:
  mode: "CreateIfMissing"
```

Now:

- validation runs
- domain logic executes
- events fire

### 3. Deterministic Workflow Execution

Instead of manual steps:
```yaml
    - name: login
  output:
    jwt: "{{response.body.token}}"

- name: create-order
  headers:
    Authorization: "Bearer {{context.jwt}}"
```

No copy/paste.
No scripts.

### 4. Execution Model

SIH supports:

- conditional logic (`runIf`)
- flow control (`jumpTo`)
- idempotency (`ensure`)
- parallel execution
- workflow composition
- data generation

This enables modeling real flows, not just requests.

## What You Gain

### Before

- runtime failures
- manual workflows
- brittle scripts
- non-reproducible tests

### After

- deterministic execution
- reproducible environments
- contract-safe workflows
- CI-ready execution

## Deterministic Workflow Tracing (Visual Execution)

SIH does not just execute workflows. It produces a  **deterministic, visual trace of their execution**.

Each run generates:

- a structured JSON trace
- an HTML visual trace
- a deterministic output state

Unlike traditional logs, this is a  **full, inspectable execution graph** of the workflow.

### What You Can See

The HTML trace provides:

- stage-by-stage timeline (Gantt-like view)
- execution order and parallelism
- duration per stage
- branching decisions (executed vs not executed)
- request/response details per stage
- inputs and outputs
- HTTP status codes
- final workflow result

This is conceptually similar to distributed tracing systems like Jaeger, but with a key difference:

- Jaeger observes what happened (passive, requires instrumentation)
- SIH defines and executes what happens (active, deterministic)

### Why This Matters

Typical debugging relies on:

- ephemeral console logs
- distributed traces that require instrumentation
- manual correlation across services
- re-running scenarios to understand behavior

SIH replaces that with a  **single, self-contained execution trace**.

### What You Gain

With a single trace, you can inspect:

- which stages executed and which were skipped
- which branch was taken
- what data entered each stage
- what data was produced
- how long each step took
- where failures occurred

This makes the trace useful for:

- debugging without re-execution
- CI/CD artifacts
- sharing execution evidence with teammates
- documenting integration behavior
- reasoning about execution paths

### Example Output Files

```text
customer-order.a3f2b5c8.workflow.output
customer-order.a3f2b5c8.workflow.trace.json
customer-order.a3f2b5c8.workflow.trace.html
```

### Example JSON Structure

```json
{
  "workflowName": "customer-order",
  "executionId": "a3f2b5c8",
  "startTime": "2026-04-20T10:30:00Z",
  "duration": "00:00:01.245",
  "stages": [
    {
      "name": "login",
      "status": "Ok",
      "duration": "00:00:00.120",
      "httpStatus": 200,
      "output": {
        "jwt": "eyJhbGc..."
      }
    },
    {
      "name": "create-order",
      "status": "Failed",
      "duration": "00:00:00.110",
      "httpStatus": 400,
      "error": "Expected status 201, got 400"
    }
  ]
}
```

### Visual Trace Example

![Deterministic workflow trace](../assets/images/sphere-integration-hub/deterministic-workflow-trace.png)

_-- Deterministic workflow trace showing execution timeline, branching, parallel stages, and per-stage input/output inspection. --_

This is one of the most differentiating aspects of SIH: it makes workflow behavior  **visible, reproducible, and explainable** without relying on external tracing systems.

This is not a log. It is a deterministic execution trace.

## MCP Integration

SIH exposes workflows via MCP.

Instead of exposing raw APIs to AI:

You expose  **controlled execution units**.

This enables:

- safer automation
- predictable agent behavior
- reproducible results

## CI/CD Native

SIH runs directly in pipelines.

```yaml
- name: Run workflows
  run: |
    sih --workflow workflows/smoke-test.workflow \
        --env staging \
        --report-format both
```

No adapters. No transformation.

### GitHub Action

SIH also provides a  **GitHub Action** for direct integration.

```yaml
- name: Run SIH workflow
  uses: PinedaTec-EU/sphere-integration-hub-action@v1
  with:
    workflow: workflows/smoke-test.workflow
    env: staging
  env:
    ADMIN_PASSWORD: ${{ secrets.ADMIN_PASSWORD }}
```

This allows:

- native execution inside GitHub workflows
- reuse across repositories
- simplified pipeline configuration
- standardized execution patterns

Reports can be uploaded as artifacts for later inspection.

## What SIH Requires to Work Well

SIH can provide deterministic execution, but only if the systems it interacts with expose enough determinism themselves.

In practice, SIH works best when APIs are:

- reasonably idempotent for creation and update flows
- explicit about success and failure through correct HTTP status codes
- contract-driven and kept aligned with OpenAPI definitions
- consistent in response structures
- stable enough to support repeatable execution paths

This matters because SIH does not invent determinism out of thin air.
It makes deterministic execution possible  **when the underlying APIs make that achievable**.

### Examples

If an API:

- returns `200`, `201`, `409`, `404` consistently
- exposes clear lookup endpoints
- distinguishes between "already exists" and "created"
- provides stable identifiers in responses

then SIH can model reusable and idempotent workflows very effectively.

If an API instead:

- always returns `200` for everything
- hides failures in response bodies
- has unstable contracts
- does not expose lookup or recovery paths
- produces side effects without clear response semantics

then workflow determinism becomes harder to guarantee.

### Important Distinction

SIH can enforce workflow logic, branching, validation, and traceability.

But its ability to provide reliable idempotency and predictable execution depends on the quality of the API surface behind it.

That is not a limitation of SIH alone. It is a property of any system that aims to orchestrate real APIs deterministically.

## Where It Fits

SIH is most useful when:

- APIs are the integration backbone
- environments must be reproducible
- workflows span multiple services
- CI/CD requires deterministic execution
- APIs are designed with clear contracts and predictable semantics

## Where It Does Not Fit

- exploratory testing
- load testing
- distributed orchestration

## Status: Active Development

SIH is under continuous improvement.

The model is stable.
The engine is evolving.

Focus remains on:

- simplicity
- determinism
- real-world applicability

## End-to-End Example: From Login to Confirmed Order

A single workflow can model a real user journey across services, with deterministic execution and no manual steps.

In this example:

- the main workflow performs authentication and order creation
- customer provisioning is delegated to a child workflow
- the child workflow checks whether the customer already exists
- `runIf` and `jumpTo` control the execution path

### Main Workflow

```yaml
version: "3.11"
name: "e2e-order-flow"

input:
  - name: "customerName"
    type: "Text"
    required: true
  - name: "customerEmail"
    type: "Text"
    required: true

references:
  workflows:
    - name: "ensure-customer"
      path: "./workflows/ensure-customer.workflow"

stages:
  - name: "login"
    kind: "Endpoint"
    endpoint: "/api/auth/login"
    httpVerb: "POST"
    body: |
      {
        "username": "admin",
        "password": "{{env:ADMIN_PASSWORD}}"
      }
    output:
      jwt: "{{response.body.token}}"

  - name: "ensure-customer"
    kind: "Workflow"
    workflowRef: "ensure-customer"
    inputs:
      customerName: "{{input.customerName}}"
      customerEmail: "{{input.customerEmail}}"
      jwt: "{{stage:login.output.jwt}}"

  - name: "create-order"
    kind: "Endpoint"
    endpoint: "/api/orders"
    httpVerb: "POST"
    headers:
      Authorization: "Bearer {{stage:login.output.jwt}}"
    body: |
      {
        "customer_id": "{{stage:ensure-customer.workflow.output.customerId}}",
        "items": [
          { "product_id": "prod-1", "quantity": 2 }
        ]
      }
    output:
      orderId: "{{response.body.id}}"

  - name: "confirm-order"
    kind: "Endpoint"
    endpoint: "/api/orders/{{stage:create-order.output.orderId}}/confirm"
    httpVerb: "POST"
    headers:
      Authorization: "Bearer {{stage:login.output.jwt}}"

endStage:
  output:
    customerId: "{{stage:ensure-customer.workflow.output.customerId}}"
    orderId: "{{stage:create-order.output.orderId}}"
```

### Child Workflow: Ensure Customer Exists

```yaml
version: "3.11"
name: "ensure-customer"

input:
  - name: "customerName"
    type: "Text"
    required: true
  - name: "customerEmail"
    type: "Text"
    required: true
  - name: "jwt"
    type: "Text"
    required: true

stages:
  - name: "find-customer"
    kind: "Endpoint"
    endpoint: "/api/customers/by-email/{{input.customerEmail}}"
    httpVerb: "GET"
    headers:
      Authorization: "Bearer {{input.jwt}}"
    expectedStatuses: [200, 404]
    output:
      exists: "{{response.status == 200}}"
      customerId: "{{response.body.id}}"

  - name: "jump-if-customer-exists"
    kind: "NoOp"
    runIf: "{{stage:find-customer.output.exists}} == true"
    jumpTo: "finish"

  - name: "create-customer"
    kind: "Endpoint"
    runIf: "{{stage:find-customer.output.exists}} == false"
    endpoint: "/api/customers"
    httpVerb: "POST"
    headers:
      Authorization: "Bearer {{input.jwt}}"
    body: |
      {
        "name": "{{input.customerName}}",
        "email": "{{input.customerEmail}}"
      }
    output:
      customerId: "{{response.body.id}}"

endStage:
  name: "finish"
  output:
    customerId: "{{stage:find-customer.output.customerId || stage:create-customer.output.customerId}}"
```

Run it:

```bash
sih --workflow e2e-order-flow.workflow \
  --env staging \
  --input customerName="John Doe" \
  --input customerEmail="john.doe@example.com" \
  --report-format both
```

What this demonstrates:

- workflow composition through nested workflows
- conditional branching with `runIf`
- flow control with `jumpTo`
- deterministic output regardless of whether the customer already existed
- reusable customer provisioning logic across multiple parent workflows

The same workflow can run in dev, staging, or production by switching the environment.

No scripts. No manual steps. No hidden logic.

## Final Thought

Most teams do not need more tools.

They need  **predictability**.

SphereIntegrationHub provides that by turning API interactions into:

- declarative
- executable
- reproducible workflows

That is the shift
