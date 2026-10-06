@IsTest
private class AI_AgentOrchestratorTest {
  /*
   * ============================================================
   * TEST DATA
   * ============================================================
   */
  @TestSetup
  static void setupToolRegistry() {
    List<AI_Tool__c> tools = new List<AI_Tool__c>();

    tools.add(
      new AI_Tool__c(
        Name = 'Search Customer',
        Tool_API_Name__c = 'search_customer',
        Description__c = 'Search Salesforce customers by customer name.',
        Active__c = true,
        Requires_Approval__c = false,
        Tool_Type__c = 'Salesforce',
        Allowed_Arguments__c = 'customer_name'
      )
    );

    tools.add(
      new AI_Tool__c(
        Name = 'Get Customer Details',
        Tool_API_Name__c = 'get_customer_details',
        Description__c = 'Retrieve customer details using a Salesforce Account ID.',
        Active__c = true,
        Requires_Approval__c = false,
        Tool_Type__c = 'Salesforce',
        Allowed_Arguments__c = 'customer_id'
      )
    );

    tools.add(
      new AI_Tool__c(
        Name = 'Get Open Cases',
        Tool_API_Name__c = 'get_open_cases',
        Description__c = 'Retrieve open customer cases for a Salesforce Account.',
        Active__c = true,
        Requires_Approval__c = false,
        Tool_Type__c = 'Salesforce',
        Allowed_Arguments__c = 'account_id'
      )
    );

    tools.add(
      new AI_Tool__c(
        Name = 'Get Order Status',
        Tool_API_Name__c = 'get_order_status',
        Description__c = 'Retrieve order status from the order-management integration.',
        Active__c = true,
        Requires_Approval__c = false,
        Tool_Type__c = 'REST',
        Allowed_Arguments__c = 'order_number'
      )
    );

    insert tools;
  }

  /*
   * ============================================================
   * HELPERS
   * ============================================================
   */
  private static Account createTestAccount() {
    Account accountRecord = new Account(
      Name = 'Acme AI Agent Test',
      Phone = '555-0200',
      Industry = 'Technology',
      BillingCity = 'Hyderabad'
    );

    insert accountRecord;

    return accountRecord;
  }

  private static Account createExactAcmeAccount() {
    Account accountRecord = new Account(Name = 'Acme');

    insert accountRecord;

    return accountRecord;
  }

  private static Case createOpenCase(Id accountId) {
    Case caseRecord = new Case(
      AccountId = accountId,
      Subject = 'Acme Support Case',
      Status = 'New',
      Priority = 'Medium',
      Origin = 'Web'
    );

    insert caseRecord;

    return caseRecord;
  }

  private static AI_AgentRequest buildRequest(String message) {
    AI_AgentRequest request = new AI_AgentRequest();

    request.userMessage = message;

    return request;
  }

  /*
   * ============================================================
   * REQUEST VALIDATION
   * ============================================================
   */

  @IsTest
  static void testNullRequest() {
    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(null);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(false, response.success, 'Null request must fail.');

    System.assertEquals(
      'Agent request is required.',
      response.errorMessage,
      'The expected validation error should be returned.'
    );

    System.assertEquals(
      'I could not process the request.',
      response.message,
      'The expected user-facing message should be returned.'
    );
  }

  @IsTest
  static void testBlankMessage() {
    AI_AgentRequest request = new AI_AgentRequest();

    request.userMessage = '';

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(false, response.success, 'Blank message must fail.');

    System.assertEquals('User message is required.', response.errorMessage);

    System.assertEquals('User message is required.', response.message);
  }

  /*
   * ============================================================
   * SINGLE-STEP PROCESSING
   * ============================================================
   */

  @IsTest
  static void testSearchCustomerEndToEnd() {
    createTestAccount();

    AI_AgentRequest request = buildRequest('Find customer Acme AI Agent Test');

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'SEARCH_CUSTOMER',
      response.intent,
      'Intent should be SEARCH_CUSTOMER.'
    );

    System.assertEquals(
      'search_customer',
      response.selectedTool,
      'Selected tool should be search_customer.'
    );

    System.assertEquals(
      true,
      response.success,
      'Customer search should execute successfully.'
    );

    System.assertNotEquals(
      null,
      response.toolData,
      'Successful customer search should contain tool data.'
    );
  }

  @IsTest
  static void testSearchCustomerWithNoMatch() {
    String customerName = 'DoesNotExistCustomer';

    AI_AgentRequest request = buildRequest('Find customer ' + customerName);

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'SEARCH_CUSTOMER',
      response.intent,
      'Intent should be SEARCH_CUSTOMER.'
    );

    System.assertEquals(
      'search_customer',
      response.selectedTool,
      'Selected tool should be search_customer.'
    );

    System.assertEquals(
      true,
      response.success,
      'A search with no records is still a successful tool execution.'
    );

    System.assertNotEquals(
      null,
      response.message,
      'A no-result search should return a user-facing message.'
    );
  }

  @IsTest
  static void testCustomerDetailsWithAccountId() {
    Account accountRecord = createTestAccount();

    AI_AgentRequest request = buildRequest(
      'Show me customer details for ' + accountRecord.Id
    );

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'GET_CUSTOMER_DETAILS',
      response.intent,
      'Intent should be GET_CUSTOMER_DETAILS.'
    );

    System.assertEquals(
      'get_customer_details',
      response.selectedTool,
      'Selected tool should be get_customer_details.'
    );

    System.assertEquals(
      true,
      response.success,
      'Customer details should execute successfully when an Account Id is supplied.'
    );

    System.assertNotEquals(
      null,
      response.toolData,
      'Customer details should return tool data.'
    );
  }

  @IsTest
  static void testOpenCasesWithAccountId() {
    Account accountRecord = createTestAccount();

    createOpenCase(accountRecord.Id);

    AI_AgentRequest request = buildRequest(
      'Find the open cases for ' + accountRecord.Id
    );

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'GET_OPEN_CASES',
      response.intent,
      'Intent should be GET_OPEN_CASES.'
    );

    System.assertEquals(
      'get_open_cases',
      response.selectedTool,
      'Selected tool should be get_open_cases.'
    );

    System.assertEquals(
      true,
      response.success,
      'Open-case lookup should succeed when an Account Id is supplied.'
    );

    System.assertNotEquals(
      null,
      response.toolData,
      'Open-case lookup should return tool data.'
    );
  }

  @IsTest
  static void testOrderStatusEndToEnd() {
    AI_AgentRequest request = buildRequest(
      'What is the status of order ORD-1001?'
    );

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'GET_ORDER_STATUS',
      response.intent,
      'Intent should be GET_ORDER_STATUS.'
    );

    System.assertEquals(
      'get_order_status',
      response.selectedTool,
      'Selected tool should be get_order_status.'
    );
  }

  /*
   * ============================================================
   * MISSING ARGUMENT / RESOLUTION PATH
   * ============================================================
   */

  @IsTest
  static void testCustomerDetailsWithoutIdRequiresResolution() {
    /*
     * No customer_id and no customer_name are supplied.
     *
     * AI_AgentArgumentBuilder must first obtain customer_name
     * before it can determine a resolution path.
     *
     * Expected:
     * Required argument missing: customer_name
     */
    AI_AgentRequest request = buildRequest('Show me customer details');

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertEquals(
      false,
      response.success,
      'The request should fail because customer_name is missing.'
    );

    System.assertEquals(
      'GET_CUSTOMER_DETAILS',
      response.intent,
      'The intent should be GET_CUSTOMER_DETAILS.'
    );

    System.assertEquals(
      'get_customer_details',
      response.selectedTool,
      'The selected tool should be get_customer_details.'
    );

    System.assertEquals(
      'Required argument missing: customer_name',
      response.errorMessage,
      'The missing customer_name should be reported.'
    );
  }

  @IsTest
  static void testOpenCasesRequiresResolution() {
    /*
     * No Account Id and no customer name are supplied.
     *
     * AI_AgentArgumentBuilder requires customer_name first
     * for the GET_OPEN_CASES intent.
     *
     * Therefore the expected result is:
     *
     * Required argument missing: customer_name
     */
    AI_AgentRequest request = buildRequest('Find the open cases');

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertEquals(
      false,
      response.success,
      'The request should fail because customer_name is missing.'
    );

    System.assertEquals(
      'GET_OPEN_CASES',
      response.intent,
      'The intent should be GET_OPEN_CASES.'
    );

    System.assertEquals(
      'get_open_cases',
      response.selectedTool,
      'The selected tool should be get_open_cases.'
    );

    System.assertEquals(
      'Required argument missing: customer_name',
      response.errorMessage,
      'The missing customer_name should be reported.'
    );
  }

  /*
   * ============================================================
   * MULTI-STEP RESOLUTION
   * ============================================================
   *
   * search_customer
   *       |
   *       v
   * resolve Account Id
   *       |
   *       v
   * get_open_cases
   */
  @IsTest
  static void testOpenCasesForCustomerSuccessfulResolutionChain() {
    Account accountRecord = createExactAcmeAccount();

    createOpenCase(accountRecord.Id);

    AI_AgentRequest request = buildRequest('Find the open cases for Acme');

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Resolution-chain response should not be null.'
    );

    System.assertEquals(
      'GET_OPEN_CASES',
      response.intent,
      'The original intent must be preserved.'
    );

    System.assertEquals(
      'get_open_cases',
      response.selectedTool,
      'The final selected tool must be get_open_cases.'
    );

    System.assertEquals(
      true,
      response.success,
      'The complete resolution chain should succeed. ' +
        'message=' +
        response.message +
        ', error=' +
        response.errorMessage +
        ', intent=' +
        response.intent +
        ', selectedTool=' +
        response.selectedTool +
        ', toolData=' +
        JSON.serialize(response.toolData)
    );

    System.assertNotEquals(
      null,
      response.toolData,
      'The final tool should return data.'
    );
  }

  /*
   * ============================================================
   * RESOLUTION FAILURE
   * ============================================================
   */

  @IsTest
  static void testOpenCasesForUnknownCustomerFailsResolution() {
    AI_AgentRequest request = buildRequest(
      'Find the open cases for CustomerThatDoesNotExist'
    );

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'GET_OPEN_CASES',
      response.intent,
      'Intent should be GET_OPEN_CASES.'
    );

    System.assertEquals(
      'get_open_cases',
      response.selectedTool,
      'Selected tool should be get_open_cases.'
    );

    System.assertEquals(
      false,
      response.success,
      'The chain should fail when customer resolution finds no customer.'
    );

    System.assertNotEquals(
      null,
      response.errorMessage,
      'A resolution failure should provide an error message.'
    );
  }

  /*
   * ============================================================
   * INVALID DOWNSTREAM TOOL ARGUMENT
   * ============================================================
   *
   * The previous value:
   *
   *     001000000000000AAA
   *
   * was accepted as a syntactically valid Salesforce Id.
   *
   * Use a deliberately malformed value instead.
   */
  @IsTest
  static void testInvalidSalesforceIdHandledByOrchestrator() {
    String invalidId = 'INVALID-ID';

    AI_AgentRequest request = buildRequest(
      'Find the open cases for ' + invalidId
    );

    Test.startTest();

    AI_AgentResponse response = AI_AgentOrchestrator.process(request);

    Test.stopTest();

    System.assertNotEquals(
      null,
      response,
      'Agent response should not be null.'
    );

    System.assertEquals(
      'GET_OPEN_CASES',
      response.intent,
      'Intent should be GET_OPEN_CASES.'
    );

    System.assertEquals(
      'get_open_cases',
      response.selectedTool,
      'Selected tool should be get_open_cases.'
    );

    System.assertEquals(
      false,
      response.success,
      'A malformed Salesforce Id should not produce a successful response.'
    );

    System.assertNotEquals(
      null,
      response.errorMessage,
      'The orchestrator should expose the execution/validation error.'
    );
  }

  /*
   * ============================================================
   * CONTEXT / CHAIN CONTROL
   * ============================================================
   */

  @IsTest
  static void testMaximumChainDepth() {
    AI_AgentContext context = new AI_AgentContext();

    System.assertEquals(
      5,
      context.maxDepth,
      'The expected maximum chain depth should be five.'
    );

    context.stepNumber = 5;

    System.assertEquals(
      false,
      context.canExecuteNextStep(),
      'Agent must stop after maximum chain depth.'
    );
  }

  @IsTest
  static void testContextRecordsToolResponses() {
    AI_AgentContext context = new AI_AgentContext();

    AI_ToolResponse response = AI_ToolResponse.failure(
      'search_customer',
      'Test failure'
    );

    context.recordToolResponse(response);

    System.assertEquals(
      1,
      context.toolResponses.size(),
      'One tool response should be recorded.'
    );

    System.assertEquals(
      1,
      context.getExecutedStepCount(),
      'Executed step count should increase after recording a response.'
    );
  }
}
