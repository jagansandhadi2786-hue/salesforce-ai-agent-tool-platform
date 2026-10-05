# Tool Calling Design

## 1. Purpose

This document defines how the Salesforce AI Agent discovers, selects, validates, authorizes, confirms, executes, and monitors AI tools.

The tool-calling architecture provides a controlled boundary between the LLM and enterprise business operations.

The LLM can recommend a tool, but the application decides whether the tool is valid and permitted.

---

# 2. Core Principle

```text
LLM
 │
 │ proposes
 ▼
Tool Registry
 │
 ▼
Contract Validation
 │
 ▼
Authorization
 │
 ▼
Risk Evaluation
 │
 ▼
Human Confirmation
 │
 ▼
Deterministic Tool Service
 │
 ▼
Salesforce / External System
```

The LLM must never directly execute arbitrary Salesforce or external-system operations.

---

# 3. Tool Categories

Tools are divided into three major categories.

## Read Tools

```text
getCustomerProfile
getCustomerCases
getCaseDetails
getOrderStatus
searchKnowledge
```

## AI Analysis Tools

```text
summarizeCase
classifyCase
analyzeSentiment
recommendKnowledge
generateCustomerResponse
```

## Write Tools

```text
createFollowUpTask
escalateCase
updateCase
sendCustomerCommunication
```

---

# 4. Tool Registry

The Tool Registry is the authoritative list of available tools.

Example:

| Tool | Type | Risk | Confirmation |
|---|---|---|---|
| `getCustomerProfile` | READ | LOW | No |
| `getCustomerCases` | READ | LOW | No |
| `getCaseDetails` | READ | LOW | No |
| `searchKnowledge` | RAG | LOW | No |
| `summarizeCase` | AI | LOW | No |
| `analyzeSentiment` | AI | LOW | No |
| `getOrderStatus` | INTEGRATION | LOW | No |
| `generateCustomerResponse` | AI | MEDIUM | Review |
| `createFollowUpTask` | WRITE | MEDIUM | Yes |
| `escalateCase` | WRITE | HIGH | Yes |

---

# 5. Tool Contract

Every tool must have a formal contract.

Example:

```json
{
  "name": "getOrderStatus",
  "version": "1.0",
  "description": "Returns the current status of an order.",
  "toolType": "INTEGRATION",
  "riskLevel": "LOW",
  "requiresConfirmation": false,
  "requiredPermission": "AI_ORDER_STATUS",
  "inputSchema": {
    "orderId": {
      "type": "string",
      "required": true
    }
  }
}
```

---

# 6. Tool Input Contract

Example:

```json
{
  "orderId": "100045"
}
```

Validation rules:

```text
Required
String
Maximum length
Allowed characters
Business format
Authorization
```

Invalid:

```json
{
  "orderId": null
}
```

The tool must not execute.

---

# 7. Tool Output Contract

Example:

```json
{
  "success": true,
  "orderId": "100045",
  "status": "SHIPPED",
  "expectedDeliveryDate": "2026-10-08"
}
```

The output must conform to the registered schema.

---

# 8. Tool Selection

The agent determines the required tool based on intent.

Example:

```text
User:
"What is the status of order 100045?"

Intent:
ORDER_STATUS

Tool:
getOrderStatus
```

The LLM may propose:

```json
{
  "tool": "getOrderStatus",
  "arguments": {
    "orderId": "100045"
  }
}
```

The application then validates the proposal.

---

# 9. Tool Selection Rules

The agent should:

1. Select only registered tools.
2. Select the minimum tools required.
3. Prefer read operations before write operations.
4. Never select tools outside the user's authorization.
5. Avoid duplicate calls.
6. Respect tool dependencies.
7. Stop when the requested outcome has been achieved.

---

# 10. Invalid Tool Selection

Example:

```text
LLM proposes:

deleteCustomer
```

If the tool does not exist:

```text
Tool Registry:
NOT FOUND
```

Result:

```text
Reject tool call.
```

The application must not dynamically create a tool because the model requested it.

---

# 11. Parameter Extraction

Example:

```text
User:
"Check order 100045."
```

Tool call:

```json
{
  "tool": "getOrderStatus",
  "arguments": {
    "orderId": "100045"
  }
}
```

---

# 12. Parameter Validation

Validation occurs before execution.

```text
LLM Output
   │
   ▼
JSON Validation
   │
   ▼
Schema Validation
   │
   ▼
Business Validation
   │
   ▼
Authorization
```

Example:

```text
orderId required
orderId must not exceed 50 characters
orderId must match supported format
```

---

# 13. Tool Authorization

Authorization must be deterministic.

Example:

```text
User
 │
 ▼
Salesforce Permission
 │
 ▼
Tool Permission
 │
 ▼
Object Permission
 │
 ▼
Field Permission
 │
 ▼
Record Access
```

The LLM cannot override an authorization failure.

---

# 14. Tool Risk Levels

## LOW

Read-only operations.

```text
getCaseDetails
getCustomerProfile
getOrderStatus
searchKnowledge
```

## MEDIUM

Operations that may modify data or create business recommendations.

```text
createFollowUpTask
generateCustomerResponse
```

## HIGH

Business-critical operations.

```text
escalateCase
updateCustomerInformation
sendCustomerCommunication
```

---

# 15. Human Confirmation

Tools marked:

```text
requiresConfirmation = true
```

must not execute immediately.

Example:

```text
User:
"Create a follow-up task."

Agent:
"I can create a follow-up task for Case 00012345
with a due date of October 6, 2026.

Would you like me to create it?"
```

Only explicit confirmation allows execution.

---

# 16. Confirmation Rules

Valid confirmation examples:

```text
Yes
Confirm
Create it
Proceed
Go ahead
```

Ambiguous:

```text
Maybe
Sounds good
Okay...
```

The application should use a controlled confirmation state rather than relying solely on natural-language interpretation.

---

# 17. Confirmation State

Example:

```json
{
  "confirmationId": "CONF-10001",
  "tool": "createFollowUpTask",
  "expiresAt": "2026-10-05T15:30:00Z",
  "status": "PENDING"
}
```

The confirmation should expire after a configured period.

---

# 18. Tool Execution

After all controls pass:

```text
AI Orchestrator
      │
      ▼
Tool Registry
      │
      ▼
Tool Validator
      │
      ▼
Authorization Service
      │
      ▼
Risk Service
      │
      ▼
Confirmation Service
      │
      ▼
Tool Service
```

---

# 19. Salesforce Tool Execution

Example:

```text
createFollowUpTask
        │
        ▼
TaskToolService
        │
        ▼
Task record creation
        │
        ▼
Salesforce
```

The business service should enforce:

- sharing
- CRUD
- FLS
- validation rules
- business rules
- duplicate prevention

---

# 20. External Tool Execution

Example:

```text
getOrderStatus
       │
       ▼
OrderToolService
       │
       ▼
ExternalApiService
       │
       ▼
Named Credential
       │
       ▼
Order Management API
```

The LLM never receives external credentials.

---

# 21. Tool Timeout

Every tool should have a timeout.

Example:

```text
Salesforce read:
3 seconds

External API:
5 seconds

RAG search:
3 seconds
```

Values are illustrative and should be tuned using production measurements.

---

# 22. Retry Policy

Retries should only be performed when safe.

Retryable:

```text
HTTP 429
HTTP 502
HTTP 503
HTTP 504
Network timeout
```

Generally non-retryable:

```text
HTTP 400
HTTP 401
HTTP 403
HTTP 404
Business validation failure
```

Write operations require idempotency protection before automatic retries.

---

# 23. Idempotency

Write tools should support idempotency where practical.

Example:

```text
Idempotency Key:
CONV-10001-TOOL-createFollowUpTask-001
```

If the same request is retried, the system should avoid creating duplicate records.

---

# 24. Tool Result Validation

Example tool response:

```json
{
  "success": true,
  "taskId": "00TXXXXXXXXXXXX",
  "status": "CREATED"
}
```

The result validator checks:

```text
Schema
Data type
Required fields
Business status
Security
Correlation ID
```

---

# 25. Tool Failure

If a tool fails:

```text
Tool Execution
      │
      ▼
Failure
      │
      ├── Retryable → Retry
      │
      ├── Business Error → Explain
      │
      └── System Error → Graceful Failure
```

The agent must never convert a failed tool execution into a successful claim.

---

# 26. Tool Error Example

Bad:

```text
"Your task has been created."
```

when the API failed.

Correct:

```text
"I couldn't create the follow-up task because Salesforce
returned an error. No task was created."
```

---

# 27. Multi-Tool Calls

Example:

```text
User:
"Review the customer's history and recommend whether we should escalate."

Tools:

getCustomerProfile
getCustomerCases
getCaseDetails
analyzeSentiment
searchKnowledge
```

The orchestrator should execute the dependency graph:

```text
getCustomerProfile
       │
getCustomerCases
       │
getCaseDetails
       │
analyzeSentiment
       │
searchKnowledge
       │
       ▼
Escalation Recommendation
```

---

# 28. Tool Dependency Graph

Example:

```text
CASE_ESCALATION
      │
      ├── getCaseDetails
      │
      ├── getCustomerProfile
      │
      ├── getCustomerCases
      │
      ├── analyzeSentiment
      │
      └── searchKnowledge
                │
                ▼
       escalation recommendation
                │
                ▼
          human confirmation
                │
                ▼
          escalateCase
```

---

# 29. Tool Security

Each tool must have:

```text
Tool ID
Tool Version
Owner
Risk Level
Permission
Input Schema
Output Schema
Confirmation Policy
Timeout
Retry Policy
Audit Policy
```

---

# 30. Tool Audit Logging

Recommended fields:

```text
correlationId
conversationId
userId
toolName
toolVersion
inputHash
riskLevel
authorizationResult
confirmationRequired
confirmationResult
executionStatus
latency
errorCode
timestamp
```

Avoid logging sensitive input unnecessarily.

---

# 31. Tool Versioning

Example:

```text
getOrderStatus:v1
getOrderStatus:v2
```

A tool contract change should not silently break existing agent behavior.

Breaking changes should use a new version.

---

# 32. Tool Governance

Before production:

```text
Business Owner Approval
        ↓
Security Review
        ↓
Technical Review
        ↓
Tool Contract Tests
        ↓
AI Evaluation
        ↓
UAT
        ↓
Production Approval
```

---

# 33. Apex Architecture

Recommended classes:

```text
AI_ToolRegistry
AI_ToolContractCatalog
AI_ToolValidator
AI_AuthorizationService
AI_RiskEvaluationService
AI_ConfirmationService
AI_Orchestrator
AI_ResponseValidator
```

Business tools:

```text
CaseToolService
CustomerToolService
KnowledgeToolService
OrderToolService
TaskToolService
EscalationToolService
```

---

# 34. Tool Calling Sequence

```text
User
 │
 ▼
AI Orchestrator
 │
 ▼
Intent Detection
 │
 ▼
Tool Selection
 │
 ▼
Tool Registry
 │
 ▼
Contract Validation
 │
 ▼
Authorization
 │
 ▼
Risk Evaluation
 │
 ├── LOW ──────────────┐
 │                      │
 └── WRITE/HIGH         ▼
                    Confirmation
                         │
                         ▼
                   Tool Execution
                         │
                         ▼
                  Result Validation
                         │
                         ▼
                  LLM Response
                         │
                         ▼
                       User
```

---

# 35. Definition of Done

- [ ] Tool registry implemented
- [ ] Tool contracts defined
- [ ] Input schemas defined
- [ ] Output schemas defined
- [ ] Tool selection implemented
- [ ] Parameter validation implemented
- [ ] Authorization implemented
- [ ] Risk classification implemented
- [ ] Confirmation mechanism implemented
- [ ] Timeout configured
- [ ] Retry policy configured
- [ ] Idempotency implemented for applicable writes
- [ ] Tool result validation implemented
- [ ] Audit logging implemented
- [ ] Tool versioning implemented
- [ ] Negative tests implemented
- [ ] Security tests implemented
- [ ] Production monitoring implemented