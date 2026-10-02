@IsTest
private class AI_AgentAzureOpenAIResponseParserTest {

    @IsTest
    static void testParseFunctionCall() {

        String body =
            '{' +
                '"id":"resp_001",' +
                '"output":[' +
                    '{' +
                        '"type":"function_call",' +
                        '"call_id":"call_001",' +
                        '"name":"search_customer",' +
                        '"arguments":"{\\"customer_name\\":\\"Acme\\"}"' +
                    '}' +
                ']' +
            '}';

        AI_AgentLLMResponse response =
            AI_AgentAzureOpenAIResponseParser.parse(
                body
            );

        System.assertEquals(
            true,
            response.requiresToolCall
        );

        System.assertEquals(
            1,
            response.toolCalls.size()
        );

        System.assertEquals(
            'search_customer',
            response.toolCalls[0].toolName
        );

        System.assertEquals(
            'Acme',
            (String)
                response.toolCalls[0]
                    .arguments
                    .get('customer_name')
        );
    }


    @IsTest
    static void testMissingCallId() {

        String body =
            '{' +
                '"output":[' +
                    '{' +
                        '"type":"function_call",' +
                        '"name":"search_customer",' +
                        '"arguments":"{\\"customer_name\\":\\"Acme\\"}"' +
                    '}' +
                ']' +
            '}';

        try {

            AI_AgentAzureOpenAIResponseParser.parse(
                body
            );

            System.assert(
                false,
                'Expected missing call_id error.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Azure function call is missing call_id.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testMissingToolName() {

        String body =
            '{' +
                '"output":[' +
                    '{' +
                        '"type":"function_call",' +
                        '"call_id":"call_001",' +
                        '"arguments":"{}"' +
                    '}' +
                ']' +
            '}';

        try {

            AI_AgentAzureOpenAIResponseParser.parse(
                body
            );

            System.assert(
                false,
                'Expected missing tool name error.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Azure function call is missing tool name.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testInvalidArguments() {

        String body =
            '{' +
                '"output":[' +
                    '{' +
                        '"type":"function_call",' +
                        '"call_id":"call_001",' +
                        '"name":"search_customer",' +
                        '"arguments":"NOT JSON"' +
                    '}' +
                ']' +
            '}';

        try {

            AI_AgentAzureOpenAIResponseParser.parse(
                body
            );

            System.assert(
                false,
                'Expected invalid arguments error.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Azure function arguments are invalid.',
                ex.getMessage()
            );
        }
    }
    @IsTest
static void testNormalMessage() {

    String body =
        '{' +
            '"id":"resp_002",' +
            '"output":[' +
                '{' +
                    '"type":"message",' +
                    '"content":[' +
                        '{' +
                            '"type":"output_text",' +
                            '"text":"Hello. How can I help?"' +
                        '}' +
                    ']' +
                '}' +
            ']' +
        '}';

    AI_AgentLLMResponse response =
        AI_AgentAzureOpenAIResponseParser.parse(
            body
        );

    System.assertEquals(
        false,
        response.requiresToolCall
    );

    System.assertEquals(
        'Hello. How can I help?',
        response.assistantMessage
    );
}
@IsTest
static void testCalloutException() {

    Test.setMock(
        HttpCalloutMock.class,
        new AI_AgentAzureOpenAIHttpMock(
            200,
            ''
        )
    );

    /*
     * Empty response is handled without making
     * a real Azure callout.
     */

    Test.startTest();

    try {

        AI_AgentAzureOpenAIService.generate(
            'Hello'
        );

        System.assert(
            false,
            'Expected Azure response exception.'
        );

    } catch (AI_ServiceException ex) {

        System.assert(
            ex.getMessage().contains(
                'Azure OpenAI'
            )
        );
    }

    Test.stopTest();
}

}
