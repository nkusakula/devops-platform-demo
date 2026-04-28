# DevOps Platform – Tool Owner Perspective Demo

> **Demo Duration:** 30 minutes  
> **Audience:** DevOps Platform / Tool Owners  
> **Platform:** GitHub (GitHub Actions, GitHub Packages, GitHub Advanced Security, GitHub Environments)

## What This Demo Covers

This repository is the authoritative reference for the **Demo View 2 – DevOps Platform / Tool Owner Perspective** walkthrough.  
It demonstrates how a centrally governed, cross-region DevOps platform operates end-to-end — from a tool owner's daily operational view to a simulated regional disaster recovery event.

## Repository Structure

```
.
├── .github/
│   ├── workflows/
│   │   ├── ci-amd64.yml              # Build & test on amd64 runners
│   │   ├── ci-arm64.yml              # Build & test on arm64 runners
│   │   ├── policy-gate.yml           # Policy-as-code enforcement gate
│   │   ├── artifact-promote.yml      # Signed artifact promotion workflow
│   │   ├── runner-patch.yml          # Scheduled runner patching
│   │   ├── emergency-response.yml    # Event-driven emergency workflow
│   │   └── dr-failover.yml           # Regional DR / failover workflow
│   └── CODEOWNERS
├── runners/
│   ├── runner-group-config.yml       # Runner group scoping & isolation
│   └── arc-values.yml                # Actions Runner Controller Helm values
├── policies/
│   ├── branch-protection.json        # Branch protection policy
│   ├── sbom-signing.yml              # SBOM & artifact signing policy
│   └── opa/
│       └── release-gate.rego         # OPA policy for release promotion
├── monitoring/
│   └── alert-rules.yml               # Alerting rules (PagerDuty / Slack)
├── infra/
│   ├── control-plane.md              # Cross-region control plane architecture
│   └── region-matrix.yml             # Region to runner pool mapping
├── secrets/
│   └── secret-injection-guide.md     # Centralized dynamic secret injection
├── itsm/
│   └── change-governance.md          # ITSM / change governance integration
└── DEMO-SCRIPT.md                    # 30-minute step-by-step demo script
```

## Quick Links

| Topic | File |
|---|---|
| **Demo Script** | [DEMO-SCRIPT.md](DEMO-SCRIPT.md) |
| **CI/CD Pipelines** | [.github/workflows/](.github/workflows/) |
| **Runner Configuration** | [runners/](runners/) |
| **Policy-as-Code** | [policies/](policies/) |
| **DR Failover Workflow** | [.github/workflows/dr-failover.yml](.github/workflows/dr-failover.yml) |
| **Control Plane Architecture** | [infra/control-plane.md](infra/control-plane.md) |

## Pre-Demo Setup Checklist

- [ ] GitHub Enterprise Cloud org with Actions enabled
- [ ] Two runner groups configured: `prod-runners-us-east` and `prod-runners-eu-west` (each with amd64 + arm64 pools)
- [ ] Actions Runner Controller (ARC) deployed to both regions
- [ ] GitHub Packages (GHCR) enabled with Cosign artifact signing
- [ ] GitHub Advanced Security (GHAS) enabled — Code Scanning, Secret Scanning, Dependabot
- [ ] Required environment protection rules set on `production` environment
- [ ] ITSM webhook configured (ServiceNow or Jira Service Management)
- [ ] Grafana DORA dashboard loaded
- [ ] PagerDuty / Slack integration active
- [ ] DR failover workflow secrets pre-populated in GitHub Secrets
