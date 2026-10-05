# REST API Design

## 1. Document Purpose

This document defines the REST API architecture, standards, contracts, security controls, error handling, versioning, observability, testing, and operational requirements for the **Salesforce Enterprise AI Tool & Customer Service Assistant**.

The REST integration layer provides controlled communication between:

```text
Salesforce
    │
    ├── LWC
    │
    ├── Apex Controllers
    │
    ├── AI Agent / Orchestrator
    │
    ├── Salesforce Tools
    │
    └── Integration Services
             │
             ▼
       REST APIs
             │
     ┌───────┼────────┐
     ▼       ▼        ▼
   LLM     RAG     Enterprise
 Provider  Service   Systems
```

The API layer must provide:

- Secure communication.
- Stable contracts.
- Strong validation.
- Consistent error handling.
- Idempotent operations.
- Observability.
- Versioning.
- Controlled retries.
- Rate limiting.
- Production-grade resilience.

---

# 2. API Design Principles

The project follows these principles:

```text
API First
Security First
Contract First
Fail Closed
Validate Everything
Never Trust External Input
Idempotency for Writes
Explicit Versioning
Observable by Default
Least Privilege
Backward Compatibility
```

The LLM must never be treated as an API security boundary.

The application determines:

```text
What operation is allowed
Which API can be called
Which parameters are valid
Which user is authorized
What data can be returned
```

---

# 3. Integration Architecture

```text
┌───────────────────────────────────────┐
│ Salesforce Experience                 │
│                                       │
│ LWC / Salesforce UI                   │
└───────────────────┬───────────────────┘
                    │
                    │ Apex
                    ▼
┌───────────────────────────────────────┐
│ Application Layer                     │
│                                       │
│ AI Agent / Orchestrator               │
│ Tool Registry                         │
│ Authorization                         │
│ Validation                            │
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│ Integration Layer                     │
│                                       │
│ REST Client                           │
│ Authentication                        │
│ Timeout / Retry                       │
│ Circuit Breaker                       │
│ Error Mapping                         │
│ Correlation ID                        │
└───────────────────┬───────────────────┘
                    │
          HTTPS / TLS│
                    ▼
        ┌──────────────────────┐
        │ External API /       │
        │ AI / Enterprise      │
        │ Service              │
        └──────────────────────┘
```

---

# 4. API Categories

The application may consume several API categories.

## 4.1 AI APIs

Examples:

```text
POST /v1/chat
POST /v1/generate
POST /v1/embeddings
```

Used for:

- Response generation.
- Classification.
- Summarization.
- Embeddings.

---

## 4.2 RAG APIs

Examples:

```text
POST /v1/search
POST /v1/retrieve
```

Used for:

- Semantic search.
- Hybrid search.
- Knowledge retrieval.

---

## 4.3 Enterprise APIs

Examples:

```text
GET  /v1/customers/{customerId}
GET  /v1/orders/{orderId}
GET  /v1/cases/{caseId}
POST /v1/tasks
```

Used for business operations.

---

## 4.4 Salesforce APIs

Potential APIs include:

```text
Salesforce REST API
Salesforce Composite API
Salesforce Bulk API
Salesforce Connect
Platform Events
Change Data Capture
```

The correct API should be selected according to transaction volume and use case.

---

# 5. REST Resource Design

APIs should represent business resources rather than implementation details.

Good:

```text
/customers
/customers/{customerId}
/cases
/cases/{caseId}
/orders
/orders/{orderId}
```

Avoid:

```text
/getCustomerData
/processCustomer
/doCaseOperation
/runSomething
```

Resource-oriented APIs are easier to understand and maintain.

---

# 6. HTTP Methods

| Method | Purpose | Example |
|---|---|---|
| GET | Retrieve resource | `/cases/500123` |
| POST | Create/process | `/cases` |
| PUT | Replace resource | `/cases/500123` |
| PATCH | Partial update | `/cases/500123` |
| DELETE | Delete resource | `/cases/500123` |

For AI operations:

```text
POST /v1/chat
POST /v1/summarize
POST /v1/classify
POST /v1/search
```

---

# 7. API Versioning

APIs should be explicitly versioned.

Recommended:

```text
/v1/
```

Example:

```text
POST /api/v1/chat
POST /api/v1/search
GET  /api/v1/customers/{customerId}
```

When a breaking change is introduced:

```text
/v2/
```

Example:

```text
POST /api/v2/chat
```

Avoid silently changing the behavior of an existing version.

---

# 8. Backward Compatibility

Non-breaking changes may include:

- Adding optional response fields.
- Adding optional request fields.
- Adding new resources.
- Adding new enum values where clients tolerate them.

Breaking changes include:

- Removing fields.
- Renaming fields.
- Changing data types.
- Changing required fields.
- Changing response semantics.

Breaking changes require a new API version.

---

# 9. Standard Headers

Recommended request headers:

```http
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
X-Correlation-Id: 8b4f6d1c-1234-4567
X-Idempotency-Key: 4d8e7a...
```

Optional:

```http
X-Client-Application: Salesforce-AI-Assistant
X-API-Version: v1
Accept-Language: en
```

---

# 10. Correlation ID

Every integration transaction should have a correlation ID.

Example:

```text
LWC
 │
 │ Correlation ID
 ▼
Apex
 │
 ▼
AI Orchestrator
 │
 ▼
REST Client
 │
 ▼
External API
```

Example:

```text
X-Correlation-Id:
c1e8d4b1-7a10-4e50-9b52-21d3d12a4f22
```

The same ID should be propagated across supported integration boundaries.

---

# 11. Why Correlation IDs Matter

A production incident may involve:

```text
Salesforce
     ↓
AI Agent
     ↓
REST API
     ↓
External Service
     ↓
LLM
```

Without a correlation ID, tracing the transaction becomes difficult.

With a correlation ID:

```text
c1e8d4b1...
```

can be searched across:

- Salesforce logs.
- Integration logs.
- API gateway logs.
- External service logs.
- Monitoring systems.

---

# 12. Request Contract

Example:

```http
POST /api/v1/chat
Content-Type: application/json
X-Correlation-Id: c1e8d4b1-7a10-4e50-9b52-21d3d12a4f22
```

Request:

```json
{
  "conversationId": "CONV-1001",
  "message": "Summarize this customer case",
  "caseId": "500ABC123",
  "language": "en"
}
```

---

# 13. Request Validation

Validate:

- Required fields.
- Data types.
- Maximum lengths.
- Allowed values.
- Object identifiers.
- Date formats.
- Numeric ranges.
- Nested structures.
- Authorization context.

Example:

```json
{
  "language": "en"
}
```

Allowed:

```text
en
```

Invalid:

```text
<script>alert(1)</script>
```

The API must reject invalid input.

---

# 14. Request Size Limits

Requests should have explicit limits.

Example:

```text
Maximum request size:
1 MB
```

For AI prompts:

```text
Maximum user message:
10,000 characters
```

The actual limits should be configurable.

Large documents should normally use:

```text
Document upload
Object storage
Asynchronous processing
```

rather than excessively large synchronous API requests.

---

# 15. Response Contract

Example:

```json
{
  "success": true,
  "requestId": "REQ-10001",
  "correlationId": "c1e8d4b1-7a10-4e50-9b52-21d3d12a4f22",
  "data": {
    "answer": "The case concerns a billing issue."
  },
  "metadata": {
    "model": "configured-model",
    "confidence": 0.94
  }
}
```

---

# 16. Standard Response Envelope

Where appropriate, APIs should use a consistent response structure.

Success:

```json
{
  "success": true,
  "requestId": "REQ-10001",
  "data": {}
}
```

Failure:

```json
{
  "success": false,
  "requestId": "REQ-10001",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid parameters."
  }
}
```

Do not expose:

- Stack traces.
- Internal class names.
- Database credentials.
- Access tokens.
- Secret values.
- Internal infrastructure details.

---

# 17. HTTP Status Codes

Recommended mapping:

| HTTP Code | Meaning |
|---|---|
| 200 | Successful request |
| 201 | Resource created |
| 202 | Accepted for asynchronous processing |
| 204 | Successful request with no response body |
| 400 | Invalid request |
| 401 | Authentication failure |
| 403 | Authorization failure |
| 404 | Resource not found |
| 409 | Conflict |
| 422 | Semantic validation failure |
| 429 | Rate limit exceeded |
| 500 | Internal server error |
| 502 | Upstream service error |
| 503 | Service unavailable |
| 504 | Gateway timeout |

---

# 18. API Error Model

Recommended error:

```json
{
  "success": false,
  "requestId": "REQ-10001",
  "correlationId": "CORR-10001",
  "error": {
    "code": "UPSTREAM_TIMEOUT",
    "message": "The requested service is temporarily unavailable.",
    "retryable": true
  }
}
```

---

# 19. Error Code Standards

Use stable machine-readable codes.

Examples:

```text
VALIDATION_ERROR
AUTHENTICATION_FAILED
AUTHORIZATION_DENIED
RESOURCE_NOT_FOUND
DUPLICATE_REQUEST
RATE_LIMIT_EXCEEDED
UPSTREAM_TIMEOUT
UPSTREAM_UNAVAILABLE
UPSTREAM_BAD_RESPONSE
AI_SERVICE_ERROR
RAG_SERVICE_ERROR
INTERNAL_ERROR
```

Applications should use the error code rather than parsing human-readable messages.

---

# 20. Idempotency

Write operations should support idempotency where duplicate execution would be harmful.

Example:

```http
POST /api/v1/tasks
X-Idempotency-Key: TASK-REQUEST-12345
```

If the same request is submitted twice:

```text
Request 1 → Create Task
Request 2 → Return existing result
```

rather than creating two tasks.

---

# 21. Idempotency Flow

```text
Request
   │
   ▼
Idempotency Key
   │
   ▼
Check Existing Request
   │
 ┌─┴───────────┐
 │             │
Exists       New
 │             │
 ▼             ▼
Return       Execute
Existing     Operation
Result          │
                ▼
             Store Result
```

---

# 22. Retry Policy

Retries should only be used for transient failures.

Potentially retryable:

```text
429
502
503
504
Network timeout
Connection reset
```

Usually not retryable:

```text
400
401
403
404
422
Business validation failure
```

---

# 23. Exponential Backoff

Recommended conceptual strategy:

```text
Attempt 1 → 1 second
Attempt 2 → 2 seconds
Attempt 3 → 4 seconds
```

Include jitter to prevent synchronized retry storms.

Example:

```text
delay = baseDelay × 2^attempt + jitter
```

Maximum retry count must be bounded.

---

# 24. Retry Safety

Do not blindly retry write operations.

For example:

```text
POST /refund
```

could create duplicate business actions if idempotency is not implemented.

Therefore:

```text
Retry
+
Idempotency
```

should be designed together.

---

# 25. Timeout Strategy

Every external API call should have a timeout.

Example configuration:

```text
Connection timeout:
5 seconds

Read timeout:
30 seconds

Maximum total operation:
45 seconds
```

The exact values depend on the service.

Never allow an external call to wait indefinitely.

---

# 26. Circuit Breaker

A circuit breaker prevents repeated calls to an unhealthy dependency.

```text
             ┌──────────────┐
             │    CLOSED    │
             └──────┬───────┘
                    │ failures
                    ▼
             ┌──────────────┐
             │     OPEN     │
             └──────┬───────┘
                    │ timeout
                    ▼
             ┌──────────────┐
             │ HALF-OPEN    │
             └──────┬───────┘
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
       Success              Failure
          │                   │
          ▼                   ▼
       CLOSED                OPEN
```

---

# 27. Rate Limiting

Rate limits should protect:

- Salesforce.
- External APIs.
- LLM providers.
- RAG services.
- API gateways.

Example:

```text
100 requests/minute/user
1,000 requests/minute/application
```

Actual limits must be configured according to service capacity.

---

# 28. API Authentication

External integrations should use secure authentication.

Supported patterns may include:

```text
OAuth 2.0
JWT
Mutual TLS
API Key
Basic Authentication
Managed Identity
```

Preferred enterprise patterns:

```text
OAuth 2.0
JWT
mTLS
Managed Identity
```

Credentials should not be hard-coded in Apex.

---

# 29. API Authorization

Authentication answers:

> Who is calling?

Authorization answers:

> What is the caller allowed to do?

The application should validate:

```text
User
Permission Set
Profile
Role
Object access
Record access
Integration permission
Tool permission
```

---

# 30. Salesforce Authorization

Apex integration code must respect:

- CRUD.
- FLS.
- Sharing.
- Permission Sets.
- User context.

Example:

```text
User
 ↓
Salesforce Authorization
 ↓
AI Tool Permission
 ↓
Integration Permission
 ↓
External API
```

An AI request must not bypass normal Salesforce security controls.

---

# 31. REST Client Architecture

Recommended Apex structure:

```text
force-app/main/default/classes/
├── AI_RestClient.cls
├── AI_HttpRequestBuilder.cls
├── AI_HttpResponseParser.cls
├── AI_AuthenticationService.cls
├── AI_RetryPolicy.cls
├── AI_ErrorMapper.cls
├── AI_CorrelationService.cls
└── AI_IntegrationLogger.cls
```

---

# 32. REST Client Responsibility

`AI_RestClient` should handle:

- HTTP request creation.
- Endpoint selection.
- Headers.
- Authentication reference.
- Timeout.
- Callout execution.
- Response parsing.
- Error mapping.

It should not contain business-specific logic.

---

# 33. Service Layer

Business services should sit above the generic REST client.

Example:

```text
CustomerService
       │
       ▼
AI_RestClient
       │
       ▼
External API
```

Example:

```text
OrderService
       │
       ▼
AI_RestClient
       │
       ▼
Order API
```

This separation makes testing easier.

---

# 34. Example Apex Interface

```apex
public interface AI_HttpClient {
    HttpResponse send(HttpRequest request);
}
```

A production implementation:

```apex
public with sharing class AI_RestClient
    implements AI_HttpClient {

    public HttpResponse send(HttpRequest request) {
        Http http = new Http();
        return http.send(request);
    }
}
```

The interface allows the implementation to be mocked during testing.

---

# 35. HTTP Request Builder

Example:

```apex
public with sharing class AI_HttpRequestBuilder {

    public static HttpRequest build(
        String endpoint,
        String method,
        String body,
        Integer timeoutMs
    ) {
        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader(
            'Content-Type',
            'application/json'
        );
        request.setBody(body);
        request.setTimeout(timeoutMs);

        return request;
    }
}
```

Authentication should be delegated to Named Credentials rather than manually inserting secrets.

---

# 36. Named Credential Endpoint

Conceptual example:

```text
callout:AI_External_Service/v1/chat
```

This avoids hard-coding:

```text
https://api.example.com
```

inside application code.

The actual credential configuration belongs in the Salesforce environment.

---

# 37. JSON Serialization

Use typed DTOs for stable contracts where practical.

Example:

```apex
public class ChatRequest {
    public String conversationId;
    public String message;
    public String language;
}
```

Serialize:

```apex
String body = JSON.serialize(request);
```

Deserialize:

```apex
ChatResponse response =
    (ChatResponse) JSON.deserialize(
        responseBody,
        ChatResponse.class
    );
```

---

# 38. Dynamic JSON

Dynamic JSON may be appropriate for:

- Provider-specific responses.
- Extensible metadata.
- Tool arguments.
- Schema-driven payloads.

Example:

```apex
Map<String, Object> payload =
    (Map<String, Object>) JSON.deserializeUntyped(
        responseBody
    );
```

Dynamic JSON should still be validated before business use.

---

# 39. AI API Contract

Example:

```http
POST /api/v1/chat
```

Request:

```json
{
  "model": "configured-model",
  "messages": [
    {
      "role": "user",
      "content": "Summarize the case."
    }
  ],
  "temperature": 0.2
}
```

Response:

```json
{
  "id": "AI-12345",
  "output": "The customer is reporting a billing issue.",
  "usage": {
    "inputTokens": 500,
    "outputTokens": 80
  }
}
```

The application should validate the response schema before using it.

---

# 40. RAG API Contract

Example:

```http
POST /api/v1/search
```

Request:

```json
{
  "query": "What is the refund policy?",
  "topK": 5,
  "filters": {
    "region": "APAC",
    "status": "Published"
  }
}
```

Response:

```json
{
  "results": [
    {
      "documentId": "KB-REFUND-001",
      "title": "Refund Policy",
      "content": "Customers may request...",
      "score": 0.94,
      "metadata": {
        "classification": "INTERNAL",
        "region": "APAC"
      }
    }
  ]
}
```

---

# 41. Security Filtering

The client must not be allowed to arbitrarily bypass authorization filters.

Bad:

```json
{
  "filters": {
    "classification": "RESTRICTED"
  }
}
```

when the current user is not authorized.

The application must derive security constraints from trusted context.

```text
User Identity
      ↓
Authorization Service
      ↓
Approved Filters
      ↓
RAG Query
```

---

# 42. External Enterprise API Example

Example:

```http
GET /api/v1/customers/C101
```

Response:

```json
{
  "customerId": "C101",
  "customerType": "BUSINESS",
  "status": "ACTIVE"
}
```

The Salesforce application should map the external representation into an internal DTO.

---

# 43. Canonical Data Model

Avoid allowing external API structures to leak throughout the application.

Example:

```text
External API
     ↓
External DTO
     ↓
Transformation
     ↓
Canonical Model
     ↓
Business Service
```

Example canonical object:

```json
{
  "customerId": "C101",
  "type": "BUSINESS",
  "status": "ACTIVE"
}
```

This reduces coupling to external providers.

---

# 44. API Gateway

For enterprise deployments, an API gateway may be placed between Salesforce and external services.

```text
Salesforce
    │
    ▼
API Gateway
    │
    ├── Authentication
    ├── Authorization
    ├── Rate Limiting
    ├── Logging
    ├── Routing
    └── Threat Protection
    │
    ▼
Backend Services
```

The gateway should not replace application-level authorization.

---

# 45. API Gateway Responsibilities

Potential responsibilities:

- TLS termination.
- OAuth validation.
- Rate limiting.
- IP restrictions.
- Request validation.
- Routing.
- API versioning.
- Monitoring.
- Threat protection.
- Centralized logging.

---

# 46. Asynchronous APIs

Long-running operations should not remain synchronous.

Examples:

```text
Document ingestion
Large document processing
Bulk embeddings
Large RAG indexing
Long-running AI jobs
```

Recommended pattern:

```text
POST /api/v1/documents
       │
       ▼
202 Accepted
       │
       ▼
Job ID
```

Example:

```json
{
  "jobId": "JOB-10001",
  "status": "QUEUED"
}
```

---

# 47. Job Status API

Example:

```http
GET /api/v1/jobs/JOB-10001
```

Response:

```json
{
  "jobId": "JOB-10001",
  "status": "COMPLETED",
  "resultUrl": "/api/v1/jobs/JOB-10001/result"
}
```

Possible states:

```text
QUEUED
RUNNING
COMPLETED
FAILED
CANCELLED
```

---

# 48. Pagination

For collection APIs:

```http
GET /api/v1/cases?page=1&pageSize=50
```

Response:

```json
{
  "items": [],
  "pagination": {
    "page": 1,
    "pageSize": 50,
    "hasNext": true
  }
}
```

For high-volume APIs, cursor-based pagination may be preferable.

---

# 49. Filtering

Example:

```http
GET /api/v1/cases?status=OPEN&priority=HIGH
```

Filters should use an allow-list.

Do not allow arbitrary query expressions to reach backend systems.

---

# 50. Sorting

Example:

```http
GET /api/v1/cases?sortBy=createdDate&sortOrder=DESC
```

Allowed fields should be explicitly defined.

---

# 51. API Contract Documentation

All APIs should have machine-readable documentation.

Recommended:

```text
OpenAPI 3.x
```

Example:

```text
docs/
└── api/
    └── openapi.yaml
```

The OpenAPI definition should document:

- Endpoints.
- Parameters.
- Request schemas.
- Response schemas.
- Authentication.
- Status codes.
- Error responses.
- Examples.

---

# 52. API Documentation Example

```yaml
paths:
  /api/v1/chat:
    post:
      summary: Generate AI response
      requestBody:
        required: true
      responses:
        "200":
          description: Successful response
        "400":
          description: Invalid request
        "401":
          description: Authentication failure
        "429":
          description: Rate limit exceeded
```

---

# 53. API Testing Strategy

API tests should include:

```text
Functional
Contract
Negative
Security
Performance
Resilience
Authentication
Authorization
Rate limiting
Idempotency
Retry
Timeout
```

---

# 54. Functional Test Example

```text
Test:
Create AI chat request

Given:
Valid authenticated user

When:
POST /api/v1/chat

Then:
HTTP 200
Response contains answer
Correlation ID is present
```

---

# 55. Negative Test Example

```text
Test:
Missing message

Request:
{
  "conversationId": "CONV-1001"
}

Expected:
HTTP 400
Error code = VALIDATION_ERROR
```

---

# 56. Authentication Test

```text
Request:
No Authorization header

Expected:
HTTP 401
```

The response must not expose internal authentication details.

---

# 57. Authorization Test

```text
Authenticated user
+
Insufficient permission
```

Expected:

```text
HTTP 403
```

No restricted data should be returned.

---

# 58. Timeout Test

Simulate an external service that does not respond.

Expected:

```text
Timeout
   ↓
Controlled error
   ↓
Retry if retryable
   ↓
Final failure
   ↓
Safe user response
```

---

# 59. Rate-Limit Test

Simulate excessive requests.

Expected:

```text
HTTP 429
```

Response may include:

```http
Retry-After: 30
```

---

# 60. Contract Testing

Contract tests verify that producer and consumer expectations remain compatible.

Example:

```text
Salesforce
   │
   │ expects contract v1
   ▼
External API
```

If the provider changes:

```json
{
  "customerId": 123
}
```

from:

```json
{
  "customerId": "C101"
}
```

the contract test should detect the breaking change.

---

# 61. Mocking External APIs

Apex tests should not depend on live external services.

Use:

```apex
HttpCalloutMock
```

Example:

```apex
Test.setMock(
    HttpCalloutMock.class,
    new AI_TestHttpMock()
);
```

The mock should cover:

```text
200
201
400
401
403
404
409
429
500
502
503
504
Timeout
Malformed JSON
```

---

# 62. Example Mock

```apex
@IsTest
private class AI_TestHttpMock
    implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest request) {

        HttpResponse response = new HttpResponse();

        response.setStatusCode(200);
        response.setHeader(
            'Content-Type',
            'application/json'
        );

        response.setBody(
            '{"success":true,"data":{"answer":"Test response"}}'
        );

        return response;
    }
}
```

---

# 63. Observability

Every important API transaction should capture:

```text
Correlation ID
Request ID
API name
API version
Timestamp
Duration
HTTP status
Retry count
Error code
Provider
Model
Token usage where applicable
```

Do not log secrets or sensitive payloads unnecessarily.

---

# 64. API Metrics

Recommended metrics:

```text
Request count
Success rate
Error rate
Latency
P50 latency
P95 latency
P99 latency
Timeout rate
Retry rate
429 rate
5xx rate
Circuit breaker state
AI token usage
AI cost
```

---

# 65. Distributed Tracing

Where supported:

```text
LWC
 ↓
Apex
 ↓
Orchestrator
 ↓
REST Client
 ↓
API Gateway
 ↓
External API
```

should be traceable as one logical transaction.

Correlation IDs provide a simple baseline; distributed tracing can provide deeper observability.

---

# 66. Logging Policy

Log:

```text
Correlation ID
Request ID
Operation
Status
Duration
Error category
Retry count
```

Avoid logging:

```text
Passwords
Tokens
API keys
Secrets
Full customer PII
Sensitive prompts
Restricted documents
```

unless explicitly required and appropriately protected.

---

# 67. Data Minimization

Send only required data to external systems.

Bad:

```text
Full Salesforce Customer Record
        ↓
External AI API
```

Preferred:

```text
Required customer attributes
        ↓
External API
```

For example:

```json
{
  "customerId": "C101",
  "caseSummary": "Billing issue"
}
```

instead of sending the entire customer profile.

---

# 68. AI Data Boundary

Before sending data to an external LLM:

```text
Salesforce Data
      ↓
Authorization
      ↓
Data Minimization
      ↓
PII/Sensitive Data Handling
      ↓
Prompt Construction
      ↓
External LLM
```

The LLM should receive only approved context.

---

# 69. API Security Controls

Minimum controls:

```text
HTTPS/TLS
Authentication
Authorization
Input validation
Output validation
Rate limiting
Timeout
Audit logging
Secret management
API versioning
Least privilege
```

Additional controls:

```text
mTLS
WAF
API Gateway
IP allow-list
Schema validation
Threat detection
```

---

# 70. Secrets Management

Never store:

```text
API keys
Passwords
Private keys
OAuth client secrets
JWT secrets
```

inside:

```text
Apex source
Git repository
LWC JavaScript
Custom Labels
Custom Metadata
```

Use Salesforce:

```text
Named Credentials
External Credentials
```

and appropriate enterprise secret-management services.

---

# 71. Environment Separation

Use separate configurations for:

```text
DEV
QA
UAT
PROD
```

Example:

```text
DEV → Development API
QA  → QA API
UAT → UAT API
PROD → Production API
```

Production credentials must never be reused in development.

---

# 72. Configuration Management

Environment-specific configuration should be externalized.

Examples:

```text
Endpoint
Timeout
Retry count
Rate limit
Model name
Feature flag
Circuit breaker threshold
```

Application code should not require modification when these values change.

---

# 73. API Feature Flags

Feature flags can control new integrations.

Example:

```text
AI_NEW_PROVIDER_ENABLED = false
```

Deployment:

```text
Deploy code
    ↓
Feature disabled
    ↓
Validate production
    ↓
Enable feature
```

This reduces deployment risk.

---

# 74. Graceful Degradation

If an external AI service fails:

```text
AI Service
    ↓
Unavailable
    ↓
Fallback
```

Possible fallback:

```text
Existing Salesforce functionality
Knowledge search
Manual case handling
Standard workflow
```

The application must never fabricate an answer merely because an external service is unavailable.

---

# 75. Integration Flow Example

Customer service question:

```text
User
 │
 ▼
LWC
 │
 ▼
Apex Controller
 │
 ▼
AI Orchestrator
 │
 ├── Authorization
 │
 ├── Intent Detection
 │
 ├── RAG Search
 │
 └── AI API
 │
 ▼
Response Validation
 │
 ▼
Apex
 │
 ▼
LWC
```

---

# 76. External API Failure Flow

```text
Salesforce
     │
     ▼
REST API
     │
     X
External Service Failure
     │
     ▼
Classify Error
     │
     ├── Retryable
     │       ↓
     │    Retry Policy
     │
     └── Non-Retryable
             ↓
         Error Mapping
             │
             ▼
       Safe User Response
```

---

# 77. Integration Boundary

The architecture should enforce this boundary:

```text
Business Logic
      │
      ▼
Service Layer
      │
      ▼
Integration Client
      │
      ▼
REST API
```

Business logic should not be embedded inside low-level HTTP code.

---

# 78. Separation of Responsibilities

### LWC

Responsible for:

- User interaction.
- Display.
- Client-side validation.

### Apex Controller

Responsible for:

- Salesforce request handling.
- User context.
- Application orchestration entry point.

### Service Layer

Responsible for:

- Business logic.
- Tool execution.
- Workflow.

### REST Client

Responsible for:

- HTTP communication.

### Authentication Layer

Responsible for:

- Credential resolution.

### External API

Responsible for:

- External business capability.

---

# 79. Recommended Apex Classes

```text
force-app/main/default/classes/
│
├── AI_RestClient.cls
├── AI_HttpRequestBuilder.cls
├── AI_HttpResponseParser.cls
├── AI_ErrorMapper.cls
├── AI_RetryPolicy.cls
├── AI_CorrelationService.cls
├── AI_IntegrationLogger.cls
├── AI_CircuitBreaker.cls
│
├── CustomerApiService.cls
├── CaseApiService.cls
├── OrderApiService.cls
├── RAGApiService.cls
└── LLMApiService.cls
```

---

# 80. Recommended Interfaces

Use interfaces to decouple implementations.

```apex
public interface AI_IntegrationClient {
    AI_IntegrationResponse execute(
        AI_IntegrationRequest request
    );
}
```

Provider-specific implementations can then be substituted without changing business services.

---

# 81. Integration Request Model

Example:

```apex
public class AI_IntegrationRequest {

    public String operation;
    public String endpoint;
    public String method;
    public String body;
    public Integer timeoutMs;
    public String correlationId;
}
```

---

# 82. Integration Response Model

```apex
public class AI_IntegrationResponse {

    public Boolean success;
    public Integer statusCode;
    public String body;
    public String errorCode;
    public Boolean retryable;
    public String correlationId;
}
```

This provides a consistent internal abstraction over different APIs.

---

# 83. Error Classification

Integration errors should be classified.

```text
CLIENT_ERROR
AUTHENTICATION_ERROR
AUTHORIZATION_ERROR
VALIDATION_ERROR
NOT_FOUND
CONFLICT
RATE_LIMIT
TRANSIENT_ERROR
UPSTREAM_ERROR
TIMEOUT
SYSTEM_ERROR
```

This classification feeds:

```text
Retry
Alerting
Monitoring
User messaging
Incident management
```

---

# 84. Security-Safe Error Mapping

External API:

```text
500 Internal Server Error
Database connection password = xyz
```

Never return the external message directly to the user.

Instead:

```json
{
  "success": false,
  "error": {
    "code": "UPSTREAM_ERROR",
    "message": "The requested service is temporarily unavailable."
  }
}
```

Detailed technical information belongs in protected logs.

---

# 85. API Governance

Every production API should have:

- Owner.
- Business purpose.
- Technical owner.
- Version.
- Authentication mechanism.
- SLA/SLO.
- Rate limit.
- Data classification.
- Dependency list.
- Runbook.
- Monitoring.
- Contract documentation.

---

# 86. API Lifecycle

```text
Design
  ↓
Contract
  ↓
Develop
  ↓
Test
  ↓
Security Review
  ↓
Deploy
  ↓
Monitor
  ↓
Version
  ↓
Deprecate
  ↓
Retire
```

---

# 87. API Deprecation

When an API version is deprecated:

```text
Announce
   ↓
Provide migration guide
   ↓
Monitor old-version usage
   ↓
Migrate consumers
   ↓
Disable old version
```

Never abruptly remove an API used by production consumers without a controlled migration.

---

# 88. Performance Targets

Initial targets should be established based on actual workload.

Illustrative targets:

| Metric | Target |
|---|---:|
| Internal API P95 | < 1 sec |
| External API P95 | < 5 sec |
| Timeout rate | < 1% |
| 5xx rate | < 1% |
| Retry rate | < 5% |
| Availability | ≥ 99.9% |

AI APIs may have higher latency and should be measured separately.

---

# 89. Load Testing

Load tests should measure:

```text
Concurrent users
Requests/second
P95 latency
P99 latency
CPU/memory
API limits
Salesforce governor limits
External service throttling
```

Test realistic AI workloads rather than only simple GET requests.

---

# 90. Resilience Testing

Test:

```text
Network timeout
Slow API
HTTP 429
HTTP 500
HTTP 502
HTTP 503
HTTP 504
Malformed JSON
Invalid authentication
Expired credential
Duplicate request
External service outage
```

Expected behavior must be documented.

---

# 91. Deployment Checklist

Before deployment:

```text
[ ] API contract approved
[ ] Authentication configured
[ ] Named Credential configured
[ ] External Credential configured
[ ] Permission Set configured
[ ] Endpoint verified
[ ] Timeout configured
[ ] Retry configured
[ ] Idempotency implemented
[ ] Error mapping tested
[ ] Security tests passed
[ ] Integration tests passed
[ ] Monitoring configured
[ ] Alerts configured
[ ] Runbook available
[ ] Rollback strategy documented
```

---

# 92. Production Readiness Checklist

```text
[ ] HTTPS/TLS enabled
[ ] No secrets in source code
[ ] Authentication enabled
[ ] Authorization enforced
[ ] Input validation enabled
[ ] Output validation enabled
[ ] Rate limiting configured
[ ] Timeout configured
[ ] Retry policy configured
[ ] Circuit breaker configured
[ ] Correlation IDs enabled
[ ] Audit logging enabled
[ ] Sensitive-data logging controlled
[ ] API metrics available
[ ] Alerts configured
[ ] API documentation published
[ ] Disaster recovery considered
```

---

# 93. Definition of Done

The REST integration implementation is complete when:

- [ ] REST API standards are documented.
- [ ] API resources are defined.
- [ ] HTTP methods are standardized.
- [ ] API versioning is implemented.
- [ ] Request schemas are documented.
- [ ] Response schemas are documented.
- [ ] Error schemas are standardized.
- [ ] HTTP status codes are mapped.
- [ ] Correlation IDs are implemented.
- [ ] Authentication is configured.
- [ ] Authorization is enforced.
- [ ] Input validation is implemented.
- [ ] Output validation is implemented.
- [ ] Idempotency is implemented for applicable writes.
- [ ] Retry policies are configured.
- [ ] Timeout policies are configured.
- [ ] Rate limiting is defined.
- [ ] Circuit breaker strategy is defined.
- [ ] Sensitive data is minimized.
- [ ] Secrets are managed securely.
- [ ] OpenAPI documentation exists.
- [ ] Apex callouts are mockable.
- [ ] Positive tests exist.
- [ ] Negative tests exist.
- [ ] Security tests exist.
- [ ] Resilience tests exist.
- [ ] Integration monitoring exists.
- [ ] Production alerts exist.
- [ ] Runbooks exist.
- [ ] API ownership is documented.

---

# 94. Final Architecture Principle

The REST layer should remain a **controlled integration boundary** between Salesforce and external services.

The target architecture is:

```text
Salesforce
    │
    ▼
Authorization
    │
    ▼
AI/Application Service
    │
    ▼
Validation
    │
    ▼
Integration Client
    │
    ▼
Authentication
    │
    ▼
HTTPS / API Gateway
    │
    ▼
External API
    │
    ▼
Response Validation
    │
    ▼
Error Mapping / Observability
    │
    ▼
Application Response
```

The key principle is:

> **External APIs are dependencies, not trusted extensions of the Salesforce application. Every request must be authenticated, authorized, validated, observable, and resilient to dependency failure.**