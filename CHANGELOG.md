# Changelog

All notable changes to this project are documented in this file.

The format follows the principles of [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses Semantic Versioning where applicable.

---

## [Unreleased]

### Added

- Enterprise Salesforce AI Tool project foundation.
- GitHub-ready repository structure.
- Salesforce DX project structure.
- Enterprise AI agent architecture documentation.
- AI tool-calling architecture and tool contract design.
- Retrieval-Augmented Generation (RAG) architecture.
- RAG security and authorization-aware filtering design.
- REST API integration architecture.
- Salesforce Named Credentials and External Credentials design.
- Integration error-handling architecture.
- Enterprise testing strategy.
- Test matrix and requirement-to-test traceability.
- Regression testing strategy.
- Test evidence and release evidence strategy.
- CI/CD and DevSecOps architecture.
- Production support and operational readiness documentation.
- AI evaluation dataset structure.
- Security scanning automation.
- Regression testing automation.
- Production smoke-test automation.

### Documentation

- Added project overview.
- Added business requirements.
- Added solution architecture.
- Added technical design.
- Added security architecture.
- Added AI agent design.
- Added RAG design.
- Added integration design.
- Added testing strategy.
- Added CI/CD and DevSecOps documentation.
- Added production support documentation.
- Added AI agent design documentation.
- Added prompt engineering design.
- Added tool-calling design.
- Added LLM integration design.
- Added RAG architecture documentation.
- Added RAG ingestion pipeline documentation.
- Added RAG security filtering documentation.
- Added REST API design documentation.
- Added Named Credentials documentation.
- Added integration testing and regression documentation.

### Automation

- Added development deployment workflow.
- Added UAT deployment workflow.
- Added production smoke-test script.
- Added regression test execution script.
- Added security scanning script.

---

## [0.1.0] - 2026-10-05

### Added

#### Project Foundation

- Created Salesforce DX project structure.
- Created GitHub repository structure.
- Added `sfdx-project.json`.
- Added project documentation structure.
- Added test and automation directories.
- Added GitHub Actions workflow structure.

#### AI Agent

- Defined enterprise AI agent architecture.
- Defined supported AI intents:
  - Case summary
  - Case classification
  - Sentiment analysis
  - Customer profile
  - Customer case history
  - Knowledge search
  - Knowledge recommendation
  - Customer response generation
  - Order status
  - Task creation
  - Case escalation
  - General questions
- Defined agent lifecycle:
  - Request intake
  - Intent detection
  - Context resolution
  - Tool selection
  - Parameter extraction
  - Validation
  - Authorization
  - Risk assessment
  - User confirmation
  - Tool execution
  - Result validation
  - RAG retrieval
  - Response generation
  - Audit logging

#### AI Tool Calling

- Defined centralized AI tool registry.
- Defined tool metadata and contracts.
- Defined tool categories.
- Defined tool risk classification.
- Defined input and output validation.
- Defined authorization controls.
- Defined human confirmation for write operations.
- Defined tool execution and error handling.
- Defined tool audit requirements.
- Defined multi-tool orchestration approach.

#### RAG

- Defined RAG architecture.
- Defined document ingestion pipeline.
- Defined document parsing and chunking.
- Defined embedding and indexing strategy.
- Defined semantic, keyword, vector and hybrid retrieval.
- Defined metadata filtering.
- Defined authorization-aware retrieval.
- Defined document-level access control.
- Defined citation requirements.
- Defined insufficient-context handling.
- Defined RAG evaluation approach.

#### Security

- Defined Salesforce authentication and authorization model.
- Defined CRUD/FLS enforcement.
- Defined sharing enforcement.
- Defined AI tool allow-listing.
- Defined prompt injection protection.
- Defined indirect prompt injection protection.
- Defined sensitive-data minimization.
- Defined secret-management strategy.
- Defined Named Credential and External Credential usage.
- Defined API security controls.
- Defined AI audit logging.
- Defined fail-closed security behavior.

#### Integration

- Defined enterprise REST API standards.
- Defined API versioning strategy.
- Defined authentication and authorization standards.
- Defined request/response contracts.
- Defined idempotency requirements.
- Defined timeout and retry strategy.
- Defined circuit-breaker approach.
- Defined correlation ID strategy.
- Defined integration error model.
- Defined Salesforce-to-external-system integration architecture.

#### Testing

- Defined enterprise testing pyramid.
- Defined Apex unit-testing strategy.
- Defined LWC testing strategy.
- Defined REST/API testing.
- Defined integration testing.
- Defined AI agent evaluation.
- Defined tool-calling evaluation.
- Defined RAG evaluation.
- Defined prompt-injection testing.
- Defined security testing.
- Defined performance and resilience testing.
- Defined regression testing.
- Defined UAT and production smoke testing.
- Defined test evidence requirements.

#### DevSecOps

- Added CI/CD architecture.
- Added development deployment workflow.
- Added UAT deployment workflow.
- Defined Salesforce validation and deployment gates.
- Defined static analysis requirements.
- Defined security scanning requirements.
- Defined AI evaluation gates.
- Defined release approval process.
- Defined rollback strategy.
- Defined environment separation.

#### Production Support

- Defined L1/L2/L3 support model.
- Defined incident management process.
- Defined P1-P4 severity model.
- Defined AI-specific production monitoring.
- Defined RAG monitoring.
- Defined integration monitoring.
- Defined Salesforce monitoring.
- Defined production smoke testing.
- Defined rollback and kill-switch strategy.
- Defined root-cause-analysis process.
- Defined production support KPIs and SLOs.

### Scripts

Added:

```text
scripts/
├── production-smoke-test.ps1
├── run-regression.ps1
└── security-scan.ps1
```

The scripts provide initial automation for:

- Production smoke validation.
- Salesforce regression testing.
- npm test execution.
- Security and secret scanning.
- Salesforce static analysis.
- npm dependency vulnerability scanning.

### GitHub Actions

Added:

```text
.github/
└── workflows/
    ├── deploy-dev.yml
    └── deploy-uat.yml
```

The workflows establish the initial CI/CD deployment foundation for:

- Development deployments.
- UAT deployments.
- Salesforce authentication.
- Salesforce validation.
- Automated Apex testing.
- Static analysis.
- Environment-specific deployment controls.

---

## Release Versioning

The project follows Semantic Versioning:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.0.0
```

### MAJOR

Used for breaking architectural, API, data-model, or compatibility changes.

Example:

```text
1.0.0 → 2.0.0
```

### MINOR

Used when adding backward-compatible functionality.

Example:

```text
1.0.0 → 1.1.0
```

### PATCH

Used for backward-compatible bug fixes, documentation corrections, and minor improvements.

Example:

```text
1.1.0 → 1.1.1
```

---

## Change Categories

Changes should be categorized using the following sections:

- `Added` — New functionality.
- `Changed` — Changes to existing functionality.
- `Deprecated` — Functionality that will be removed.
- `Removed` — Removed functionality.
- `Fixed` — Bug fixes.
- `Security` — Security-related changes.
- `Documentation` — Documentation-only changes.
- `Infrastructure` — CI/CD, deployment, and infrastructure changes.
- `Testing` — Test framework, test cases, and automation changes.

---

## Release Checklist

Before creating a production release, verify:

- [ ] Business requirements updated.
- [ ] Technical design updated.
- [ ] Architecture documentation updated.
- [ ] Security review completed.
- [ ] Apex tests passed.
- [ ] LWC tests passed.
- [ ] Integration tests passed.
- [ ] AI evaluation passed.
- [ ] RAG evaluation passed.
- [ ] Security scans passed.
- [ ] Regression suite passed.
- [ ] UAT completed.
- [ ] Production deployment approved.
- [ ] Production smoke tests passed.
- [ ] Release notes updated.
- [ ] Rollback plan confirmed.
- [ ] Production monitoring enabled.

---

## Change Management

All production changes should follow the controlled release process:

```text
Requirement
    ↓
Design
    ↓
Development
    ↓
Code Review
    ↓
Unit Testing
    ↓
Security Testing
    ↓
Integration Testing
    ↓
AI / RAG Evaluation
    ↓
Regression Testing
    ↓
UAT
    ↓
Release Approval
    ↓
Production Deployment
    ↓
Production Smoke Test
    ↓
Monitoring
```

Production changes should be traceable to:

```text
Business Requirement
        ↓
User Story / Issue
        ↓
Git Commit
        ↓
Pull Request
        ↓
Test Evidence
        ↓
Release
        ↓
Production Deployment
```

---

## Future Releases

Planned future releases may include:

### 0.2.0

- Implement Salesforce AI Tool Registry.
- Implement Apex tool contracts.
- Implement tool authorization service.
- Implement AI orchestration service.
- Implement initial LWC AI assistant UI.
- Implement structured AI response contracts.
- Add Apex unit tests.

### 0.3.0

- Implement RAG ingestion pipeline.
- Implement vector/hybrid retrieval.
- Implement authorization-aware RAG filtering.
- Add knowledge citations.
- Add RAG evaluation automation.

### 0.4.0

- Implement external AI/LLM integration.
- Implement Named Credential-based callouts.
- Implement integration retry and error handling.
- Add integration mocks and tests.

### 0.5.0

- Implement enterprise security controls.
- Implement AI safety and prompt-injection controls.
- Implement audit logging.
- Implement AI evaluation CI gates.

### 1.0.0

Target production-ready portfolio release containing:

- Salesforce AI Assistant.
- AI Agent orchestration.
- Tool calling.
- RAG.
- Enterprise integrations.
- Security controls.
- Automated testing.
- AI evaluation.
- CI/CD.
- DevSecOps.
- Production monitoring.
- Production support procedures.

---

## Unreleased Change Log