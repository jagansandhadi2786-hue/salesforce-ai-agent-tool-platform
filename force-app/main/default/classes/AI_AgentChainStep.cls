public class AI_AgentChainStep {
    public Integer stepNumber;
    public String toolName;
    public Map<String, Object> arguments;
    public String status;
    public String reason;

    public AI_AgentChainStep() {

        arguments =
            new Map<String, Object>();
    }
}