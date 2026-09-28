@IsTest(SeeAllData=true)
private class AI_ToolNegativeTest {

    private static AI_ToolRequest buildRequest(
        String toolName,
        Map<String, Object> arguments
    ) {
        AI_ToolRequest request = new AI_ToolRequest();

        request.toolName = toolName;
        request.arguments = arguments;

        return request;
    }

    private static AI_Tool__c getTool(
        String toolName
    ) {
        return AI_ToolRegistry.getActiveTool(toolName);
    }

    // =========================================================
    // Test 1 — Null request
    // =========================================================
    @IsTest
    static void testNullRequestRejected() {

        try {
            AI_ToolSchemaValidator.validate(
                null,
                null
            );

            System.assert(
                false,
                'Null request should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool request is required.',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 2 — Blank tool name
    // =========================================================
    @IsTest
    static void testBlankToolNameRejected() {

        AI_ToolRequest request =
            buildRequest(
                '',
                new Map<String, Object>()
            );

        try {

            AI_ToolSchemaValidator.validate(
                request,
                null
            );

            System.assert(
                false,
                'Blank tool name should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Tool name is required.',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 3 — Unknown tool
    // =========================================================
    @IsTest
    static void testUnknownToolRejected() {

        AI_ToolRequest request =
            buildRequest(
                'delete_all_customers',
                new Map<String, Object>()
            );

        try {

            AI_ToolSchemaValidator.validate(
                request,
                null
            );

            System.assert(
                false,
                'Unknown tool should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                        'Tool is not registered or not active.'
                ),
                'Unexpected error: ' + ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 4 — Unexpected argument
    // =========================================================
    @IsTest
    static void testUnexpectedArgumentRejected() {

        AI_ToolRequest request =
            buildRequest(
                'search_customer',
                new Map<String, Object>{
                    'customer_name' => 'Acme',
                    'password' => 'secret'
                }
            );

        AI_Tool__c tool =
            getTool('search_customer');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Unexpected argument should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'password'
                ),
                'Unexpected error: ' + ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 5 — Missing customer name
    // =========================================================
    @IsTest
    static void testSearchCustomerMissingName() {

        AI_ToolRequest request =
            buildRequest(
                'search_customer',
                new Map<String, Object>()
            );

        AI_Tool__c tool =
            getTool('search_customer');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'customer_name should be required.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Required argument missing: customer_name',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 6 — Blank customer name
    // =========================================================
    @IsTest
    static void testSearchCustomerBlankName() {

        AI_ToolRequest request =
            buildRequest(
                'search_customer',
                new Map<String, Object>{
                    'customer_name' => '   '
                }
            );

        AI_Tool__c tool =
            getTool('search_customer');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Blank customer_name should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Required argument is blank: customer_name',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 7 — Invalid customer ID
    // =========================================================
    @IsTest
    static void testInvalidCustomerId() {

        AI_ToolRequest request =
            buildRequest(
                'get_customer_details',
                new Map<String, Object>{
                    'customer_id' => 'INVALID-ID'
                }
            );

        AI_Tool__c tool =
            getTool('get_customer_details');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Invalid ID should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Invalid ID argument: customer_id',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // create_case requires:
    // account_id
    // subject
    // description
    // =========================================================

    // =========================================================
    // Test 8 — Missing account ID
    // =========================================================
    @IsTest
    static void testCreateCaseMissingAccountId() {

        AI_ToolRequest request =
            buildRequest(
                'create_case',
                new Map<String, Object>{
                    'subject' => 'Payment issue',
                    'description' => 'Payment failed'
                }
            );

        AI_Tool__c tool =
            getTool('create_case');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'account_id should be required.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Required argument missing: account_id',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 9 — Missing subject
    // =========================================================
    @IsTest
    static void testCreateCaseMissingSubject() {

        AI_ToolRequest request =
            buildRequest(
                'create_case',
                new Map<String, Object>{
                    'account_id' => '001XXXXXXXXXXXX',
                    'description' => 'Payment failed'
                }
            );

        AI_Tool__c tool =
            getTool('create_case');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'subject should be required.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Required argument missing: subject',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 10 — Missing description
    // =========================================================
    @IsTest
    static void testCreateCaseMissingDescription() {

        AI_ToolRequest request =
            buildRequest(
                'create_case',
                new Map<String, Object>{
                    'account_id' => '001XXXXXXXXXXXX',
                    'subject' => 'Payment issue'
                }
            );

        AI_Tool__c tool =
            getTool('create_case');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'description should be required.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Required argument missing: description',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 11 — Invalid priority
    // =========================================================
    @IsTest
    static void testInvalidCreateCasePriority() {

        AI_ToolRequest request =
            buildRequest(
                'create_case',
                new Map<String, Object>{
                    'account_id' => '001XXXXXXXXXXXX',
                    'subject' => 'Payment issue',
                    'description' => 'Payment failed',
                    'priority' => 'Urgent'
                }
            );

        AI_Tool__c tool =
            getTool('create_case');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Urgent should not be accepted.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Invalid value for priority'
                ),
                'Unexpected error: ' + ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 12 — Create Task invalid date
    // =========================================================
    @IsTest
    static void testInvalidTaskDate() {

        AI_ToolRequest request =
            buildRequest(
                'create_task',
                new Map<String, Object>{
                    'what_id' => '500XXXXXXXXXXXX',
                    'subject' => 'Follow up',
                    'due_date' => 'tomorrow'
                }
            );

        AI_Tool__c tool =
            getTool('create_task');

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Invalid date should be rejected.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Invalid date for argument: due_date',
                ex.getMessage()
            );
        }
    }

    // =========================================================
    // Test 13 — Optional priority can be omitted
    // =========================================================
    @IsTest
    static void testOptionalPriorityCanBeOmitted() {

        AI_ToolRequest request =
            buildRequest(
                'create_case',
                new Map<String, Object>{
                    'account_id' => '001XXXXXXXXXXXX',
                    'subject' => 'Payment issue',
                    'description' => 'Payment failed'
                }
            );

        AI_Tool__c tool =
            getTool('create_case');

        Test.startTest();

        AI_ToolSchemaValidator.validate(
            request,
            tool
        );

        Test.stopTest();

        System.assert(
            true,
            'Request without optional priority should be valid.'
        );
    }

    // =========================================================
    // Test 14 — All tools reject unexpected arguments
    // =========================================================
 @IsTest
static void testAllToolsRejectUnexpectedArgument() {

List<String> toolNames =
    AI_ToolContractCatalog.getToolNames();

for (String toolName : toolNames) {

    Map<String, Object> arguments =
        new Map<String, Object>();

    if (toolName == 'search_customer') {
        arguments.put('customer_name', 'Acme');
    }
    else if (toolName == 'get_customer_details') {
        arguments.put(
            'customer_id',
            '001000000000001'
        );
    }
    else if (toolName == 'get_open_cases') {
        arguments.put(
            'account_id',
            '001000000000001'
        );
    }
    else if (toolName == 'get_case_details') {
        arguments.put(
            'case_id',
            '500000000000001'
        );
    }
    else if (toolName == 'create_case') {
        arguments.put(
            'account_id',
            '001000000000001'
        );
        arguments.put(
            'subject',
            'Test Case'
        );
        arguments.put(
            'description',
            'Test Description'
        );
    }
    else if (toolName == 'update_case') {
        arguments.put(
            'case_id',
            '500000000000001'
        );
        arguments.put(
            'status',
            'New'
        );
    }
    else if (toolName == 'create_task') {
        arguments.put(
            'what_id',
            '500000000000001'
        );
        arguments.put(
            'subject',
            'Follow up'
        );
    }
    else if (toolName == 'escalate_case') {
        arguments.put(
            'case_id',
            '500000000000001'
        );
    }
    else if (toolName == 'search_knowledge') {
        arguments.put(
            'search_term',
            'payment'
        );
    }
    else if (toolName == 'get_order_status') {
        arguments.put(
            'order_id',
            'ORD-1001'
        );
    }

    // Deliberately add an argument that is NOT
    // defined in the tool contract.
    arguments.put(
        'malicious_argument',
        'unexpected'
    );

    AI_ToolRequest request =
        buildRequest(
            toolName,
            arguments
        );

    AI_Tool__c tool =
        getTool(toolName);

    try {

        AI_ToolSchemaValidator.validate(
            request,
            tool
        );

        System.assert(
            false,
            'Tool should reject unexpected argument: ' +
            toolName
        );

    }
    catch (AI_ServiceException ex) {

        System.assert(
            ex.getMessage() != null &&
            ex.getMessage().contains(
                'Unexpected argument'
            ),
            'Unexpected error for tool ' +
            toolName +
            ': ' +
            ex.getMessage()
        );
    }
  }
 }
}