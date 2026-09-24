@IsTest
private class AI_ToolRegistryTest {

    @TestSetup
    static void setupData() {

        insert new AI_Tool__c(
            Name = 'Test Search Customer',
            Tool_API_Name__c = 'test_search_customer',
            Description__c = 'Test customer search tool',
            Tool_Type__c = 'Salesforce',
            Active__c = true,
            Requires_Approval__c = false,
            Handler_Class__c = 'CustomerService'
        );

        insert new AI_Tool__c(
            Name = 'Inactive Tool',
            Tool_API_Name__c = 'inactive_tool',
            Description__c = 'Inactive test tool',
            Tool_Type__c = 'Salesforce',
            Active__c = false,
            Requires_Approval__c = false,
            Handler_Class__c = 'CustomerService'
        );
    }

    @IsTest
    static void testGetTool() {

        Test.startTest();

        AI_Tool__c tool =
            AI_ToolRegistry.getTool(
                'test_search_customer'
            );

        Test.stopTest();

        System.assertEquals(
            'test_search_customer',
            tool.Tool_API_Name__c
        );
    }

    @IsTest
    static void testGetActiveTool() {

        Test.startTest();

        AI_Tool__c tool =
            AI_ToolRegistry.getActiveTool(
                'test_search_customer'
            );

        Test.stopTest();

        System.assertEquals(
            true,
            tool.Active__c
        );
    }

    @IsTest
    static void testInactiveTool() {

        try {

            AI_ToolRegistry.getActiveTool(
                'inactive_tool'
            );

            System.assert(
                false,
                'Expected exception'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'inactive'
                )
            );
        }
    }

    @IsTest
    static void testMissingTool() {

        try {

            AI_ToolRegistry.getTool(
                'does_not_exist'
            );

            System.assert(
                false,
                'Expected exception'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Tool not found'
                )
            );
        }
    }
}
