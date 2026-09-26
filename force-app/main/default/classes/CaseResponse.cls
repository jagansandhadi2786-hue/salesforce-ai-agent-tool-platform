public class CaseResponse {

    public String id;
    public String caseNumber;
    public String subject;
    public String status;
    public String priority;
    public Datetime createdDate;

    public CaseResponse() {
    }

    public CaseResponse(Case caseRecord) {

        if (caseRecord == null) {
            return;
        }

        this.id =
            String.valueOf(
                caseRecord.Id
            );

        this.caseNumber =
            caseRecord.CaseNumber;

        this.subject =
            caseRecord.Subject;

        this.status =
            caseRecord.Status;

        this.priority =
            caseRecord.Priority;

        this.createdDate =
            caseRecord.CreatedDate;
    }
}
