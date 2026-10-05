# Secrets Management

## 1. Purpose

This document defines how credentials, tokens, API keys, certificates, and other sensitive configuration are protected throughout the Salesforce AI Agent development and deployment lifecycle.

---

## 2. Secrets Must Never Be Committed

The following must never be committed to Git:

```text
.env.production
production-password.txt
azure-api-key.txt
salesforce-token.txt
```

Also never commit:

```text
API keys
Client secrets
Access tokens
Passwords
Private keys
Certificates containing private material
OAuth credentials
Connection strings
Bearer tokens
```

---

## 3. Git Ignore

The project `.gitignore` should include:

```gitignore
.env
.env.*
!.env.example

*.key
*.pem
*.p12
*.crt

secrets/
credentials/

.env.production
production-password.txt
azure-api-key.txt
salesforce-token.txt
```

---

## 4. Example Environment File

A safe template may be committed:

```text
.env.example
```

Example:

```env
SALESFORCE_CLIENT_ID=
SALESFORCE_CLIENT_SECRET=
SALESFORCE_LOGIN_URL=

AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_API_KEY=
AZURE_OPENAI_DEPLOYMENT=
```

The values must remain empty.

---

## 5. GitHub Actions Secrets

CI/CD secrets should be stored using GitHub Actions Secrets or protected GitHub Environments.

Example:

```text
SFDX_AUTH_URL
```

The workflow may reference it:

```yaml
${{ secrets.SFDX_AUTH_URL }}
```

The actual secret value must never appear in source code.

---

## 6. Salesforce Credentials

Salesforce integrations should use Salesforce security mechanisms such as:

- Named Credentials
- External Credentials
- OAuth
- JWT-based authentication where approved
- Connected Apps
- Permission Sets
- Least-privilege access

Avoid hard-coded credentials in Apex, JavaScript, LWC, or configuration files.

---

## 7. Azure Credentials

Azure credentials should be managed using approved Azure/GitHub secret-management mechanisms.

Do not place an Azure API key directly in:

```text
Apex
LWC
JavaScript
Git
README
.env.example
CI YAML
```

For production workloads, prefer managed identity or another approved identity-based authentication mechanism where supported.

---

## 8. Local Development

Developers should maintain local secrets outside Git-tracked files.

Example:

```text
.env
```

The file should remain ignored by Git.

Developers should never share secrets through:

- Email
- Slack
- Teams
- Git commits
- Screenshots
- Public documentation
- GitHub Issues

---

## 9. Secret Rotation

Secrets should be rotated according to organizational policy and immediately when:

- A secret is exposed.
- An employee or service account is compromised.
- Unauthorized access is suspected.
- A credential is accidentally committed.
- A third-party service reports a compromise.

---

## 10. Compromised Secret Procedure

If a secret is committed:

### Step 1 — Revoke

Immediately revoke or rotate the credential.

### Step 2 — Investigate

Determine:

- Where the secret was exposed.
- Whether it was pushed remotely.
- Whether it appears in Git history.
- Whether unauthorized access occurred.

### Step 3 — Remove

Remove the secret from the working tree and repository.

### Step 4 — Rewrite History if Required

If the secret exists in Git history, repository history may need to be cleaned according to the organization's security process.

### Step 5 — Replace

Create a new credential and update the appropriate secret store.

---

## 11. Least Privilege

CI/CD identities should have only the permissions required for their tasks.

For example:

```text
CI Validation
    ↓
Read / Validate permissions

Deployment Pipeline
    ↓
Deployment permissions

Production Operations
    ↓
Restricted production permissions
```

Do not use a highly privileged personal administrator account for automated deployments.

---

## 12. Production Secrets

Production secrets must be separated from:

```text
Development
QA
UAT
```

Never reuse production credentials in lower environments.

---

## 13. Secret Scanning

CI should perform automated secret scanning.

The current pipeline includes a basic source scan:

```bash
git grep -n -i \
  -e "api_key" \
  -e "apikey" \
  -e "client_secret" \
  -e "access_token" \
  -e "password" \
  -e "Bearer "
```

This is useful as a basic control but should not be considered a complete enterprise secret-detection solution.

---

## 14. Security Requirements

The following requirements apply to all environments:

- No secrets in Git.
- No production secrets in development.
- No credentials in source code.
- Use least privilege.
- Use environment-specific credentials.
- Rotate compromised credentials immediately.
- Protect production deployment secrets.
- Audit access to sensitive credentials.

---

## 15. Security Ownership

Secret management should be jointly governed by:

```text
Engineering
Security
DevOps / Platform
Salesforce Administration
Cloud / Azure Team
```

Actual ownership should follow the organization's security governance.