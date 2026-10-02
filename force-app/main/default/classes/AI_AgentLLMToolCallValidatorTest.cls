@IsTest
private class AI_AgentLLMToolCallValidatorTest {

    @IsTest
    static void testUnknownToolRejected() {

        AI_AgentLLMToolCall toolCall =
            new AI_AgentLLMToolCall();

        toolCall.callId = 'call-malicious-001';
        toolCall.toolName = 'execute_soql';

        toolCall.arguments =
            new Map<String, Object>{
                'query' => 'SELECT Id FROM User'
            };

        AI_AgentLLMToolCallValidationResult result =
            AI_AgentLLMToolCallValidator.validate(
                toolCall
            );

        System.assertEquals(
            false,
            result.valid,
            'Unregistered tools must be rejected.'
        );
    }


    @IsTest
    static void testBlankToolRejected() {

        AI_AgentLLMToolCall toolCall =
            new AI_AgentLLMToolCall();

        toolCall.toolName = '';

        AI_AgentLLMToolCallValidationResult result =
            AI_AgentLLMToolCallValidator.validate(
                toolCall
            );

        System.assertEquals(
            false,
            result.valid,
            'Blank tool names must be rejected.'
        );
    }


    @IsTest
    static void testNullToolCallRejected() {

        AI_AgentLLMToolCallValidationResult result =
            AI_AgentLLMToolCallValidator.validate(
                null
            );

        System.assertEquals(
            false,
            result.valid,
            'Null tool calls must be rejected.'
        );
    }


    @IsTest
    static void testUnexpectedArgumentsRejected() {

        AI_AgentLLMToolCall toolCall =
            new AI_AgentLLMToolCall();

        toolCall.callId = 'call-malicious-002';
        toolCall.toolName = 'search_customer';

        toolCall.arguments =
            new Map<String, Object>{
                'customer_name' => 'Acme',
                'soql' => 'SELECT Id FROM User',
                'admin' => true
            };

        AI_AgentLLMToolCallValidationResult result =
            AI_AgentLLMToolCallValidator.validate(
                toolCall
            );

        System.assertEquals(
            false,
            result.valid,
            'Unexpected arguments must be rejected.'
        );
    }


    @IsTest
    static void testMissingRequiredArgumentRejected() {

        AI_AgentLLMToolCall toolCall =
            new AI_AgentLLMToolCall();

        toolCall.callId = 'call-invalid-003';
        toolCall.toolName = 'search_customer';

        toolCall.arguments =
            new Map<String, Object>();

        AI_AgentLLMToolCallValidationResult result =
            AI_AgentLLMToolCallValidator.validate(
                toolCall
            );

        System.assertEquals(
            false,
            result.valid,
            'Missing required arguments must be rejected.'
        );
    }
}