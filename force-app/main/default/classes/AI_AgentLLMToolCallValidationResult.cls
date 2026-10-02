public class AI_AgentLLMToolCallValidationResult {

    public Boolean valid;
    public String toolName;
    public String errorMessage;
    public Boolean approvalRequired;

    public AI_AgentLLMToolCallValidationResult() {
        valid = false;
        approvalRequired = false;
    }

    public static AI_AgentLLMToolCallValidationResult success(
        String toolName,
        Boolean approvalRequired
    ) {

        AI_AgentLLMToolCallValidationResult result =
            new AI_AgentLLMToolCallValidationResult();

        result.valid = true;
        result.toolName = toolName;
        result.approvalRequired =
            approvalRequired == true;

        return result;
    }

    public static AI_AgentLLMToolCallValidationResult failure(
        String message
    ) {

        AI_AgentLLMToolCallValidationResult result =
            new AI_AgentLLMToolCallValidationResult();

        result.valid = false;
        result.errorMessage = message;

        return result;
    }
}