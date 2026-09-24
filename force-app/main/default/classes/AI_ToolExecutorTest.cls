@IsTest
private class AI_ToolExecutorTest {

    @TestSetup
    static void setupData() {

        Account account = new Account(
            Name = 'Acme Corporation'
        );

        insert account;

        insert new AI_Tool__c(
            Name = 'Search Customer',
            Tool_API_Name__c = 'search_customer',
            Description__c = 'Search customer',
            Tool_Type__c = 'Salesforce',
            Active__c = true,
            Requires_Approval__c = false,
            Handler_Class__c = 'CustomerService'
        );

        insert new AI_Tool__c(
            Name = 'Create Case',
            Tool_API_Name__c = 'create_case',
            Description__c = 'Create case',
            Tool_Type__c = 'Salesforce',
            Active__c = true,
            Requires_Approval__c = true,
            Handler_Class__c = 'CaseService'
        );
    }

    @IsTest
    static void testSearchCustomer() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>{
                    'customer_name' =>
                        'Acme Corporation'
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(
                request
            );

        Test.stopTest();

        System.assertEquals(
            true,
            response.success
        );

        System.assertEquals(
            'search_customer',
            response.toolName
        );

        System.assertNotEquals(
            null,
            response.data
        );
    }

    @IsTest
    static void testMissingArgument() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>()
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(
                request
            );

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assert(
            response.message.contains(
                'Required argument'
            )
        );
    }

   @IsTest
static void testApprovalRequired() {

    AI_ToolRequest request =
        new AI_ToolRequest(
            'create_case',
            new Map<String, Object>()
        );

    Test.startTest();

    AI_ToolResponse response =
        AI_ToolExecutor.execute(
            request
        );

    Test.stopTest();

    System.assertEquals(
        false,
        response.success
    );

    System.assertEquals(
        true,
        response.requiresApproval
    );
}

    @IsTest
    static void testUnknownTool() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'unknown_tool',
                new Map<String, Object>()
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(
                request
            );

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assert(
            response.message.contains(
                'Tool not found'
            )
        );
    }
}
