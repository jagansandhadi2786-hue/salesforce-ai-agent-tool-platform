public class AI_AgentLLMToolCall {

    public String callId;
    public String toolName;
    public Map<String, Object> arguments;

    public AI_AgentLLMToolCall() {
        arguments = new Map<String, Object>();
    }
}
