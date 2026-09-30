@IsTest
private class AI_AgentOrchestratorTest {
    @TestSetup
static void setupToolRegistry() {

    List<AI_Tool__c> tools = new List<AI_Tool__c>();

    tools.add(
        new AI_Tool__c(
            Name = 'Search Customer',
            Tool_API_Name__c = 'search_customer',
            Description__c = 'Search Salesforce customers by customer name.',
            Active__c = true,
            Requires_Approval__c = false,
            Tool_Type__c = 'Salesforce',
            Allowed_Arguments__c = 'customer_name'
        )
    );

    tools.add(
        new AI_Tool__c(
            Name = 'Get Customer Details',
            Tool_API_Name__c = 'get_customer_details',
            Description__c = 'Retrieve customer details using a Salesforce Account ID.',
            Active__c = true,
            Requires_Approval__c = false,
            Tool_Type__c = 'Salesforce',
            Allowed_Arguments__c = 'customer_id'
        )
    );

    tools.add(
        new AI_Tool__c(
            Name = 'Get Open Cases',
            Tool_API_Name__c = 'get_open_cases',
            Description__c = 'Retrieve open customer cases for a Salesforce Account.',
            Active__c = true,
            Requires_Approval__c = false,
            Tool_Type__c = 'Salesforce',
            Allowed_Arguments__c = 'account_id'
        )
    );

    tools.add(
        new AI_Tool__c(
            Name = 'Get Order Status',
            Tool_API_Name__c = 'get_order_status',
            Description__c = 'Retrieve order status from the order-management integration.',
            Active__c = true,
            Requires_Approval__c = false,
            Tool_Type__c = 'REST',
            Allowed_Arguments__c = 'order_number'
        )
    );

    insert tools;
}

    private static Account createTestAccount() {

        Account accountRecord = new Account(
            Name = 'Acme AI Agent Test',
            Phone = '555-0200',
            Industry = 'Technology',
            BillingCity = 'Hyderabad'
        );

        insert accountRecord;

        return accountRecord;
    }


    private static AI_AgentRequest buildRequest(
        String message
    ) {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage = message;

        return request;
    }


    @IsTest
    static void testSearchCustomerEndToEnd() {

        Account accountRecord =
            createTestAccount();

        AI_AgentRequest request =
            buildRequest(
                'Find customer Acme'
            );

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentOrchestrator.process(request);

        Test.stopTest();


        System.assertNotEquals(
            null,
            response,
            'Agent response should not be null.'
        );

        System.assertEquals(
            'SEARCH_CUSTOMER',
            response.intent,
            'Intent should be SEARCH_CUSTOMER.'
        );

        System.assertEquals(
            'search_customer',
            response.selectedTool,
            'Selected tool should be search_customer.'
        );
    }


    @IsTest
    static void testOpenCasesRequiresResolution() {

        AI_AgentRequest request =
            buildRequest(
                'Find the open cases for Acme'
            );

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentOrchestrator.process(request);

        Test.stopTest();


        System.assertNotEquals(
            null,
            response,
            'Response should not be null.'
        );

        System.assertEquals(
            'GET_OPEN_CASES',
            response.intent,
            'Intent should be GET_OPEN_CASES.'
        );

        System.assertEquals(
            'get_open_cases',
            response.selectedTool,
            'Tool should be get_open_cases.'
        );

        System.assertEquals(
            false,
            response.success,
            'Request should wait for argument resolution.'
        );
    }


    @IsTest
    static void testNullRequest() {

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentOrchestrator.process(null);

        Test.stopTest();


        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            'Agent request is required.',
            response.errorMessage
        );
    }


    @IsTest
    static void testBlankMessage() {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage = '';


        Test.startTest();

        AI_AgentResponse response =
            AI_AgentOrchestrator.process(request);

        Test.stopTest();


        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            'User message is required.',
            response.errorMessage
        );
    }


    @IsTest
    static void testOrderStatusEndToEnd() {

        AI_AgentRequest request =
            buildRequest(
                'What is the status of order ORD-1001?'
            );

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentOrchestrator.process(request);

        Test.stopTest();


        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            'GET_ORDER_STATUS',
            response.intent
        );

        System.assertEquals(
            'get_order_status',
            response.selectedTool
        );
    }


    @IsTest
    static void testCustomerDetailsWithoutIdRequiresResolution() {

        AI_AgentRequest request =
            buildRequest(
                'Show me customer details for Acme'
            );

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentOrchestrator.process(request);

        Test.stopTest();


        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            'GET_CUSTOMER_DETAILS',
            response.intent
        );

        System.assertEquals(
            'get_customer_details',
            response.selectedTool
        );

        System.assertEquals(
            false,
            response.success
        );
    }
}