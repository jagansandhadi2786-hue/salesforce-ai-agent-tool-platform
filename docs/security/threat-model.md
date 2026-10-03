Use this structure:
# AI Agent Threat Model

## Assets

- Salesforce customer data
- Case data
- Knowledge articles
- Order information
- OAuth credentials
- Azure credentials
- Agent conversations
- Audit records

## Threats

1. Prompt injection
2. Tool hallucination
3. Unauthorized tool execution
4. Salesforce data leakage
5. RAG data leakage
6. Credential leakage
7. SSRF
8. Excessive API calls
9. Malicious Knowledge content
10. Sensitive data exposure

## Controls

- Salesforce identity
- Permission sets
- USER_MODE
- Tool contracts
- Schema validation
- Authorization
- Approval
- Named Credentials
- OAuth
- RAG security filters
- Prompt Shields
- PII masking
- Rate limiting
- Audit
- Security tests
