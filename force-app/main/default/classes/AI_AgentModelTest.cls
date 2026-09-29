@IsTest
private class AI_AgentModelTest {

    /*
     * Test default request construction.
     */
    @IsTest
    static void testDefaultRequest() {

        AI_AgentRequest request = new AI_AgentRequest();

        System.assertEquals(
            null,
            request.userMessage,
            'Default request should not contain a user message.'
        );

        System.assertEquals(
            false,
            request.isValid(),
            'Request without a user message should be invalid.'
        );
    }


    /*
     * Test simple request constructor.
     */
    @IsTest
    static void testRequestConstructor() {

        AI_AgentRequest request =
            new AI_AgentRequest(
                'Find the open cases for Acme.'
            );

        System.assertEquals(
            'Find the open cases for Acme.',
            request.userMessage
        );

        System.assertEquals(
            true,
            request.isValid(),
            'Request with a valid message should be valid.'
        );
    }


    /*
     * Test full request constructor.
     */
    @IsTest
    static void testFullRequestConstructor() {

        AI_AgentRequest request =
            new AI_AgentRequest(
                'SESSION-001',
                'Find the open cases for Acme.',
                UserInfo.getUserId(),
                'CONV-001'
            );

        System.assertEquals(
            'SESSION-001',
            request.sessionId
        );

        System.assertEquals(
            'Find the open cases for Acme.',
            request.userMessage
        );

        System.assertEquals(
            UserInfo.getUserId(),
            request.userId
        );

        System.assertEquals(
            'CONV-001',
            request.conversationId
        );

        System.assertEquals(
            true,
            request.isValid()
        );
    }


    /*
     * Test null user message.
     */
    @IsTest
    static void testNullUserMessage() {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage = null;

        System.assertEquals(
            false,
            request.isValid(),
            'Null user message should be invalid.'
        );
    }


    /*
     * Test blank user message.
     */
    @IsTest
    static void testBlankUserMessage() {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage = '   ';

        System.assertEquals(
            false,
            request.isValid(),
            'Blank user message should be invalid.'
        );
    }


    /*
     * Test successful Agent response.
     */
    @IsTest
    static void testSuccessResponse() {

        CustomerResponse customer =
            new CustomerResponse();

        customer.id = '001000000000001';
        customer.name = 'Acme';
        customer.phone = '555-0100';
        customer.industry = 'Technology';
        customer.billingCity = 'Hyderabad';

        AI_AgentResponse response =
            AI_AgentResponse.successResponse(
                'Customer found.',
                'SEARCH_CUSTOMER',
                'search_customer',
                customer
            );

        System.assertEquals(
            true,
            response.success
        );

        System.assertEquals(
            'Customer found.',
            response.message
        );

        System.assertEquals(
            'SEARCH_CUSTOMER',
            response.intent
        );

        System.assertEquals(
            'search_customer',
            response.selectedTool
        );

        System.assertEquals(
            false,
            response.approvalRequired
        );

        System.assertEquals(
            null,
            response.errorMessage
        );

        System.assertEquals(
            customer,
            response.toolData
        );
    }


    /*
     * Test approval-required response.
     */
    @IsTest
    static void testApprovalRequiredResponse() {

        AI_AgentResponse response =
            AI_AgentResponse.approvalRequiredResponse(
                'Creating the case requires approval.',
                'CREATE_CASE',
                'create_case',
                null
            );

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            true,
            response.approvalRequired
        );

        System.assertEquals(
            'CREATE_CASE',
            response.intent
        );

        System.assertEquals(
            'create_case',
            response.selectedTool
        );

        System.assertEquals(
            null,
            response.errorMessage
        );
    }


    /*
     * Test failure response.
     */
    @IsTest
    static void testFailureResponse() {

        AI_AgentResponse response =
            AI_AgentResponse.failureResponse(
                'I could not process your request.',
                'GET_OPEN_CASES',
                'get_open_cases',
                'Unable to determine the customer.'
            );

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            false,
            response.approvalRequired
        );

        System.assertEquals(
            'GET_OPEN_CASES',
            response.intent
        );

        System.assertEquals(
            'get_open_cases',
            response.selectedTool
        );

        System.assertEquals(
            'Unable to determine the customer.',
            response.errorMessage
        );

        System.assertEquals(
            null,
            response.toolData
        );
    }
}