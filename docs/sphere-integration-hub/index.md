---
title: "Sphere Integration Hub"
description: "Sphere Integration Hub is a deterministic workflow engine for API integration, contract validation, automation, and reproducible execution evidence."
image: assets/images/sphere-integration-hub/SIH.png
author: José Manuel Rodríguez Pineda
author_id: jmpineda
published: 2026-05-28
hide:
  - toc
---

# Sphere Integration Hub

Sphere Integration Hub is a deterministic workflow engine for API integration, testing, automation, and operational diagnostics.

Compatibility: Sphere Integration Hub `v1.7.20.278`.

![Sphere Integration Hub deterministic workflow engine](../assets/images/sphere-integration-hub/SIH.png)

## The Problem

Most integration work fails in the space between isolated API calls and real system behavior.

Teams can call an endpoint from Postman. They can write a script. They can seed a database. They can inspect logs after production breaks.

The hard part is different:

- recreate a multi-API scenario without manual setup
- validate contracts before execution
- carry context across steps without copy and paste
- keep execution evidence that another person can inspect later
- run the same workflow in CI, support, local debugging, or a controlled environment

That is the gap SIH targets.

## What SIH Is

Sphere Integration Hub models API behavior as repository-owned workflows.

An SIH workflow defines how a scenario is built, validated, executed, and reported. The workflow can call APIs, reuse response values, branch, run steps in parallel, generate input data, execute nested workflows, validate OpenAPI contracts, and write a report that explains what happened.

The result is a repeatable engineering artifact instead of a private manual routine.

```text
workflow
  -> catalog
  -> environment variables
  -> dry-run validation
  -> execution
  -> report evidence
```

## What It Is For

Use SIH when the work depends on a sequence of API interactions that must be repeatable.

Common cases include:

- production debugging across several services
- API contract validation before a workflow runs
- CI checks that need execution evidence
- test data generation through real APIs
- setup flows for issues, QA scenarios, or demos
- DNS and infrastructure automation through provider APIs
- model or provider evaluation as a reproducible workflow
- concurrency probes where the spike evidence must survive the run

The common thread is not the domain. It is the need to make behavior reproducible.

## What It Is Not

SIH is not an interactive API client.

It does not try to replace Postman, Bruno, Apidog, curl, or a load testing platform for exploratory work. Those tools are useful when a developer is investigating a request by hand.

SIH starts where manual interaction becomes too fragile:

- the sequence has business meaning
- the workflow should live in Git
- validation should run before execution
- evidence should be kept after execution
- another team member should be able to reproduce the same path

## Core Capabilities

### Deterministic Workflows

Workflows describe the steps, inputs, outputs, conditions, loops, and context propagation required to run a scenario.

This makes a multi-step behavior reviewable in a pull request.

### Contract-Aware Execution

The API catalog points SIH to the expected OpenAPI contracts.

`--dry-run` lets teams catch mismatches before a workflow calls live endpoints.

### Execution Evidence

SIH writes JSON and HTML reports that keep stage status, timings, inputs, outputs, provider responses, and failure context.

That turns a run into an artifact that can be attached to a PR, incident, release, or support case.

### Mocked and Controlled Runs

Workflows can be validated against mocked services when a real provider is not available, too expensive, too unstable, or too risky for repeated checks.

### API-First State Creation

Instead of injecting database state directly, SIH can create the scenario through the same APIs the system exposes.

That keeps validation, domain logic, side effects, and integration behavior inside the path being tested.

## Read Next

Start with the article that matches the problem in front of you.

- [Postman Collections Rot When API Teams Scale](postman-collections-rot-when-api-teams-scale.md) for contract drift, stale collections, and API review evidence.
- [Simulate concurrent users and catch latency spikes with a deterministic workflow](simulate-concurrent-users-and-catch-latency-spikes.md) for repeatable concurrency probes and timing evidence.
- [Switching Issues Should Not Mean Rebuilding Test Context](switching-issues-should-not-mean-rebuilding-test-context.md) for issue setup across APIs, SQL, scripts, and browser steps.
- [SphereIntegrationHub: A Deterministic API Workflow Engine](deterministic-api-workflow-engine.md) for the initial architecture overview.
- [The 3 AM Production Debugging Nightmare](3-am-production-debugging-nightmare.md) for execution evidence during incident analysis.

## Source

The implementation is public:

- [Sphere Integration Hub on GitHub](https://github.com/PinedaTec-EU/SphereIntegrationHub){ target="_blank" rel="noopener" }
- [npm package](https://www.npmjs.com/package/@pinedatec.eu/sphere-integration-hub){ target="_blank" rel="noopener" }
- [NuGet package](https://www.nuget.org/packages/SphereIntegrationHub.Tool){ target="_blank" rel="noopener" }
