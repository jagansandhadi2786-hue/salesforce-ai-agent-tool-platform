# Rollback Plan

## 1. Purpose

This document defines the rollback approach for failed or unsafe Salesforce AI Agent releases.

Rollback decisions must prioritize:

1. Customer impact
2. Data integrity
3. Security
4. Business continuity
5. System stability

---

## 2. Rollback Triggers

Rollback may be initiated when:

- Production deployment fails.
- Critical Apex functionality fails.
- AI assistant becomes unavailable.
- AI tool calling behaves incorrectly.
- RAG responses are materially incorrect.
- A security vulnerability is introduced.
- Integration failures affect business processing.
- Production performance becomes unacceptable.
- Data integrity is threatened.

---

## 3. Rollback Decision

The release owner and appropriate technical/business stakeholders should determine whether to:

```text
Fix Forward
     OR
Rollback
```

Not every production issue requires a rollback.

---

## 4. Deployment Failure

If deployment fails before completion:

1. Review deployment errors.
2. Identify failed metadata.
3. Correct the issue.
4. Re-run validation.
5. Re-run CI.
6. Retry deployment after approval.

Do not manually modify production to bypass deployment controls unless required by an approved emergency procedure.

---

## 5. Metadata Rollback

Salesforce metadata rollback should be based on a known-good Git revision.

Example:

```bash
git checkout <known-good-release>
```

The exact Salesforce deployment/retrieval procedure should be determined by the organization's source-of-truth strategy.

---

## 6. Emergency Hotfix

For urgent production issues:

```text
Production Incident
       ↓
Create hotfix branch
       ↓
Implement minimal fix
       ↓
Run CI
       ↓
Code Review
       ↓
Production Approval
       ↓
Deploy
       ↓
Smoke Test
       ↓
Close Incident
```

Example:

```text
hotfix/ai-service-timeout
```

---

## 7. AI Service Rollback

If the issue is related to AI behavior:

- Disable affected functionality where possible.
- Revert prompt/configuration changes.
- Revert model/deployment configuration where applicable.
- Disable affected tools.
- Verify fallback behavior.
- Run AI regression tests.
- Monitor production responses.

---

## 8. RAG Rollback

If RAG quality degrades:

1. Identify the affected knowledge source or index.
2. Disable the affected configuration if required.
3. Restore the previous known-good configuration/index.
4. Run retrieval tests.
5. Run grounding tests.
6. Validate representative queries.
7. Re-enable functionality after approval.

---

## 9. Integration Rollback

If an external integration fails:

- Verify endpoint availability.
- Verify authentication.
- Check request/response changes.
- Disable the affected integration if necessary.
- Restore the previous integration configuration.
- Validate retry/error handling.
- Monitor failed transactions.

---

## 10. Post-Rollback Validation

After rollback:

- [ ] Salesforce application available
- [ ] Critical business processes working
- [ ] AI assistant available or safely disabled
- [ ] Tool calling validated
- [ ] RAG functionality validated
- [ ] Integrations validated
- [ ] Error logs reviewed
- [ ] Security validated
- [ ] Business smoke test completed

---

## 11. Incident Documentation

Record:

```text
Incident ID:
Release:
Git Commit:
Deployment ID:
Incident Start:
Rollback Start:
Rollback Completed:
Root Cause:
Customer Impact:
Actions Taken:
Preventive Actions:
```

---

## 12. Lessons Learned

After a significant rollback:

1. Perform root-cause analysis.
2. Identify why CI/CD did not detect the issue.
3. Add regression tests where appropriate.
4. Update monitoring.
5. Update deployment documentation.
6. Update the production checklist.
7. Communicate lessons learned to the engineering team.