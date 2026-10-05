# Salesforce AI Agent & Tool-Calling Platform

> **Enterprise-style Salesforce AI Agent platform combining Salesforce, Azure OpenAI, native LLM tool calling, RAG, REST integrations, security controls, observability, automated testing, and DevSecOps CI/CD.**

---

## Overview

This project demonstrates how an enterprise customer-service AI agent can safely interact with Salesforce and approved external systems through a controlled tool-execution framework.

The platform intentionally separates:

- Natural-language understanding
- LLM tool selection
- Tool contract validation
- Tool authorization
- Human approval
- Tool execution
- Salesforce security
- RAG retrieval
- External REST integration
- Audit
- Observability
- Automated testing
- CI/CD
- DevSecOps

### Core Security Principle

> **The LLM is never treated as the security boundary.**

The LLM can recommend an action, but Salesforce-controlled application logic determines whether that action is valid, authorized, approved, and executed.

---

# Business Scenario

A customer-service representative can interact with the AI agent using natural language.

Example requests:

```text
Find customer Acme.

Show Acme's open cases.

What is our refund policy?

What is the status of order ORD-10001?

Create a case for this customer.

Escalate this case.
```

The platform processes the request through the following controlled flow:

```text
User Request
     |
     v
LLM Understanding
     |
     v
Tool Selection
     |
     v
Tool Contract Validation
     |
     v
Authorization
     |
     v
Human Approval
     |
     v
Tool Execution
     |
     v
Controlled Response
```

Read operations can execute without approval when authorized.

Sensitive write operations can require explicit human approval.

---

# Architecture

```text
                         +----------------------+
                         |        User          |
                         +----------+-----------+
                                    |
                                    v
                    +-------------------------------+
                    | Salesforce LWC Agent Console |
                    +---------------+---------------+
                                    |
                                    v
                    +-------------------------------+
                    |      AI_AgentController       |
                    +---------------+---------------+
                                    |
                                    v
                    +-------------------------------+
                    |     AI_AgentOrchestrator      |
                    +---------------+---------------+
                           |                   |
                           v                   v
                 +----------------+   +------------------+
                 | Azure OpenAI   |   | Session / Audit  |
                 +-------+--------+   +------------------+
                         |
                         v
                +----------------------+
                | Native Tool Calling  |
                +----------+-----------+
                           |
                           v
                +----------------------+
                | Tool Call Validator  |
                +----------+-----------+
                           |
                           v
                +----------------------+
                |     Tool Registry    |
                +----------+-----------+
                           |
                           v
                +----------------------+
                | Contract + Schema +  |
                | Authorization        |
                +----------+-----------+
                           |
                           v
                +----------------------+
                | Human Approval       |
                +----------+-----------+
                           |
                           v
                +----------------------+
                |   AI_ToolExecutor    |
                +----------+-----------+
                           |
          +----------------+-------------------+
          |                |                   |
          v                v                   v
   +-------------+   +------------+    +---------------+
   | Salesforce  |   |    RAG     |    | REST Services |
   |  Services   |   |  Services  |    |               |
   +------+------+   +-----+------+    +-------+-------+
          |                |                   |
          v                v                   v
   Salesforce Data   Azure AI Search      External APIs
```

---

# Core Technologies

## Salesforce

- Apex
- Lightning Web Components
- Salesforce DX
- Custom Objects
- Custom Metadata
- Permission Sets
- Named Credentials
- External Credentials
- SOQL
- User Mode
- Apex Testing
- Sharing and authorization controls

## AI / GenAI

- Azure OpenAI
- Native LLM function/tool calling
- LLM orchestration
- Prompt engineering
- Tool selection
- Tool contract validation
- Argument validation
- RAG
- Embeddings
- Azure AI Search
- Grounded responses
- Citation handling

## Integration

- REST APIs
- HTTP callouts
- JSON
- Salesforce Named Credentials
- External authentication
- DTO-based response mapping
- Controlled endpoint configuration

## DevOps

- Git
- GitHub
- GitHub Actions
- Salesforce CLI
- CI/CD
- DevSecOps
- Automated quality gates
- Environment promotion
- Production validation
- Smoke testing

---

# Tool Catalog

| Tool | Type | Approval |
|---|---|---|
| `search_customer` | Salesforce | No |
| `get_customer_details` | Salesforce | No |
| `get_open_cases` | Salesforce | No |
| `get_case_details` | Salesforce | No |
| `create_case` | Salesforce | Yes |
| `update_case` | Salesforce | Yes |
| `create_task` | Salesforce | Yes |
| `escalate_case` | Salesforce | Yes |
| `search_knowledge` | RAG | No |
| `get_order_status` | REST | No |

The tool registry provides a controlled allow-list.

The model cannot dynamically create or execute arbitrary tools.

---

# Tool Execution Security

Every LLM-generated tool request follows a controlled execution path:

```text
LLM Tool Call
     |
     v
Tool Exists?
     |
     v
Contract Validation
     |
     v
Schema Validation
     |
     v
Argument Validation
     |
     v
Authorization
     |
     v
Approval Required?
     |
     +------ Yes ------> Human Approval
     |                         |
     |                         v
     |                    Approved?
     |                         |
     +----------- No ----------+
                  |
                  v
           Tool Execution
                  |
                  v
           Output Validation
                  |
                  v
           Audit / Logging
```

---

# Security Architecture

The platform follows a defense-in-depth security model.

```text
User Identity
      |
      v
Permission Set
      |
      v
CRUD / FLS
      |
      v
User Mode
      |
      v
Tool Authorization
      |
      v
Tool Contract
      |
      v
Schema Validation
      |
      v
Human Approval
      |
      v
Named Credential
      |
      v
External Authentication
      |
      v
RAG Security
      |
      v
Prompt Injection Protection
      |
      v
PII Minimization
      |
      v
Rate Limiting
      |
      v
Audit
      |
      v
Monitoring
```

### Security Principles

- The LLM cannot execute Apex directly.
- The LLM cannot execute arbitrary SOQL.
- The LLM cannot select arbitrary URLs.
- Only registered tools can execute.
- Every tool call is contract validated.
- Tool arguments are schema validated.
- Sensitive write operations require approval.
- Salesforce authorization remains authoritative.
- Retrieved documents are treated as untrusted data.
- Credentials are never supplied to the LLM.
- Production secrets are never stored in Git.
- External endpoints are configuration-controlled.
- Access to Salesforce data remains subject to Salesforce security.

---

# RAG Architecture

The RAG pipeline is designed to provide grounded answers from authorized enterprise content.

```text
Salesforce Knowledge
        |
        v
Content Extraction
        |
        v
Chunking
        |
        v
Embeddings
        |
        v
Azure AI Search
        |
        v
Hybrid Retrieval
        |
        v
Security Filtering
        |
        v
Grounded Context
        |
        v
Azure OpenAI
        |
        v
Cited Response
```

### RAG Security

RAG responses must be grounded in authorized retrieved content.

Security considerations include:

- Document-level authorization
- User-context filtering
- Retrieval filtering
- Sensitive-data protection
- Prompt-injection protection
- Untrusted-document handling
- Unsupported-claim detection
- Grounding validation
- Citation validation

---

# REST Integration

The Order Status tool demonstrates controlled external API integration.

```text
get_order_status
       |
       v
AI_ToolExecutor
       |
       v
OrderService
       |
       v
AI_OrderApiService
       |
       v
Named Credential
       |
       v
External Order API
```

The model supplies only the required business argument, such as:

```json
{
  "orderNumber": "ORD-10001"
}
```

The endpoint itself is controlled by Salesforce configuration.

The model cannot select an arbitrary URL.

---

# Observability

The platform records operational information such as:

- Agent sessions
- User interactions
- Tool execution
- Execution status
- Execution duration
- Approval status
- Errors
- Correlation IDs

Operational monitoring covers:

```text
Request Volume
      |
      +-- Success / Failure Rate
      |
      +-- Tool Failures
      |
      +-- RAG Failures
      |
      +-- REST Failures
      |
      +-- Azure Failures
      |
      +-- Latency
      |
      +-- Security Denials
      |
      +-- Approval Requests
```

Correlation IDs are used to trace a request across agent orchestration, tool execution, integrations, and downstream dependencies.

---

# Testing Strategy

The project uses multiple layers of testing.

```text
Unit Tests
     |
     v
Tool Contract Tests
     |
     v
Security Tests
     |
     v
RAG Evaluation
     |
     v
LLM Tool-Calling Tests
     |
     v
REST Integration Tests
     |
     v
End-to-End Tests
     |
     v
Negative Tests
     |
     v
Performance Tests
     |
     v
Regression Suite
     |
     v
CI/CD Quality Gates
```

## Testing Areas

### Apex

- Positive scenarios
- Negative scenarios
- Bulkification
- Error handling
- Authorization
- CRUD/FLS
- Sharing
- Tool execution

### AI

- Tool selection
- Tool argument generation
- Invalid tool requests
- Unauthorized tools
- Missing arguments
- Invalid arguments
- Tool failures
- Timeout handling
- Model failures
- Output validation

### Security

- Authentication
- Authorization
- CRUD/FLS
- Sharing
- Tool allow-list enforcement
- Prompt injection
- SOQL injection
- URL injection
- Secret protection
- Sensitive-data handling

### RAG

- Retrieval relevance
- Retrieval completeness
- Grounding
- Citation correctness
- Unsupported claims
- Unauthorized-document access
- Prompt injection in retrieved content

---

# CI/CD

```text
Feature Branch
      |
      v
Pull Request
      |
      v
GitHub Actions
      |
      +-- Git Validation
      +-- Static Analysis
      +-- Secret Scan
      +-- Salesforce Validation
      +-- Apex Tests
      +-- Security Tests
      +-- AI Tests
      +-- RAG Evaluation
      +-- REST Tests
      +-- E2E Tests
      |
      v
Quality Gates
      |
      v
DEV
      |
      v
UAT
      |
      v
Production Validation
      |
      v
Approval
      |
      v
Production
      |
      v
Smoke Tests
      |
      v
Monitoring
```

The pipeline treats AI behavior and security controls as part of the software quality lifecycle rather than as separate post-development activities.

---

# Repository Structure

```text
salesforce-ai-agent-tool-platform/
|
+-- .github/
|   +-- workflows/
|       +-- ci.yml
|       +-- deploy-dev.yml
|       +-- deploy-uat.yml
|       +-- production.yml
|
+-- docs/
|   +-- architecture/
|   +-- security/
|   +-- rag/
|   +-- testing/
|   +-- operations/
|   +-- deployment/
|   +-- devsecops/
|   +-- releases/
|
+-- force-app/
|   +-- main/
|       +-- default/
|           +-- classes/
|           +-- lwc/
|           +-- objects/
|           +-- customMetadata/
|           +-- permissionsets/
|           +-- dashboards/
|           +-- reports/
|
+-- scripts/
|   +-- production-smoke-test.ps1
|
+-- tests/
|   +-- rag/
|   +-- performance/
|
+-- sfdx-project.json
+-- README.md
+-- .gitignore
```

---

# Key Apex Components

## Agent Orchestration

```text
AI_AgentController
AI_AgentOrchestrator
AI_AgentIntentResolver
AI_AgentToolSelector
AI_AgentArgumentBuilder
```

## LLM

```text
AI_AgentAzureOpenAIService
AI_AgentAzureToolCallingService
AI_AgentLLMToolDefinitionBuilder
AI_AgentLLMToolCallValidator
AI_AgentAzureOpenAIResponseParser
```

## Tool Framework

```text
AI_ToolRegistry
AI_ToolExecutor
AI_ToolValidator
AI_ToolSchemaValidator
AI_ToolAuthorization
AI_ToolContractCatalog
```

## Business Services

```text
CustomerService
CaseService
KnowledgeService
OrderService
AI_RAGService
AI_OrderApiService
```

## Security

```text
AI_SecurityService
AI_DataMaskingService
AI_SecurityExceptionHandler
AI_RateLimitService
```

## Session and Audit

```text
AI_AgentSessionService
AI_Agent_Session__c
AI_Agent_Interaction__c
AI_Agent_Tool_Execution__c
```

---

# Deployment

Production deployment follows a controlled validation-first strategy.

Authenticate to the target Salesforce environment using the organization's approved CI/CD authentication mechanism.

Validate the deployment:

```bash
sf project deploy validate \
  --source-dir force-app \
  --target-org ai-agent-prod \
  --test-level RunLocalTests \
  --wait 60
```

After successful validation and production approval:

```bash
sf project deploy quick \
  --job-id <VALIDATION_JOB_ID> \
  --target-org ai-agent-prod \
  --wait 30
```

Production deployment should be performed only through the organization's approved release process.

---

# Production Smoke Tests

The production smoke-test script is:

```text
scripts/production-smoke-test.ps1
```

Example:

```powershell
.\scripts\production-smoke-test.ps1
```

Or specify an alternate Salesforce org alias:

```powershell
.\scripts\production-smoke-test.ps1 `
    -OrgAlias "ai-agent-prod"
```

The smoke-test process validates the production Salesforce connection and AI tool configuration.

Production functional validation should include:

- Customer search
- Customer details
- Open cases
- Knowledge/RAG search
- Order status
- Approval-required operations
- Prompt-injection rejection
- Security authorization
- Audit logging
- Correlation IDs
- Monitoring

---

# Production Support

Production incidents use the following severity model:

| Severity | Description |
|---|---|
| **P1** | Critical production outage or major security incident |
| **P2** | High-impact production degradation |
| **P3** | Medium-impact functional or integration issue |
| **P4** | Low-impact issue or service request |

## Support Workflow

```text
Incident
   |
   v
Correlation ID
   |
   v
Salesforce Logs
   |
   v
AI Tool Execution
   |
   v
Azure Monitor
   |
   v
Dependency Analysis
   |
   v
Mitigation
   |
   v
Root Cause
   |
   v
Corrective Release
   |
   v
Post-Incident Review
```

---

# Rollback

Every production release should be tagged in Git.

Example:

```bash
git tag -a v1.0.0 -m "Production release 1.0.0"
git push origin v1.0.0
```

Rollback options include:

1. Deploy previous known-good Salesforce metadata.
2. Disable an affected AI tool.
3. Disable an affected external integration.
4. Disable RAG functionality.
5. Disable specific AI capabilities.
6. Use the emergency AI kill switch.
7. Restore a known-good application configuration.

Rollback decisions should follow the documented production rollback procedure.

See:

```text
docs/deployment/rollback-plan.md
```

---

# DevSecOps

Security is integrated throughout the development lifecycle.

```text
Plan
 |
 v
Develop
 |
 v
Commit
 |
 v
Pull Request
 |
 v
Static Analysis
 |
 v
Secret Scanning
 |
 v
Security Testing
 |
 v
Apex Testing
 |
 v
AI Testing
 |
 v
RAG Evaluation
 |
 v
Deployment Validation
 |
 v
Approval
 |
 v
Production
 |
 v
Monitoring
```

Key controls include:

- Protected branches
- Pull-request reviews
- Secret scanning
- Static analysis
- Automated Apex tests
- Security regression tests
- AI tool-calling tests
- RAG evaluation
- Deployment validation
- Environment separation
- Production approval
- Auditability
- Rollback capability

---

# Configuration and Secrets

Production secrets must never be committed to Git.

Examples of sensitive information include:

```text
API keys
Access tokens
Client secrets
Passwords
Private keys
Certificates
Salesforce authentication data
Azure credentials
External API credentials
```

Recommended mechanisms include:

- GitHub Actions Secrets
- GitHub Environments
- Salesforce Named Credentials
- Salesforce External Credentials
- Azure Key Vault
- Managed Identity where supported

The `.gitignore` configuration prevents common secret and environment files from being committed.

---

# Environment Strategy

```text
Developer
    |
    v
QA / Integration
    |
    v
UAT / Staging
    |
    v
Production
```

Environment-specific configuration should be externalized rather than hard-coded.

Typical configuration areas include:

- Salesforce org
- Azure OpenAI endpoint
- Azure OpenAI deployment
- Azure AI Search configuration
- External API endpoints
- Authentication configuration
- Feature flags
- AI tool activation
- RAG configuration

---

# AI Safety Model

The platform follows an important architectural rule:

```text
                 LLM
                  |
                  | Recommendation
                  v
        +----------------------+
        | Salesforce Controls  |
        +----------------------+
                  |
          +-------+-------+
          |       |       |
          v       v       v
       Contract Auth   Approval
          |       |       |
          +-------+-------+
                  |
                  v
             Execution
```

The model does **not** have direct authority to:

- Execute Apex
- Execute arbitrary SOQL
- Access arbitrary Salesforce records
- Call arbitrary URLs
- Bypass Salesforce security
- Retrieve unrestricted documents
- Access credentials
- Perform sensitive operations without required approval

---

# Project Outcome

This project demonstrates an enterprise-style implementation of:

- Salesforce development
- AI agent architecture
- Native LLM tool calling
- Secure Apex
- Salesforce security
- Human-in-the-loop approval
- RAG
- Azure AI Search
- Azure OpenAI
- REST integrations
- Tool contract validation
- Observability
- Enterprise testing
- CI/CD
- DevSecOps
- Production deployment
- Production support
- Incident response
- Rollback strategy

The platform is designed around one key principle:

> **AI can recommend an action, but Salesforce-controlled application logic decides whether that action is authorized and executed.**

---

# Portfolio Highlights

This project can be used to demonstrate practical experience across several enterprise technology areas:

| Area | Demonstrated Capability |
|---|---|
| Salesforce | Apex, LWC, SOQL, security, metadata |
| AI | Azure OpenAI, tool calling, orchestration |
| Agent Architecture | Tool registry, contracts, authorization |
| RAG | Azure AI Search, retrieval, grounding |
| Integration | REST APIs, Named Credentials |
| Security | CRUD/FLS, User Mode, authorization, secrets |
| Testing | Unit, security, AI, RAG, integration, E2E |
| DevOps | Git, GitHub, GitHub Actions |
| DevSecOps | Quality gates, secret scanning, security testing |
| Operations | Monitoring, audit, incident response |
| Deployment | Validation, approval, smoke tests, rollback |

---

# Documentation

Additional project documentation is organized under:

```text
docs/
|
+-- architecture/
+-- security/
+-- rag/
+-- testing/
+-- operations/
+-- deployment/
+-- devsecops/
+-- releases/
```

Important operational documents include:

```text
docs/deployment/deployment-strategy.md
docs/deployment/environment-matrix.md
docs/deployment/production-release-checklist.md
docs/deployment/rollback-plan.md
docs/deployment/secrets-management.md

docs/devsecops/ci-cd-architecture.md
docs/devsecops/quality-gates.md
docs/devsecops/branch-strategy.md
docs/devsecops/security-controls.md
docs/devsecops/incident-response.md
```

---

# Getting Started

## Prerequisites

Recommended tooling:

```text
Salesforce CLI
Git
GitHub account
VS Code
Salesforce Extension Pack
Node.js
Salesforce Developer / Sandbox environment
Azure subscription
Azure OpenAI access
Azure AI Search
```

## Clone Repository

```bash
git clone <REPOSITORY_URL>
cd salesforce-ai-agent-tool-platform
```

## Authenticate Salesforce

Use the organization's approved authentication mechanism.

For local development, authenticate using the appropriate Salesforce CLI login method and verify the target org:

```bash
sf org list
```

## Validate Project

```bash
sf project deploy validate \
  --source-dir force-app \
  --target-org <ORG_ALIAS> \
  --test-level RunLocalTests \
  --wait 60
```

---

# Recommended Development Workflow

```text
1. Create feature branch
        |
        v
2. Implement Salesforce / AI functionality
        |
        v
3. Add Apex tests
        |
        v
4. Add security tests
        |
        v
5. Add AI / tool-calling tests
        |
        v
6. Add RAG evaluation
        |
        v
7. Run local validation
        |
        v
8. Commit changes
        |
        v
9. Push feature branch
        |
        v
10. Create Pull Request
        |
        v
11. GitHub Actions quality gates
        |
        v
12. Code review
        |
        v
13. Merge to develop
        |
        v
14. UAT
        |
        v
15. Production validation
        |
        v
16. Production approval
        |
        v
17. Production deployment
        |
        v
18. Smoke tests
        |
        v
19. Monitoring

# Disclaimer

This repository is an educational and portfolio implementation.

Production organizations should adapt the architecture and controls to their own requirements, including:

- Authentication
- Authorization
- Regulatory compliance
- Data retention
- Data residency
- Network architecture
- Encryption
- Monitoring
- Incident management
- AI governance
- Model governance
- Privacy
- Security controls
- Disaster recovery
- Business continuity
- Operational procedures

The implementation should be reviewed and approved by the organization's security, architecture, compliance, and operations teams before production use.


# Author / Portfolio

**Salesforce AI Agent & Tool-Calling Platform**

Enterprise-focused portfolio project demonstrating the integration of:

```text
Salesforce
+
Azure OpenAI
+
AI Agents
+
Tool Calling
+
RAG
+
REST Integration
+
Security
+
Testing
+
DevSecOps
+
CI/CD
+
Production Operations