# Demo Script – DevOps Platform / Tool Owner Perspective

**Duration:** 30 minutes  
**Platform:** GitHub (GitHub Actions · GitHub Packages · GHAS · GitHub Environments · ARC)  
**Presenter Role:** You are the DevOps Platform / Tool Owner  

---

## Segment Overview

| # | Segment | Time |
|---|---|---|
| 1 | Platform Dashboard & Morning Health Check | 3 min |
| 2 | Cross-Region Runner Pool Management (amd64 / arm64) | 4 min |
| 3 | Policy-Driven CI/CD Execution | 4 min |
| 4 | Artifact Signing & Controlled Promotion | 4 min |
| 5 | Secrets & Environment Configuration | 3 min |
| 6 | ITSM & Change Governance Integration | 3 min |
| 7 | DORA Metrics & Enterprise Delivery Visibility | 4 min |
| 8 | Scheduled Runner Patching & Image Hardening | 2 min |
| 9 | Disaster Recovery – Regional Failover Live Demo | 3 min |

**Total: 30 minutes**

---

## Segment 1 — Platform Dashboard & Morning Health Check (3 min)

### What You're Showing
A tool owner begins the day by reviewing the centrally governed DevOps platform health.

### Talking Points
- *"As a DevOps platform owner, the first thing I do every morning is open our platform observability dashboard."*
- The dashboard aggregates signal from **all repositories, pipelines, and environments** across both US-East and EU-West regions.
- Every component — runner pools, artifact registries, secret stores, ITSM connectors — shows a real-time health status.

### Demo Steps
1. Open **GitHub Actions** tab → show the organization-level **Actions usage metrics** page.
2. Open the **Grafana / GitHub Insights** DORA dashboard — point out the four DORA KPIs prominently displayed.
3. Navigate to **GitHub Enterprise Cloud → Admin → Actions → Runner groups** — show two groups: `prod-runners-us-east` and `prod-runners-eu-west`, both green.
4. Point out that all checks are in a normal state. *"Nothing is on fire — let's walk through how we keep it that way."*

---

## Segment 2 — Cross-Region Runner Pool Management (4 min)

### What You're Showing
Provisioning and managing region-distributed, architecture-specific runner pools with secure scoping and isolation.

### Talking Points
- The platform runs **Actions Runner Controller (ARC)** on Kubernetes clusters in two regions, providing elastic, self-healing runner pools.
- Runner groups enforce **repository-level scoping** — only authorized repositories can dispatch jobs to production runner pools.
- Separate pools for `amd64` and `arm64` allow multi-architecture builds without cross-contamination.
- Runners are **ephemeral** — each job gets a fresh, hardened runner image; nothing persists between runs.

### Demo Steps
1. Open [`runners/runner-group-config.yml`](runners/runner-group-config.yml) — walk through the `visibility` and `selected_repositories` fields.
2. Navigate to **GitHub → Org Settings → Actions → Runner Groups** → show `prod-runners-us-east` restricted to the `platform` and `release` teams.
3. Open [`runners/arc-values.yml`](runners/arc-values.yml) — show `runnerScaleSetName`, `minRunners`, `maxRunners`, and `nodeSelector: kubernetes.io/arch: arm64`.
4. Trigger a short `ci-arm64.yml` run to show a job picking up an arm64 runner live.
5. *"If we need to add capacity, we change `maxRunners` here — Helm rolls it out within seconds. No tickets, no manual VM provisioning."*

---

## Segment 3 — Policy-Driven CI/CD Execution (4 min)

### What You're Showing
Every pipeline run is governed by policy-as-code controls that enforce security, quality, and release gates automatically.

### Talking Points
- **Branch protection** rules enforce that no code reaches `main` without required status checks, CODEOWNERS approval, and signed commits.
- The **policy gate workflow** (`policy-gate.yml`) runs OPA policies on every pull request to evaluate release readiness before a human reviews.
- Policies cover: image hardening standards, dependency vulnerability thresholds, SBOM completeness, and environment-specific deployment rules.

### Demo Steps
1. Open [`policies/branch-protection.json`](policies/branch-protection.json) — show `required_status_checks`, `required_pull_request_reviews`, and `require_signed_commits: true`.
2. Open [`.github/workflows/policy-gate.yml`](.github/workflows/policy-gate.yml) — walk through the OPA evaluation step.
3. Open [`policies/opa/release-gate.rego`](policies/opa/release-gate.rego) — show deny rules for: unapproved base images, CVSS score above threshold, missing SBOM.
4. Show a **pull request** where the policy gate blocked a merge due to a critical CVE. *"The developer sees exactly why it was blocked and what to fix."*
5. Open [`.github/CODEOWNERS`](.github/CODEOWNERS) — show platform team ownership of pipeline and policy files.

---

## Segment 4 — Artifact Signing & Controlled Promotion (4 min)

### What You're Showing
Artifacts are signed at build time and can only be promoted through controlled gates with cryptographic verification.

### Talking Points
- Every container image is signed using **Sigstore/Cosign** at build time, producing an attestation stored in GitHub Packages (GHCR).
- Promotion from `staging` to `production` requires: policy gate pass + manual approval from the `release` team + **signature verification**.
- This creates a complete, immutable chain of custody from source commit to production deployment.

### Demo Steps
1. Open [`.github/workflows/artifact-promote.yml`](.github/workflows/artifact-promote.yml) — walk through the three stages: `verify-signature` → `promote`.
2. Show the `cosign sign` step in `ci-amd64.yml` and the `cosign verify` step in `artifact-promote.yml`.
3. Navigate to **GitHub Packages** — show the container image with SBOM + provenance attestation attached.
4. Open the `production` **Environment** settings — show the required reviewer approval gate.
5. *"Every artifact we deploy to production has a verified, auditable lineage back to the exact commit and workflow run that built it."*

---

## Segment 5 — Secrets & Environment Configuration (3 min)

### What You're Showing
Centralized dynamic secret injection via GitHub Actions OIDC and environment-scoped configuration.

### Talking Points
- No static long-lived credentials in any repository — secrets are **dynamically injected** at runtime using GitHub Actions OIDC tokens exchanged with HashiCorp Vault or Azure Key Vault.
- Environment-specific configuration is managed through GitHub **Environment variables and secrets** with strict scoping.
- **GHAS Secret Scanning** with push protection blocks any accidental credential commit before it reaches the server.

### Demo Steps
1. Open [`secrets/secret-injection-guide.md`](secrets/secret-injection-guide.md) — show the OIDC token exchange flow.
2. Navigate to **GitHub → Repository Settings → Environments → production** → show environment secrets (values masked).
3. Open a workflow YAML — show `id-token: write` permission and the Vault step that exchanges the OIDC token for a short-lived secret.
4. Open **GitHub → Security → Secret Scanning** → show push protection enabled.
5. *"If a developer accidentally commits a credential, push protection blocks the push before it even hits the server."*

---

## Segment 6 — ITSM & Change Governance Integration (3 min)

### What You're Showing
Every deployment automatically creates and closes change records in the ITSM system — no manual tickets.

### Talking Points
- The platform integrates with **ServiceNow / Jira Service Management** via webhook — a change request is automatically opened when a deployment starts and closed (with evidence) when it completes.
- This eliminates manual change management overhead while ensuring every deployment is auditable.
- For emergency changes, `emergency-response.yml` follows an expedited path with reduced approval steps but enhanced audit logging.

### Demo Steps
1. Open [`itsm/change-governance.md`](itsm/change-governance.md) — show the workflow: `deployment started → ITSM CR opened → deployment completes → evidence attached → CR auto-closed`.
2. Open [`.github/workflows/artifact-promote.yml`](.github/workflows/artifact-promote.yml) — point to the `notify-itsm` steps.
3. Switch to the **ServiceNow / JSM** demo instance — show an auto-created change record linked to the GitHub workflow run URL.
4. *"Compliance teams get the audit trail they need without slowing down deployments."*

---

## Segment 7 — DORA Metrics & Enterprise Delivery Visibility (4 min)

### What You're Showing
Real-time aggregation of DORA metrics and broader delivery health signals across all repositories, pipelines, environments, and regions.

### Talking Points
- The platform continuously aggregates **Lead Time for Changes, Deployment Frequency, Change Failure Rate, and MTTR** from GitHub Actions run data and deployment events.
- Metrics are correlated **across repos, pipelines, environments, and regions** — drill from org-level trends down to a specific team or repository.
- Alongside DORA: test coverage trends, security vulnerability aging, dependency health, and operational SLO compliance.

### Demo Steps
1. Open the **Grafana DORA dashboard** — walk through all four DORA indicators:
   - **Deployment Frequency:** daily deploys across all teams
   - **Lead Time for Changes:** P50/P95 from commit to production
   - **Change Failure Rate:** % of deployments requiring rollback or hotfix
   - **MTTR:** average time from incident open to resolution
2. Drill down to a specific repository — show its individual DORA trend over 30 days.
3. Show the **security posture panel**: open CVEs by severity, SBOM coverage %, secret scanning alerts.
4. Show the **cross-region panel**: compare US-East vs. EU-West pipeline throughput and failure rates.
5. Open **GitHub → Insights → Actions** — show native GitHub Actions usage metrics.
6. *"This is the single pane of glass that tells me whether we're getting better or worse as a platform — and I can attribute every change to a specific team or pipeline."*

---

## Segment 8 — Scheduled Runner Patching & Image Hardening (2 min)

### What You're Showing
Non-disruptive, automated patching of runner pools and base images on a scheduled cadence.

### Talking Points
- The `runner-patch.yml` workflow runs on a weekly cron and performs a **rolling replacement** of runner pods — old runners complete current jobs, new runners with updated images take new jobs.
- Base images are built from a hardened, minimal foundation (distroless / UBI minimal), automatically rebuilt when upstream CVEs are patched.
- The control plane itself (ARC, ingress, secrets operator) is patched via a GitOps-driven Helm upgrade pipeline.

### Demo Steps
1. Open [`.github/workflows/runner-patch.yml`](.github/workflows/runner-patch.yml) — show the `schedule` trigger, rolling update strategy, and the wait-for-idle step.
2. Show the **GitHub Actions run history** for `runner-patch.yml` — all green, running weekly.
3. *"Patching is invisible to developers — their next job just picks up a runner with the latest patches already applied."*

---

## Segment 9 — Disaster Recovery: Regional Failover Live Demo (3 min)

### What You're Showing
The platform automatically reroutes CI/CD execution when a region fails — maintaining full delivery capability, artifact access, compliance, and observability throughout.

### Talking Points
- The `dr-failover.yml` workflow is triggered by a health probe failure event from the US-East region.
- It automatically: **reroutes** pipeline dispatch to EU-West runner groups, **verifies** artifact and cache replication, switches ITSM to the emergency change policy, and emits `DR_ACTIVE` status to all dashboards.
- Developers experience zero disruption — their pipelines queue briefly and resume on EU-West runners without any configuration change.
- Full audit, compliance evidence, and DORA data continue throughout the incident.

### Demo Steps
1. Open [`.github/workflows/dr-failover.yml`](.github/workflows/dr-failover.yml) — walk through the trigger and the four automated response steps.
2. Open [`infra/region-matrix.yml`](infra/region-matrix.yml) — show the primary/failover mapping.
3. **Simulate the failover:**
   - Navigate to **Actions → Run workflow → `dr-failover.yml`**
   - Set `target_region: us-east`, `failover_region: eu-west`, `incident_id: INC-20260428`
   - Click **Run workflow**
4. Watch the steps execute in real time:
   - `health-check` → `reroute-runners` → `verify-artifact-cache` → `notify-itsm` → `update-dashboard`
5. Open the **Grafana dashboard** — show the `DR_ACTIVE` annotation on the timeline and that DORA metrics continue flowing.
6. Show a test pipeline (`ci-amd64.yml`) dispatched — it picks up an EU-West runner automatically.
7. *"From region health failure to full reroute took under 90 seconds — and every pipeline run during the incident is fully audited and compliant."*

---

## Closing (30 seconds)

> *"What you've seen today is how GitHub serves as a complete, enterprise-grade DevOps platform control plane — not just a code host. Cross-region resilience, policy-as-code governance, signed artifact chains, dynamic secrets, automatic ITSM integration, real-time DORA metrics, and self-healing disaster recovery — all from a single platform, all auditable, all continuously enforced."*

---

## Common Questions & Answers

**Q: How do you prevent a rogue workflow from bypassing policy gates?**  
A: CODEOWNERS ensures any change to workflow files or policies requires platform team approval. Required status checks cannot be bypassed by repo admins. Organization-level ruleset policies override repo-level settings.

**Q: What happens to in-flight builds during a DR failover?**  
A: The `dr-failover.yml` workflow first waits for in-flight jobs on the failing region to complete or timeout, then reroutes. For emergency failovers, a `--force` flag cancels in-flight jobs and immediately reroutes — operators choose based on incident severity.

**Q: How is the artifact cache kept in sync across regions?**  
A: GitHub Packages (GHCR) uses geo-replication. The `verify-artifact-cache` step in the DR workflow checks replication lag and alerts if it exceeds the SLA threshold (default: 5 minutes).

**Q: How granular is DORA tracking — can we see it by team?**  
A: Yes — metrics are tagged by repository, team (via CODEOWNERS), environment, and region. The Grafana dashboard supports filtering by any dimension.

**Q: Does the ITSM integration support both ServiceNow and Jira SM?**  
A: Yes — the integration uses a generic webhook interface. A platform-hosted adapter service normalizes the payload for either system.
