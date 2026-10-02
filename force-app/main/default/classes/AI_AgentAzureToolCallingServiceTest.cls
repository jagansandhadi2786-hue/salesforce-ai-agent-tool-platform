
@IsTest
private class AI_AgentAzureToolCallingServiceTest {


    /*
     * =========================================================
     * MOCK 1
     *
     * Azure returns a normal assistant response.
     * =========================================================
     */
    private class AzureSuccessMock
        implements HttpCalloutMock {

        public HttpResponse respond(
            HttpRequest request
        ) {

            HttpResponse response =
                new HttpResponse();

            response.setStatusCode(200);

            response.setHeader(
                'Content-Type',
                'application/json'
            );

            response.setBody(
                '{' +
                    '"id":"resp_test_001",' +
                    '"output":[' +
                        '{' +
                            '"type":"message",' +
                            '"content":[' +
                                '{' +
                                    '"type":"output_text",' +
                                    '"text":"Customer Acme was found."' +
                                '}' +
                            ']' +
                        '}' +
                    ']' +
                '}'
            );

            return response;
        }
    }


    /*
     * =========================================================
     * MOCK 2
     *
     * Azure returns HTTP 500.
     * =========================================================
     */
    private class AzureErrorMock
        implements HttpCalloutMock {

        public HttpResponse respond(
            HttpRequest request
        ) {

            HttpResponse response =
                new HttpResponse();

            response.setStatusCode(500);

            response.setHeader(
                'Content-Type',
                'application/json'
            );

            response.setBody(
                '{' +
                    '"error":{' +
                        '"message":"Azure service unavailable"' +
                    '}' +
                '}'
            );

            return response;
        }
    }


    /*
     * =========================================================
     * TEST 1
     *
     * Normal Azure response.
     * =========================================================
     */
    @IsTest
    static void testProcessSuccess() {

        Test.setMock(
            HttpCalloutMock.class,
            new AzureSuccessMock()
        );

        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentAzureToolCallingService.process(
                'Find customer Acme'
            );

        Test.stopTest();


        System.assertNotEquals(
            null,
            response,
            'Azure response should not be null.'
        );

        System.assertEquals(
            false,
            response.requiresToolCall,
            'Response should not require a tool call.'
        );

        System.assertNotEquals(
            null,
            response.assistantMessage,
            'Assistant message should not be null.'
        );

        System.assert(
            response.assistantMessage.contains(
                'Customer Acme was found.'
            ),
            'Assistant message should contain the expected text.'
        );
    }


    /*
     * =========================================================
     * TEST 2
     *
     * Blank message.
     * =========================================================
     */
    @IsTest
    static void testProcessBlankMessage() {

        Boolean exceptionThrown = false;

        Test.startTest();

        try {

            AI_AgentAzureToolCallingService.process(
                ''
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;

            System.assertEquals(
                'User message is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();


        System.assertEquals(
            true,
            exceptionThrown,
            'Expected AI_ServiceException for blank message.'
        );
    }


    /*
     * =========================================================
     * TEST 3
     *
     * Null message.
     * =========================================================
     */
    @IsTest
    static void testProcessNullMessage() {

        Boolean exceptionThrown = false;

        Test.startTest();

        try {

            AI_AgentAzureToolCallingService.process(
                null
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;

            System.assertEquals(
                'User message is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();


        System.assertEquals(
            true,
            exceptionThrown,
            'Expected AI_ServiceException for null message.'
        );
    }


    /*
     * =========================================================
     * TEST 4
     *
     * Orchestrator success.
     *
     * This validates:
     *
     * Orchestrator
     *      ↓
     * Azure Tool Calling Service
     *      ↓
     * Azure OpenAI Service
     *      ↓
     * Azure response parser
     *      ↓
     * AI_AgentLLMResponse
     * =========================================================
     */
    @IsTest
    static void testOrchestratorSuccess() {

        Test.setMock(
            HttpCalloutMock.class,
            new AzureSuccessMock()
        );


        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();


        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentAzureOrchestrator.execute(
                'Find customer Acme',
                context
            );

        Test.stopTest();


        System.assertNotEquals(
            null,
            response,
            'Orchestrator response should not be null.'
        );

        System.assertEquals(
            'Find customer Acme',
            context.userMessage,
            'Execution context should contain user message.'
        );

        System.assertEquals(
            'resp_test_001',
            context.azureResponseId,
            'Execution context should contain Azure response ID.'
        );

        System.assertEquals(
            true,
            context.completed,
            'Execution context should be completed.'
        );

        System.assertEquals(
            false,
            context.failed,
            'Execution context should not be failed.'
        );

        System.assertEquals(
            false,
            response.requiresToolCall,
            'Final response should not require a tool call.'
        );
    }


    /*
     * =========================================================
     * TEST 5
     *
     * Orchestrator with null context.
     * =========================================================
     */
    @IsTest
    static void testOrchestratorNullContext() {

        Boolean exceptionThrown = false;

        Test.startTest();

        try {

            AI_AgentAzureOrchestrator.execute(
                'Find customer Acme',
                null
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;

            System.assertEquals(
                'LLM execution context is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();


        System.assertEquals(
            true,
            exceptionThrown,
            'Expected AI_ServiceException for null context.'
        );
    }


    /*
     * =========================================================
     * TEST 6
     *
     * Orchestrator with blank message.
     * =========================================================
     */
    @IsTest
    static void testOrchestratorBlankMessage() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        Boolean exceptionThrown = false;


        Test.startTest();

        try {

            AI_AgentAzureOrchestrator.execute(
                '',
                context
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;

            System.assertEquals(
                'User message is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();


        System.assertEquals(
            true,
            exceptionThrown,
            'Expected AI_ServiceException.'
        );

        System.assertEquals(
            true,
            context.failed,
            'Context should be marked failed.'
        );

        System.assertEquals(
            false,
            context.completed,
            'Context should not be completed.'
        );

        System.assertEquals(
            'User message is required.',
            context.failureReason,
            'Failure reason should be recorded.'
        );
    }


    /*
     * =========================================================
     * TEST 7
     *
     * Azure HTTP failure.
     * =========================================================
     */
    @IsTest
    static void testAzureHttpError() {

        Test.setMock(
            HttpCalloutMock.class,
            new AzureErrorMock()
        );


        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();


        Boolean exceptionThrown = false;


        Test.startTest();

        try {

            AI_AgentAzureOrchestrator.execute(
                'Find customer Acme',
                context
            );

        } catch (Exception ex) {

            exceptionThrown = true;

            System.assertNotEquals(
                null,
                ex.getMessage(),
                'Exception message should not be null.'
            );
        }

        Test.stopTest();


        System.assertEquals(
            true,
            exceptionThrown,
            'Expected Azure HTTP error.'
        );

        System.assertEquals(
            true,
            context.failed,
            'Context should be marked failed.'
        );

        System.assertEquals(
            false,
            context.completed,
            'Context should not be completed.'
        );
    }
}