public class AI_AgentContext {

    public static final Integer MAX_CHAIN_DEPTH = 5;

    public String userMessage;

    public AI_AgentIntent intent;

    public String currentTool;

    public Map<String, Object> arguments;

    public List<AI_ToolResponse> toolResponses;

    public Integer stepNumber;

    public Integer maxDepth;

    public Boolean completed;

    public String failureReason;

    // Salesforce AI Agent session record ID
    public Id sessionRecordId;

    // Business/session identifier
    public String sessionId;

    // Complete Salesforce session record
    public AI_Agent_Session__c sessionRecord;


    public AI_AgentContext() {

        arguments =
            new Map<String, Object>();

        toolResponses =
            new List<AI_ToolResponse>();

        stepNumber = 0;

        maxDepth =
            MAX_CHAIN_DEPTH;

        completed = false;
    }


    public Boolean canExecuteNextStep() {

        return stepNumber < maxDepth;
    }


    public void recordToolResponse(
        AI_ToolResponse response
    ) {

        if (response != null) {

            toolResponses.add(
                response
            );
        }
    }

    public Integer getExecutedStepCount() {

        return toolResponses.size();
    }
}