# Salesforce Named Credentials & External Credentials

## 1. Document Purpose

This document defines the authentication and credential-management architecture for the **Salesforce Enterprise AI Tool & Customer Service Assistant**.

The design covers:

- Salesforce Named Credentials.
- External Credentials.
- OAuth 2.0.
- JWT authentication.
- API keys.
- Mutual TLS.
- Permission Sets.
- Principal mapping.
- Authentication providers.
- External APIs.
- AI/LLM providers.
- RAG services.
- Environment-specific configuration.
- Secret rotation.
- Credential security.
- CI/CD considerations.
- Monitoring and troubleshooting.

The primary security principle is:

> **Application code must never contain credentials or secrets. Authentication must be delegated to Salesforce's credential-management framework wherever possible.**

---

# 2. Why Named Credentials Are Required

Without Named Credentials, developers may be tempted to write:

```apex
request.setEndpoint(
    'https://api.example.com/v1/customers'
);

request.setHeader(
    'Authorization',
    'Bearer ' + apiKey
);
```

This creates significant risks.

Potential problems include:

- Secrets committed to Git.
- Credentials exposed in debug logs.
- Difficult credential rotation.
- Environment-specific code changes.
- Developers having unnecessary access to production credentials.
- Security review failures.

Instead:

```text
Apex
  │
  ▼
Named Credential
  │
  ▼
External Credential
  │
  ▼
Authentication
  │
  ▼
External API
```

---

# 3. Named Credential Architecture

```text
┌──────────────────────────────────────┐
│ Salesforce Application               │
│                                      │
│ Apex / Integration Service           │
└───────────────────┬──────────────────┘
                    │
                    │ callout:NAME
                    ▼
┌──────────────────────────────────────┐
│ Named Credential                     │
│                                      │
│ Endpoint                             │
│ Connection configuration             │
└───────────────────┬──────────────────┘
                    │
                    ▼
┌──────────────────────────────────────┐
│ External Credential                  │
│                                      │
│ Authentication Protocol              │
│ Principal                            │
│ Permission Mapping                   │
└───────────────────┬──────────────────┘
                    │
                    ▼
┌──────────────────────────────────────┐
│ External Service                     │
│                                      │
│ REST API / AI / RAG / Enterprise     │
└──────────────────────────────────────┘
```

---

# 4. Named Credential vs External Credential

These concepts should be separated.

## Named Credential

Defines the connection configuration and endpoint.

Conceptually:

```text
Named Credential
    =
Endpoint + Connection Configuration
```

Example:

```text
AI_External_Service
```

---

## External Credential

Defines how Salesforce authenticates to the external system.

Conceptually:

```text
External Credential
    =
Authentication + Principals + Permissions
```

Example:

```text
AI_External_Credential
```

---

# 5. Recommended Architecture

```text
Named Credential
       │
       ▼
External Credential
       │
       ├── Principal
       │
       ├── Permission Set Mapping
       │
       └── Authentication Protocol
```

This creates a clean separation between:

```text
Where am I connecting?
```

and:

```text
How am I authenticating?
```

---

# 6. Integration Targets

This project may require credentials for:

```text
Salesforce
│
├── LLM Provider
│
├── RAG / AI Search Service
│
├── Customer API
│
├── Order API
│
├── CRM API
│
├── Enterprise API Gateway
│
└── Other external services
```

Each integration should have its own credential boundary where practical.

---

# 7. Recommended Credential Naming Convention

Use predictable names.

Example:

```text
NC_AI_LLM
NC_AI_RAG
NC_CUSTOMER_API
NC_ORDER_API
NC_CRM_API
NC_ENTERPRISE_GATEWAY
```

External Credentials:

```text
EC_AI_LLM
EC_AI_RAG
EC_CUSTOMER_API
EC_ORDER_API
EC_CRM_API
EC_ENTERPRISE_GATEWAY
```

Permission Sets:

```text
PS_AI_LLM_Integration
PS_AI_RAG_Integration
PS_Customer_API_Integration
PS_Order_API_Integration
```

---

# 8. Environment Naming

Do not use the same production credential for every environment.

Recommended logical separation:

```text
DEV
QA
UAT
PROD
```

Example:

```text
DEV:
NC_AI_LLM_DEV

QA:
NC_AI_LLM_QA

UAT:
NC_AI_LLM_UAT

PROD:
NC_AI_LLM_PROD
```

The exact naming convention can be simplified if the deployment mechanism manages environment-specific values.

---

# 9. Environment Architecture

```text
              Salesforce Environments

      ┌─────────┐
      │   DEV   │
      └────┬────┘
           │
      DEV Credential
           │
           ▼
     Development API


      ┌─────────┐
      │   QA    │
      └────┬────┘
           │
      QA Credential
           │
           ▼
       QA API


      ┌─────────┐
      │   UAT   │
      └────┬────┘
           │
      UAT Credential
           │
           ▼
      UAT API


      ┌─────────┐
      │  PROD   │
      └────┬────┘
           │
     PROD Credential
           │
           ▼
      Production API
```

---

# 10. Security Principle

Production credentials must never be reused in:

- Developer laptops.
- Scratch orgs.
- Development sandboxes.
- QA environments.
- Source code.
- GitHub repositories.

---

# 11. Authentication Methods

The project may use:

```text
OAuth 2.0
JWT
API Key
Mutual TLS
Basic Authentication
Managed Identity
```

The preferred method depends on the external service.

---

# 12. OAuth 2.0

OAuth 2.0 is recommended where the external API supports it.

Conceptual flow:

```text
Salesforce
    │
    │ OAuth request
    ▼
Authorization Server
    │
    │ Access Token
    ▼
Salesforce
    │
    │ Bearer Token
    ▼
External API
```

The token should be managed by the credential framework rather than manually stored in Apex.

---

# 13. OAuth Client Credentials

For machine-to-machine integration:

```text
Salesforce
    │
    │ Client Authentication
    ▼
Authorization Server
    │
    ▼
Access Token
    │
    ▼
External API
```

This is appropriate for many server-to-server integrations.

---

# 14. OAuth Authorization Code

For delegated user access:

```text
User
 │
 ▼
Salesforce
 │
 ▼
Authorization Server
 │
 ▼
User Consent
 │
 ▼
Authorization Code
 │
 ▼
Access Token
```

This is appropriate when the external system needs to act on behalf of a user.

---

# 15. JWT Authentication

JWT-based authentication may be used when supported by the external provider.

Conceptually:

```text
Salesforce
   │
   │ Signed JWT
   ▼
Authorization Server
   │
   ▼
Access Token
   │
   ▼
External API
```

Private keys must be securely managed.

Never commit:

```text
private.key
private.pem
client-secret
JWT secret
```

to Git.

---

# 16. API Key Authentication

Some services require:

```http
Authorization: Bearer <API_KEY>
```

or:

```http
X-API-Key: <API_KEY>
```

The API key should be stored in the credential-management layer.

Application code should reference the configured credential rather than embedding the value.

---

# 17. Mutual TLS

For high-security integrations:

```text
Salesforce
    │
    │ Client Certificate
    │
    ▼
External API
```

Both sides authenticate the connection.

mTLS may be appropriate for:

- Banking systems.
- Financial services.
- High-trust enterprise APIs.
- B2B integrations.
- Regulated environments.

---

# 18. Managed Identity

For Azure-based architectures, managed identity can reduce secret management requirements.

Conceptual architecture:

```text
Salesforce / Integration Layer
          │
          ▼
      Azure Service
          │
          ▼
   Managed Identity
          │
          ▼
 Azure Protected Resource
```

Where Salesforce itself cannot directly use the required Azure identity mechanism, an intermediary integration service or API gateway may be used.

---

# 19. AI/LLM Credential Architecture

For an external LLM:

```text
Salesforce
    │
    ▼
NC_AI_LLM
    │
    ▼
EC_AI_LLM
    │
    ▼
OAuth / API Key / JWT
    │
    ▼
LLM Provider
```

The application should not contain:

```text
API key
client secret
private key
token
```

---

# 20. RAG Credential Architecture

For an external RAG service:

```text
AI_RAG_Service
      │
      ▼
Named Credential
      │
      ▼
External Credential
      │
      ▼
Authentication
      │
      ▼
RAG API
```

The RAG service must independently enforce authorization.

Credential management does not replace data-level authorization.

---

# 21. Permission Sets

Access to external credentials should be explicitly controlled.

Example:

```text
PS_AI_LLM_Integration
        │
        ▼
Access to EC_AI_LLM
```

Only authorized application users or integration contexts should have access.

---

# 22. Least Privilege

Do not grant every user access to every external credential.

Example:

```text
Salesforce User
      │
      ▼
AI Assistant Permission Set
      │
      ▼
Approved Tool
      │
      ▼
Approved External Credential
```

A user who can use:

```text
CASE_SUMMARY
```

does not automatically need permission to:

```text
CREATE_TASK
```

or:

```text
CREATE_ORDER
```

---

# 23. Credential-to-Tool Mapping

The project should explicitly map tools to credentials.

Example:

| Tool | Credential |
|---|---|
| Customer Lookup | `NC_CUSTOMER_API` |
| Order Status | `NC_ORDER_API` |
| Knowledge Search | `NC_AI_RAG` |
| AI Generation | `NC_AI_LLM` |
| CRM Enrichment | `NC_CRM_API` |

This prevents accidental credential reuse.

---

# 24. Tool Security Architecture

```text
AI Agent
   │
   ▼
Tool Registry
   │
   ▼
Tool Authorization
   │
   ▼
Credential Authorization
   │
   ▼
Named Credential
   │
   ▼
External API
```

The LLM does not receive direct access to credentials.

---

# 25. Apex Callout

Conceptual Apex usage:

```apex
HttpRequest request = new HttpRequest();

request.setEndpoint(
    'callout:NC_CUSTOMER_API/v1/customers/C101'
);

request.setMethod('GET');

Http http = new Http();

HttpResponse response = http.send(request);
```

The application code references the Named Credential.

It does not contain the credential secret.

---

# 26. POST Example

```apex
HttpRequest request = new HttpRequest();

request.setEndpoint(
    'callout:NC_AI_LLM/v1/chat'
);

request.setMethod('POST');

request.setHeader(
    'Content-Type',
    'application/json'
);

request.setBody(
    JSON.serialize(payload)
);

HttpResponse response =
    new Http().send(request);
```

Authentication should be handled by the configured credential.

---

# 27. Endpoint Abstraction

Do not scatter endpoint URLs throughout Apex.

Avoid:

```apex
request.setEndpoint(
    'https://prod-api.example.com/v1/customer'
);
```

Prefer:

```apex
request.setEndpoint(
    'callout:NC_CUSTOMER_API/v1/customer'
);
```

This enables environment-specific configuration without changing business code.

---

# 28. External Credential Principal

A principal represents the authentication identity used by the external credential.

Conceptually:

```text
External Credential
       │
       ├── Principal A
       ├── Principal B
       └── Principal C
```

Different principals can support different integration identities where required.

---

# 29. Principal Mapping

Principal access should be explicitly mapped.

```text
Permission Set
       │
       ▼
External Credential Principal
       │
       ▼
External API Identity
```

This supports least privilege and controlled access.

---

# 30. Named Credential Access Model

Recommended model:

```text
User
 │
 ▼
Permission Set
 │
 ▼
External Credential Principal
 │
 ▼
Named Credential
 │
 ▼
External API
```

Every layer should be intentional.

---

# 31. Credential Security Boundaries

Credentials should be separated by:

```text
Environment
System
Application
Business capability
Risk level
```

For example:

```text
NC_CUSTOMER_API
NC_ORDER_API
NC_PAYMENT_API
```

should not necessarily share one broad production credential.

---

# 32. Credential Rotation

Credentials should support controlled rotation.

Example:

```text
Current Credential
       │
       ▼
Generate New Credential
       │
       ▼
Configure External System
       │
       ▼
Update Salesforce Credential
       │
       ▼
Test
       │
       ▼
Monitor
       │
       ▼
Revoke Old Credential
```

---

# 33. Rotation Strategy

Avoid:

```text
Delete old credential
       ↓
Create new credential
       ↓
Hope integration works
```

Prefer:

```text
Prepare
  ↓
Configure
  ↓
Validate
  ↓
Switch
  ↓
Monitor
  ↓
Revoke
```

This minimizes downtime.

---

# 34. Credential Expiration

Monitor:

```text
OAuth token expiry
Certificate expiry
Client secret expiry
API key expiration
JWT signing certificate expiry
mTLS certificate expiry
```

Create alerts before expiration.

Example:

```text
30 days → Warning
14 days → High priority
7 days  → Critical
```

Actual thresholds should be configurable.

---

# 35. Secret Storage

Secrets should reside in approved secure storage.

Preferred Salesforce mechanisms:

```text
Named Credentials
External Credentials
```

For supporting infrastructure:

```text
Azure Key Vault
GitHub Actions Secrets
Enterprise Secret Manager
```

The correct mechanism depends on the integration boundary.

---

# 36. GitHub Security

Never commit:

```text
.env
secrets.json
credentials.json
*.pem
*.key
client-secret.txt
access-token.txt
```

Recommended `.gitignore` entries:

```gitignore
.env
.env.*
*.pem
*.key
*.p12
*.pfx
secrets/
credentials/
```

---

# 37. Secret Scanning

CI/CD should scan repositories for accidentally committed secrets.

Recommended controls:

```text
Secret scanning
SAST
Dependency scanning
Pull-request checks
Pre-commit scanning
```

A detected credential should be treated as compromised.

---

# 38. Credential Compromise Response

If a credential is accidentally exposed:

```text
Exposure detected
      ↓
Disable / revoke credential
      ↓
Generate replacement
      ↓
Update Salesforce
      ↓
Review access logs
      ↓
Investigate usage
      ↓
Remove secret from repository
      ↓
Document incident
```

Simply deleting the Git commit is not sufficient if the secret was already exposed.

---

# 39. CI/CD Considerations

Metadata and source configuration can be deployed through CI/CD.

However, secret values should not be placed in source control.

Conceptually:

```text
GitHub
  │
  │ Metadata
  ▼
Salesforce Deployment
  │
  ▼
Environment-specific credential configuration
```

Secrets should be supplied through secure deployment mechanisms.

---

# 40. Deployment Architecture

```text
Git Repository
      │
      ▼
GitHub Actions
      │
      ├── Validate
      ├── Test
      ├── Security Scan
      └── Deploy Metadata
             │
             ▼
      Salesforce Environment
             │
             ▼
      Named Credential
             │
             ▼
      External Credential
```

---

# 41. Environment Configuration

Example:

```text
Development

NC_AI_LLM_DEV
Endpoint → Development API
Credential → Development identity
```

Production:

```text
NC_AI_LLM_PROD
Endpoint → Production API
Credential → Production identity
```

The application code remains unchanged.

---

# 42. Configuration Metadata

Non-secret configuration may be stored separately.

Examples:

```text
Endpoint path
Timeout
Retry count
Feature flags
Model name
API version
Rate limit
```

Secrets remain in credential-management systems.

---

# 43. Named Credential and Custom Metadata

Use Custom Metadata for:

```text
Integration configuration
Tool-to-API mapping
Timeout configuration
Feature flags
Provider selection
Non-sensitive endpoint paths
```

Do not use Custom Metadata as a secret store.

---

# 44. Credential Architecture for Multiple AI Providers

The project may support multiple AI providers.

Example:

```text
                    AI Provider
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        Provider A              Provider B
              │                     │
       NC_AI_PROVIDER_A       NC_AI_PROVIDER_B
              │                     │
              ▼                     ▼
       External Credential    External Credential
```

The AI adapter selects the configured provider.

---

# 45. AI Provider Failover

Conceptual flow:

```text
Primary LLM
     │
     X
Failure
     │
     ▼
Failure Classification
     │
     ▼
Retry / Fallback
     │
     ▼
Secondary LLM
```

The fallback provider must have:

- Approved security controls.
- Approved data-processing terms.
- Compatible API contract.
- Independent credential.
- Tested model behavior.

---

# 46. Credential and Data Classification

Higher-risk data may require stricter integration controls.

Example:

| Data Classification | Credential Requirement |
|---|---|
| Public | Standard secure API |
| Internal | Authenticated API |
| Confidential | Strong authentication + authorization |
| Restricted | Strong authentication + additional controls |

The data classification should determine which external services may receive the data.

---

# 47. Data Residency

Before integrating with an external AI or data service, verify:

```text
Data residency
Data processing location
Cross-border transfer requirements
Retention
Subprocessors
Encryption
Compliance requirements
```

Do not assume that an authenticated API is automatically approved for all enterprise data.

---

# 48. Salesforce-to-Azure Architecture

A potential architecture:

```text
Salesforce
     │
     ▼
Named Credential
     │
     ▼
API Gateway / Azure API Management
     │
     ├── Authentication
     ├── Rate Limiting
     ├── Monitoring
     └── Routing
     │
     ▼
Azure Service
     │
     ├── Azure OpenAI
     ├── Azure AI Search
     ├── Azure Functions
     └── Storage
```

This architecture provides a controlled integration boundary.

---

# 49. API Management Integration

For enterprise APIs, Azure API Management or another gateway can provide:

```text
Authentication
Authorization
Rate limiting
Throttling
Transformation
Versioning
Logging
Monitoring
```

Salesforce still needs to enforce application-level authorization.

---

# 50. Network Security

Where supported, use:

```text
TLS 1.2+
Private connectivity
IP restrictions
mTLS
Firewall controls
API gateway
WAF
```

Never disable TLS certificate validation merely to resolve an integration issue.

---

# 51. Credential Monitoring

Monitor:

```text
Authentication failures
401 responses
403 responses
Token refresh failures
Certificate expiration
Credential rotation
API key expiration
Unusual request volume
Unexpected geographic access
```

---

# 52. Credential Audit

Audit:

```text
Who created the credential
Who modified the credential
Who accessed the integration
When it was changed
Which environment
Which external service
```

Where possible, use platform audit capabilities and centralized security monitoring.

---

# 53. Authentication Failure

Example:

```text
Salesforce
    │
    ▼
Named Credential
    │
    X
Authentication Failure
```

Expected behavior:

```text
Do not retry indefinitely
Do not expose credentials
Log sanitized error
Raise alert
Return controlled error
```

Authentication failures generally require configuration or credential remediation rather than blind retries.

---

# 54. Authorization Failure

Example:

```text
HTTP 403
```

Expected:

```text
Classify as authorization failure
        ↓
No automatic retry
        ↓
Log correlation ID
        ↓
Alert if unexpected
        ↓
Safe user message
```

---

# 55. Credential Troubleshooting

Recommended troubleshooting sequence:

```text
1. Verify Named Credential exists
2. Verify endpoint
3. Verify External Credential
4. Verify principal
5. Verify Permission Set
6. Verify authentication configuration
7. Verify external API availability
8. Check HTTP status
9. Check correlation ID
10. Review sanitized logs
```

Never ask developers to print secret values to diagnose an issue.

---

# 56. Common Configuration Errors

### Error: 401

Potential causes:

```text
Expired token
Invalid client
Incorrect authentication
Wrong credential
```

### Error: 403

Potential causes:

```text
Missing permission
Insufficient external API scope
Incorrect principal
External authorization failure
```

### Error: DNS / Connection Failure

Potential causes:

```text
Incorrect endpoint
Network restriction
Firewall
Service outage
```

---

# 57. Testing Credential Configuration

Integration tests should verify:

```text
Valid credential
Invalid credential
Expired credential
Insufficient scope
Unauthorized principal
Wrong endpoint
Certificate failure
Token refresh
```

Production credentials should never be used in automated tests.

---

# 58. Test Environment

Use dedicated test identities.

Example:

```text
DEV:
svc-salesforce-ai-dev

QA:
svc-salesforce-ai-qa

UAT:
svc-salesforce-ai-uat

PROD:
svc-salesforce-ai-prod
```

Each identity should have only the required permissions.

---

# 59. Service Account Principle

Where a machine-to-machine integration is required, use a dedicated integration identity.

Avoid using:

```text
Individual developer account
Salesforce administrator account
Personal external API account
```

for production integrations.

---

# 60. Credential Ownership

Every credential should have an owner.

Example:

| Credential | Owner |
|---|---|
| `NC_AI_LLM` | AI Engineering |
| `NC_AI_RAG` | AI Engineering |
| `NC_CUSTOMER_API` | Integration Team |
| `NC_ORDER_API` | Integration Team |
| `NC_CRM_API` | CRM Integration Team |

Also document:

- Technical owner.
- Business owner.
- Security owner.
- Support team.

---

# 61. Credential Inventory

Maintain an inventory:

```text
Credential Name
Environment
External System
Authentication Type
Owner
Created Date
Expiration Date
Rotation Date
Business Criticality
Data Classification
```

Example:

```text
NC_AI_LLM_PROD
Production
LLM Provider
OAuth 2.0
AI Engineering
Critical
```

---

# 62. Credential Lifecycle

```text
Request
  ↓
Security Review
  ↓
Create
  ↓
Configure
  ↓
Test
  ↓
Deploy
  ↓
Monitor
  ↓
Rotate
  ↓
Retire
```

---

# 63. Credential Decommissioning

When an integration is retired:

```text
Stop application usage
       ↓
Disable integration
       ↓
Verify no active consumers
       ↓
Revoke external credential
       ↓
Remove Salesforce configuration
       ↓
Remove permission mappings
       ↓
Update documentation
```

---

# 64. Security Checklist

```text
[ ] No credentials in Apex
[ ] No credentials in LWC
[ ] No credentials in Git
[ ] No credentials in logs
[ ] Named Credentials configured
[ ] External Credentials configured
[ ] Permission Sets configured
[ ] Least privilege enforced
[ ] OAuth/JWT/mTLS used where appropriate
[ ] Environment separation implemented
[ ] Credential rotation documented
[ ] Expiration monitoring implemented
[ ] Secret scanning enabled
[ ] Production credentials isolated
[ ] Integration identities are dedicated
[ ] Authentication failures monitored
[ ] Authorization failures monitored
```

---

# 65. Production Readiness Checklist

```text
[ ] Endpoint verified
[ ] Authentication verified
[ ] Principal verified
[ ] Permission Set verified
[ ] External API permissions verified
[ ] Timeout configured
[ ] Retry configured
[ ] Rate limit configured
[ ] Correlation ID enabled
[ ] Error handling implemented
[ ] Monitoring enabled
[ ] Alerting configured
[ ] Credential owner identified
[ ] Rotation process documented
[ ] Incident runbook available
[ ] Rollback plan available
```

---

# 66. Recommended Salesforce Metadata Structure

For the portfolio project, maintain credential-related metadata alongside the Salesforce project source where supported by the deployment model.

Conceptually:

```text
force-app/main/default/
├── externalCredentials/
├── namedCredentials/
├── permissionsets/
├── customMetadata/
└── classes/
```

The exact metadata representation depends on the Salesforce API/CLI version and deployment approach being used.

Secret values should remain outside source control.

---

# 67. Integration Security Flow

```text
User
 │
 ▼
Salesforce Authentication
 │
 ▼
Permission Set
 │
 ▼
AI Tool Authorization
 │
 ▼
Application Service
 │
 ▼
Named Credential
 │
 ▼
External Credential
 │
 ▼
Authentication
 │
 ▼
API Gateway
 │
 ▼
External Service
```

Every layer has a distinct security responsibility.

---

# 68. Example End-to-End Customer Lookup

```text
User:
"Show customer C101 information."

        │
        ▼

Salesforce User Authentication

        │
        ▼

Authorization Check

        │
        ▼

Customer Lookup Tool

        │
        ▼

Customer API Service

        │
        ▼

NC_CUSTOMER_API

        │
        ▼

EC_CUSTOMER_API

        │
        ▼

OAuth Authentication

        │
        ▼

Customer API

        │
        ▼

Response Validation

        │
        ▼

Salesforce

        │
        ▼

LWC
```

---

# 69. Example AI Request

```text
User
 │
 ▼
AI Assistant
 │
 ▼
Authorization
 │
 ▼
Context Filtering
 │
 ▼
LLM Tool
 │
 ▼
NC_AI_LLM
 │
 ▼
External LLM
 │
 ▼
Response Validation
 │
 ▼
Groundedness / Safety Checks
 │
 ▼
User
```

The LLM never receives the underlying credential.

---

# 70. Example RAG Request

```text
AI Agent
   │
   ▼
Knowledge Search Tool
   │
   ▼
Authorization Context
   │
   ▼
NC_AI_RAG
   │
   ▼
RAG API
   │
   ▼
Filtered Results
   │
   ▼
RAG Validation
   │
   ▼
LLM Context
```

Credential security and document authorization are separate controls.

---

# 71. Separation of Concerns

The architecture should maintain:

```text
Credential Management
        ≠
Authorization
        ≠
Business Logic
        ≠
API Communication
        ≠
AI Reasoning
```

For example:

```text
Named Credential
```

answers:

> How do we securely connect?

It does not answer:

> Is this business operation allowed?

That decision belongs to the application authorization layer.

---

# 72. Definition of Done

The Named Credential and External Credential implementation is complete when:

- [ ] Named Credentials are defined.
- [ ] External Credentials are defined.
- [ ] Authentication mechanisms are documented.
- [ ] Permission Set mappings are defined.
- [ ] Principal mappings are defined.
- [ ] Environment separation is implemented.
- [ ] No secrets exist in source code.
- [ ] No credentials exist in Git.
- [ ] OAuth/JWT/API-key/mTLS requirements are documented.
- [ ] Credential rotation is documented.
- [ ] Credential expiration is monitored.
- [ ] Integration identities are dedicated.
- [ ] Least privilege is enforced.
- [ ] Credential-to-tool mapping is documented.
- [ ] Production credentials are isolated.
- [ ] CI/CD does not expose secrets.
- [ ] Secret scanning is enabled.
- [ ] Authentication failures are monitored.
- [ ] Authorization failures are monitored.
- [ ] Credential ownership is documented.
- [ ] Credential inventory exists.
- [ ] Decommissioning process exists.
- [ ] Security testing is complete.
- [ ] Production runbook exists.

---

# 73. Final Security Principle

The target architecture is:

```text
                  Salesforce
                      │
                      ▼
               Application Auth
                      │
                      ▼
                 Tool AuthZ
                      │
                      ▼
              Named Credential
                      │
                      ▼
             External Credential
                      │
                      ▼
               Secure Identity
                      │
                      ▼
                 HTTPS / TLS
                      │
                      ▼
                API Gateway
                      │
                      ▼
              External Service
```

The key principle is:

> **Credentials belong to the platform security layer, not to application code. Salesforce application code should reference a controlled Named Credential, while authentication, principal management, secret handling, and credential rotation remain outside the business logic.**

A second principle is equally important:

> **Authentication does not equal authorization. A valid credential only establishes the integration identity; the application must still determine whether the requested operation and data access are permitted.**