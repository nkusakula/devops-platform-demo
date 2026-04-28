# Centralized Dynamic Secret Injection

## Approach: GitHub Actions OIDC + HashiCorp Vault / Azure Key Vault

No static long-lived credentials are stored in any repository. All secrets are dynamically injected at runtime using short-lived OIDC tokens.

## Flow

```
GitHub Actions Job starts
        |
        v
Request OIDC token from GitHub
(token contains: repo, workflow, environment, ref, sha)
        |
        v
Present OIDC token to HashiCorp Vault / Azure Key Vault
(Vault validates token signature against GitHub JWKS endpoint)
        |
        v
Vault issues short-lived secret (TTL: duration of workflow job only)
        |
        v
Secret injected as environment variable into job step
        |
        v
Job completes – secret automatically expires
```

## GitHub Actions Permissions Required

```yaml
permissions:
  id-token: write   # Required to request an OIDC token
  contents: read
```

## Example Workflow Step (HashiCorp Vault)

```yaml
- name: Get secrets from Vault
  uses: hashicorp/vault-action@v3
  with:
    url: ${{ secrets.VAULT_ADDR }}
    method: jwt
    role: github-actions-${{ github.event.repository.name }}
    secrets: |
      secret/data/production/db password | DB_PASSWORD ;
      secret/data/production/api key     | API_KEY
```

## Environment Scoping

| Environment | Access Scope | Secrets Mount |
|---|---|---|
| development | All repositories (read-only) | `dev/` |
| staging | Selected repositories | `staging/` |
| production | Restricted repos + manual approval | `production/` |

## Audit

Every secret access is logged in Vault audit log with:
- GitHub repository and workflow run ID (links back to GitHub Actions)
- Commit SHA and environment
- Requesting identity and timestamp
