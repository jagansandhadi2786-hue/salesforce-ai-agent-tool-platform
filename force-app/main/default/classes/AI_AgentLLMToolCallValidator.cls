public with sharing class AI_AgentLLMToolCallValidator {

    public static AI_AgentLLMToolCallValidationResult validate(
        AI_AgentLLMToolCall toolCall
    ) {

        if (toolCall == null) {
            return failure(
                'Tool call is required.'
            );
        }

        if (String.isBlank(toolCall.toolName)) {
            return failure(
                'Tool name is required.'
            );
        }

        String toolName =
            toolCall.toolName.trim();

        /*
         * STEP 1
         * Verify that the tool exists in the
         * Salesforce contract catalog.
         */
        if (!AI_ToolContractCatalog.isRegistered(toolName)) {
            return failure(
                'Requested tool is not registered.'
            );
        }

        /*
         * STEP 2
         * Retrieve the registered Salesforce tool.
         */
        AI_Tool__c tool;

        try {

            List<AI_Tool__c> tools = [
                SELECT
                    Id,
                    Name,
                    Tool_API_Name__c,
                    Description__c,
                    Active__c,
                    Requires_Approval__c,
                    Tool_Type__c,
                    Handler_Class__c
                FROM AI_Tool__c
                WHERE Tool_API_Name__c = :toolName
                WITH USER_MODE
                LIMIT 1
            ];

            if (tools.isEmpty()) {
                return failure(
                    'Requested tool is not available.'
                );
            }

            tool = tools[0];

        } catch (Exception ex) {

            return failure(
                'Unable to validate requested tool.'
            );
        }

        /*
         * STEP 3
         * Tool must be active.
         */
        if (tool.Active__c != true) {
            return failure(
                'Requested tool is inactive.'
            );
        }

        /*
         * STEP 4
         * Convert LLM arguments into AI_ToolRequest.
         *
         * This delegates final argument validation
         * to the existing Phase 6 framework.
         */
        AI_ToolRequest request =
            new AI_ToolRequest();

        request.toolName = toolName;

        request.arguments =
            toolCall.arguments == null
                ? new Map<String, Object>()
                : toolCall.arguments;

        /*
         * STEP 5
         * Existing tool validator.
         */
        try {

            AI_ToolValidator.validate(
                request,
                tool
            );

        } catch (Exception ex) {

            return failure(
                sanitizeError(
                    ex.getMessage()
                )
            );
        }

        /*
         * STEP 6
         * Existing schema validator.
         */
        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

        } catch (Exception ex) {

            return failure(
                sanitizeError(
                    ex.getMessage()
                )
            );
        }

        /*
         * STEP 7
         * Authorization.
         *
         * AI_ToolAuthorization.authorize()
         * is fail-closed and returns void.
         *
         * Successful completion means authorization
         * passed.
         *
         * Any exception means authorization failed.
         */
        try {

            AI_ToolAuthorization.authorize(
                tool
            );

        } catch (Exception ex) {

            return failure(
                'Tool authorization failed.'
            );
        }

        /*
         * STEP 8
         * Approval.
         *
         * Do not execute approval-required tools here.
         */
        if (tool.Requires_Approval__c == true) {

            return AI_AgentLLMToolCallValidationResult.success(
                toolName,
                true
            );
        }

        return AI_AgentLLMToolCallValidationResult.success(
            toolName,
            false
        );
    }


    private static AI_AgentLLMToolCallValidationResult failure(
        String message
    ) {

        return AI_AgentLLMToolCallValidationResult.failure(
            message
        );
    }


    private static String sanitizeError(
        String message
    ) {

        if (String.isBlank(message)) {
            return 'Tool call validation failed.';
        }

        /*
         * Do not expose implementation details,
         * SOQL, stack traces, endpoint URLs,
         * credentials, or internal class names.
         */
        if (
            message.toLowerCase().contains('exception') ||
            message.toLowerCase().contains('stack trace') ||
            message.toLowerCase().contains('callout:')
        ) {

            return 'Tool call validation failed.';
        }

        return message;
    }
}