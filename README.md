# Tech Blog

Technical articles about deterministic API workflows, execution evidence, integration automation, and AI-assisted engineering under operational control.

Site: [tech-blog.pinedatec.eu](https://tech-blog.pinedatec.eu/)

## Start Here

If you are arriving from GitHub and want the strongest entry points first:

- [The 3 AM Production Debugging Nightmare](https://tech-blog.pinedatec.eu/sphere-integration-hub/3-am-production-debugging-nightmare/) explains the production debugging pain behind Sphere Integration Hub.
- [SphereIntegrationHub: A Deterministic API Workflow Engine](https://tech-blog.pinedatec.eu/sphere-integration-hub/deterministic-api-workflow-engine/) gives the product and architecture overview.
- [Sphere Integration Hub repository](https://github.com/PinedaTec-EU/SphereIntegrationHub) contains the CLI, samples, MCP server, and workflow runtime.

## Main Series

### Sphere Integration Hub

Focused on reproducible multi-API workflows, contract validation before execution, CI/CD automation, and portable execution evidence.

### SpecForge.AI

Focused on spec-driven development, AI-assisted delivery governance, traceability, and reviewable evidence.

## Why This Repository Exists

The public site replaced earlier article publishing on third-party platforms. The goal is to keep the canonical version of the articles in Git, publish them through GitHub Pages, and keep editorial control over structure, assets, and updates.

## Local Development

Run the local preview:

```sh
python3 -m mkdocs serve
```

Build the static site:

```sh
python3 -m mkdocs build
```

## Content Conventions

Public articles are written in English, including titles, descriptions, navigation labels, article cards, and social preview metadata.

## Deployment

The site is published to GitHub Pages through GitHub Actions via `.github/workflows/deploy-pages.yml`.

Pushes to `main` trigger deployment automatically.
