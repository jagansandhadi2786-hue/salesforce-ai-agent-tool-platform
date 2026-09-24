public with sharing class AI_ToolRegistry {

//     When the AI sends:
// {
//     "tool": "search_customer"
// }
// the executor calls: AI_ToolRegistry.getActiveTool('search_customer');
// The registry performs:
// search_customer
//        ↓
// AI_Tool__c
//        ↓
// Does tool exist?
//        ├── NO → Error
//        │
//        └── YES
//              ↓
//         Active?
//              │
//        ┌─────┴─────┐
//        NO          YES
//        │            │
//      Error        Continue
// This prevents the AI from executing an unknown or disabled tool.


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
                Handler_Class__c
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

        AI_Tool__c tool = getTool(toolName);

        if (!tool.Active__c) {
            throw new AI_ServiceException(
                'Tool is inactive: ' + toolName
            );
        }

        return tool;
    }
}
