public with sharing class AI_ToolRegistry {

    public static AI_Tool__c getTool(
        String toolName
    ) {

        if (String.isBlank(toolName)) {

            throw new AI_ServiceException(
                'Tool name is required.'
            );
        }

        List<AI_Tool__c> tools = [
            SELECT
                Id,
                Name,
                Tool_API_Name__c,
                Description__c,
                Tool_Type__c,
                Active__c,
                Requires_Approval__c,
                Handler_Class__c,
                Allowed_Arguments__c,
                Required_Arguments__c,
                Permission_Name__c
            FROM AI_Tool__c
            WHERE Tool_API_Name__c = :toolName
            LIMIT 1
        ];

        if (tools.isEmpty()) {

            throw new AI_ServiceException(
                'Tool not found: ' + toolName
            );
        }

        return tools[0];
    }

    public static AI_Tool__c getActiveTool(
        String toolName
    ) {

        AI_Tool__c tool =
            getTool(toolName);

        if (!tool.Active__c) {

            throw new AI_ServiceException(
                'Tool is inactive: ' + toolName
            );
        }

        return tool;
    }
}