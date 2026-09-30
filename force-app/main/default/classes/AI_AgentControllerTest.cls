
@IsTest
private class AI_AgentControllerTest {

    @TestSetup
    static void setupTestData() {

        List<AI_Tool__c> tools = new List<AI_Tool__c>();

        tools.add(new AI_Tool__c(
            Name = 'Search Customer',
            Tool_API_Name__c = 'search_customer',
            Description__c = 'Searches for a customer.',
            Active__c = true,
            Handler_Class__c = 'AI_ToolExecutor',
            Requires_Approval__c = false,
            Tool_Type__c = 'Salesforce',
            Allowed_Arguments__c = 'customer_name'
        ));

        tools.add(new AI_Tool__c(
            Name = 'Get Order Status',
            Tool_API_Name__c = 'get_order_status',
            Description__c = 'Gets the status of an order.',
            Active__c = true,
            Handler_Class__c = 'AI_ToolExecutor',
            Requires_Approval__c = false,
            Tool_Type__c = 'REST',
            Allowed_Arguments__c = 'order_number'
        ));

        insert tools;
    }


    @IsTest
    static void testProcessMessage() {

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentController.processMessage(
                'Find customer Acme'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response,
            'Controller should return an Agent response.'
        );

        System.assertEquals(
            'SEARCH_CUSTOMER',
            response.intent,
            'Intent should be SEARCH_CUSTOMER.'
        );

        System.assertEquals(
            'search_customer',
            response.selectedTool,
            'Tool should be search_customer.'
        );
    }


    @IsTest
    static void testBlankMessage() {

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentController.processMessage('');

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
    static void testNullMessage() {

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentController.processMessage(null);

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            false,
            response.success
        );
    }


    @IsTest
    static void testOrderStatusRequest() {

        Test.startTest();

        AI_AgentResponse response =
            AI_AgentController.processMessage(
                'What is the status of order ORD-1001?'
            );

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
}