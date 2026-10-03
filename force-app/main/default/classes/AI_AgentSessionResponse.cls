public class AI_AgentSessionResponse {

    @AuraEnabled
    public String sessionId;

    @AuraEnabled
    public String status;

    @AuraEnabled
    public Datetime startTime;

    @AuraEnabled
    public Datetime endTime;

    @AuraEnabled
    public Integer toolCallCount;


    public AI_AgentSessionResponse() {
    }


    public AI_AgentSessionResponse(
        String sessionId,
        String status,
        Datetime startTime,
        Datetime endTime,
        Integer toolCallCount
    ) {

        this.sessionId =
            sessionId;

        this.status =
            status;

        this.startTime =
            startTime;

        this.endTime =
            endTime;

        this.toolCallCount =
            toolCallCount;
    }
}
