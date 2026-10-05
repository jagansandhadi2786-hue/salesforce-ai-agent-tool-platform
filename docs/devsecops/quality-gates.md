# Quality Gates

## 1. Purpose

Quality gates ensure that only code meeting defined engineering, security, testing, and deployment requirements can progress toward production.

---

## 2. Quality Gate Model

```text
Source Control
      ↓
Code Quality
      ↓
Security
      ↓
Apex Tests
      ↓
AI Tests
      ↓
RAG Evaluation
      ↓
Deployment Validation
      ↓
Approval
      ↓
Production
```

---

## 3. Gate 1 — Source Control

Requirements:

- [ ] Valid Git branch
- [ ] Pull request created
- [ ] No unintended changes
- [ ] No merge conflicts
- [ ] Commit message follows team standards
- [ ] `git diff --check` passes

---

## 4. Gate 2 — Project Validation

Requirements:

- [ ] Valid Salesforce project structure
- [ ] `sfdx-project.json` valid
- [ ] Salesforce metadata structure valid
- [ ] Salesforce CLI command succeeds

---

## 5. Gate 3 — Secret Detection

The pipeline must detect obvious credentials and sensitive values.

Examples:

```text
API keys
Client secrets
Access tokens
Passwords
Bearer tokens
Private keys
Salesforce tokens
Azure credentials
```

No production credential should exist in source control.

---

## 6. Gate 4 — Static Analysis

Salesforce Code Analyzer should be executed against:

```text
force-app/main/default
```

Example:

```bash
sf scanner run \
  --target force-app/main/default \
  --format table
```

Critical or organization-defined high-severity findings should block promotion.

---

## 7. Gate 5 — Apex Tests

Apex tests must pass.

Example:

```bash
sf apex run test \
  --target-org ci-org \
  --test-level RunLocalTests \
  --result-format junit \
  --output-dir test-results \
  --wait 30
```

---

## 8. Gate 6 — Security Tests

Security regression tests should validate:

- Authentication
- Authorization
- CRUD
- FLS
- Sharing
- Tool authorization
- Input validation
- Negative scenarios

---

## 9. Gate 7 — AI Tests

AI tests should validate:

- Correct tool selection
- Correct tool arguments
- Invalid arguments
- Unauthorized tools
- Tool failure
- API failure
- Timeout behavior
- Response validation
- Safety controls

---

## 10. Gate 8 — RAG Evaluation

RAG evaluation should measure:

- Retrieval relevance
- Retrieval completeness
- Grounding
- Unsupported claims
- Answer correctness
- Context utilization

A release should not proceed if RAG quality falls below agreed thresholds.

---

## 11. Gate 9 — Deployment Validation

Salesforce deployment validation must succeed before production deployment.

Example:

```bash
sf project deploy validate \
  --source-dir force-app/main/default \
  --target-org production \
  --wait 30
```

---

## 12. Gate 10 — Approval

Production requires appropriate approval.

Approval should confirm:

- CI successful
- Tests successful
- Security checks successful
- UAT completed
- Release notes completed
- Rollback plan available

---

## 13. Blocking vs Non-Blocking Findings

### Blocking

Examples:

- Failed Apex tests
- Critical security findings
- Exposed secrets
- Failed deployment validation
- Failed mandatory AI security tests
- Failed mandatory RAG thresholds

### Non-Blocking

Examples:

- Low-severity static-analysis finding
- Documentation warning
- Technical-debt warning

Non-blocking findings must still be tracked.

---

## 14. Quality Gate Evidence

The pipeline should retain evidence such as:

```text
CI logs
Apex test results
Static-analysis results
Security test results
AI test results
RAG evaluation results
Deployment validation results
```

Test artifacts should be retained using GitHub Actions artifacts.

---

## 15. Quality Gate Ownership

| Gate | Owner |
|---|---|
| Code Quality | Development |
| Apex Testing | Development / QA |
| Security | Security / Engineering |
| AI Testing | AI / Engineering |
| RAG Evaluation | AI / Data Engineering |
| UAT | Business / QA |
| Production Approval | Release Owner |