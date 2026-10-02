@IsTest
private class AI_AgentAzureEndToEndTest {

    @IsTest
    static void testAzureEndToEndThroughOrchestrator() {

        /*
         * Create complete Salesforce test data:
         *
         * Account
         *   ↓
         * Cases
         *   ↓
         * AI_Tool__c definitions
         */
        AI_AgentE2ETestDataFactory.TestData data =
            AI_AgentE2ETestDataFactory.createCustomerScenario();

        System.assertNotEquals(
            null,
            data,
            'Test data should be created.'
        );

        System.assertNotEquals(
            null,
            data.account,
            'Test Account should be created.'
        );

        System.assertEquals(
            'Acme',
            data.account.Name,
            'Expected Acme test account.'
        );

        System.assertEquals(
            2,
            data.cases.size(),
            'Expected two test cases.'
        );


        /*
         * Reuse the existing passing Azure round-trip mock.
         *
         * The mock performs:
         *
         * Call 1:
         * search_customer
         *
         * Call 2:
         * get_open_cases
         *
         * Call 3:
         * final assistant response
         */
        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureRoundTripHttpMock(
                data.account.Id
            )
        );


        /*
         * Create execution context.
         */
        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        context.sessionId =
            'E2E-SESSION-001';

        context.sessionRecordId =
            data.account.Id;


        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentAzureOrchestrator.execute(
                'Find the open cases for Acme',
                context
            );

        Test.stopTest();


        /*
         * Validate final Azure response.
         */
        System.assertNotEquals(
            null,
            response,
            'Azure response should not be null.'
        );

        System.assertEquals(
            false,
            response.requiresToolCall,
            'Final response should not require another tool call.'
        );

        System.assertNotEquals(
            null,
            response.assistantMessage,
            'Final assistant message should exist.'
        );

        System.assert(
            response.assistantMessage.contains(
                'Acme has 2 open cases'
            ),
            'Expected final assistant response to mention two open cases.'
        );


        /*
         * Validate execution context.
         */
        System.assertEquals(
            'Find the open cases for Acme',
            context.userMessage,
            'User message should be stored in execution context.'
        );

        System.assertEquals(
            'resp_003',
            context.azureResponseId,
            'Final Azure response ID should be stored.'
        );

        System.assertEquals(
            true,
            context.completed,
            'Execution context should be marked completed.'
        );

        System.assertEquals(
            false,
            context.failed,
            'Execution context should not be marked failed.'
        );

        System.assertEquals(
            null,
            context.failureReason,
            'Successful execution should not contain a failure reason.'
        );
    }


    @IsTest
    static void testAzureEndToEndBlankMessage() {

        AI_AgentLLMExecutionContext context =
            new AI_AgentLLMExecutionContext();

        Test.startTest();

        try {

            AI_AgentAzureOrchestrator.execute(
                '',
                context
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'User message is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();


        System.assertEquals(
            true,
            context.failed,
            'Context should be marked failed.'
        );

        System.assertEquals(
            false,
            context.completed,
            'Context should not be marked completed.'
        );

        System.assertEquals(
            'User message is required.',
            context.failureReason
        );
    }


    @IsTest
    static void testAzureEndToEndNullContext() {

        Test.startTest();

        try {

            AI_AgentAzureOrchestrator.execute(
                'Find customer Acme',
                null
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'LLM execution context is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testControllerEntryPoint() {

        /*
         * AI_AgentController.processMessage()
         * accepts a String, not AI_AgentRequest.
         *
         * Therefore the controller should be called
         * with the user's message directly.
         */
        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureRoundTripHttpMock(
                createControllerTestAccount()
            )
        );

        Test.startTest();

        /*
         * IMPORTANT:
         * processMessage accepts String.
         */
        AI_AgentResponse result =
        AI_AgentController.processMessage(
        'Find the open cases for Acme'
         );

        Test.stopTest();


        System.assertNotEquals(
            null,
            result,
            'Controller should return a response.'
        );
    }


    private static Id createControllerTestAccount() {

        Account account =
            new Account(
                Name = 'Acme'
            );

        insert account;

        Case caseOne =
            new Case(
                AccountId = account.Id,
                Subject = 'Acme Case 1',
                Status = 'New',
                Priority = 'Medium'
            );

        Case caseTwo =
            new Case(
                AccountId = account.Id,
                Subject = 'Acme Case 2',
                Status = 'Working',
                Priority = 'High'
            );

        insert new List<Case>{
            caseOne,
            caseTwo
        };

        return account.Id;
    }
}