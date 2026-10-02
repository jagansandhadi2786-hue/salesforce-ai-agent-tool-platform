public class AI_AgentLLMExecutionContext {

    public static final Integer DEFAULT_MAX_TOOL_CALLS = 5;

    public String sessionId;

    public Id sessionRecordId;

    public Id interactionRecordId;

    public String userMessage;

    public String azureResponseId;

    public Integer toolCallCount;

    public Integer maxToolCalls;

    public Boolean completed;

    public Boolean failed;

    public String failureReason;


    public AI_AgentLLMExecutionContext() {

        toolCallCount = 0;

        maxToolCalls =
            DEFAULT_MAX_TOOL_CALLS;

        completed = false;

        failed = false;
    }


    public Boolean canContinue() {

        return toolCallCount < maxToolCalls;
    }


    public void recordToolCall() {

        toolCallCount++;
    }


    public void markCompleted() {

        completed = true;

        failed = false;
    }


    public void markFailed(
        String reason
    ) {

        failed = true;

        completed = false;

        failureReason = reason;
    }
}
