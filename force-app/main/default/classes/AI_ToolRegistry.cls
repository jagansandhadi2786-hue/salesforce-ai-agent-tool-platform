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

        String normalizedName =
            toolName.trim();

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
            WHERE Tool_API_Name__c = :normalizedName
            LIMIT 1
        ];

        if (tools.isEmpty()) {
            return null;
        }

        return tools[0];
    }


    /**
     * Returns an active tool by its Tool API Name.
     *
     * Security boundary:
     * An unknown or inactive tool must never be
     * returned as an executable runtime tool.
     *
     * Blank input returns null because there is
     * no valid tool name to look up.
     */
    public static AI_Tool__c getActiveTool(
        String toolName
    ) {

        /*
         * Blank tool name.
         *
         * Preserve the registry lookup contract:
         * invalid/blank lookup returns null.
         */
        if (String.isBlank(toolName)) {
            return null;
        }


        String normalizedName =
            toolName.trim();


        /*
         * Locate the tool regardless of Active__c.
         *
         * getTool() performs the registry lookup.
         */
        AI_Tool__c tool =
            getTool(normalizedName);


        /*
         * Tool does not exist.
         *
         * Do not expose whether a requested tool
         * exists as an executable runtime tool.
         */
        if (tool == null) {

            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }


        /*
         * Tool exists but is inactive.
         *
         * Inactive tools must never be returned
         * for runtime execution.
         */
        if (tool.Active__c != true) {

            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }


        /*
         * Tool exists and is active.
         */
        return tool;
    }
}