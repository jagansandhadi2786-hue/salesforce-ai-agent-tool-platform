@IsTest
private class AI_AgentLLMServiceTest {


    @IsTest
    static void testOpenCasesInterpretation() {

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Find the open cases for Acme';


        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(
                request
            );

        Test.stopTest();


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
    }


    @IsTest
    static void testCustomerDetailsInterpretation() {

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Show me the customer details for Acme';


        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(
                request
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

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'What is the status of order ORD-1001?';


        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(
                request
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

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Tell me something unrelated';


        AI_AgentLLMResponse response =
            AI_AgentLLMService.interpret(
                request
            );


        System.assertEquals(
            false,
            response.success
        );
    }


    @IsTest
    static void testNullRequest() {

        try {

            AI_AgentLLMService.interpret(
                null
            );

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
    }


    @IsTest
    static void testBlankMessage() {

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage = ' ';


        try {

            AI_AgentLLMService.interpret(
                request
            );

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
    }
}
