@IsTest
private class AI_ToolSchemaValidatorTest {

    @IsTest
    static void testSearchCustomerValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'search_customer';

        request.arguments = new Map<String, Object>{
            'customer_name' => 'Acme'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testSearchCustomerMissingArgument() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'search_customer';

        request.arguments = new Map<String, Object>();

        Test.startTest();

        try {

            AI_ToolSchemaValidator.validate(request);

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains('customer_name'),
                'Unexpected message: ' + ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testSearchCustomerUnexpectedArgument() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'search_customer';

        request.arguments = new Map<String, Object>{
            'customer_name' => 'Acme',
            'unexpected' => 'value'
        };

        Test.startTest();

        try {

            AI_ToolSchemaValidator.validate(request);

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains('Unexpected argument'),
                'Unexpected message: ' + ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testGetCustomerDetailsValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'get_customer_details';

        request.arguments = new Map<String, Object>{
            'customer_id' => '001000000000001AAA'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testGetOpenCasesValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'get_open_cases';

        request.arguments = new Map<String, Object>{
            'account_id' => '001000000000001AAA'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testCreateCaseValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'create_case';

        request.arguments = new Map<String, Object>{
            'account_id' => '001000000000001AAA',
            'subject' => 'Test Case',
            'description' => 'Test Description',
            'priority' => 'Medium'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testUpdateCaseValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'update_case';

        request.arguments = new Map<String, Object>{
            'case_id' => '500000000000001AAA',
            'status' => 'Working'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testUpdateCaseRequiresField() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'update_case';

        request.arguments = new Map<String, Object>{
            'case_id' => '500000000000001AAA'
        };

        Test.startTest();

        try {

            AI_ToolSchemaValidator.validate(request);

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'At least one case update field'
                ),
                'Unexpected message: ' + ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testCreateTaskValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'create_task';

        request.arguments = new Map<String, Object>{
            'what_id' => '001000000000001AAA',
            'subject' => 'Follow up'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testEscalateCaseValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'escalate_case';

        request.arguments = new Map<String, Object>{
            'case_id' => '500000000000001AAA'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testSearchKnowledgeValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'search_knowledge';

        request.arguments = new Map<String, Object>{
            'search_term' => 'password reset'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testGetOrderStatusValid() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'get_order_status';

        request.arguments = new Map<String, Object>{
            'order_id' => 'ORD-10001'
        };

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }


    @IsTest
    static void testNullRequest() {

        Test.startTest();

        try {

            AI_ToolSchemaValidator.validate(null);

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool request is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testBlankToolName() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = '';

        request.arguments = new Map<String, Object>();

        Test.startTest();

        try {

            AI_ToolSchemaValidator.validate(request);

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool name is required.',
                ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testUnknownTool() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'unknown_tool';

        request.arguments = new Map<String, Object>();

        Test.startTest();

        try {

            AI_ToolSchemaValidator.validate(request);

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains('Unknown tool'),
                'Unexpected message: ' + ex.getMessage()
            );
        }

        Test.stopTest();
    }


    @IsTest
    static void testNullArguments() {

        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = 'search_customer';

        request.arguments = null;

        Test.startTest();

        AI_ToolSchemaValidator.validate(request);

        Test.stopTest();

        System.assert(true);
    }
}