public class AI_AgentLLMResponse {

    public Boolean success;

    public String intent;

    public String toolName;

    public Map<String, Object> arguments;

    public String assistantMessage;

    public Decimal confidence;

    public String errorMessage;

    public Boolean requiresToolCall;

    public String responseId;

    public List<AI_AgentLLMToolCall> toolCalls;


    public AI_AgentLLMResponse() {

        success = false;

        arguments = new Map<String, Object>();

        toolCalls = new List<AI_AgentLLMToolCall>();

        requiresToolCall = false;
    }


    public Boolean isValid() {

        return success == true
            && !String.isBlank(intent)
            && (
                !String.isBlank(toolName)
                || (toolCalls != null && !toolCalls.isEmpty())
            );
    }
}