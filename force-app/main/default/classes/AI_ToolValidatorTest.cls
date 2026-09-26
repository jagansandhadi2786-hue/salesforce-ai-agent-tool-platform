@IsTest
private class AI_ToolValidatorTest {

    private static AI_Tool__c createTool() {

        return new AI_Tool__c(
            Name = 'Test Tool',
            Tool_API_Name__c = 'test_tool',
            Active__c = true,
            Tool_Type__c = 'Salesforce',
            Allowed_Arguments__c =
                'customer_name,priority',
            Required_Arguments__c =
                'customer_name'
        );
    }


    @IsTest
    static void testValidArguments() {

        AI_Tool__c tool =
            createTool();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'test_tool',
                new Map<String, Object>{
                    'customer_name' => 'Acme',
                    'priority' => 'High'
                }
            );

        Test.startTest();

        AI_ToolValidator.validate(
            request,
            tool
        );

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testUnknownArgument() {

        AI_Tool__c tool =
            createTool();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'test_tool',
                new Map<String, Object>{
                    'customer_name' => 'Acme',
                    'unknown' => 'value'
                }
            );

        try {

            AI_ToolValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Expected validation failure.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'not allowed'
                )
            );
        }
    }


    @IsTest
    static void testMissingRequiredArgument() {

        AI_Tool__c tool =
            createTool();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'test_tool',
                new Map<String, Object>()
            );

        try {

            AI_ToolValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Expected validation failure.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Required argument missing'
                )
            );
        }
    }


    @IsTest
    static void testBlankRequiredArgument() {

        AI_Tool__c tool =
            createTool();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'test_tool',
                new Map<String, Object>{
                    'customer_name' => ''
                }
            );

        try {

            AI_ToolValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Expected validation failure.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'blank'
                )
            );
        }
    }
}
