@IsTest
private class AI_ToolExecutorTest {

    /*
     * =========================================================
     * Test Data Setup
     * =========================================================
     */
    @TestSetup
    static void setupTestData() {

        List<AI_Tool__c> tools = new List<AI_Tool__c>();

        tools.add(createTool(
            'Search Customer',
            'search_customer',
            false
        ));

        tools.add(createTool(
            'Get Customer Details',
            'get_customer_details',
            false
        ));

        tools.add(createTool(
            'Get Open Cases',
            'get_open_cases',
            false
        ));

        tools.add(createTool(
            'Get Case Details',
            'get_case_details',
            false
        ));

        tools.add(createTool(
            'Create Case',
            'create_case',
            true
        ));

        tools.add(createTool(
            'Update Case',
            'update_case',
            true
        ));

        tools.add(createTool(
            'Create Task',
            'create_task',
            true
        ));

        tools.add(createTool(
            'Escalate Case',
            'escalate_case',
            true
        ));

        tools.add(createTool(
            'Search Knowledge',
            'search_knowledge',
            false
        ));

        tools.add(createTool(
            'Get Order Status',
            'get_order_status',
            false
        ));

        insert tools;
    }


    /*
     * =========================================================
     * AI Tool Factory
     * =========================================================
     */
    private static AI_Tool__c createTool(
        String name,
        String apiName,
        Boolean requiresApproval
    ) {

        AI_Tool__c tool = new AI_Tool__c();

        tool.Name = name;
        tool.Tool_API_Name__c = apiName;
        tool.Active__c = true;
        tool.Requires_Approval__c = requiresApproval;
        tool.Tool_Type__c = 'Salesforce';
        tool.Description__c =
            'Test tool for ' + apiName;
        tool.Handler_Class__c = '';
        tool.Allowed_Arguments__c = '';

        return tool;
    }


    /*
     * =========================================================
     * Helper: create Account
     * =========================================================
     */
    private static Account createAccount() {

        Account account = new Account(
            Name = 'AI Test Customer'
        );

        insert account;

        return account;
    }


    /*
     * =========================================================
     * Helper: create Case
     * =========================================================
     */
    private static Case createCase(Id accountId) {

        Case testCase = new Case(
            AccountId = accountId,
            Subject = 'AI Test Case',
            Description = 'AI Tool Executor test case',
            Status = 'New',
            Priority = 'Medium'
        );

        insert testCase;

        return testCase;
    }


    /*
     * =========================================================
     * 1. search_customer
     * =========================================================
     */
    @IsTest
    static void testSearchCustomerEndToEnd() {

        createAccount();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>{
                    'customer_name' => 'AI Test Customer'
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            true,
            response.success,
            'search_customer failed. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 2. get_customer_details
     * =========================================================
     */
    @IsTest
    static void testGetCustomerDetailsEndToEnd() {

        Account account = createAccount();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'get_customer_details',
                new Map<String, Object>{
                    'customer_id' => account.Id
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            true,
            response.success,
            'get_customer_details failed. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 3. get_open_cases
     * =========================================================
     */
    @IsTest
    static void testGetOpenCasesEndToEnd() {

        Account account = createAccount();

        createCase(account.Id);

        AI_ToolRequest request =
            new AI_ToolRequest(
                'get_open_cases',
                new Map<String, Object>{
                    'account_id' => account.Id
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            true,
            response.success,
            'get_open_cases failed. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 4. get_case_details
     * =========================================================
     */
    @IsTest
    static void testGetCaseDetailsEndToEnd() {

        Account account = createAccount();

        Case testCase =
            createCase(account.Id);

        AI_ToolRequest request =
            new AI_ToolRequest(
                'get_case_details',
                new Map<String, Object>{
                    'case_id' => testCase.Id
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            true,
            response.success,
            'get_case_details failed. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 5. create_case approval gate
     * =========================================================
     */
    @IsTest
    static void testCreateCaseRequiresApproval() {

        Account account = createAccount();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'create_case',
                new Map<String, Object>{
                    'account_id' => account.Id,
                    'subject' => 'Approval Test',
                    'description' => 'Approval required test'
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            true,
            response.requiresApproval,
            'create_case should require approval. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 6. update_case approval gate
     * =========================================================
     */
    @IsTest
    static void testUpdateCaseRequiresApproval() {

        Account account = createAccount();

        Case testCase =
            createCase(account.Id);

        AI_ToolRequest request =
            new AI_ToolRequest(
                'update_case',
                new Map<String, Object>{
                    'case_id' => testCase.Id,
                    'status' => 'Working'
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            true,
            response.requiresApproval,
            'update_case should require approval. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 7. create_task approval gate
     * =========================================================
     */
    @IsTest
    static void testCreateTaskRequiresApproval() {

        Account account = createAccount();

        AI_ToolRequest request =
            new AI_ToolRequest(
                'create_task',
                new Map<String, Object>{
                    'what_id' => account.Id,
                    'subject' => 'Approval Test Task'
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            true,
            response.requiresApproval,
            'create_task should require approval. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 8. escalate_case approval gate
     * =========================================================
     */
    @IsTest
    static void testEscalateCaseRequiresApproval() {

        Account account = createAccount();

        Case testCase =
            createCase(account.Id);

        AI_ToolRequest request =
            new AI_ToolRequest(
                'escalate_case',
                new Map<String, Object>{
                    'case_id' => testCase.Id
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            true,
            response.requiresApproval,
            'escalate_case should require approval. Message: ' +
            response.message
        );
    }


    /*
     * =========================================================
     * 9. search_knowledge
     * =========================================================
     */
    @IsTest
    static void testSearchKnowledgeEndToEnd() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_knowledge',
                new Map<String, Object>{
                    'search_term' => 'password'
                }
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            true,
            response.success,
            'search_knowledge failed. Message: ' +
            response.message
        );
    }


    /*
 * =========================================================
 * 10. get_order_status
 * =========================================================
 */
@IsTest
static void testGetOrderStatusEndToEnd() {

    /*
     * Use the shared HTTP mock.
     *
     * Do NOT use:
     * AI_OrderApiServiceTest.OrderApiMock
     *
     * OrderApiMock is an inner class of another test class
     * and is not visible here.
     */
    AI_OrderApiHttpMock mock =
        new AI_OrderApiHttpMock();

    mock.responseStatusCode = 200;

    mock.responseBody =
        '{' +
        '"orderNumber":"ORD-1001",' +
        '"status":"SHIPPED",' +
        '"message":"Order has been shipped.",' +
        '"estimatedDelivery":"2026-10-08",' +
        '"trackingNumber":"TRK123456789"' +
        '}';

    Test.setMock(
        HttpCalloutMock.class,
        mock
    );

    AI_ToolRequest request =
        new AI_ToolRequest(
            'get_order_status',
            new Map<String, Object>{
                'order_number' => 'ORD-1001'
            }
        );

    Test.startTest();

    AI_ToolResponse response =
        AI_ToolExecutor.execute(request);

    Test.stopTest();

    System.assertEquals(
        true,
        response.success,
        'get_order_status failed. Message: ' +
        response.message
    );

    System.assertNotEquals(
        null,
        response.message,
        'get_order_status should return a response message.'
    );
}
    /*
     * =========================================================
     * 11. Invalid request
     * =========================================================
     */
    @IsTest
    static void testExecutorRejectsInvalidRequest() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'search_customer',
                new Map<String, Object>()
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertNotEquals(
            null,
            response.message
        );
    }


    /*
     * =========================================================
     * 12. Unknown tool
     * =========================================================
     */
    @IsTest
    static void testExecutorRejectsUnknownTool() {

        AI_ToolRequest request =
            new AI_ToolRequest(
                'delete_all_customers',
                new Map<String, Object>()
            );

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(request);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertNotEquals(
            null,
            response.message
        );
    }


    /*
     * =========================================================
     * 13. Null request
     * =========================================================
     */
    @IsTest
    static void testExecutorHandlesNullRequest() {

        Test.startTest();

        AI_ToolResponse response =
            AI_ToolExecutor.execute(null);

        Test.stopTest();

        System.assertEquals(
            false,
            response.success
        );

        System.assertEquals(
            'Tool request is required.',
            response.message
        );
    }
}