@IsTest
private class AI_AgentLLMResponseValidatorTest {

    @IsTest
    static void testUnknownToolRejected() {

        AI_AgentLLMResponse response = new AI_AgentLLMResponse();

        response.success = true;
        response.intent = 'DELETE_CASES';
        response.toolName = 'delete_all_cases';

        try {

            AI_AgentLLMResponseValidator.validate(
                response
            );

            System.assert(
                false,
                'Unknown tool should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'unregistered tool'
                ),
                'Expected an unregistered tool error, but received: '
                + ex.getMessage()
            );
        }
    }
}