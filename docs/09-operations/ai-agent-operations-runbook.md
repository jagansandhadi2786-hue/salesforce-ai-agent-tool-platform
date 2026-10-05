Include:
# AI Agent Operations Runbook

## Incident 1 — Azure OpenAI unavailable

Check:
1. Azure Monitor
2. Azure OpenAI dependency
3. Recent deployments
4. Error rate
5. Correlation ID

Action:
- Confirm service status
- Review failure pattern
- Activate fallback behavior if configured

## Incident 2 — Order API failing

Check:
1. REST error rate
2. HTTP status
3. API Management
4. External API health
5. Correlation ID

## Incident 3 — RAG no-result spike

Check:
1. Azure AI Search
2. Index status
3. Recent ingestion
4. Security filters
5. Query latency

## Incident 4 — High latency

Break down:
LLM
RAG
Tool
REST
Total
This becomes part of your production-support portfolio
