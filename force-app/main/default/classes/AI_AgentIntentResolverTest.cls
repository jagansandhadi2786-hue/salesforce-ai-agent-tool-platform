@IsTest
private class AI_AgentIntentResolverTest {


    private static AI_AgentRequest buildRequest(
        String message
    ) {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage = message;

        return request;
    }


    /*
     * ----------------------------------------------------
     * SEARCH CUSTOMER
     * ----------------------------------------------------
     */

    @IsTest
    static void testSearchCustomer() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Find customer Acme'
                )
            );

        System.assertEquals(
            'SEARCH_CUSTOMER',
            intent.intentName
        );

        System.assertEquals(
            'search_customer',
            intent.toolName
        );

        System.assertEquals(
            0.95,
            intent.confidence
        );

        System.assertEquals(
            true,
            intent.isValid()
        );
    }


    @IsTest
    static void testSearchAccount() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Search account Acme'
                )
            );

        System.assertEquals(
            'SEARCH_CUSTOMER',
            intent.intentName
        );

        System.assertEquals(
            'search_customer',
            intent.toolName
        );
    }


    /*
     * ----------------------------------------------------
     * CUSTOMER DETAILS
     * ----------------------------------------------------
     */

    @IsTest
    static void testCustomerDetails() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Show me customer details for Acme'
                )
            );

        System.assertEquals(
            'GET_CUSTOMER_DETAILS',
            intent.intentName
        );

        System.assertEquals(
            'get_customer_details',
            intent.toolName
        );
    }


    @IsTest
    static void testCustomerInformation() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Show customer information for Acme'
                )
            );

        System.assertEquals(
            'GET_CUSTOMER_DETAILS',
            intent.intentName
        );
    }


    /*
     * ----------------------------------------------------
     * OPEN CASES
     * ----------------------------------------------------
     */

    @IsTest
    static void testOpenCases() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Find the open cases for Acme'
                )
            );

        System.assertEquals(
            'GET_OPEN_CASES',
            intent.intentName
        );

        System.assertEquals(
            'get_open_cases',
            intent.toolName
        );

        System.assertEquals(
            0.95,
            intent.confidence
        );
    }


    @IsTest
    static void testOpenTickets() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Show open tickets for Acme'
                )
            );

        System.assertEquals(
            'GET_OPEN_CASES',
            intent.intentName
        );

        System.assertEquals(
            'get_open_cases',
            intent.toolName
        );
    }


    /*
     * ----------------------------------------------------
     * CASE DETAILS
     * ----------------------------------------------------
     */

    @IsTest
    static void testCaseDetails() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Show case details for case 00001001'
                )
            );

        System.assertEquals(
            'GET_CASE_DETAILS',
            intent.intentName
        );

        System.assertEquals(
            'get_case_details',
            intent.toolName
        );
    }


    /*
     * ----------------------------------------------------
     * CREATE CASE
     * ----------------------------------------------------
     */

    @IsTest
    static void testCreateCase() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Create a case for Acme'
                )
            );

        System.assertEquals(
            'CREATE_CASE',
            intent.intentName
        );

        System.assertEquals(
            'create_case',
            intent.toolName
        );
    }


    @IsTest
    static void testRaiseCase() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Raise a case for Acme'
                )
            );

        System.assertEquals(
            'CREATE_CASE',
            intent.intentName
        );
    }


    /*
     * ----------------------------------------------------
     * UPDATE CASE
     * ----------------------------------------------------
     */

    @IsTest
    static void testUpdateCase() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Update case 00001001'
                )
            );

        System.assertEquals(
            'UPDATE_CASE',
            intent.intentName
        );

        System.assertEquals(
            'update_case',
            intent.toolName
        );
    }


    /*
     * ----------------------------------------------------
     * CREATE TASK
     * ----------------------------------------------------
     */

    @IsTest
    static void testCreateTask() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Create a task for Acme'
                )
            );

        System.assertEquals(
            'CREATE_TASK',
            intent.intentName
        );

        System.assertEquals(
            'create_task',
            intent.toolName
        );
    }


    /*
     * ----------------------------------------------------
     * ESCALATE CASE
     * ----------------------------------------------------
     */

    @IsTest
    static void testEscalateCase() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Escalate case 00001001'
                )
            );

        System.assertEquals(
            'ESCALATE_CASE',
            intent.intentName
        );

        System.assertEquals(
            'escalate_case',
            intent.toolName
        );
    }


    /*
     * ----------------------------------------------------
     * KNOWLEDGE
     * ----------------------------------------------------
     */

    @IsTest
    static void testKnowledgeSearch() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Search the knowledge articles for password reset'
                )
            );

        System.assertEquals(
            'SEARCH_KNOWLEDGE',
            intent.intentName
        );

        System.assertEquals(
            'search_knowledge',
            intent.toolName
        );
    }


    @IsTest
    static void testHowDoI() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'How do I reset my password?'
                )
            );

        System.assertEquals(
            'SEARCH_KNOWLEDGE',
            intent.intentName
        );
    }


    /*
     * ----------------------------------------------------
     * ORDER STATUS
     * ----------------------------------------------------
     */

    @IsTest
    static void testOrderStatus() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'What is the status of order ORD-1001?'
                )
            );

        System.assertEquals(
            'GET_ORDER_STATUS',
            intent.intentName
        );

        System.assertEquals(
            'get_order_status',
            intent.toolName
        );
    }


    @IsTest
    static void testOrderTracking() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'Track order ORD-1001'
                )
            );

        System.assertEquals(
            'GET_ORDER_STATUS',
            intent.intentName
        );
    }


    /*
     * ----------------------------------------------------
     * NORMALIZATION
     * ----------------------------------------------------
     */

    @IsTest
    static void testCaseInsensitiveInput() {

        AI_AgentIntent intent =
            AI_AgentIntentResolver.resolve(
                buildRequest(
                    'FIND THE OPEN CASES FOR ACME!!!'
                )
            );

        System.assertEquals(
            'GET_OPEN_CASES',
            intent.intentName
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

            AI_AgentIntentResolver.resolve(null);

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
     * BLANK MESSAGE
     * ----------------------------------------------------
     */

    @IsTest
    static void testBlankMessage() {

        AI_AgentRequest request =
            buildRequest('   ');

        try {

            AI_AgentIntentResolver.resolve(
                request
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
    }


    /*
     * ----------------------------------------------------
     * UNKNOWN INTENT
     * ----------------------------------------------------
     */

    @IsTest
    static void testUnknownIntent() {

        AI_AgentRequest request =
            buildRequest(
                'Tell me something completely unrelated'
            );

        try {

            AI_AgentIntentResolver.resolve(
                request
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Unable to determine user intent.',
                ex.getMessage()
            );
        }
    }
}