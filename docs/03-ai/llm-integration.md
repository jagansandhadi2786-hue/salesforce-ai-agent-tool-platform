# LLM Integration

## 1. Purpose

This document defines the integration architecture between the Salesforce AI Assistant and the Large Language Model (LLM) provider.

The integration provides:

- Model invocation
- Authentication
- Request/response contracts
- Model configuration
- Prompt delivery
- Structured output
- Tool calling
- Retry handling
- Timeout handling
- Rate-limit handling
- Error handling
- Logging
- Cost control
- Model governance

The architecture is provider-independent wherever practical.

---

# 2. LLM Integration Architecture

```text
Salesforce LWC
      │
      ▼
AI_AssistantController
      │
      ▼
AI_Orchestrator
      │
      ▼
AI_PromptService
      │
      ▼
LLM Integration Service
      │
      ├───────────────┐
      ▼               ▼
Provider Adapter    Configuration
      │
      ▼
LLM Provider
      │
      ▼
Model
```

The Salesforce application should not tightly couple business logic to a single LLM provider.

---

# 3. Provider Adapter Pattern

Recommended architecture:

```text
AI_Orchestrator
       │
       ▼
LLMService
       │
       ▼
LLMProviderAdapter
       │
       ├── AzureOpenAIAdapter
       ├── OpenAIAdapter
       └── FutureProviderAdapter
```

The application interacts with a common internal interface.

---

# 4. Internal LLM Request Contract

Example:

```json
{
  "requestId": "REQ-10001",
  "model": "configured-model",
  "promptVersion": "CASE_SUMMARY_v1.0",
  "messages": [
    {
      "role": "system",
      "content": "..."
    },
    {
      "role": "user",
      "content": "..."
    }
  ],
  "temperature": 0.2,
  "maxTokens": 1000,
  "responseFormat": "json"
}
```

The internal contract should remain stable even if the external provider API changes.

---

# 5. Internal LLM Response Contract

Example:

```json
{
  "success": true,
  "requestId": "REQ-10001",
  "model": "configured-model",
  "content": {
    "summary": "Customer reported duplicate billing."
  },
  "usage": {
    "inputTokens": 500,
    "outputTokens": 150
  },
  "latencyMs": 1420
}
```

---

# 6. Provider Adapter

The provider adapter translates the internal request into the provider-specific API format.

```text
Internal Request
       │
       ▼
Provider Adapter
       │
       ▼
Provider API Request
       │
       ▼
LLM Provider
       │
       ▼
Provider Response
       │
       ▼
Normalized Response
```

This isolates provider-specific changes.

---

# 7. Authentication

LLM credentials must never be hardcoded.

Use enterprise secret-management mechanisms such as:

```text
Salesforce Named Credentials
External Credentials
OAuth
Managed Identity
Azure Key Vault
Environment Secrets
GitHub Actions Secrets
```

The exact mechanism depends on the selected provider and deployment architecture.

---

# 8. Authentication Flow

Conceptual flow:

```text
Salesforce
    │
    ▼
Named / External Credential
    │
    ▼
Authentication Provider
    │
    ▼
LLM Endpoint
```

The application code should not contain:

```text
API_KEY = "..."
```

---

# 9. Network Security

LLM communication should use:

```text
HTTPS/TLS
```

Additional controls may include:

```text
Private networking
Firewall rules
IP restrictions
API gateway
Private endpoints
mTLS
Network segmentation
```

depending on enterprise requirements.

---

# 10. Model Configuration

Model configuration should be externalized.

Example:

```text
Model Name
Provider
Endpoint
API Version
Temperature
Max Output Tokens
Timeout
Retry Count
Rate Limit
Enabled
Environment
Prompt Version
```

Example conceptual configuration:

```json
{
  "provider": "AzureOpenAI",
  "model": "configured-model",
  "temperature": 0.2,
  "maxOutputTokens": 1000,
  "timeoutSeconds": 30,
  "maxRetries": 2
}
```

The exact model name and API parameters should be environment-specific configuration rather than hardcoded application logic.

---

# 11. Model Selection Strategy

Different tasks may require different models.

Example:

```text
Case Summary
    ↓
Fast / cost-efficient model

Complex Escalation Analysis
    ↓
Higher-reasoning model

Classification
    ↓
Structured-output optimized model
```

Model routing should be configuration-driven.

---

# 12. Temperature

Temperature should be selected according to the task.

Typical strategy:

```text
Classification:
Low

Structured extraction:
Low

Case summary:
Low

Customer response:
Low–Medium

Creative generation:
Higher
```

For enterprise workflows, deterministic behavior is generally preferred.

---

# 13. Token Management

Token usage should be controlled.

Reduce unnecessary context:

```text
Entire Case History
```

to:

```text
Relevant Case Data
+
Relevant Comments
+
Relevant Knowledge
```

Token controls reduce:

- latency
- cost
- context overflow
- unnecessary data exposure

---

# 14. Context Window Management

If context exceeds the model limit:

```text
Large Context
      │
      ▼
Relevance Filtering
      │
      ▼
Summarization
      │
      ▼
Top-K Retrieval
      │
      ▼
LLM
```

RAG should be used instead of sending the entire enterprise knowledge base.

---

# 15. Structured Output

For machine-readable tasks, require structured output.

Example:

```json
{
  "priority": "HIGH",
  "confidence": 0.94,
  "reason": "Customer has experienced repeated unresolved failures."
}
```

The response validator should verify the structure before business processing.

---

# 16. Tool Calling Through the LLM

The LLM may return a tool request such as:

```json
{
  "toolName": "getOrderStatus",
  "arguments": {
    "orderId": "100045"
  }
}
```

The request must then pass through:

```text
Tool Registry
      ↓
Contract Validation
      ↓
Authorization
      ↓
Risk Evaluation
      ↓
Confirmation
      ↓
Execution
```

The LLM itself does not directly invoke Salesforce operations.

---

# 17. Multi-Turn LLM Interaction

Example:

```text
User
 │
 ▼
LLM
 │
 └── tool request
        │
        ▼
    Salesforce Tool
        │
        ▼
    Tool Result
        │
        ▼
       LLM
        │
        ▼
    Final Answer
```

This pattern supports agentic workflows while maintaining application control.

---

# 18. Request Timeout

Every LLM request must have a timeout.

Example:

```text
LLM timeout:
30 seconds
```

This is illustrative.

Production values should be based on:

- model performance
- user experience
- Salesforce transaction limits
- external API limits

---

# 19. Retry Strategy

Retry only transient failures.

Potentially retryable:

```text
429 Too Many Requests
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
Network timeout
```

Generally non-retryable:

```text
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
Invalid request schema
Content policy rejection
```

---

# 20. Exponential Backoff

Example:

```text
Attempt 1
   ↓
Wait 1 second

Attempt 2
   ↓
Wait 2 seconds

Attempt 3
   ↓
Fail
```

Actual backoff values should be configurable.

Use jitter where appropriate to avoid synchronized retries.

---

# 21. Retry Safety

Retries must not duplicate business actions.

LLM generation is generally safer to retry than a write operation.

For tool calls:

```text
LLM
 ↓
createFollowUpTask
 ↓
Timeout
 ↓
Retry
```

could create two tasks.

Therefore:

```text
Idempotency Key
+
Duplicate Detection
```

should be used for write operations.

---

# 22. Rate Limiting

The application should protect against excessive model usage.

Possible controls:

```text
Requests per user
Requests per minute
Requests per conversation
Token budget
Daily budget
Maximum tool calls
Maximum agent iterations
```

Example:

```text
Maximum agent iterations = 5
Maximum tool calls/request = 10
```

These are illustrative limits.

---

# 23. Agent Loop Protection

The agent must not enter an infinite tool-calling loop.

Example:

```text
LLM
 ↓
Tool A
 ↓
LLM
 ↓
Tool A
 ↓
LLM
 ↓
Tool A
```

The orchestrator should enforce:

```text
Maximum iterations
Maximum tool calls
Execution timeout
Repeated-tool detection
```

---

# 24. Error Handling Model

Standard error categories:

```text
LLM_AUTHENTICATION_ERROR
LLM_RATE_LIMIT
LLM_TIMEOUT
LLM_PROVIDER_ERROR
LLM_INVALID_RESPONSE
LLM_INVALID_JSON
LLM_CONTENT_POLICY
LLM_CONTEXT_LIMIT
LLM_CONFIGURATION_ERROR
LLM_NETWORK_ERROR
```

---

# 25. Standard Error Response

Internal:

```json
{
  "success": false,
  "error": {
    "code": "LLM_TIMEOUT",
    "message": "The model request timed out.",
    "retryable": true,
    "correlationId": "CORR-10001"
  }
}
```

User-facing:

```text
"I couldn't complete the AI request because the AI service
did not respond in time. Please try again."
```

Internal technical details should not be exposed unnecessarily.

---

# 26. Provider Failure

If the primary model provider becomes unavailable:

```text
Primary LLM
     │
     ▼
Failure
     │
     ▼
Retry
     │
     ▼
Fallback Provider/Model
     │
     ▼
Response
```

Fallback should only be used when:

- approved
- security-compatible
- contract-compatible
- evaluated
- configured

---

# 27. Graceful Degradation

If the LLM is unavailable, Salesforce functionality should continue where possible.

For example:

```text
LLM unavailable
     │
     ├── Salesforce Case access → Available
     ├── Case search → Available
     ├── Order lookup → Available
     └── AI summarization → Temporarily unavailable
```

The system should clearly communicate which capability is unavailable.

---

# 28. Observability

Record:

```text
correlationId
requestId
model
provider
promptVersion
latency
inputTokens
outputTokens
totalTokens
retryCount
status
errorCode
timestamp
```

Avoid storing complete prompts/responses when they contain unnecessary sensitive information.

---

# 29. Cost Monitoring

Track:

```text
Requests
Input Tokens
Output Tokens
Total Tokens
Cost
Cost per User
Cost per Use Case
Cost per Model
```

Example dashboard:

```text
Daily Requests
Daily Token Usage
Daily Cost
Average Cost/Request
P95 Latency
Error Rate
Retry Rate
```

---

# 30. Model Governance

Every production model should have:

```text
Provider
Model
Version
Owner
Approved Use Cases
Security Review
Evaluation Results
Cost Profile
Performance Profile
Fallback Model
Status
```

---

# 31. Model Evaluation

Before production:

```text
Accuracy
Groundedness
Hallucination
Safety
Latency
Cost
Structured Output
Tool Selection
Prompt Injection Resistance
```

The model should be evaluated using representative enterprise scenarios.

---

# 32. LLM Integration Security

Required controls:

- HTTPS/TLS
- Secure credentials
- No secrets in prompts
- Least-privilege access
- Data minimization
- Sensitive-data filtering
- Prompt injection controls
- Output validation
- Audit logging
- Rate limiting
- Provider access controls

---

# 33. Salesforce Apex Service Architecture

Recommended classes:

```text
AI_LLMService
AI_LLMProviderAdapter
AI_LLMRequest
AI_LLMResponse
AI_LLMConfigurationService
AI_LLMErrorHandler
AI_LLMRetryService
AI_ResponseValidator
AI_PromptService
```

Provider-specific implementations:

```text
AzureOpenAIAdapter
OpenAIAdapter
FutureProviderAdapter
```

The actual implementation can use interfaces:

```text
ILLMProvider
ILLMRequestBuilder
ILLMResponseParser
```

---

# 34. Conceptual Apex Interface

```text
interface ILLMProvider {

    generate(
        LLMRequest request
    );

}
```

Provider adapters implement the interface.

This prevents business logic from becoming tightly coupled to a specific provider.

---

# 35. End-to-End LLM Flow

```text
User Request
     │
     ▼
AI Orchestrator
     │
     ▼
Intent
     │
     ▼
Prompt Service
     │
     ▼
Context Builder
     │
     ├── Salesforce Data
     ├── Tool Results
     └── RAG Context
     │
     ▼
LLM Request Builder
     │
     ▼
Authentication
     │
     ▼
Provider Adapter
     │
     ▼
LLM Provider
     │
     ▼
Response
     │
     ▼
Response Validator
     │
     ├── Invalid → Error/Fallback
     │
     └── Valid
          │
          ▼
       Orchestrator
          │
          ▼
       Final User Response
```

---

# 36. Production Failure Scenarios

## Scenario 1 — Provider Timeout

```text
LLM timeout
    ↓
Retry
    ↓
Failure
    ↓
Graceful response
    ↓
Alert/monitoring
```

## Scenario 2 — Rate Limit

```text
429
 ↓
Backoff
 ↓
Retry
 ↓
Fallback or graceful failure
```

## Scenario 3 — Invalid JSON

```text
Invalid JSON
     ↓
Response validation
     ↓
Retry with constrained format
     ↓
Failure
     ↓
Graceful response
```

## Scenario 4 — Provider Outage

```text
Primary Provider
      ↓
Unavailable
      ↓
Approved Fallback
      ↓
Continue
```

## Scenario 5 — Context Limit

```text
Context too large
      ↓
Reduce context
      ↓
RAG top-K filtering
      ↓
Summarize
      ↓
Retry
```

---

# 37. LLM Integration Testing

Tests should cover:

```text
Authentication
Request serialization
Response parsing
Timeout
Retry
Rate limiting
Invalid JSON
Malformed response
Provider outage
Context overflow
Tool calling
Structured output
Security
Sensitive-data handling
```

---

# 38. Mocking

Automated tests should not depend on live production LLM calls.

Use:

```text
Mock Provider
HTTP Callout Mock
Recorded Responses
Synthetic Test Dataset
```

Example:

```text
Test:
CASE_SUMMARY

Mock LLM Response:
{
  "summary": "Duplicate billing issue",
  "confidence": 0.95
}
```

---

# 39. Production Monitoring

Monitor:

```text
Availability
Latency
Error Rate
Token Usage
Cost
Rate Limits
Retry Rate
Model Quality
Hallucination Rate
Tool Calling Success
Fallback Usage
```

Recommended latency metrics:

```text
Average
P50
P95
P99
```

---

# 40. Kill Switch

The platform should support disabling AI functionality without deploying code.

Example:

```text
AI_ENABLED = false
```

or feature configuration:

```text
LLM_ENABLED = false
```

When disabled:

```text
Salesforce Core Functions
        ↓
Continue

AI Functions
        ↓
Disabled
```

---

# 41. Definition of Done

- [ ] Internal LLM contract defined
- [ ] Provider adapter implemented
- [ ] Authentication configured securely
- [ ] Model configuration externalized
- [ ] Prompt versioning integrated
- [ ] Structured output implemented
- [ ] Tool calling supported
- [ ] Timeout configured
- [ ] Retry policy implemented
- [ ] Exponential backoff implemented
- [ ] Rate limiting implemented
- [ ] Agent loop protection implemented
- [ ] Error model implemented
- [ ] Fallback strategy defined
- [ ] Token monitoring implemented
- [ ] Cost monitoring implemented
- [ ] Security controls implemented
- [ ] Mock provider implemented
- [ ] Integration tests implemented
- [ ] AI evaluation implemented
- [ ] Production monitoring implemented
- [ ] AI kill switch implemented
- [ ] Model governance implemented