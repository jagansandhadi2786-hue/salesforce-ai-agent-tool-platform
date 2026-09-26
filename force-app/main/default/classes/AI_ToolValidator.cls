public with sharing class AI_ToolValidator {

    /*
     * ---------------------------------------------------------
     * Main request validation
     * ---------------------------------------------------------
     */
    public static void validate(
        AI_ToolRequest request
    ) {

        if (request == null) {
            throw new AI_ServiceException(
                'Tool request is required.'
            );
        }

        if (!request.isValid()) {
            throw new AI_ServiceException(
                'Tool name is required.'
            );
        }

        validateToolName(
            request.toolName
        );

        AI_Tool__c tool =
            AI_ToolRegistry.getActiveTool(
                request.toolName
            );

        if (tool == null) {
            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }
    }


    /*
     * ---------------------------------------------------------
     * Validation overload used by AI_ToolExecutor
     * ---------------------------------------------------------
     */
    public static void validate(
        AI_ToolRequest request,
        AI_Tool__c tool
    ) {

        if (request == null) {
            throw new AI_ServiceException(
                'Tool request is required.'
            );
        }

        if (!request.isValid()) {
            throw new AI_ServiceException(
                'Tool name is required.'
            );
        }

        validateToolName(
            request.toolName
        );

        if (tool == null) {
            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }

        if (
            String.isBlank(
                tool.Tool_API_Name__c
            )
        ) {
            throw new AI_ServiceException(
                'Tool API name is required.'
            );
        }

        if (
            tool.Tool_API_Name__c !=
            request.toolName
        ) {
            throw new AI_ServiceException(
                'Tool request does not match the registered tool.'
            );
        }
    }


    /*
     * ---------------------------------------------------------
     * Tool name allow-list
     * ---------------------------------------------------------
     */
    public static void validateToolName(
        String toolName
    ) {

        if (String.isBlank(toolName)) {
            throw new AI_ServiceException(
                'Tool name is required.'
            );
        }

        String normalizedName =
            toolName.trim();

        Set<String> allowedTools =
            new Set<String>{
                'search_customer',
                'get_customer_details',
                'get_open_cases',
                'get_case_details',
                'create_case',
                'update_case',
                'create_task',
                'escalate_case',
                'search_knowledge',
                'get_order_status'
            };

        if (!allowedTools.contains(
            normalizedName
        )) {

            throw new AI_ServiceException(
                'Unknown tool: ' +
                normalizedName
            );
        }
    }


    /*
     * ---------------------------------------------------------
     * Validate and return active tool
     * ---------------------------------------------------------
     */
    public static AI_Tool__c validateActiveTool(
        String toolName
    ) {

        validateToolName(
            toolName
        );

        AI_Tool__c tool =
            AI_ToolRegistry.getActiveTool(
                toolName
            );

        if (tool == null) {
            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }

        return tool;
    }


    /*
     * ---------------------------------------------------------
     * Generic argument validation
     *
     * Detailed argument schemas are handled by
     * AI_ToolSchemaValidator.
     * ---------------------------------------------------------
     */
    public static void validateArguments(
        Map<String, Object> arguments
    ) {

        if (arguments == null) {
            throw new AI_ServiceException(
                'Tool arguments are required.'
            );
        }
    }
}