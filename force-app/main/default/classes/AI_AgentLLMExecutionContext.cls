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


    // ============================================================
    // Tool execution tracking
    // ============================================================

    public List<AI_AgentToolExecutionResponse>
        toolExecutions;


    // ============================================================
    // Constructor
    // ============================================================

    public AI_AgentLLMExecutionContext() {

        toolCallCount = 0;

        maxToolCalls =
            DEFAULT_MAX_TOOL_CALLS;

        completed = false;

        failed = false;

        toolExecutions =
            new List<AI_AgentToolExecutionResponse>();
    }


    // ============================================================
    // Check whether another tool call is allowed
    // ============================================================

    public Boolean canContinue() {

        return toolCallCount < maxToolCalls;
    }


    // ============================================================
    // Record a tool call
    // ============================================================

    public void recordToolCall() {

        toolCallCount++;
    }


    // ============================================================
    // Mark execution as completed
    // ============================================================

    public void markCompleted() {

        completed = true;

        failed = false;
    }


    // ============================================================
    // Mark execution as failed
    // ============================================================

    public void markFailed(
        String reason
    ) {

        failed = true;

        completed = false;

        failureReason = reason;
    }
}