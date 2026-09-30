@IsTest
private class AI_AgentResponseFormatterTest {

    /*
     * ------------------------------------------------
     * Test 1
     * Null inputs
     * ------------------------------------------------
     */
    @IsTest
    static void testFormatWithNullInputs() {

        Test.startTest();

        String message =
            AI_AgentResponseFormatter.format(
                null,
                null,
                null,
                null,
                null
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            message,
            'Formatter should return a message.'
        );

        System.assertEquals(
            'I could not complete the request because the tool did not return a response.',
            message,
            'Null tool response should return the expected fallback message.'
        );
    }


    /*
     * ------------------------------------------------
     * Test 2
     * Successful tool response
     * ------------------------------------------------
     */
    @IsTest
    static void testFormatWithToolSuccess() {

        Map<String, Object> data =
            new Map<String, Object>{
                'caseId' => '500000000000001'
            };

        AI_ToolResponse toolResponse =
            AI_ToolResponse.success(
                'CaseService',
                data
            );

        Test.startTest();

        String message =
            AI_AgentResponseFormatter.format(
                null,
                null,
                null,
                null,
                toolResponse
            );

        Test.stopTest();

        System.assertEquals(
            'Tool executed successfully.',
            message,
            'Successful tool response should use the tool message.'
        );
    }


    /*
     * ------------------------------------------------
     * Test 3
     * Tool failure
     * ------------------------------------------------
     */
    @IsTest
    static void testFormatWithToolFailure() {

        AI_ToolResponse toolResponse =
            AI_ToolResponse.failure(
                'CaseService',
                'Case could not be processed.'
            );

        Test.startTest();

        String message =
            AI_AgentResponseFormatter.format(
                null,
                null,
                null,
                null,
                toolResponse
            );

        Test.stopTest();

        System.assertEquals(
            'Case could not be processed.',
            message,
            'Tool failure message should be returned.'
        );
    }


    /*
     * ------------------------------------------------
     * Test 4
     * Approval required
     * ------------------------------------------------
     */
    @IsTest
    static void testFormatWithApprovalRequired() {

        AI_ToolResponse toolResponse =
            AI_ToolResponse.approvalRequired(
                'UpdateCase'
            );

        Test.startTest();

        String message =
            AI_AgentResponseFormatter.format(
                null,
                null,
                null,
                null,
                toolResponse
            );

        Test.stopTest();

        System.assertEquals(
            'Approval is required before this tool can be executed.',
            message,
            'Approval message should be returned.'
        );
    }
}