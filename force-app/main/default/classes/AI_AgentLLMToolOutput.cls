public with sharing class AI_AgentLLMToolOutput {

    public String callId;
    public String output;

    public AI_AgentLLMToolOutput() {
    }

    public AI_AgentLLMToolOutput(
        String callId,
        String output
    ) {
        this.callId = callId;
        this.output = output;
    }
}