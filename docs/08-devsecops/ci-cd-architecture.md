# CI/CD Architecture

## 1. Purpose

This document describes the CI/CD architecture for the Salesforce AI Agent application.

The pipeline integrates Salesforce development, automated testing, security validation, AI testing, RAG evaluation, and controlled deployment into a repeatable DevSecOps process.

---

## 2. Architecture Overview

```text
Developer
    |
    v
Feature Branch
    |
    v
Pull Request
    |
    v
GitHub Actions
    |
    +--> Git Validation
    |
    +--> Secret Scan
    |
    +--> Salesforce Project Validation
    |
    +--> Salesforce Code Analyzer
    |
    +--> Salesforce Authentication
    |
    +--> Apex Tests
    |
    +--> Security Tests
    |
    +--> AI Tests
    |
    +--> RAG Evaluation
    |
    v
Quality Gates
    |
    v
Develop / UAT
    |
    v
Production Approval
    |
    v
Deployment Validation
    |
    v
Production Deployment
    |
    v
Smoke Tests
    |
    v
Monitoring
```

---

## 3. Source Control

Git is the source-control system.

The repository contains:

- Salesforce metadata
- Apex
- LWC
- Configuration templates
- Tests
- CI/CD workflows
- Deployment documentation
- Architecture documentation

Secrets must not be stored in the repository.

---

## 4. CI Pipeline

The CI pipeline executes automatically for:

- Pull requests targeting `develop`
- Pull requests targeting `main`
- Pushes to `develop`
- Pushes to `main`

The pipeline performs:

1. Checkout
2. Node.js setup
3. Salesforce CLI installation
4. CLI verification
5. Salesforce project validation
6. Git validation
7. Secret scanning
8. Static analysis
9. Salesforce authentication
10. Apex testing
11. Test artifact collection
12. Security regression testing
13. AI testing
14. RAG evaluation
15. Deployment validation

---

## 5. Continuous Integration

Every pull request should provide automated feedback before merging.

A failed quality gate should prevent the pull request from being merged when branch protection requires successful CI.

---

## 6. Continuous Delivery

Deployment should promote an approved release through controlled environments:

```text
Development
    ↓
QA
    ↓
UAT
    ↓
Production
```

Production deployment requires explicit approval.

---

## 7. Salesforce Deployment

Salesforce metadata is deployed from the version-controlled project.

Example validation:

```bash
sf project deploy validate \
  --source-dir force-app/main/default \
  --target-org ci-org \
  --wait 30
```

The exact CLI syntax should be verified against the CLI version used by CI.

---

## 8. AI/GenAI Pipeline

The pipeline treats AI functionality as software that requires automated validation.

AI testing should cover:

- Prompt behavior
- Tool selection
- Tool authorization
- Input validation
- Output validation
- Error handling
- Timeout handling
- Negative scenarios
- Grounding
- RAG retrieval
- Response quality

---

## 9. Security Integration

Security is integrated into the pipeline rather than performed only before production.

Security controls include:

- Secret scanning
- Static code analysis
- Apex security tests
- CRUD/FLS validation
- Sharing validation
- Authentication validation
- Authorization testing
- Dependency review
- AI security testing

---

## 10. Production Deployment

Production deployment requires:

- Successful CI
- Code review
- Security validation
- UAT approval
- Release approval
- Deployment validation
- Rollback plan

---

## 11. Post-Deployment

After deployment:

- Run smoke tests.
- Validate critical business processes.
- Validate AI functionality.
- Validate integrations.
- Review logs.
- Monitor errors.
- Confirm release health.

---

## 12. Traceability

Each release should be traceable to:

```text
Git Commit
Pull Request
Release Version
CI Run
Test Results
Deployment Validation
Production Deployment
Deployment ID
Approval
```

---

## 13. Failure Handling

If a quality gate fails:

```text
Pipeline Failure
      ↓
Identify Failure
      ↓
Fix Code / Configuration
      ↓
Commit Fix
      ↓
Re-run CI
      ↓
Quality Gates
```

Production incidents should follow the incident-response process documented in:

```text
docs/devsecops/incident-response.md
