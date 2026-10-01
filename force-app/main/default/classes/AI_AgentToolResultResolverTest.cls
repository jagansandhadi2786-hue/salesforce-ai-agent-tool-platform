@IsTest
private class AI_AgentToolResultResolverTest {

    @IsTest
    static void testResolveCustomerToOpenCases() {

        /*
         * Create a customer result.
         *
         * The resolver expects:
         * List<CustomerResponse>
         */
        CustomerResponse customer =
            new CustomerResponse();

        customer.id = '001000000000001';

        List<CustomerResponse> customers =
            new List<CustomerResponse>{
                customer
            };

        AI_ToolResponse response =
            new AI_ToolResponse();

        response.success = true;
        response.data = customers;

        /*
         * Resolve:
         *
         * search_customer
         *        ↓
         * get_open_cases
         *
         * Expected:
         * account_id = customer Id
         */
        Test.startTest();

        Map<String, Object> result =
            AI_AgentToolResultResolver.resolveNextArguments(
                'search_customer',
                response,
                'get_open_cases'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'Resolved arguments should not be null.'
        );

        System.assertEquals(
            '001000000000001',
            (String) result.get('account_id'),
            'The customer Account Id should be mapped to account_id.'
        );
    }
}