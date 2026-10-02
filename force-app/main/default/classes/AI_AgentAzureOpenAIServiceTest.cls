@IsTest
private class AI_AgentAzureOpenAIServiceTest {

    @IsTest
    static void testNativeFunctionCallResponse() {

        String responseBody =
            '{' +
                '"id":"resp_123",' +
                '"output":[' +
                    '{' +
                        '"type":"function_call",' +
                        '"call_id":"call_123",' +
                        '"name":"search_customer",' +
                        '"arguments":"{\\"customer_name\\":\\"Acme\\"}"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureOpenAIHttpMock(
                200,
                responseBody
            )
        );

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Find customer Acme';

        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentAzureOpenAIService.generate(
                request
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response,
            'LLM response must not be null.'
        );

        System.assertEquals(
            true,
            response.success,
            'Response should be successful.'
        );

        System.assertEquals(
            true,
            response.requiresToolCall,
            'Response should require a tool call.'
        );

        System.assertEquals(
            1,
            response.toolCalls.size(),
            'Exactly one tool call should be returned.'
        );

        AI_AgentLLMToolCall toolCall =
            response.toolCalls[0];

        System.assertEquals(
            'call_123',
            toolCall.callId,
            'Tool call ID should be parsed correctly.'
        );

        System.assertEquals(
            'search_customer',
            toolCall.toolName,
            'Tool name should be parsed correctly.'
        );

        System.assertEquals(
            'Acme',
            String.valueOf(
                toolCall.arguments.get(
                    'customer_name'
                )
            ),
            'Tool argument should be parsed correctly.'
        );
    }


    @IsTest
    static void testHttp500() {

        String responseBody =
            '{"error":{"message":"Internal server error"}}';

        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureOpenAIHttpMock(
                500,
                responseBody
            )
        );

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Find customer Acme';

        Test.startTest();

        try {

            AI_AgentAzureOpenAIService.generate(
                request
            );

            System.assert(
                false,
                'Expected Azure OpenAI exception.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Azure OpenAI request failed.',
                ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testInvalidJson() {

        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureOpenAIHttpMock(
                200,
                'NOT VALID JSON'
            )
        );

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Find customer Acme';

        Test.startTest();

        try {

            AI_AgentAzureOpenAIService.generate(
                request
            );

            System.assert(
                false,
                'Expected invalid response exception.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Azure OpenAI returned an invalid response.',
                ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testMissingOutput() {

        String responseBody =
            '{"id":"resp_123"}';

        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureOpenAIHttpMock(
                200,
                responseBody
            )
        );

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Find customer Acme';

        Test.startTest();

        try {

            AI_AgentAzureOpenAIService.generate(
                request
            );

            System.assert(
                false,
                'Expected invalid response exception.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Azure OpenAI returned an invalid response.',
                ex.getMessage()
            );
        }

        Test.stopTest();
    }
}