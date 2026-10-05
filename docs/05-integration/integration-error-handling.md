# Integration Error Handling

## 1. Document Purpose

This document defines the enterprise integration error-handling strategy for the **Salesforce Enterprise AI Tool & Customer Service Assistant**.

The objective is to ensure that integration failures are:

- Detected consistently.
- Classified correctly.
- Logged securely.
- Correlated across systems.
- Retried only when appropriate.
- Prevented from causing duplicate business transactions.
- Presented to users with safe and meaningful messages.
- Escalated when required.
- Recoverable through controlled operational procedures.

The strategy applies to:

- Salesforce Apex.
- REST APIs.
- AI/LLM providers.
- RAG services.
- Customer APIs.
- Order APIs.
- CRM APIs.
- API gateways.
- Named Credentials.
- External Credentials.
- Synchronous integrations.
- Asynchronous integrations.
- Platform Events.
- Queueable Apex.
- Scheduled processing.

---

# 2. Core Principle

The application must distinguish between:

```text
Business Error
Technical Error
Authentication Error
Authorization Error
Validation Error
Timeout
Rate Limit
Transient Error
Permanent Error
AI Error
Security Error
```

Not every error should be retried.

The core principle is:

> **Retry only when the failure is potentially recoverable and retrying will not create an unsafe or duplicate business operation.**

---

# 3. Error Handling Architecture

```text
┌───────────────────────────────────────────┐
│ Salesforce LWC / API Consumer             │
└───────────────────┬───────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────┐
│ Apex Controller / REST Resource            │
└───────────────────┬───────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────┐
│ AI Orchestrator / Integration Service      │
└───────────────────┬───────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────┐
│ Tool / API Adapter                         │
└───────────────────┬───────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────┐
│ Named Credential / External Credential     │
└───────────────────┬───────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────┐
│ API Gateway / External Service             │
└───────────────────────────────────────────┘

                    │
                    ▼
          Error Classification
                    │
       ┌────────────┼────────────┐
       ▼            ▼            ▼
    Retry        Reject       Escalate
       │            │            │
       └────────────┼────────────┘
                    ▼
              Audit / Logging
                    │
                    ▼
              Monitoring
```

---

# 4. Error Handling Layers

Errors should be handled at the appropriate layer.

```text
Layer 1  → Input Validation
Layer 2  → Authentication
Layer 3  → Authorization
Layer 4  → API Communication
Layer 5  → Response Validation
Layer 6  → Business Validation
Layer 7  → AI Safety / Validation
Layer 8  → Retry / Recovery
Layer 9  → Logging / Audit
Layer 10 → Monitoring / Alerting
```

A lower layer should not expose internal implementation details to the end user.

---

# 5. Standard Error Model

All integration errors should be normalized into a common internal structure.

Example:

```json
{
  "errorCode": "EXT_API_TIMEOUT",
  "category": "TECHNICAL",
  "message": "The external service did not respond within the configured timeout.",
  "retryable": true,
  "severity": "HIGH",
  "httpStatus": 504,
  "correlationId": "CORR-20261005-000123",
  "source": "CustomerAPI",
  "operation": "GET_CUSTOMER",
  "timestamp": "2026-10-05T10:30:00Z"
}
```

---

# 6. Error Contract

Recommended internal error contract:

```text
IntegrationError
├── errorCode
├── category
├── severity
├── message
├── userMessage
├── retryable
├── httpStatus
├── externalStatus
├── externalErrorCode
├── correlationId
├── operation
├── sourceSystem
├── timestamp
└── details
```

Sensitive information must not be exposed in `details`.

---

# 7. Error Categories

## 7.1 Validation Error

The request is invalid.

Examples:

```text
Missing customer ID
Invalid order ID
Invalid date
Unsupported operation
Malformed JSON
Invalid field value
```

Typical response:

```text
HTTP 400
```

Retry:

```text
NO
```

---

# 8. Authentication Error

Examples:

```text
Invalid OAuth client
Expired token
Invalid API key
JWT validation failure
Certificate failure
```

Typical responses:

```text
401 Unauthorized
```

Retry:

```text
NO
```

unless the authentication framework can safely refresh the token automatically.

---

# 9. Authorization Error

Example:

```text
403 Forbidden
```

Possible causes:

```text
Insufficient permission
Invalid scope
Incorrect principal
Business authorization failure
```

Retry:

```text
NO
```

The issue normally requires authorization remediation.

---

# 10. Not Found

Example:

```text
404 Not Found
```

Possible meaning:

```text
Customer does not exist
Order does not exist
Endpoint does not exist
Resource has been removed
```

Classification depends on the operation.

For a missing customer:

```text
Permanent business condition
```

Retry:

```text
NO
```

For an unexpectedly missing API endpoint:

```text
Technical configuration issue
```

Retry:

```text
NO
```

and escalate.

---

# 11. Conflict

Example:

```text
409 Conflict
```

Possible causes:

```text
Duplicate transaction
Concurrent update
Resource state conflict
Idempotency conflict
```

Retry should depend on the business operation.

---

# 12. Rate Limiting

Typical response:

```text
429 Too Many Requests
```

The external service may provide:

```text
Retry-After
```

The application should respect it where appropriate.

Example:

```text
429
  ↓
Check Retry-After
  ↓
Wait
  ↓
Retry
```

Do not perform rapid repeated retries.

---

# 13. Server Errors

Typical responses:

```text
500
502
503
504
```

These may represent transient failures.

Potential actions:

```text
Retry
Circuit breaker
Fallback
Queue for later
Return controlled error
Alert
```

The correct action depends on the operation.

---

# 14. Timeout Handling

Timeouts should be explicitly configured.

Example:

```text
Connect Timeout
Read Timeout
Overall Request Timeout
```

Conceptual flow:

```text
Salesforce
    │
    ▼
External API
    │
    X
Timeout
    │
    ▼
Integration Error Handler
```

The user should receive:

> The requested service is temporarily unavailable. Please try again later.

Do not expose internal timeout configuration unless appropriate.

---

# 15. Retry Classification

A practical classification:

| Error | Retry |
|---|---|
| 400 | No |
| 401 | Conditional |
| 403 | No |
| 404 | Usually no |
| 409 | Conditional |
| 429 | Yes, controlled |
| 500 | Usually yes |
| 502 | Usually yes |
| 503 | Usually yes |
| 504 | Usually yes |
| Timeout | Usually yes |
| Validation | No |
| Security violation | No |
| Prompt injection | No |
| Invalid AI output | Conditional |
| Business rule failure | No |

---

# 16. Retry Policy

Use bounded retries.

Example:

```text
Attempt 1
   ↓
Failure
   ↓
Wait
   ↓
Attempt 2
   ↓
Failure
   ↓
Wait
   ↓
Attempt 3
   ↓
Failure
   ↓
Stop
```

Never retry indefinitely.

---

# 17. Exponential Backoff

Recommended pattern:

```text
Retry 1 → 1 second
Retry 2 → 2 seconds
Retry 3 → 4 seconds
```

Production values should be configurable.

Add jitter where appropriate to avoid synchronized retry storms.

---

# 18. Retry Configuration

Store non-secret retry configuration centrally.

Example:

```json
{
  "maxAttempts": 3,
  "initialDelayMs": 1000,
  "maxDelayMs": 10000,
  "backoffMultiplier": 2,
  "jitter": true
}
```

The actual values should be tuned based on the external service's SLA and rate limits.

---

# 19. Do Not Retry Business Writes Blindly

Consider:

```http
POST /orders
```

If Salesforce sends the request and receives a timeout, the external system may have successfully created the order even though Salesforce did not receive the response.

Blind retry could create:

```text
Order 1001
Order 1002
```

instead of one order.

Therefore:

> **Retries for non-idempotent operations require idempotency protection or reconciliation.**

---

# 20. Idempotency

For write operations, generate an idempotency key.

Example:

```text
Idempotency-Key:
ORD-1001-REQUEST-ABC123
```

The external service should treat repeated requests with the same key as the same logical transaction.

---

# 21. Idempotent Integration Flow

```text
Salesforce
    │
    ▼
Generate Idempotency Key
    │
    ▼
POST External API
    │
    X
Timeout
    │
    ▼
Retry Same Idempotency Key
    │
    ▼
External API
    │
    ▼
Original Transaction Result
```

Never generate a new business transaction ID for a retry unless the API contract explicitly requires it.

---

# 22. Correlation ID

Every integration transaction should have a correlation ID.

Example:

```text
CORR-20261005-000123
```

The same ID should be propagated where supported:

```text
Salesforce
   │
   ├── Correlation ID
   ▼
API Gateway
   │
   ├── Correlation ID
   ▼
External API
   │
   ├── Correlation ID
   ▼
Logging / Monitoring
```

---

# 23. Correlation Headers

A standard header can be used:

```http
X-Correlation-Id: CORR-20261005-000123
```

For systems using another enterprise tracing standard, use the organization's approved distributed-tracing mechanism.

---

# 24. Error Logging

Log enough information to diagnose the problem.

Recommended fields:

```text
Correlation ID
Transaction ID
Timestamp
User / Integration Context
Source System
Target System
Operation
Endpoint name
HTTP status
External error code
Error category
Retry attempt
Duration
Outcome
```

Do not log:

```text
Passwords
API keys
OAuth tokens
Private keys
Full authorization headers
Sensitive customer data
Full prompts containing restricted information
```

---

# 25. Sanitized Logging

Bad:

```text
Authorization: Bearer eyJhbGciOi...
```

Good:

```text
Authentication: OAuth
Credential: NC_CUSTOMER_API
Result: Authentication failure
```

---

# 26. Error Logging Example

```json
{
  "timestamp": "2026-10-05T10:35:00Z",
  "correlationId": "CORR-12345",
  "source": "Salesforce",
  "target": "CustomerAPI",
  "operation": "GET_CUSTOMER",
  "errorCode": "EXT_API_TIMEOUT",
  "category": "TECHNICAL",
  "severity": "HIGH",
  "retryable": true,
  "attempt": 2,
  "durationMs": 5000
}
```

---

# 27. User-Facing Errors

Internal error:

```text
EXT_API_TIMEOUT
Connection timed out after 5000ms.
```

User-facing message:

```text
The customer service is temporarily unavailable.
Please try again shortly.
```

The user should not see:

```text
NullPointerException
```

or:

```text
System.CalloutException: Read timed out
```

---

# 28. Error Message Separation

Maintain three layers:

```text
Technical Error
       │
       ▼
Operational Error
       │
       ▼
User-Friendly Message
```

Example:

```text
Technical:
HTTP 503 from CRM API

Operational:
CRM service unavailable

User:
Customer information is temporarily unavailable.
```

---

# 29. Salesforce Apex Exception Strategy

Use meaningful custom exceptions.

Example:

```apex
public class IntegrationException extends Exception {}
public class AuthenticationException extends IntegrationException {}
public class AuthorizationException extends IntegrationException {}
public class ValidationException extends IntegrationException {}
public class TimeoutException extends IntegrationException {}
public class RetryableIntegrationException extends IntegrationException {}
```

The hierarchy should remain simple enough to maintain.

---

# 30. Central Error Handler

Recommended architecture:

```text
Apex Service
      │
      ▼
Exception
      │
      ▼
Integration Error Handler
      │
      ├── Classify
      ├── Log
      ├── Retry
      ├── Transform
      └── Escalate
```

Suggested classes:

```text
force-app/main/default/classes/
├── IntegrationErrorHandler.cls
├── IntegrationError.cls
├── IntegrationException.cls
├── RetryPolicyService.cls
├── CorrelationIdService.cls
├── IntegrationLogger.cls
├── ErrorResponseMapper.cls
└── CircuitBreakerService.cls
```

---

# 31. REST API Error Contract

External REST APIs should ideally return a consistent structure.

Example:

```json
{
  "error": {
    "code": "CUSTOMER_NOT_FOUND",
    "message": "Customer was not found.",
    "correlationId": "CORR-12345"
  }
}
```

Do not expose stack traces.

---

# 32. HTTP Status Mapping

Recommended mapping:

| HTTP | Meaning | Application Action |
|---|---|---|
| 400 | Invalid request | Reject |
| 401 | Authentication failure | Refresh/reject |
| 403 | Authorization failure | Reject |
| 404 | Resource missing | Business handling |
| 409 | Conflict | Reconcile/conditional retry |
| 422 | Business validation | Reject |
| 429 | Rate limit | Backoff |
| 500 | Server error | Retry |
| 502 | Gateway error | Retry |
| 503 | Service unavailable | Retry |
| 504 | Gateway timeout | Retry/reconcile |

---

# 33. Circuit Breaker

A circuit breaker protects Salesforce from repeatedly calling an unhealthy external service.

States:

```text
CLOSED
   │
   │ failures exceed threshold
   ▼
OPEN
   │
   │ wait period
   ▼
HALF-OPEN
   │
   ├── success → CLOSED
   │
   └── failure → OPEN
```

---

# 34. Circuit Breaker Example

```text
Customer API

Failures:
1
2
3
4
5

Threshold reached

        ↓

Circuit OPEN

        ↓

Stop sending requests

        ↓

Recovery interval

        ↓

Test request

        ↓

Success → CLOSED
```

---

# 35. Fallback

For AI services:

```text
Primary LLM
     │
     X
Failure
     │
     ▼
Fallback LLM
```

For knowledge search:

```text
Primary RAG
    │
    X
Failure
    │
    ▼
Keyword Search / Salesforce Knowledge
```

Fallbacks must not bypass security controls.

---

# 36. Graceful Degradation

The application should continue providing useful functionality when a non-critical integration fails.

Example:

```text
AI Summary unavailable
        │
        ▼
Display original Case information
```

Do not allow an optional AI capability to break core Salesforce functionality unnecessarily.

---

# 37. AI/LLM Errors

Possible AI failures:

```text
Model unavailable
Rate limit
Timeout
Invalid response
Malformed JSON
Tool call failure
Context limit exceeded
Safety refusal
Hallucinated output
Low confidence
Provider outage
```

These require AI-specific handling.

---

# 38. Invalid Structured AI Output

Expected:

```json
{
  "classification": "HIGH",
  "confidence": 0.94
}
```

Actual:

```text
I think this case should probably be HIGH priority.
```

The application should not blindly parse this as trusted structured data.

Flow:

```text
LLM Response
     │
     ▼
Schema Validation
     │
     X
Invalid
     │
     ▼
Retry / Repair / Reject
```

---

# 39. AI Tool-Calling Failure

Example:

```text
LLM
 │
 ▼
getCustomer()
 │
 X
API timeout
```

The agent should receive a controlled tool result:

```json
{
  "success": false,
  "errorCode": "CUSTOMER_API_TIMEOUT",
  "retryable": true
}
```

It should not receive internal stack traces or credentials.

---

# 40. Tool Execution Errors

Tool execution should follow:

```text
Tool Request
    │
    ▼
Validate Input
    │
    ▼
Authorize
    │
    ▼
Execute
    │
    ▼
Validate Result
    │
    ▼
Return Safe Result
```

Failures must stop unsafe execution.

---

# 41. RAG Errors

Potential failures:

```text
Search service unavailable
Embedding failure
Index unavailable
No results
Unauthorized documents
Stale index
Malformed document
Retrieval timeout
```

No-result is not necessarily a technical error.

It may be:

```text
NO_RELEVANT_KNOWLEDGE
```

The AI should not fabricate an answer.

---

# 42. RAG No-Result Handling

```text
User Question
     │
     ▼
RAG Search
     │
     ▼
No authorized relevant documents
     │
     ▼
Do not hallucinate
     │
     ▼
Return:
"I could not find sufficient approved information..."
```

---

# 43. RAG Authorization Failure

If a document exists but the user is not authorized:

```text
Document Found
      │
      ▼
Authorization Check
      │
      X
Access Denied
```

The application should not reveal:

- Document title.
- Document ID.
- Snippet.
- Metadata.
- Existence of restricted information.

The correct result may simply be:

```text
NO_AUTHORIZED_CONTEXT
```

---

# 44. Prompt Injection Error

If retrieved content contains malicious instructions:

```text
RAG Document
     │
     ▼
Prompt Injection Detection
     │
     X
Suspicious content
     │
     ▼
Quarantine / Ignore / Reject
```

Retrieved content must never override system or application instructions.

---

# 45. Security Errors

Security violations include:

```text
Unauthorized tool
Unauthorized record
Unauthorized document
Prompt injection
Credential exposure attempt
Data exfiltration attempt
Privilege escalation
```

Security errors should generally be:

```text
No retry
High priority logging
Security monitoring
Possible alert
```

---

# 46. Async Processing

For long-running integrations:

```text
User
 │
 ▼
Create Request
 │
 ▼
Queueable / Platform Event
 │
 ▼
External API
 │
 ▼
Process Result
 │
 ▼
Update Salesforce
```

The user does not need to wait for the external operation.

---

# 47. Async Failure Handling

```text
Queue Job
   │
   ▼
External Call
   │
   X
Temporary Failure
   │
   ▼
Retry Queue
   │
   ▼
Retry
   │
   ├── Success
   │
   └── Failure
         │
         ▼
      Dead Letter
```

---

# 48. Dead-Letter Processing

Messages that cannot be processed successfully should be placed into a controlled failure state.

Example:

```text
FAILED
  │
  ▼
RETRY_EXHAUSTED
  │
  ▼
DEAD_LETTER
  │
  ▼
Operations Review
```

The dead-letter record should contain:

```text
Correlation ID
Transaction ID
Error Code
Failure Reason
Retry Count
Timestamp
Payload Reference
Processing Status
```

Sensitive payload data should not be stored unnecessarily.

---

# 49. Replay

Operations should be able to replay eligible failures.

Example:

```text
Dead Letter
    │
    ▼
Validate Cause Resolved
    │
    ▼
Replay
    │
    ▼
Original Processing
```

Replay must preserve idempotency.

---

# 50. Error State Model

Recommended state model:

```text
RECEIVED
   ↓
PROCESSING
   ↓
SUCCESS
```

Failure path:

```text
PROCESSING
   ↓
FAILED
   ↓
RETRY_PENDING
   ↓
RETRYING
   ↓
SUCCESS
```

Permanent failure:

```text
RETRYING
   ↓
RETRY_EXHAUSTED
   ↓
DEAD_LETTER
```

---

# 51. Integration Transaction State

A transaction may maintain:

```text
transactionId
correlationId
status
attemptCount
lastErrorCode
lastErrorTimestamp
```

Example:

```json
{
  "transactionId": "TX-1001",
  "correlationId": "CORR-1001",
  "status": "RETRY_PENDING",
  "attemptCount": 2,
  "lastErrorCode": "EXT_API_TIMEOUT"
}
```

---

# 52. Error Persistence

For important asynchronous transactions, persist operational state.

Possible Salesforce mechanisms include:

```text
Custom Object
Platform Event
Platform Event + persistent audit record
External monitoring system
```

Example custom object:

```text
Integration_Error__c
```

Potential fields:

```text
Correlation_Id__c
Transaction_Id__c
Source_System__c
Target_System__c
Operation__c
Error_Code__c
Error_Category__c
Severity__c
Retryable__c
Retry_Count__c
Status__c
Occurred_At__c
Resolved_At__c
```

---

# 53. Avoid Storing Sensitive Payloads

Do not automatically store:

```text
Full customer payload
Authentication tokens
Credit card information
Passwords
Private data
Full LLM prompts
Restricted documents
```

Instead store:

```text
Reference ID
Sanitized metadata
Error code
Correlation ID
```

---

# 54. Monitoring

Monitor:

```text
Error rate
Success rate
Timeout rate
Authentication failures
Authorization failures
429 rate
5xx rate
Average latency
P95 latency
P99 latency
Retry count
Dead-letter count
Circuit-breaker state
AI failure rate
RAG failure rate
```

---

# 55. Alerting

Example alerts:

```text
Authentication failures > threshold
5xx rate > threshold
Timeout rate > threshold
429 rate > threshold
Dead-letter queue > threshold
AI provider unavailable
RAG service unavailable
Credential expiration approaching
```

Thresholds should be environment-specific and tuned against observed baselines.

---

# 56. Error Severity

Recommended severity levels:

### CRITICAL

System-wide or security-impacting failure.

Examples:

```text
Production AI outage
Credential compromise
Mass integration failure
Data security incident
```

### HIGH

Major business capability affected.

```text
Customer API unavailable
Order integration unavailable
Large number of failed transactions
```

### MEDIUM

Limited functionality affected.

```text
Specific API operation failing
Intermittent timeout
Moderate retry increase
```

### LOW

Non-critical issue.

```text
Single recoverable request failure
Minor monitoring issue
```

---

# 57. Operational Response

```text
Error Detected
      │
      ▼
Classify
      │
      ├── Transient
      │      ↓
      │    Retry
      │
      ├── Permanent
      │      ↓
      │    Reject
      │
      ├── Security
      │      ↓
      │    Alert
      │
      └── Unknown
             ↓
          Escalate
```

---

# 58. Error Handling in LWC

LWC should not display raw Apex exceptions.

Bad:

```javascript
this.errorMessage = error.body.message;
```

if the backend message may contain internal information.

Prefer a standardized error response:

```javascript
this.errorMessage =
    error.body?.message ||
    'The request could not be completed.';
```

The backend should already have sanitized the message.

---

# 59. REST API Consumer Error Handling

A consumer should receive:

```json
{
  "success": false,
  "error": {
    "code": "CUSTOMER_API_UNAVAILABLE",
    "message": "Customer information is temporarily unavailable.",
    "correlationId": "CORR-12345"
  }
}
```

The correlation ID allows support teams to investigate the request.

---

# 60. Error Response Standards

Do not expose:

```text
Java stack trace
Apex stack trace
SQL statements
Internal endpoint
Credential information
Class names
Internal IP addresses
Infrastructure details
```

---

# 61. Integration Error Codes

Use stable application-level codes.

Example:

```text
INT_VALIDATION_ERROR
INT_AUTHENTICATION_ERROR
INT_AUTHORIZATION_ERROR
INT_TIMEOUT
INT_RATE_LIMITED
INT_SERVICE_UNAVAILABLE
INT_BAD_RESPONSE
INT_DUPLICATE
INT_CONFLICT
INT_UNKNOWN_ERROR
```

AI-specific:

```text
AI_MODEL_TIMEOUT
AI_MODEL_RATE_LIMITED
AI_INVALID_RESPONSE
AI_TOOL_CALL_FAILED
AI_SAFETY_BLOCK
AI_CONTEXT_LIMIT
```

RAG-specific:

```text
RAG_SEARCH_FAILED
RAG_NO_RESULTS
RAG_UNAUTHORIZED_CONTEXT
RAG_INDEX_UNAVAILABLE
RAG_INVALID_DOCUMENT
```

---

# 62. Error Mapping Service

Recommended class:

```apex
public with sharing class ErrorResponseMapper {

    public static IntegrationError map(
        Integer statusCode,
        String operation
    ) {
        // Map external failures
        // to standardized application errors.

        return null;
    }
}
```

The implementation should map external-specific errors to stable internal codes.

---

# 63. Retry Policy Service

Recommended abstraction:

```apex
public interface RetryPolicy {
    Boolean isRetryable(
        IntegrationError error
    );

    Integer getMaxAttempts();

    Long getDelay(
        Integer attempt
    );
}
```

This prevents retry logic from being duplicated across integrations.

---

# 64. Integration Service

Conceptual architecture:

```apex
public with sharing class CustomerApiService {

    public static CustomerResponse getCustomer(
        String customerId
    ) {
        // Validate
        // Create request
        // Execute callout
        // Validate response
        // Handle error
        // Return normalized response

        return null;
    }
}
```

The service should not expose raw HTTP details to business logic unnecessarily.

---

# 65. Integration Adapter Pattern

Use adapters for external systems:

```text
CustomerService
      │
      ▼
CustomerApiAdapter
      │
      ▼
HTTP Client
      │
      ▼
Named Credential
```

This allows the application to change providers without rewriting business logic.

---

# 66. Standard Integration Flow

```text
Receive Request
      ↓
Validate Input
      ↓
Authorize
      ↓
Create Correlation ID
      ↓
Create Idempotency Key
      ↓
Build Request
      ↓
Execute Callout
      ↓
Classify Response
      ↓
Validate Response
      ↓
Retry if Appropriate
      ↓
Transform Response
      ↓
Audit
      ↓
Return Result
```

---

# 67. Complete Failure Flow

```text
Request
   │
   ▼
Validation
   │
   X
Invalid
   │
   ▼
400 Response
```

or:

```text
Request
   │
   ▼
External API
   │
   X
503
   │
   ▼
Retry Policy
   │
   ▼
Retry
   │
   X
503
   │
   ▼
Retry
   │
   X
503
   │
   ▼
Retry Exhausted
   │
   ▼
Alert
   │
   ▼
Controlled Error
```

---

# 68. Business Error vs Technical Error

This distinction is critical.

Example:

```text
Customer not found
```

is generally a business condition.

```text
Customer API unavailable
```

is a technical condition.

The first should not trigger infrastructure retries.

The second may.

---

# 69. Unknown Errors

Unknown errors must fail safely.

```text
Unknown Error
     │
     ▼
Do not assume retryable
     │
     ▼
Sanitize
     │
     ▼
Log
     │
     ▼
Escalate
```

Never classify an unknown failure as retryable simply because retrying seems convenient.

---

# 70. Security Fail-Closed Principle

If authorization cannot be determined:

```text
Authorization = UNKNOWN
```

should generally result in:

```text
DENY
```

not:

```text
ALLOW
```

This is particularly important for:

- RAG.
- Customer data.
- Financial data.
- AI tool execution.
- Write operations.

---

# 71. Error Handling and AI Agent

The AI agent should receive structured errors.

Example:

```json
{
  "tool": "getCustomer",
  "success": false,
  "error": {
    "code": "CUSTOMER_API_TIMEOUT",
    "retryable": true
  }
}
```

The agent may then:

```text
Retry
Ask user
Use fallback
Explain limitation
Stop
```

The LLM must not determine whether a security failure should be bypassed.

---

# 72. Human-in-the-Loop

For high-risk failures:

```text
Integration Failure
      │
      ▼
Business Impact Assessment
      │
      ▼
Human Review
      │
      ├── Retry
      ├── Cancel
      └── Reprocess
```

Examples:

```text
Order creation
Financial transaction
Customer status change
Case escalation
```

---

# 73. Error Handling and Transactions

Salesforce database changes and external API calls require careful transaction design.

Example:

```text
Update Salesforce
      ↓
Call External API
      X
Failure
```

The application must determine whether the Salesforce update should:

- Roll back.
- Remain pending.
- Be marked failed.
- Be processed asynchronously.

Do not assume a distributed transaction exists across Salesforce and external APIs.

---

# 74. Saga / Compensation Pattern

For multi-step workflows:

```text
Step 1 → Create Customer
Step 2 → Create Order
Step 3 → Create Case
```

If Step 3 fails:

```text
Step 1 ✓
Step 2 ✓
Step 3 ✗
```

The system may need:

```text
Compensation
```

rather than trying to roll back all external systems automatically.

---

# 75. Example Compensation

```text
Create Order
    │
    ▼
Create Customer
    │
    ▼
Failure
    │
    ▼
Compensation Action
    │
    ▼
Cancel / Mark Pending
```

Compensation logic must be explicitly designed per business process.

---

# 76. Integration Runbook

For production failures:

```text
1. Obtain correlation ID
2. Identify source system
3. Identify target system
4. Identify operation
5. Check HTTP status
6. Check external service health
7. Check authentication
8. Check authorization
9. Check rate limits
10. Check recent deployments
11. Check retry count
12. Check circuit breaker
13. Determine recovery action
14. Replay if safe
15. Document resolution
```

---

# 77. Production Incident Example

### Problem

Customer lookup returns errors.

### Investigation

```text
Correlation ID
    ↓
Salesforce logs
    ↓
Customer API
    ↓
HTTP 503
    ↓
Retry exhausted
```

### Action

```text
Check external API health
      ↓
Confirm outage
      ↓
Open incident
      ↓
Circuit breaker
      ↓
Enable graceful degradation
      ↓
Monitor recovery
```

---

# 78. Post-Incident Review

After significant incidents document:

```text
Incident ID
Start time
End time
Duration
Impact
Root cause
Contributing factors
Detection method
Recovery
Customer impact
Data impact
Corrective actions
Preventive actions
Owner
Due date
```

---

# 79. Metrics

Recommended integration KPIs:

```text
Availability
Success Rate
Error Rate
Retry Rate
Timeout Rate
5xx Rate
429 Rate
Mean Latency
P95 Latency
P99 Latency
Dead-Letter Count
Mean Time To Detect
Mean Time To Recover
```

AI-specific:

```text
AI Error Rate
Tool Failure Rate
RAG Failure Rate
LLM Timeout Rate
AI Fallback Rate
AI Invalid Output Rate
```

---

# 80. Recommended Error Dashboard

```text
Integration Health
──────────────────────────────

Success Rate           99.2%
Error Rate              0.8%
Timeout Rate            0.3%
429 Rate                0.1%
Retry Rate              0.5%
Dead Letters              12

Customer API            Healthy
Order API               Healthy
CRM API                 Degraded
LLM Provider            Healthy
RAG Service             Healthy
```

---

# 81. Error Handling Test Strategy

Test at least:

```text
[ ] 400
[ ] 401
[ ] 403
[ ] 404
[ ] 409
[ ] 422
[ ] 429
[ ] 500
[ ] 502
[ ] 503
[ ] 504
[ ] Timeout
[ ] Invalid JSON
[ ] Missing fields
[ ] Unexpected schema
[ ] Credential failure
[ ] Certificate failure
[ ] Rate limit
[ ] Duplicate request
[ ] Idempotency
[ ] Circuit breaker
[ ] Retry exhaustion
[ ] Dead letter
[ ] Replay
```

---

# 82. AI Security Testing

Test:

```text
Prompt injection
Indirect prompt injection
Unauthorized tool selection
Unauthorized record access
Unauthorized RAG document
Sensitive data leakage
Malformed tool arguments
Invalid structured output
Hallucination
Provider failure
Fallback failure
```

---

# 83. Performance Testing

Test:

```text
Normal traffic
Peak traffic
Burst traffic
Concurrent requests
External API latency
429 responses
Retry storms
Large payloads
Large RAG context
LLM latency
```

The objective is to ensure that failure recovery does not itself create an availability problem.

---

# 84. Retry Storm Prevention

Bad architecture:

```text
1000 requests
   │
   ▼
External API failure
   │
   ▼
1000 immediate retries
   │
   ▼
External API overloaded
```

Better:

```text
1000 requests
      │
      ▼
Controlled backoff
      │
      ▼
Rate limiting
      │
      ▼
Circuit breaker
      │
      ▼
Gradual recovery
```

---

# 85. Error Handling Configuration

Recommended configuration areas:

```text
Maximum retry attempts
Initial retry delay
Maximum retry delay
Backoff multiplier
Jitter
Timeout
Circuit breaker threshold
Circuit breaker recovery period
Rate limits
Dead-letter retention
Alert thresholds
```

Keep these configurable rather than hard-coded when operationally appropriate.

---

# 86. Suggested Project Classes

```text
force-app/main/default/classes/
│
├── IntegrationError.cls
├── IntegrationException.cls
├── IntegrationErrorHandler.cls
├── ErrorResponseMapper.cls
├── RetryPolicyService.cls
├── CorrelationIdService.cls
├── IdempotencyService.cls
├── IntegrationLogger.cls
├── CircuitBreakerService.cls
├── IntegrationHealthService.cls
└── DeadLetterService.cls
```

---

# 87. Suggested Custom Metadata

```text
Integration_Config__mdt
```

Possible fields:

```text
Integration_Name__c
Timeout_Ms__c
Max_Retry_Attempts__c
Initial_Backoff_Ms__c
Max_Backoff_Ms__c
Circuit_Breaker_Threshold__c
Circuit_Breaker_Reset_Ms__c
Enabled__c
```

Do not store secrets in this metadata.

---

# 88. Error Handling Architecture for GitHub Portfolio

Recommended documentation structure:

```text
docs/
├── 05-integration/
│   ├── rest-api-design.md
│   ├── named-credentials.md
│   └── integration-error-handling.md
│
├── 03-ai/
│   ├── agent-design.md
│   ├── prompt-design.md
│   ├── tool-calling-design.md
│   └── llm-integration.md
│
└── 04-rag/
    ├── rag-architecture.md
    ├── ingestion-pipeline.md
    ├── security-filtering.md
    └── rag-evaluation-dataset.md
```

---

# 89. Definition of Done

The integration error-handling implementation is complete when:

- [ ] Standard error model is defined.
- [ ] Error categories are defined.
- [ ] HTTP status mapping is defined.
- [ ] Retry policy is implemented.
- [ ] Exponential backoff is implemented where appropriate.
- [ ] Retry limits are enforced.
- [ ] Idempotency is implemented for retryable writes.
- [ ] Correlation IDs are generated and propagated.
- [ ] Errors are sanitized before user display.
- [ ] Sensitive information is excluded from logs.
- [ ] Authentication errors are handled.
- [ ] Authorization errors are handled.
- [ ] Rate limiting is handled.
- [ ] Timeout handling is implemented.
- [ ] Circuit breaker strategy is defined.
- [ ] Fallback strategy is defined.
- [ ] AI-specific errors are handled.
- [ ] RAG-specific errors are handled.
- [ ] Security errors fail closed.
- [ ] Async failures are persisted where required.
- [ ] Dead-letter processing is implemented where required.
- [ ] Replay is controlled and idempotent.
- [ ] Monitoring is implemented.
- [ ] Alerting is configured.
- [ ] Production runbook exists.
- [ ] Integration error tests exist.
- [ ] Security tests exist.
- [ ] Performance tests exist.
- [ ] Operational ownership is documented.

---

# 90. Final Architecture Principle

The final integration error-handling model is:

```text
                  Request
                     │
                     ▼
                Validation
                     │
                     ▼
                Authorization
                     │
                     ▼
              Correlation ID
                     │
                     ▼
              Idempotency
                     │
                     ▼
              External Call
                     │
                     ▼
              Response Check
                     │
          ┌──────────┼──────────┐
          │          │          │
       Success    Retryable   Permanent
          │          │          │
          │          ▼          ▼
          │       Backoff      Reject
          │          │          │
          │          ▼          │
          │       Retry         │
          │          │          │
          └──────────┼──────────┘
                     │
                     ▼
              Result Validation
                     │
                     ▼
               Audit / Log
                     │
                     ▼
             Monitoring / Alert
                     │
                     ▼
             Safe User Response
```

The most important principle is:

> **Integration errors must be treated as controlled system states, not simply exceptions.**

A production-grade integration layer should know **what failed, why it failed, whether it is safe to retry, how to recover, how to prevent duplication, how to correlate the transaction, and how to communicate the failure without exposing sensitive implementation details.**