# Regression Test Suite

## 1. Purpose

The regression suite ensures that changes to the Salesforce Enterprise AI Tool & Customer Service Assistant do not break existing functionality.

The suite covers:

- Salesforce functionality.
- Apex.
- LWC.
- APIs.
- Integrations.
- AI agents.
- Tool calling.
- RAG.
- Security.
- Error handling.
- Critical business journeys.

---

# 2. Regression Philosophy

Every production change should answer:

```text
What changed?
       ↓
What could be affected?
       ↓
Which regression tests cover it?
       ↓
Did those tests pass?
```

---

# 3. Regression Levels

```text
Smoke Regression
       ↓
Core Regression
       ↓
Full Regression
       ↓
Security Regression
       ↓
AI/RAG Regression
       ↓
End-to-End Regression
```

---

# 4. Smoke Suite

The smoke suite validates that the application is operational.

```text
SMOKE-001 Login
SMOKE-002 Load application
SMOKE-003 Open AI assistant
SMOKE-004 Submit basic question
SMOKE-005 Retrieve customer
SMOKE-006 Search knowledge
SMOKE-007 Case summary
SMOKE-008 Validate API connectivity
SMOKE-009 Validate AI provider
SMOKE-010 Validate RAG service
```

Smoke tests should execute quickly after deployment.

---

# 5. Salesforce Regression

```text
SF-REG-001
Create Case

SF-REG-002
Update Case

SF-REG-003
View Case

SF-REG-004
Customer lookup

SF-REG-005
Case history

SF-REG-006
Task creation

SF-REG-007
Case escalation

SF-REG-008
Permission enforcement
```

---

# 6. Apex Regression

Validate:

```text
Apex controllers
Apex services
Tool registry
Tool contracts
AI orchestrator
RAG services
Integration services
Error handlers
Retry services
Security services
```

---

# 7. LWC Regression

Validate:

```text
Chat window
Message rendering
Loading state
Error state
Tool confirmation
Citation rendering
Case summary
Customer information
Escalation workflow
```

---

# 8. API Regression

Critical endpoints:

```text
POST /chat
POST /documents
GET /documents
POST /ask
```

Validate:

```text
Authentication
Authorization
Request validation
Response validation
Error handling
Correlation ID
Rate limiting
```

---

# 9. AI Agent Regression

Core scenarios:

```text
AI-REG-001 Case summary
AI-REG-002 Case classification
AI-REG-003 Sentiment analysis
AI-REG-004 Customer profile
AI-REG-005 Customer case history
AI-REG-006 Knowledge search
AI-REG-007 Knowledge recommendation
AI-REG-008 Customer response
AI-REG-009 Order status
AI-REG-010 Create task
AI-REG-011 Case escalation
AI-REG-012 General question
```

---

# 10. Tool Regression

For every registered tool:

```text
Tool exists
Tool metadata valid
Input schema valid
Authorization valid
Execution valid
Output schema valid
Error handling valid
Audit logging valid
```

---

# 11. RAG Regression

Test:

```text
RAG-REG-001 Relevant document retrieval
RAG-REG-002 No-result behavior
RAG-REG-003 Citation generation
RAG-REG-004 Grounded answer
RAG-REG-005 Unauthorized document exclusion
RAG-REG-006 Expired document exclusion
RAG-REG-007 Unpublished document exclusion
RAG-REG-008 Prompt injection document
RAG-REG-009 RAG outage
RAG-REG-010 Retrieval timeout
```

---

# 12. AI Evaluation Regression

Maintain a fixed evaluation dataset.

Example:

```text
tests/
└── ai-evaluation/
    ├── case-summary.json
    ├── classification.json
    ├── knowledge-search.json
    ├── rag-grounding.json
    ├── tool-selection.json
    ├── safety.json
    └── hallucination.json
```

The same evaluation dataset should be run against controlled releases.

---

# 13. Prompt Regression

Prompt changes can alter model behavior.

Every production prompt change should evaluate:

```text
Intent accuracy
Tool selection
Answer quality
Groundedness
Safety
Hallucination
Citation quality
```

---

# 14. Model Regression

When changing the LLM model:

```text
Old Model
   ↓
Baseline Evaluation

New Model
   ↓
Evaluation

Compare
   ↓
Approve / Reject
```

Do not promote a model solely because it performs better on one metric.

---

# 15. Security Regression

Security regression must include:

```text
SEC-REG-001 CRUD
SEC-REG-002 FLS
SEC-REG-003 Sharing
SEC-REG-004 Tool authorization
SEC-REG-005 RAG authorization
SEC-REG-006 Prompt injection
SEC-REG-007 Sensitive data exposure
SEC-REG-008 Credential protection
SEC-REG-009 API authentication
SEC-REG-010 API authorization
```

---

# 16. Integration Regression

Validate:

```text
Customer API
CRM API
Order API
Enterprise Gateway
AI provider
RAG provider
```

For each:

```text
Success
Timeout
Authentication failure
Authorization failure
Rate limit
5xx
Malformed response
```

---

# 17. Error Regression

Every known production defect should become a regression test.

Example:

```text
INC-1023
Customer API timeout caused duplicate request.

Root Cause:
Missing idempotency key.

Regression:
TC-ERR-010
```

---

# 18. Data Regression

Validate:

```text
Customer data
Case data
Order data
Knowledge data
AI metadata
Audit records
```

Ensure changes do not alter data unexpectedly.

---

# 19. End-to-End Regression

Critical journey:

```text
User
 ↓
LWC
 ↓
Apex
 ↓
AI Orchestrator
 ↓
Tool
 ↓
Salesforce / External API
 ↓
RAG
 ↓
LLM
 ↓
Validation
 ↓
User
```

Validate the complete flow.

---

# 20. Regression Frequency

| Suite | Frequency |
|---|---|
| Smoke | Every deployment |
| Unit | Every commit |
| API | Every deployment |
| Core regression | Every deployment |
| AI evaluation | Every AI-related change |
| RAG evaluation | Every RAG/data/prompt change |
| Security | Every release |
| Full E2E | Release/UAT |
| Performance | Major release |
| Disaster recovery | Periodic |

---

# 21. Change-Based Regression

Use impacted-area analysis.

Example:

```text
Prompt Change
    ↓
AI Regression
RAG Regression
Safety Regression
Tool Selection Regression
```

A Salesforce UI-only change may require:

```text
LWC
E2E
Smoke
```

A Named Credential change may require:

```text
Authentication
Integration
API
Smoke
```

---

# 22. Release Regression

Before production:

```text
Code Validation
     ↓
Unit Tests
     ↓
Integration Tests
     ↓
Security Tests
     ↓
AI Evaluation
     ↓
RAG Evaluation
     ↓
Regression Suite
     ↓
UAT
     ↓
Approval
     ↓
Production
```

---

# 23. Production Smoke Test

Immediately after deployment:

```text
PROD-SMOKE-001 Login
PROD-SMOKE-002 Open Assistant
PROD-SMOKE-003 Submit question
PROD-SMOKE-004 Customer lookup
PROD-SMOKE-005 Knowledge search
PROD-SMOKE-006 Case summary
PROD-SMOKE-007 Verify integration
PROD-SMOKE-008 Verify monitoring
```

---

# 24. Regression Failure Handling

If a critical regression fails:

```text
Regression Failure
       ↓
Stop Promotion
       ↓
Analyze
       ↓
Fix
       ↓
Re-run Failed Test
       ↓
Run Relevant Regression
       ↓
Approve
```

Do not simply mark the test as passed without investigation.

---

# 25. Regression Ownership

| Area | Owner |
|---|---|
| Salesforce | Salesforce Development |
| Apex | Salesforce Development |
| LWC | Salesforce Development |
| API | Integration Team |
| AI | AI Engineering |
| RAG | AI/RAG Engineering |
| Security | Security Team |
| UAT | Business |
| Production Smoke | Release/Support |

---

# 26. Regression Metrics

Track:

```text
Total Tests
Passed
Failed
Blocked
Skipped
Pass Rate
Defect Leakage
Automation Rate
Execution Time
Flaky Test Rate
AI Evaluation Score
RAG Evaluation Score
```

---

# 27. Flaky Tests

Flaky tests must be identified.

A flaky test is not automatically a successful test.

Track:

```text
Test ID
Failure Frequency
Environment
Root Cause
Last Failure
Owner
Resolution
```

---

# 28. Regression Suite Structure

Recommended repository structure:

```text
tests/
├── apex/
├── lwc/
├── api/
├── integration/
├── security/
├── ai-evaluation/
│   ├── case-summary.json
│   ├── classification.json
│   ├── knowledge-search.json
│   ├── rag-grounding.json
│   ├── tool-selection.json
│   ├── safety.json
│   └── hallucination.json
└── e2e/
```

---

# 29. Definition of Done

Regression is complete when:

- [ ] Smoke tests pass.
- [ ] Core regression passes.
- [ ] Critical integration tests pass.
- [ ] Security regression passes.
- [ ] AI regression passes where applicable.
- [ ] RAG regression passes where applicable.
- [ ] No unexplained test failures remain.
- [ ] Evidence is captured.
- [ ] Release approval is obtained.