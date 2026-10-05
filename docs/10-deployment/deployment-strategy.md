# Deployment Strategy

## 1. Purpose

This document defines the deployment strategy for the Salesforce AI Agent application.

The strategy is designed to support controlled deployments across development, testing, staging, and production environments while maintaining Salesforce metadata quality, security, test coverage, and deployment traceability.

## 2. Deployment Principles

The deployment process follows these principles:

- All production changes must be version controlled.
- Developers should not make unmanaged production changes.
- Pull requests must pass CI quality checks before merge.
- Apex tests must pass before production deployment.
- Salesforce Code Analyzer findings must be reviewed.
- Secrets must never be committed to Git.
- Production deployments require explicit approval.
- Every production release must be traceable to a Git commit or release tag.
- Rollback procedures must be documented before production deployment.

## 3. Environment Strategy

The project uses the following environments:

```text
Developer
   ↓
Development
   ↓
QA / Integration
   ↓
UAT / Staging
   ↓
Production
```

### Development

Used for:

- Feature development
- Apex development
- LWC development
- AI service development
- Integration development
- Unit testing

### QA / Integration

Used for:

- Integration testing
- API testing
- Security testing
- AI tool-calling testing
- Regression testing

### UAT / Staging

Used for:

- Business validation
- End-to-end testing
- Release candidate validation
- Production deployment rehearsal

### Production

Used for:

- Live customer service operations
- Production integrations
- Production AI services
- Monitoring and support

---

## 4. Branching Strategy

Recommended Git branches:

```text
main
│
├── develop
│
├── feature/*
├── bugfix/*
└── hotfix/*
```

### Feature Branch

Example:

```text
feature/ai-tool-calling
```

Used for individual development work.

### Develop

Integration branch for completed development work.

### Main

Production-ready branch.

Only tested and approved changes should reach `main`.

### Hotfix

Used for urgent production fixes.

Example:

```text
hotfix/critical-ai-service-failure
```

---

## 5. Pull Request Process

The recommended workflow is:

```text
Developer
   ↓
Feature Branch
   ↓
Commit
   ↓
Pull Request
   ↓
CI Validation
   ↓
Code Review
   ↓
Merge to Develop
```

CI should validate:

- Git formatting
- Secret scanning
- Salesforce project structure
- Salesforce Code Analyzer
- Apex tests
- Security regression tests
- AI tests
- RAG evaluation

---

## 6. Production Deployment Process

Production deployment follows:

```text
Develop
   ↓
QA
   ↓
UAT
   ↓
Release Candidate
   ↓
Production Approval
   ↓
Deployment Validation
   ↓
Production Deployment
   ↓
Smoke Testing
   ↓
Monitoring
```

Production deployments should be performed using an approved CI/CD process rather than a developer workstation.

---

## 7. Deployment Validation

Before production deployment, validate the Salesforce metadata:

```bash
sf project deploy validate \
  --source-dir force-app/main/default \
  --target-org production \
  --wait 30
```

The exact command should be verified against the Salesforce CLI version used by the project.

---

## 8. Apex Testing

Production deployments must meet the organization's Salesforce testing requirements.

Run local tests:

```bash
sf apex run test \
  --target-org production \
  --test-level RunLocalTests \
  --result-format human \
  --wait 30
```

Critical AI and security test suites should also be executed.

---

## 9. AI-Specific Validation

The release process should validate:

- AI service connectivity
- Prompt configuration
- Tool definitions
- Tool authorization
- Tool input validation
- Tool output validation
- Negative scenarios
- Hallucination controls
- RAG retrieval
- RAG grounding
- Response safety
- Failure handling
- Timeout handling
- API error handling

---

## 10. Production Deployment Approval

Production deployment requires:

- Successful CI pipeline
- Code review approval
- Successful UAT
- Security validation
- Release notes
- Deployment plan
- Rollback plan
- Business approval where required

---

## 11. Post-Deployment Validation

After deployment:

1. Verify Salesforce metadata.
2. Execute smoke tests.
3. Verify Apex functionality.
4. Verify integrations.
5. Verify AI service connectivity.
6. Verify tool calling.
7. Verify RAG functionality.
8. Check application logs.
9. Check integration failures.
10. Monitor production behavior.

---

## 12. Release Traceability

Every production deployment should be associated with:

```text
Release Version
Git Commit
Pull Request
Deployment ID
Deployment Date
Deployment Owner
Approval
Test Results
Rollback Reference
```

Example:

```text
Release: v1.4.0
Commit: abc1234
Environment: Production
Deployment Date: YYYY-MM-DD
Status: Successful
```