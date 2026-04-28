# ITSM & Change Governance Integration

## Overview

Every deployment workflow automatically creates, updates, and closes change records in the ITSM system (ServiceNow or Jira Service Management), eliminating manual ticket creation while maintaining full audit compliance.

## Change Record Lifecycle

```
Deployment workflow triggered
        |
        v
[auto] ITSM Change Request OPENED
  - Type: Standard or Emergency
  - Linked to: GitHub workflow run URL
  - Assigned to: Platform team / On-call
        |
        v
Deployment executes (GitHub Actions)
  - Build logs captured
  - Test results attached
  - Artifact signature verified
        |
        v
[auto] ITSM CR UPDATED with deployment evidence
  - Deployment log URL
  - Container image digest
  - SBOM reference
  - Policy gate pass evidence (OPA output)
        |
        v
Deployment completes
        |
        v
[auto] ITSM CR CLOSED
  - Status: Successful / Failed / Rolled Back
  - Duration and approvals recorded
```

## Change Types

| Type | Approval Path | Gate Requirements |
|---|---|---|
| Standard | 2 CODEOWNERS approvals + required checks | Policy gate, signature verification, staging deploy |
| Emergency | On-call lead + platform owner | Expedited – 1 approval, enhanced audit logging |
| Automated | No manual approval (pre-approved model) | All automated checks must pass |

## Compliance Evidence Package

For each deployment, the following evidence is automatically collected and attached to the change record:

1. **Source control evidence:** commit SHA, branch, PR number, approvals
2. **Build evidence:** workflow run log, test results, coverage report
3. **Security evidence:** SBOM, Trivy scan results, OPA policy gate output
4. **Artifact evidence:** container image digest, Cosign signature, Rekor log entry
5. **Deployment evidence:** environment, timestamp, deployer identity, rollback plan
