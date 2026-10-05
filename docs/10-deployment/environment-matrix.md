<!-- Setting	   DEV	        UAT	            PROD
Salesforce Org	ai-agent-dev	UAT	            PROD
Azure OpenAI	DEV deployment	UAT deployment	PROD deployment
AI Search	    DEV index	    UAT index	    PROD index
Order API	    Sandbox	        UAT	            Production
Logging	        Verbose	        Standard	    Controlled
Approval	    Optional	    Required	    Required
LLM limits	    Lower	        Medium	        Production
Monitoring	    Enabled	        Enabled	        Strict -->


# Environment Matrix

## 1. Purpose

This document defines the Salesforce environments used by the Salesforce AI Agent application and identifies the purpose, access model, deployment method, and configuration expectations for each environment.

---

## 2. Environment Overview

| Environment | Purpose | Deployment | Data |
|---|---|---|---|
| Development | Feature development | Developer / CI | Test data |
| QA | Integration and regression testing | CI/CD | Test data |
| UAT | Business validation | CI/CD | Masked / representative data |
| Production | Live application | Approved CI/CD | Production data |

---

## 3. Development

### Purpose

Used by developers for active development.

### Typical Activities

- Apex development
- LWC development
- Salesforce configuration
- AI service development
- Unit testing
- Integration development

### Access

Developers may have development access according to organizational policy.

### Deployment

Development deployments may be performed from VS Code or Salesforce CLI.

---

## 4. QA

### Purpose

QA validates the application before UAT.

### Testing

- Apex unit tests
- Integration tests
- API tests
- Security tests
- AI tool-calling tests
- Negative tests
- Regression tests

### Deployment

QA deployments should be performed through CI/CD.

---

## 5. UAT

### Purpose

UAT validates business functionality before production.

### Validation

Business users should validate:

- Customer service workflows
- Case summarization
- Case classification
- Suggested responses
- Knowledge recommendations
- AI assistant behavior
- Integration behavior

### Deployment

Deployments should be controlled and approved.

---

## 6. Production

### Purpose

Production contains the live Salesforce AI Agent application.

### Access

Production access must follow least-privilege principles.

### Deployment

Production deployment should occur through the approved CI/CD pipeline.

Manual production changes should be restricted and documented.

---

## 7. Environment Configuration

Environment-specific configuration should not be hard-coded.

Examples include:

```text
Salesforce endpoints
Azure OpenAI endpoint
Azure deployment name
AI Search endpoint
API credentials
Integration credentials
Named Credentials
External Credentials
Feature flags
Timeout values
```

---

## 8. Configuration Separation

Application code should remain environment independent wherever possible.

Use Salesforce configuration mechanisms such as:

- Custom Metadata Types
- Custom Settings where appropriate
- Named Credentials
- External Credentials
- Protected configuration
- GitHub Actions Secrets
- GitHub Environment Secrets

---

## 9. Salesforce Authentication

Each environment should have its own authentication configuration.

Example:

```text
ci-org
qa-org
uat-org
production
```

Production credentials must never be reused in development or QA.

---

## 10. Environment Promotion

The recommended promotion path is:

```text
Development
     ↓
QA
     ↓
UAT
     ↓
Production
```

A release should not bypass environments without documented approval.

---

## 11. Production Protection

The production GitHub environment should use:

- Required reviewers
- Environment secrets
- Restricted deployment permissions
- Branch protection
- Audit logging

---

## 12. Environment Ownership

| Environment | Primary Owner |
|---|---|
| Development | Development Team |
| QA | QA / Engineering Team |
| UAT | Business + Engineering |
| Production | Engineering / Platform Team |

Actual ownership should follow the organization's governance model.