public with sharing class AI_AgentLLMToolDefinitionBuilder {

    public static List<AI_AgentLLMToolDefinition> buildAll() {

        List<AI_AgentLLMToolDefinition> definitions =
            new List<AI_AgentLLMToolDefinition>();

        for (String toolName :
            AI_ToolContractCatalog.getToolNames()) {

            AI_AgentLLMToolDefinition definition =
                build(toolName);

            if (definition != null) {
                definitions.add(definition);
            }
        }

        return definitions;
    }


    public static AI_AgentLLMToolDefinition build(
        String toolName
    ) {

        if (String.isBlank(toolName)) {
            return null;
        }

        if (!AI_ToolContractCatalog.isRegistered(toolName)) {
            return null;
        }

        AI_ToolContractCatalog.ToolContract contract =
            AI_ToolContractCatalog.getContract(toolName);

        if (contract == null) {
            return null;
        }

        Map<String, Object> parameters =
            new Map<String, Object>();

        parameters.put('type', 'object');

        Map<String, Object> properties =
            new Map<String, Object>();

        List<String> requiredArguments =
            new List<String>();

        for (String argumentName : contract.arguments.keySet()) {
            AI_ToolContractCatalog.ArgumentDefinition argument =
            contract.arguments.get(argumentName);
            Map<String, Object> property =
                new Map<String, Object>();

            property.put(
                'type',
                mapDataType(argument.dataType)
            );

            if (argument.allowedValues != null &&
                !argument.allowedValues.isEmpty()) {

                property.put(
                    'enum',
                    argument.allowedValues
                );
            }

            properties.put(
                argument.name,
                property
            );

            if (argument.required == true) {
                requiredArguments.add(argument.name);
            }
        }

        parameters.put(
            'properties',
            properties
        );

        parameters.put(
            'required',
            requiredArguments
        );

        parameters.put(
            'additionalProperties',
            false
        );

        return new AI_AgentLLMToolDefinition(
            toolName,
            buildDescription(toolName),
            parameters
        );
    }


    private static String mapDataType(
        String dataType
    ) {

        if (String.isBlank(dataType)) {
            return 'string';
        }

        String normalized =
            dataType.trim().toLowerCase();

        if (normalized == 'integer') {
            return 'integer';
        }

        if (normalized == 'number') {
            return 'number';
        }

        if (normalized == 'boolean') {
            return 'boolean';
        }

        if (normalized == 'object') {
            return 'object';
        }

        if (normalized == 'array') {
            return 'array';
        }

        return 'string';
    }


    private static String buildDescription(
        String toolName
    ) {

        if (toolName == 'search_customer') {
            return 'Find a Salesforce customer by name.';
        }

        if (toolName == 'get_customer_details') {
            return 'Retrieve details for a Salesforce customer.';
        }

        if (toolName == 'get_open_cases') {
            return 'Retrieve open cases for a Salesforce customer.';
        }

        if (toolName == 'get_case_details') {
            return 'Retrieve details for a Salesforce case.';
        }

        if (toolName == 'create_case') {
            return 'Create a Salesforce customer service case.';
        }

        if (toolName == 'update_case') {
            return 'Update an existing Salesforce customer service case.';
        }

        if (toolName == 'create_task') {
            return 'Create a Salesforce task.';
        }

        if (toolName == 'escalate_case') {
            return 'Escalate a Salesforce customer service case.';
        }

        if (toolName == 'search_knowledge') {
            return 'Search approved customer service knowledge.';
        }

        if (toolName == 'get_order_status') {
            return 'Retrieve the status of a customer order.';
        }

        return 'Execute an approved Salesforce AI Agent tool.';
    }
}
