public class AI_AgentLLMRequest {

    public String sessionId;
    public String userMessage;

    public List<String> availableTools;

    public AI_AgentLLMRequest() {
        availableTools = new List<String>();
    }

    public Boolean isValid() {
        return !String.isBlank(userMessage);
    }
}
