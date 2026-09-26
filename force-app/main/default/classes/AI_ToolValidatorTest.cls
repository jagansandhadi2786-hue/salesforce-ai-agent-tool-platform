@IsTest
private class AI_ToolValidatorTest {

    private static AI_Tool__c createTool(String toolApiName) {

        return new AI_Tool__c(
            Name = 'Test Tool',
            Tool_API_Name__c = toolApiName,
            Active__c = true,
            Tool_Type__c = 'Salesforce'
        );
    }


    @IsTest
    static void testValidRequest() {

        AI_Tool__c tool =
            createTool('search_customer');

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>{
                    'customer_name' => 'Acme'
                }
            );

        Test.startTest();

        AI_ToolValidator.validate(
            request,
            tool
        );

        Test.stopTest();

        System.assert(
            true,
            'Valid request should pass validation.'
        );
    }


    @IsTest
    static void testNullRequest() {

        try {

            AI_ToolValidator.validate(
                null,
                createTool('search_customer')
            );

            System.assert(
                false,
                'Expected validation failure for null request.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool request is required.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testMissingToolName() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                '',
                new Map<String, Object>()
            );

        try {

            AI_ToolValidator.validate(
                request,
                createTool('search_customer')
            );

            System.assert(
                false,
                'Expected validation failure for missing tool name.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool name is required.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testUnknownToolName() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'unknown_tool',
                new Map<String, Object>()
            );

        try {

            AI_ToolValidator.validate(
                request,
                createTool('unknown_tool')
            );

            System.assert(
                false,
                'Expected validation failure for unknown tool.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Unknown tool: unknown_tool'
                ),
                'Unexpected error: ' + ex.getMessage()
            );
        }
    }


    @IsTest
    static void testNullRegisteredTool() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>{
                    'customer_name' => 'Acme'
                }
            );

        try {

            AI_ToolValidator.validate(
                request,
                null
            );

            System.assert(
                false,
                'Expected validation failure for null registered tool.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool is not registered or not active.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testMissingToolApiName() {

        AI_Tool__c tool =
            new AI_Tool__c(
                Name = 'Test Tool',
                Active__c = true,
                Tool_Type__c = 'Salesforce'
            );

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>()
            );

        try {

            AI_ToolValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Expected validation failure for missing API name.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool API name is required.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testToolNameMismatch() {

        AI_Tool__c tool =
            createTool('get_customer_details');

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>()
            );

        try {

            AI_ToolValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Expected validation failure for tool mismatch.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool request does not match the registered tool.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testValidateToolName() {

        Test.startTest();

        AI_ToolValidator.validateToolName(
            'search_customer'
        );

        AI_ToolValidator.validateToolName(
            'get_customer_details'
        );

        AI_ToolValidator.validateToolName(
            'get_open_cases'
        );

        AI_ToolValidator.validateToolName(
            'get_case_details'
        );

        AI_ToolValidator.validateToolName(
            'create_case'
        );

        AI_ToolValidator.validateToolName(
            'update_case'
        );

        AI_ToolValidator.validateToolName(
            'create_task'
        );

        AI_ToolValidator.validateToolName(
            'escalate_case'
        );

        AI_ToolValidator.validateToolName(
            'search_knowledge'
        );

        AI_ToolValidator.validateToolName(
            'get_order_status'
        );

        Test.stopTest();

        System.assert(
            true,
            'All configured tool names should be accepted.'
        );
    }


    @IsTest
    static void testValidateToolNameBlank() {

        try {

            AI_ToolValidator.validateToolName('');

            System.assert(
                false,
                'Expected validation failure for blank tool name.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool name is required.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testValidateArgumentsNull() {

        try {

            AI_ToolValidator.validateArguments(
                null
            );

            System.assert(
                false,
                'Expected validation failure for null arguments.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool arguments are required.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testValidateArgumentsProvided() {

        Map<String, Object> arguments =
            new Map<String, Object>{
                'customer_name' => 'Acme'
            };

        Test.startTest();

        AI_ToolValidator.validateArguments(
            arguments
        );

        Test.stopTest();

        System.assert(
            true,
            'Provided arguments should pass generic validation.'
        );
    }
}