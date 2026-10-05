# Test Matrix

## 1. Purpose

This document maps business and technical requirements to test scenarios for the Salesforce Enterprise AI Tool & Customer Service Assistant.

The matrix provides traceability between:

```text
Requirement
    ↓
Test Scenario
    ↓
Expected Result
    ↓
Automation
    ↓
Execution Evidence
```

---

# 2. Test Case Convention

Test IDs follow:

```text
TC-[AREA]-[NUMBER]
```

Examples:

```text
TC-AUTH-001
TC-API-001
TC-AI-001
TC-RAG-001
TC-SEC-001
```

---

# 3. Priority

| Priority | Meaning |
|---|---|
| P0 | Business/security critical |
| P1 | High |
| P2 | Medium |
| P3 | Low |

---

# 4. Functional Test Matrix

| Test ID | Area | Scenario | Expected Result | Priority | Automation |
|---|---|---|---|---|---|
| TC-FUNC-001 | Chat | Submit valid question | Correct response returned | P1 | Yes |
| TC-FUNC-002 | Chat | Submit empty question | Validation message shown | P1 | Yes |
| TC-FUNC-003 | Case | Summarize case | Accurate summary generated | P1 | Yes |
| TC-FUNC-004 | Case | Invalid Case ID | Controlled error returned | P1 | Yes |
| TC-FUNC-005 | Customer | Lookup valid customer | Authorized data returned | P1 | Yes |
| TC-FUNC-006 | Customer | Customer not found | Business error returned | P2 | Yes |
| TC-FUNC-007 | Task | Create task | Confirmation requested | P0 | Yes |
| TC-FUNC-008 | Task | User rejects creation | No task created | P0 | Yes |
| TC-FUNC-009 | Escalation | Escalate case | Correct escalation workflow executed | P0 | Yes |
| TC-FUNC-010 | Knowledge | Search knowledge | Relevant results returned | P1 | Yes |

---

# 5. Authentication Test Matrix

| Test ID | Scenario | Expected Result |
|---|---|---|
| TC-AUTH-001 | Valid authentication | Request succeeds |
| TC-AUTH-002 | Expired credential | Controlled authentication error |
| TC-AUTH-003 | Invalid credential | Request rejected |
| TC-AUTH-004 | Missing credential | Request rejected |
| TC-AUTH-005 | Invalid OAuth scope | Authorization failure |
| TC-AUTH-006 | Credential rotation | New credential works |
| TC-AUTH-007 | Old credential revoked | Old credential rejected |

---

# 6. Authorization Matrix

| Test ID | Scenario | Expected Result |
|---|---|---|
| TC-AUTHZ-001 | Authorized user accesses Case | Access allowed |
| TC-AUTHZ-002 | Unauthorized Case access | Access denied |
| TC-AUTHZ-003 | Unauthorized customer access | Access denied |
| TC-AUTHZ-004 | Unauthorized tool execution | Tool execution blocked |
| TC-AUTHZ-005 | Restricted RAG document | Document excluded |
| TC-AUTHZ-006 | Missing authorization context | Fail closed |
| TC-AUTHZ-007 | User lacks required permission | Operation denied |

---

# 7. API Test Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-API-001 | Valid GET | 200 |
| TC-API-002 | Valid POST | 201/200 |
| TC-API-003 | Invalid JSON | 400 |
| TC-API-004 | Missing required field | 400/422 |
| TC-API-005 | Unauthorized request | 401/403 |
| TC-API-006 | Resource missing | 404 |
| TC-API-007 | Conflict | 409 |
| TC-API-008 | Rate limited | 429 |
| TC-API-009 | Server failure | Controlled 5xx |
| TC-API-010 | Timeout | Controlled timeout response |

---

# 8. Integration Test Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-INT-001 | Customer API success | Customer returned |
| TC-INT-002 | Customer API 500 | Retry |
| TC-INT-003 | Customer API 503 | Retry |
| TC-INT-004 | Customer API timeout | Retry |
| TC-INT-005 | Customer API 400 | No retry |
| TC-INT-006 | Customer API 401 | Authentication handling |
| TC-INT-007 | Customer API 403 | Access denied |
| TC-INT-008 | Customer API 429 | Backoff |
| TC-INT-009 | Malformed response | Response validation failure |
| TC-INT-010 | Duplicate request | Idempotency maintained |

---

# 9. AI Agent Test Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-AI-001 | Case summary request | CASE_SUMMARY intent |
| TC-AI-002 | Customer lookup | CUSTOMER_PROFILE intent |
| TC-AI-003 | Knowledge question | KNOWLEDGE_SEARCH intent |
| TC-AI-004 | Order question | ORDER_STATUS intent |
| TC-AI-005 | Task creation | CREATE_TASK intent |
| TC-AI-006 | Case escalation | CASE_ESCALATION intent |
| TC-AI-007 | Ambiguous request | Clarification requested |
| TC-AI-008 | Unknown request | Safe fallback |
| TC-AI-009 | Wrong tool candidate | Correct tool selected |
| TC-AI-010 | Unauthorized tool | Tool blocked |

---

# 10. Tool-Calling Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-TOOL-001 | Valid tool arguments | Tool executes |
| TC-TOOL-002 | Missing required argument | Execution blocked |
| TC-TOOL-003 | Invalid data type | Execution blocked |
| TC-TOOL-004 | Invalid enum | Execution blocked |
| TC-TOOL-005 | Unauthorized tool | Execution blocked |
| TC-TOOL-006 | Write tool | Confirmation required |
| TC-TOOL-007 | Tool timeout | Controlled failure |
| TC-TOOL-008 | Tool response invalid | Result rejected |
| TC-TOOL-009 | Tool unavailable | Fallback/error |
| TC-TOOL-010 | Duplicate write | Idempotency enforced |

---

# 11. RAG Test Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-RAG-001 | Relevant question | Relevant documents retrieved |
| TC-RAG-002 | No matching document | No-result response |
| TC-RAG-003 | Restricted document | Document excluded |
| TC-RAG-004 | Expired document | Document excluded |
| TC-RAG-005 | Unpublished document | Document excluded |
| TC-RAG-006 | Hybrid search | Relevant results returned |
| TC-RAG-007 | Citation required | Citation included |
| TC-RAG-008 | Unsupported answer | Model does not fabricate |
| TC-RAG-009 | Prompt injection document | Injection blocked |
| TC-RAG-010 | RAG service unavailable | Graceful degradation |

---

# 12. AI Quality Matrix

| Test ID | Metric | Expected |
|---|---|---|
| TC-AIE-001 | Intent accuracy | Meets threshold |
| TC-AIE-002 | Tool selection | Meets threshold |
| TC-AIE-003 | Parameter extraction | Meets threshold |
| TC-AIE-004 | Answer correctness | Meets threshold |
| TC-AIE-005 | Groundedness | Meets threshold |
| TC-AIE-006 | Citation accuracy | Meets threshold |
| TC-AIE-007 | Hallucination | Below threshold |
| TC-AIE-008 | Unsafe response | Zero critical failures |

---

# 13. Prompt Security Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-SEC-AI-001 | Direct prompt injection | Block/ignore |
| TC-SEC-AI-002 | Indirect RAG injection | Block/ignore |
| TC-SEC-AI-003 | System prompt extraction | Refuse |
| TC-SEC-AI-004 | Secret extraction | Refuse |
| TC-SEC-AI-005 | Unauthorized tool request | Block |
| TC-SEC-AI-006 | Restricted customer request | Deny |
| TC-SEC-AI-007 | Privilege escalation attempt | Deny |

---

# 14. Security Test Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-SEC-001 | CRUD violation | Denied |
| TC-SEC-002 | FLS violation | Denied |
| TC-SEC-003 | Sharing violation | Denied |
| TC-SEC-004 | Invalid session | Rejected |
| TC-SEC-005 | API token leakage | No leakage |
| TC-SEC-006 | PII logging | PII masked |
| TC-SEC-007 | Unauthorized RAG retrieval | Zero leakage |
| TC-SEC-008 | Credential exposure | No credentials exposed |

---

# 15. Error Handling Matrix

| Test ID | Failure | Expected |
|---|---|---|
| TC-ERR-001 | Timeout | Retry |
| TC-ERR-002 | 500 | Retry |
| TC-ERR-003 | 503 | Retry |
| TC-ERR-004 | 429 | Backoff |
| TC-ERR-005 | 400 | No retry |
| TC-ERR-006 | 403 | No retry |
| TC-ERR-007 | Retry exhausted | Controlled failure |
| TC-ERR-008 | Circuit threshold reached | Circuit opens |
| TC-ERR-009 | Dead-letter condition | Message persisted |
| TC-ERR-010 | Replay | Idempotent processing |

---

# 16. Performance Matrix

| Test ID | Scenario | Expected |
|---|---|---|
| TC-PERF-001 | Normal load | SLA met |
| TC-PERF-002 | Peak load | SLA met |
| TC-PERF-003 | Concurrent users | Stable |
| TC-PERF-004 | Large payload | Controlled |
| TC-PERF-005 | Slow external API | Timeout handled |
| TC-PERF-006 | LLM latency | SLA monitored |
| TC-PERF-007 | RAG latency | SLA monitored |

---

# 17. Regression Matrix

| Test Area | Critical Tests | Frequency |
|---|---|---|
| Salesforce Core | P0/P1 | Every deployment |
| Apex | All automated tests | Every deployment |
| LWC | Core UI suite | Every deployment |
| API | Critical endpoints | Every deployment |
| AI | Critical evaluation set | Every deployment |
| RAG | Security + relevance | Every deployment |
| Security | Critical controls | Every release |
| Performance | Baseline suite | Release |
| E2E | Critical journeys | Release/UAT |

---

# 18. Traceability

Every critical requirement should map to one or more test cases.

Example:

```text
FR-007
  ↓
TC-AI-003
TC-TOOL-001
TC-RAG-001
TC-SEC-AI-006
```

This provides requirement-to-test traceability.

---

# 19. Test Status

Use:

```text
NOT_STARTED
IN_PROGRESS
PASS
FAIL
BLOCKED
DEFERRED
NOT_APPLICABLE
```

---

# 20. Exit Criteria

Testing can exit when:

- All P0 tests pass.
- All mandatory P1 tests pass.
- No open critical security defects exist.
- AI evaluation meets approved thresholds.
- RAG authorization tests pass.
- Regression suite passes.
- UAT is approved.
- Evidence is stored.
- Known limitations are documented.