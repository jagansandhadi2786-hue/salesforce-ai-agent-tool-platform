public class AI_AgentChainResult {

    public Boolean success;

    public Boolean completed;

    public Boolean stopped;

    public String reason;

    public Integer stepsExecuted;

    public List<AI_ToolResponse> toolResponses;


    public AI_AgentChainResult() {

        success = false;

        completed = false;

        stopped = false;

        stepsExecuted = 0;

        toolResponses =
            new List<AI_ToolResponse>();
    }
}