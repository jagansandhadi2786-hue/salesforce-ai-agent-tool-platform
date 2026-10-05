# Production Go-Live Checklist

## Salesforce

[ ] Production org identified
[ ] Deployment user identified
[ ] Permission Sets reviewed
[ ] Apex classes validated
[ ] LWC validated
[ ] Custom Objects validated
[ ] Custom Metadata validated
[ ] Reports validated
[ ] Dashboards validated

## Security

[ ] CRUD/FLS verified
[ ] USER_MODE verified
[ ] Tool authorization verified
[ ] Approval controls verified
[ ] Named Credentials configured
[ ] External Credentials configured
[ ] No secrets in source code
[ ] No production data in GitHub
[ ] Prompt injection tests passed
[ ] RAG security tests passed

## Azure

[ ] Azure OpenAI deployment available
[ ] Azure AI Search index available
[ ] Search security filters configured
[ ] Azure Monitor enabled
[ ] Log Analytics configured
[ ] Alerts configured

## Integration

[ ] Order API available
[ ] API authentication tested
[ ] Timeout tested
[ ] 401/403 tested
[ ] 429 tested
[ ] 500 tested

## Testing

[ ] Apex tests passed
[ ] Security regression passed
[ ] Tool contract tests passed
[ ] LLM mock tests passed
[ ] RAG evaluation passed
[ ] REST integration tests passed
[ ] E2E tests passed

## Release

[ ] UAT approved
[ ] Production validation passed
[ ] Release notes prepared
[ ] Rollback version identified
[ ] Production approval obtained

## Post Deployment

[ ] Smoke tests passed
[ ] Monitoring verified
[ ] Alerts verified
[ ] Agent enabled
[ ] RAG enabled
[ ] Required tools enabled