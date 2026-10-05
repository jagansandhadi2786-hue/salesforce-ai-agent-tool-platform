# Branch Strategy

## 1. Purpose

This document defines the Git branching strategy for the Salesforce AI Agent project.

The strategy provides controlled development, testing, release management, and production deployment.

---

## 2. Branch Structure

```text
main
  |
  +---- develop
          |
          +---- feature/*
          |
          +---- bugfix/*
          |
          +---- hotfix/*
```

---

## 3. Main Branch

`main` represents production-ready code.

Rules:

- Direct pushes should be restricted.
- Pull requests are required.
- CI must pass.
- Required reviewers must approve.
- Production deployment should be controlled.

---

## 4. Develop Branch

`develop` contains integrated development work.

It is used for:

- Integration testing
- QA promotion
- Feature integration
- Pre-release validation

---

## 5. Feature Branches

Feature branches are created from `develop`.

Example:

```text
feature/ai-tool-calling
```

Naming convention:

```text
feature/<short-description>
```

Examples:

```text
feature/case-summarization
feature/rag-search
feature/tool-security
feature/customer-assistant
```

---

## 6. Bugfix Branches

Used for non-production defects.

Example:

```text
bugfix/case-classification-error
```

Naming:

```text
bugfix/<short-description>
```

---

## 7. Hotfix Branches

Used for urgent production issues.

Example:

```text
hotfix/ai-service-timeout
```

Hotfixes require expedited but documented review and testing.

---

## 8. Pull Request Rules

Pull requests should include:

- Description
- Business impact
- Technical changes
- Testing performed
- Security considerations
- Deployment considerations

---

## 9. Branch Protection

Recommended protections for `main`:

- Require pull request
- Require approval
- Require successful CI
- Prevent force pushes
- Prevent branch deletion
- Require branch to be up to date
- Restrict direct pushes

---

## 10. Merge Strategy

Recommended process:

```text
feature/*
    ↓
Pull Request
    ↓
develop
    ↓
QA / UAT
    ↓
Pull Request
    ↓
main
    ↓
Production
```

---

## 11. Commit Standards

Commits should be clear and meaningful.

Examples:

```text
feat: add AI tool contract validation
fix: handle Azure timeout
test: add negative tool authorization tests
security: enforce tool authorization
docs: update deployment strategy
```

---

## 12. Hotfix Flow

```text
main
  ↓
hotfix/*
  ↓
CI
  ↓
Review
  ↓
Production
  ↓
Merge back to develop
```

Hotfixes must be synchronized back into the development branch.

---

## 13. Release Tags

Production releases should use Git tags.

Example:

```text
v1.0.0
v1.1.0
v1.2.0
```

This provides release traceability and simplifies rollback.

---

## 14. Branch Lifecycle

Feature and bugfix branches should be deleted after successful merge unless there is a documented reason to retain them.