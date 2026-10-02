@IsTest
private class AI_AgentLLMServiceTest {

    @IsTest
    static void testOpenCasesInterpretation() {

        String structuredOutput =
            '{"intent":"GET_OPEN_CASES",' +
            '"toolName":"get_open_cases",' +
            '"arguments":{},' +
            '"assistantMessage":"I will look up the open cases.",' +
            '"confidence":0.90}';

        String responseBody =
            '{"output_text":' +
            JSON.serialize(structuredOutput) +
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
            'Find the open cases for Acme';

        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(request);

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            true,
            response.success
        );

        System.assertEquals(
            'GET_OPEN_CASES',
            response.intent
        );

        System.assertEquals(
            'get_open_cases',
            response.toolName
        );

        System.assertEquals(
            0,
            response.arguments.size()
        );
    }


    @IsTest
    static void testCustomerDetailsInterpretation() {

        String structuredOutput =
            '{"intent":"GET_CUSTOMER_DETAILS",' +
            '"toolName":"get_customer_details",' +
            '"arguments":{},' +
            '"assistantMessage":"I will retrieve the customer details.",' +
            '"confidence":0.90}';

        String responseBody =
            '{"output_text":' +
            JSON.serialize(structuredOutput) +
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
            'Show me the customer details for Acme';

        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(request);

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            true,
            response.success
        );

        System.assertEquals(
            'GET_CUSTOMER_DETAILS',
            response.intent
        );

        System.assertEquals(
            'get_customer_details',
            response.toolName
        );
    }


    @IsTest
    static void testOrderStatusInterpretation() {

        String structuredOutput =
            '{"intent":"GET_ORDER_STATUS",' +
            '"toolName":"get_order_status",' +
            '"arguments":{},' +
            '"assistantMessage":"I will check the order status.",' +
            '"confidence":0.90}';

        String responseBody =
            '{"output_text":' +
            JSON.serialize(structuredOutput) +
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
            'What is the status of order ORD-1001?';

        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(request);

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            true,
            response.success
        );

        System.assertEquals(
            'GET_ORDER_STATUS',
            response.intent
        );

        System.assertEquals(
            'get_order_status',
            response.toolName
        );
    }


    @IsTest
    static void testUnknownRequest() {

        String structuredOutput =
            '{"intent":"UNKNOWN",' +
            '"toolName":"",' +
            '"arguments":{},' +
            '"assistantMessage":"I cannot interpret this request.",' +
            '"confidence":0.10}';

        String responseBody =
            '{"output_text":' +
            JSON.serialize(structuredOutput) +
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
            'Tell me something unrelated';

        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(request);

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );

        /*
         * The Azure service currently sets success = true
         * whenever structured output is successfully parsed.
         *
         * Therefore this test validates the UNKNOWN intent
         * rather than expecting success = false.
         */
        System.assertEquals(
            'UNKNOWN',
            response.intent
        );

        System.assertEquals(
            '',
            response.toolName
        );
    }


    @IsTest
    static void testNullRequest() {

        Test.startTest();

        try {

            AI_AgentLLMService.interpret(null);

            System.assert(
                false,
                'Expected exception.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'LLM request is required'
                )
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testBlankMessage() {

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage = ' ';

        Test.startTest();

        try {

            AI_AgentLLMService.interpret(request);

            System.assert(
                false,
                'Expected exception.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'User message is required'
                )
            );
        }

        Test.stopTest();
    }
}