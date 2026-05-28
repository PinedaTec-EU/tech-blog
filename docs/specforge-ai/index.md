---
title: "SpecForge.AI"
description: "SpecForge.AI is a governed spec-driven development system for turning product intent into controlled, reviewable, AI-assisted engineering work."
image: assets/images/specforge-ai/sdd-seven-layers.png
author: José Manuel Rodríguez Pineda
author_id: jmpineda
published: 2026-05-28
hide:
  - toc
---

# SpecForge.AI

SpecForge.AI is a governed spec-driven development system for AI-assisted software delivery.

It turns product intent into explicit phases, persisted artifacts, human checkpoints, review evidence, and a repository-owned source of truth.

![The seven layers of Spec-Driven Development](../assets/images/specforge-ai/sdd-seven-layers.png)

## The Problem

AI coding agents are fast enough to expose weak delivery systems.

A developer can ask an agent to implement a feature from a short ticket. The agent can produce code quickly. Tests may pass. The pull request may look reasonable.

The risk is what disappears between the request and the diff:

- what was actually approved
- which ambiguity was resolved
- which assumption came from the model
- which files and constraints shaped the implementation
- why the design moved forward
- why the workflow moved backwards
- what evidence supports the final review

When that record lives only in chat, the team has speed without durable control.

## What SpecForge.AI Is

SpecForge.AI gives AI-assisted delivery a controlled workflow.

It separates the work into explicit phases so teams can clarify intent, shape the specification, approve design, implement against the approved plan, review evidence, and decide whether the story can move forward.

The important artifacts stay close to the repository:

```text
request
  -> specification
  -> technical design
  -> implementation record
  -> review evidence
  -> release decision
```

The goal is not to slow agents down. The goal is to make their work usable by a team after the original chat has disappeared.

## What It Is For

Use SpecForge.AI when AI-assisted development needs more than code generation.

It is designed for teams that need:

- requirements that survive beyond a prompt
- explicit approval before implementation starts
- review evidence next to the code
- traceability from intent to release decision
- controlled regression when a phase needs to move backwards
- shared delivery standards across repositories
- a workflow that an MCP-capable agent can operate without making chat the source of truth

This matters most when architecture, QA, security, product, and engineering leadership need to see the reasoning around a change, not only the final diff.

## What It Is Not

SpecForge.AI is not a generic prompt library.

It is not a replacement for GitHub, an IDE, a ticket system, or a coding agent. It sits around those tools as the control layer for spec-driven work.

The boundary is important:

- the ticket can introduce the need
- the agent can help draft and implement
- the repository keeps the durable artifacts
- the workflow decides when a phase can advance, regress, or wait for a human decision

## Core Capabilities

### Phase-Based Delivery

Work moves through explicit phases instead of one long chat.

Each phase has a purpose, an expected output, and a decision point.

### Repository-Owned Artifacts

Specifications, technical design, implementation notes, review evidence, and release material are persisted as files.

That makes the work inspectable, versioned, and portable across tools.

### Human Gates

The workflow can stop when a real decision is needed.

That separates model output from human approval.

### Regression as a First-Class Action

When a design is wrong, the workflow can move back to design.

When the specification is incomplete, it can move back to refinement.

The reason for that movement stays visible.

### Agent-Operated Workflow

SpecForge.AI is built for AI-assisted execution through MCP-capable agents, local tools, and a workflow portal.

The agent can help move work forward while the repository keeps the source of truth.

## Read Next

Start with the article that matches the problem in front of you.

- [AI-assisted development has a governance problem](governed-ai-assisted-development.md) for the operating gap created by fast coding agents.
- [Spec-Driven Development needs seven layers of control](seven-layers-of-spec-driven-development.md) for the control model behind governed SDD.

## Source

The implementation is public:

- [SpecForge.AI on GitHub](https://github.com/PinedaTec-EU/SpecForge.AI){ target="_blank" rel="noopener" }
