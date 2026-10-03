public class AI_AgentToolExecutionResponse {

    @AuraEnabled
    public Integer stepNumber;

    @AuraEnabled
    public String toolName;

    @AuraEnabled
    public String status;

    @AuraEnabled
    public Decimal executionTime;

    @AuraEnabled
    public Boolean approvalRequired;

    @AuraEnabled
    public String errorMessage;


    public AI_AgentToolExecutionResponse() {
    }


    public AI_AgentToolExecutionResponse(
        Integer stepNumber,
        String toolName,
        String status,
        Decimal executionTime,
        Boolean approvalRequired,
        String errorMessage
    ) {

        this.stepNumber =
            stepNumber;

        this.toolName =
            toolName;

        this.status =
            status;

        this.executionTime =
            executionTime;

        this.approvalRequired =
            approvalRequired == true;

        this.errorMessage =
            errorMessage;
    }
}
