public class AI_AgentResponse {

    // ============================================================
    // Existing response properties
    // ============================================================

    @AuraEnabled
    public Boolean success;

    @AuraEnabled
    public String message;

    @AuraEnabled
    public String intent;

    @AuraEnabled
    public String selectedTool;

    @AuraEnabled
    public Object toolData;

    @AuraEnabled
    public Boolean approvalRequired;

    @AuraEnabled
    public String errorMessage;

    @AuraEnabled
    public String correlationId;



    // ============================================================
    // New agent execution properties
    // ============================================================

    @AuraEnabled
    public String sessionId;

    @AuraEnabled
    public String agentStatus;

    @AuraEnabled
    public String executionStatus;

    @AuraEnabled
    public Decimal executionTime;

    @AuraEnabled
    public List<AI_AgentToolExecutionResponse> toolExecutions;


    // ============================================================
    // Default constructor
    // ============================================================

    public AI_AgentResponse() {

        this.success = false;
        this.approvalRequired = false;

        this.toolExecutions =
            new List<AI_AgentToolExecutionResponse>();
    }


    // ============================================================
    // Successful response
    // ============================================================

    public static AI_AgentResponse successResponse(
        String message,
        String intent,
        String selectedTool,
        Object toolData
    ) {

        AI_AgentResponse response =
            new AI_AgentResponse();

        response.success = true;
        response.message = message;
        response.intent = intent;
        response.selectedTool = selectedTool;
        response.toolData = toolData;
        response.approvalRequired = false;
        response.errorMessage = null;

        response.agentStatus = 'COMPLETED';
        response.executionStatus = 'SUCCESS';

        return response;
    }


    // ============================================================
    // Approval-required response
    // ============================================================

    public static AI_AgentResponse approvalRequiredResponse(
        String message,
        String intent,
        String selectedTool,
        Object toolData
    ) {

        AI_AgentResponse response =
            new AI_AgentResponse();

        response.success = false;
        response.message = message;
        response.intent = intent;
        response.selectedTool = selectedTool;
        response.toolData = toolData;
        response.approvalRequired = true;
        response.errorMessage = null;

        response.agentStatus = 'WAITING_FOR_APPROVAL';
        response.executionStatus = 'APPROVAL_REQUIRED';

        return response;
    }


    // ============================================================
    // Failure response
    // ============================================================

    public static AI_AgentResponse failureResponse(
        String message,
        String intent,
        String selectedTool,
        String errorMessage
    ) {

        AI_AgentResponse response =
            new AI_AgentResponse();

        response.success = false;
        response.message = message;
        response.intent = intent;
        response.selectedTool = selectedTool;
        response.toolData = null;
        response.approvalRequired = false;
        response.errorMessage = errorMessage;

        response.agentStatus = 'FAILED';
        response.executionStatus = 'ERROR';

        return response;
    }
}