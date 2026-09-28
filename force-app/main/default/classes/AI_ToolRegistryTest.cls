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

        System.assertNotEquals(
            null,
            tool,
            'Expected registered tool to be returned.'
        );

        System.assertEquals(
            'test_search_customer',
            tool.Tool_API_Name__c
        );

        System.assertEquals(
            true,
            tool.Active__c
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

        System.assertNotEquals(
            null,
            tool,
            'Expected active tool to be returned.'
        );

        System.assertEquals(
            'test_search_customer',
            tool.Tool_API_Name__c
        );

        System.assertEquals(
            true,
            tool.Active__c
        );
    }

    @IsTest
    static void testInactiveTool() {

        Boolean exceptionThrown = false;

        try {

            AI_ToolRegistry.getActiveTool(
                'inactive_tool'
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;

            System.assertEquals(
                'Tool is not registered or not active.',
                ex.getMessage()
            );
        }

        System.assertEquals(
            true,
            exceptionThrown,
            'Expected AI_ServiceException for inactive tool.'
        );
    }

    @IsTest
    static void testMissingTool() {

        Test.startTest();

        AI_Tool__c tool =
            AI_ToolRegistry.getTool(
                'does_not_exist'
            );

        Test.stopTest();

        System.assertEquals(
            null,
            tool,
            'getTool should return null when the tool is not registered.'
        );
    }

    @IsTest
    static void testMissingActiveTool() {

        Boolean exceptionThrown = false;

        try {

            AI_ToolRegistry.getActiveTool(
                'does_not_exist'
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;

            System.assertEquals(
                'Tool is not registered or not active.',
                ex.getMessage()
            );
        }

        System.assertEquals(
            true,
            exceptionThrown,
            'Expected AI_ServiceException for missing active tool.'
        );
    }

    @IsTest
    static void testBlankToolName() {

        Test.startTest();

        AI_Tool__c tool =
            AI_ToolRegistry.getTool('');

        Test.stopTest();

        System.assertEquals(
            null,
            tool,
            'Blank tool name should return null.'
        );
    }

@IsTest
static void testBlankActiveToolName() {

    Test.startTest();

    AI_Tool__c tool =
        AI_ToolRegistry.getActiveTool('');

    Test.stopTest();

    System.assertEquals(
        null,
        tool,
        'Blank tool name should return null.'
    );
}
}