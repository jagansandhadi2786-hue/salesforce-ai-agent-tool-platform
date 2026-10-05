# Security Controls

## 1. Purpose

This document defines the security controls applied to the Salesforce AI Agent application throughout development, CI/CD, deployment, and production operations.

---

## 2. Security Principles

The project follows:

- Least privilege
- Defense in depth
- Secure-by-default configuration
- Zero trust principles
- Secret isolation
- Strong authentication
- Explicit authorization
- Auditability
- Continuous security validation

---

## 3. Source Code Security

Developers must not hard-code:

```text
Passwords
API keys
Access tokens
Client secrets
Private keys
Certificates with private material
Connection strings
```

---

## 4. Secret Management

Secrets must be stored outside source control.

Approved mechanisms may include:

- GitHub Actions Secrets
- GitHub Environment Secrets
- Salesforce Named Credentials
- Salesforce External Credentials
- Azure Key Vault
- Managed Identity

Environment-specific credentials must be isolated.

---

## 5. Salesforce Security

The application should enforce:

### Object-Level Security

Use:

- Permission Sets
- Permission Set Groups
- Profiles where required

### Field-Level Security

Sensitive fields must have appropriate FLS restrictions.

### Record-Level Security

Use appropriate:

- Organization-Wide Defaults
- Sharing Rules
- Role Hierarchy
- Manual Sharing
- Apex managed sharing where required

---

## 6. Apex Security

Apex should:

- Respect sharing requirements.
- Enforce CRUD/FLS.
- Validate user input.
- Avoid SOQL injection.
- Avoid dynamic SOQL where unnecessary.
- Avoid exposing sensitive data.
- Use appropriate exception handling.

---

## 7. API Security

External API integrations should use approved authentication mechanisms.

Examples:

```text
OAuth 2.0
JWT
Named Credentials
External Credentials
mTLS where required
```

Credentials should not be manually embedded in Apex.

---

## 8. AI Tool Security

Every AI tool must enforce authorization independently.

The AI model must not be trusted to enforce access control.

Recommended flow:

```text
AI Request
   ↓
Tool Selection
   ↓
Tool Contract Validation
   ↓
User Authorization
   ↓
CRUD/FLS Check
   ↓
Input Validation
   ↓
Tool Execution
   ↓
Output Validation
```

---

## 9. Prompt Injection Protection

AI functionality should account for prompt-injection attempts.

Controls may include:

- System instruction isolation
- Tool authorization
- Input validation
- Context filtering
- Retrieval filtering
- Output validation
- Sensitive-action confirmation

---

## 10. RAG Security

RAG systems must ensure users only retrieve information they are authorized to access.

Controls should address:

- Document-level permissions
- User context
- Retrieval filtering
- Sensitive data
- Prompt injection in retrieved documents
- Unsupported claims

---

## 11. Data Protection

Sensitive customer information must be protected during:

- Storage
- Processing
- Transmission
- Logging
- AI processing

Avoid placing sensitive customer data in logs unless explicitly required and appropriately protected.

---

## 12. Logging and Monitoring

Monitor:

- Authentication failures
- Authorization failures
- API failures
- AI service errors
- Tool execution failures
- RAG failures
- Deployment failures
- Unexpected application behavior

---

## 13. Dependency Security

Third-party dependencies should be reviewed regularly.

Monitor:

- npm dependencies
- Salesforce CLI plugins
- GitHub Actions
- External libraries
- AI SDKs

Use pinned or controlled versions where organizational policy requires it.

---

## 14. CI/CD Security

GitHub Actions should:

- Use minimal permissions.
- Protect production environments.
- Restrict production secrets.
- Require approval for production deployment.
- Avoid printing secrets.
- Retain security evidence.
- Prevent unauthorized workflow changes.

---

## 15. Security Testing

Security testing should include:

- Secret scanning
- Static analysis
- Apex security tests
- CRUD/FLS tests
- Sharing tests
- Authentication tests
- Authorization tests
- Negative tests
- AI tool authorization tests
- Prompt-injection tests
- RAG security tests

---

## 16. Vulnerability Severity

| Severity | Action |
|---|---|
| Critical | Block release immediately |
| High | Block production unless formally accepted |
| Medium | Remediate according to SLA |
| Low | Track and remediate |
| Informational | Review and document |

Actual severity thresholds should follow organizational security policy.

---

## 17. Security Incident

If a credential or sensitive data is exposed:

1. Stop further exposure.
2. Revoke or rotate credentials.
3. Investigate access.
4. Preserve evidence.
5. Remove the exposure.
6. Assess impact.
7. Deploy remediation.
8. Document the incident.

See:

```text
docs/devsecops/incident-response.md
```