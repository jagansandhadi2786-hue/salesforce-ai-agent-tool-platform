@IsTest
private class AI_AgentArgumentBuilderTest {

    /*
     * ----------------------------------------------------
     * Helper: create request
     * ----------------------------------------------------
     */
    private static AI_AgentRequest buildRequest(
        String message
    ) {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage =
            message;

        return request;
    }


    /*
     * ----------------------------------------------------
     * Helper: create intent
     * ----------------------------------------------------
     */
    private static AI_AgentIntent buildIntent(
        String intentName,
        String toolName
    ) {

        return new AI_AgentIntent(
            intentName,
            toolName,
            0.95
        );
    }


    /*
     * ----------------------------------------------------
     * Helper: create valid selection
     * ----------------------------------------------------
     */
    private static AI_AgentToolSelection buildSelection(
        String intentName,
        String toolName
    ) {

        AI_AgentToolSelection selection =
            new AI_AgentToolSelection();

        selection.intentName =
            intentName;

        selection.toolName =
            toolName;

        selection.description =
            'Test tool';

        selection.toolType =
            'Salesforce';

        selection.contractActive =
            true;

        selection.requiresApproval =
            false;

        selection.toolRecordId =
            '001000000000001AAA';

        selection.registryActive =
            true;

        return selection;
    }


    /*
     * ----------------------------------------------------
     * SEARCH CUSTOMER
     * ----------------------------------------------------
     */
    @IsTest
    static void testSearchCustomer() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find customer Acme'
                ),
                buildIntent(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                ),
                buildSelection(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            'Acme',
            String.valueOf(
                result.arguments.get(
                    'customer_name'
                )
            )
        );

        System.assertEquals(
            null,
            result.missingArgument
        );
    }


    /*
     * ----------------------------------------------------
     * SEARCH CUSTOMER USING "FOR"
     * ----------------------------------------------------
     */
    @IsTest
    static void testSearchCustomerUsingFor() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find customer for Acme'
                ),
                buildIntent(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                ),
                buildSelection(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            'Acme',
            String.valueOf(
                result.arguments.get(
                    'customer_name'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * GET CUSTOMER DETAILS WITH ID
     * ----------------------------------------------------
     */
    @IsTest
    static void testCustomerDetailsWithId() {

        String accountId =
            '001000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Show customer details for ' +
                    accountId
                ),
                buildIntent(
                    'GET_CUSTOMER_DETAILS',
                    'get_customer_details'
                ),
                buildSelection(
                    'GET_CUSTOMER_DETAILS',
                    'get_customer_details'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            accountId,
            String.valueOf(
                result.arguments.get(
                    'customer_id'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * GET CUSTOMER DETAILS WITH NAME
     *
     * Name cannot be converted into an Id.
     * ----------------------------------------------------
     */
    @IsTest
    static void testCustomerDetailsRequiresResolution() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Show me customer details for Acme'
                ),
                buildIntent(
                    'GET_CUSTOMER_DETAILS',
                    'get_customer_details'
                ),
                buildSelection(
                    'GET_CUSTOMER_DETAILS',
                    'get_customer_details'
                )
            );

        System.assertEquals(
            false,
            result.complete
        );

        System.assertEquals(
            'customer_id',
            result.missingArgument
        );

        System.assertEquals(
            'search_customer',
            result.resolutionTool
        );
    }


    /*
     * ----------------------------------------------------
     * GET OPEN CASES WITH ACCOUNT ID
     * ----------------------------------------------------
     */
    @IsTest
    static void testOpenCasesWithAccountId() {

        String accountId =
            '001000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find open cases for ' +
                    accountId
                ),
                buildIntent(
                    'GET_OPEN_CASES',
                    'get_open_cases'
                ),
                buildSelection(
                    'GET_OPEN_CASES',
                    'get_open_cases'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            accountId,
            String.valueOf(
                result.arguments.get(
                    'account_id'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * GET OPEN CASES WITH CUSTOMER NAME
     * ----------------------------------------------------
     */
    @IsTest
    static void testOpenCasesRequiresCustomerResolution() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find the open cases for Acme'
                ),
                buildIntent(
                    'GET_OPEN_CASES',
                    'get_open_cases'
                ),
                buildSelection(
                    'GET_OPEN_CASES',
                    'get_open_cases'
                )
            );

        System.assertEquals(
            false,
            result.complete
        );

        System.assertEquals(
            'account_id',
            result.missingArgument
        );

        System.assertEquals(
            'search_customer',
            result.resolutionTool
        );

        System.assertEquals(
            'Acme',
            String.valueOf(
                result.arguments.get(
                    'customer_name'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * CASE DETAILS
     * ----------------------------------------------------
     */
    @IsTest
    static void testCaseDetails() {

        String caseId =
            '500000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Show case details for ' +
                    caseId
                ),
                buildIntent(
                    'GET_CASE_DETAILS',
                    'get_case_details'
                ),
                buildSelection(
                    'GET_CASE_DETAILS',
                    'get_case_details'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            caseId,
            String.valueOf(
                result.arguments.get(
                    'case_id'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * ESCALATE CASE
     * ----------------------------------------------------
     */
    @IsTest
    static void testEscalateCase() {

        String caseId =
            '500000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Escalate case ' +
                    caseId
                ),
                buildIntent(
                    'ESCALATE_CASE',
                    'escalate_case'
                ),
                buildSelection(
                    'ESCALATE_CASE',
                    'escalate_case'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            caseId,
            String.valueOf(
                result.arguments.get(
                    'case_id'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * UPDATE CASE
     * ----------------------------------------------------
     */
    @IsTest
    static void testUpdateCase() {

        String caseId =
            '500000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Update case ' +
                    caseId +
                    ' set status to Working'
                ),
                buildIntent(
                    'UPDATE_CASE',
                    'update_case'
                ),
                buildSelection(
                    'UPDATE_CASE',
                    'update_case'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            caseId,
            String.valueOf(
                result.arguments.get(
                    'case_id'
                )
            )
        );

        System.assertEquals(
            'Working',
            String.valueOf(
                result.arguments.get(
                    'status'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * CREATE CASE
     *
     * Missing account ID.
     * ----------------------------------------------------
     */
    @IsTest
    static void testCreateCaseRequiresAccount() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Create a case with subject: ' +
                    'Payment issue description: ' +
                    'Customer cannot make payment'
                ),
                buildIntent(
                    'CREATE_CASE',
                    'create_case'
                ),
                buildSelection(
                    'CREATE_CASE',
                    'create_case'
                )
            );

        System.assertEquals(
            false,
            result.complete
        );

        System.assertEquals(
            'account_id',
            result.missingArgument
        );

        System.assertEquals(
            'search_customer',
            result.resolutionTool
        );
    }


    /*
     * ----------------------------------------------------
     * CREATE CASE WITH COMPLETE DATA
     * ----------------------------------------------------
     */
    @IsTest
    static void testCreateCaseComplete() {

        String accountId =
            '001000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Create a case for ' +
                    accountId +
                    ' subject: Payment issue ' +
                    'description: Customer cannot pay ' +
                    'high priority'
                ),
                buildIntent(
                    'CREATE_CASE',
                    'create_case'
                ),
                buildSelection(
                    'CREATE_CASE',
                    'create_case'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            accountId,
            String.valueOf(
                result.arguments.get(
                    'account_id'
                )
            )
        );

        System.assertEquals(
            'Payment issue',
            String.valueOf(
                result.arguments.get(
                    'subject'
                )
            )
        );

        System.assertEquals(
            'Customer cannot pay',
            String.valueOf(
                result.arguments.get(
                    'description'
                )
            )
        );

        System.assertEquals(
            'High',
            String.valueOf(
                result.arguments.get(
                    'priority'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * CREATE TASK
     * ----------------------------------------------------
     */
    @IsTest
    static void testCreateTask() {

        String accountId =
            '001000000000001AAA';

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Create task for ' +
                    accountId +
                    ' subject: Call customer'
                ),
                buildIntent(
                    'CREATE_TASK',
                    'create_task'
                ),
                buildSelection(
                    'CREATE_TASK',
                    'create_task'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            accountId,
            String.valueOf(
                result.arguments.get(
                    'what_id'
                )
            )
        );

        System.assertEquals(
            'Call customer',
            String.valueOf(
                result.arguments.get(
                    'subject'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * KNOWLEDGE SEARCH
     * ----------------------------------------------------
     */
    @IsTest
    static void testKnowledgeSearch() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Search knowledge for password reset'
                ),
                buildIntent(
                    'SEARCH_KNOWLEDGE',
                    'search_knowledge'
                ),
                buildSelection(
                    'SEARCH_KNOWLEDGE',
                    'search_knowledge'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            'password reset',
            String.valueOf(
                result.arguments.get(
                    'search_term'
                )
            )
        );
    }

    /*
     * ----------------------------------------------------
     * ORDER STATUS
     * ----------------------------------------------------
     */
    @IsTest
    static void testOrderStatus() {

        AI_AgentArgumentResult result =
            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'What is the status of order ORD-1001?'
                ),
                buildIntent(
                    'GET_ORDER_STATUS',
                    'get_order_status'
                ),
                buildSelection(
                    'GET_ORDER_STATUS',
                    'get_order_status'
                )
            );

        System.assertEquals(
            true,
            result.complete
        );

        System.assertEquals(
            'ORD-1001',
            String.valueOf(
                result.arguments.get(
                    'order_number'
                )
            )
        );
    }


    /*
     * ----------------------------------------------------
     * NULL REQUEST
     * ----------------------------------------------------
     */
    @IsTest
    static void testNullRequest() {

        try {

            AI_AgentArgumentBuilder.build(
                null,
                buildIntent(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                ),
                buildSelection(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                )
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Agent request is required.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * NULL INTENT
     * ----------------------------------------------------
     */
    @IsTest
    static void testNullIntent() {

        try {

            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find customer Acme'
                ),
                null,
                buildSelection(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                )
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Agent intent is required.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * NULL TOOL SELECTION
     * ----------------------------------------------------
     */
    @IsTest
    static void testNullSelection() {

        try {

            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find customer Acme'
                ),
                buildIntent(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                ),
                null
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool selection is required.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * INVALID SELECTION
     * ----------------------------------------------------
     */
    @IsTest
    static void testInvalidSelection() {

        AI_AgentToolSelection selection =
            new AI_AgentToolSelection();

        selection.intentName =
            'SEARCH_CUSTOMER';

        selection.toolName =
            'search_customer';

        selection.contractActive =
            false;

        try {

            AI_AgentArgumentBuilder.build(
                buildRequest(
                    'Find customer Acme'
                ),
                buildIntent(
                    'SEARCH_CUSTOMER',
                    'search_customer'
                ),
                selection
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool selection is invalid.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * UNKNOWN INTENT
     * ----------------------------------------------------
     */
   @IsTest
static void testUnsupportedIntent() {

    try {

        AI_AgentArgumentBuilder.build(
            buildRequest(
                'Something'
            ),
            buildIntent(
                'UNKNOWN_INTENT',
                'unknown_tool'
            ),
            buildSelection(
                'UNKNOWN_INTENT',
                'unknown_tool'
            )
        );

        System.assert(
            false,
            'Expected AI_ServiceException for unsupported intent.'
        );

    } catch (AI_ServiceException ex) {

        System.assertEquals(
        'No argument builder exists for intent: UNKNOWN_INTENT',
         ex.getMessage()
    );
    }
}
}