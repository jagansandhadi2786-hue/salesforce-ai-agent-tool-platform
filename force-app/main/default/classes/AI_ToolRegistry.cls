public with sharing class AI_ToolRegistry {

    /**
     * Returns a tool by its Tool API Name.
     *
     * The registry is responsible only for locating
     * the AI_Tool__c record.
     *
     * Contract/schema validation is handled separately
     * by AI_ToolSchemaValidator.
     */
    public static AI_Tool__c getTool(String toolName) {

        if (String.isBlank(toolName)) {
            return null;
        }

        List<AI_Tool__c> tools = [
            SELECT
                Id,
                Name,
                Tool_API_Name__c,
                Description__c,
                Active__c,
                Handler_Class__c,
                Requires_Approval__c,
                Tool_Type__c,
                Allowed_Arguments__c
            FROM AI_Tool__c
            WHERE Tool_API_Name__c = :toolName
            LIMIT 1
        ];

        if (tools.isEmpty()) {
            return null;
        }

        return tools[0];
    }


    /**
     * Returns an active tool by its Tool API Name.
     */
    public static AI_Tool__c getActiveTool(String toolName) {

        if (String.isBlank(toolName)) {
            return null;
        }

        List<AI_Tool__c> tools = [
            SELECT
                Id,
                Name,
                Tool_API_Name__c,
                Description__c,
                Active__c,
                Handler_Class__c,
                Requires_Approval__c,
                Tool_Type__c,
                Allowed_Arguments__c
            FROM AI_Tool__c
            WHERE Tool_API_Name__c = :toolName
            AND Active__c = true
            LIMIT 1
        ];

        if (tools.isEmpty()) {
            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }

        return tools[0];
    }
}