@IsTest
private class AI_AgentLLMExecutionContextTest {

    @IsTest
    static void testDefaultContext() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        System.assertEquals(
            0,
            context.toolCallCount
        );

        System.assertEquals(
            5,
            context.maxToolCalls
        );

        System.assertEquals(
            true,
            context.canContinue()
        );
    }


    @IsTest
    static void testToolCallCount() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        context.recordToolCall();

        System.assertEquals(
            1,
            context.toolCallCount
        );
    }


    @IsTest
    static void testMaximumToolCalls() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        for (
            Integer i = 0;
            i < 5;
            i++
        ) {

            context.recordToolCall();
        }

        System.assertEquals(
            false,
            context.canContinue()
        );
    }


    @IsTest
    static void testCompleted() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        context.markCompleted();

        System.assertEquals(
            true,
            context.completed
        );

        System.assertEquals(
            false,
            context.failed
        );
    }


    @IsTest
    static void testFailed() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        context.markFailed(
            'Test failure'
        );

        System.assertEquals(
            true,
            context.failed
        );

        System.assertEquals(
            'Test failure',
            context.failureReason
        );
    }
}
