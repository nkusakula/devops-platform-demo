# Cross-Region Control Plane Architecture

## Overview

The DevOps platform control plane is deployed across two primary regions with active-active configuration for normal operations and automatic failover capability.

```
┌───────────────────────────────────────────────────────────────┐
│              GitHub Enterprise Cloud (Global)              │
│                                                             │
│  Org-level Policies & Rulesets                             │
│  GitHub Actions (workflow orchestration + runner routing)  │
│  GHAS (code scanning, secret scanning, Dependabot)        │
│  GitHub Packages / GHCR (geo-replicated OCI registry)     │
└───────────────────────────────────────────────────────────────┘
            |                              |
            v                              v
┌────────────────────┐          ┌────────────────────┐
│   US-East Region     │          │   EU-West Region     │
│ ───────────────── │          │ ───────────────── │
│ ARC (amd64 pool)     │          │ ARC (amd64 pool)     │
│ ARC (arm64 pool)     │          │ ARC (arm64 pool)     │
│ Local cache store    │          │ Local cache store    │
│ Vault Agent          │          │ Vault Agent          │
│ ITSM Webhook Fwd     │          │ ITSM Webhook Fwd     │
│ Grafana Agent        │          │ Grafana Agent        │
└────────────────────┘          └────────────────────┘
```

## Component Responsibilities

| Component | Responsibility |
|---|---|
| GitHub Enterprise Cloud | Policy enforcement, workflow orchestration, identity |
| Actions Runner Controller (ARC) | Elastic runner pool lifecycle per region |
| GitHub Packages (GHCR) | Geo-replicated OCI artifact and dependency cache |
| HashiCorp Vault / Azure Key Vault | Dynamic secret injection via OIDC |
| Grafana Agent | DORA metrics collection and forwarding |
| ITSM Webhook Forwarder | Change record automation (ServiceNow / Jira SM) |

## Failover Design

- **Normal operation:** Traffic split across both regions based on runner group assignment.
- **Region degradation:** Automated health probes detect runner group unavailability within 3 minutes.
- **DR activation:** `dr-failover.yml` workflow reroutes all pipeline dispatches to the healthy region.
- **Recovery:** Once the failing region recovers, runner groups are rebalanced via the same workflow with `action: restore`.

## RTO / RPO Targets

| Metric | Target |
|---|---|
| Pipeline reroute time (RTO) | < 5 minutes |
| Artifact replication lag (RPO) | < 5 minutes |
| DORA data continuity | Continuous (no gap) |
| Audit trail completeness | 100% |
