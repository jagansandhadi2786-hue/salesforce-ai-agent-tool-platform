public with sharing class AI_ToolSchemaValidator {

    /*
     * Validates a tool request using the
     * application-defined contract for each tool.
     *
     * The schema is intentionally defined in Apex.
     * It does NOT depend on AI_Tool__c.Argument_Schema__c.
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

        AI_ToolValidator.validateToolName(
            request.toolName
        );

        validateArguments(
            request.toolName,
            request.arguments
        );
    }


    /*
     * Overload used by AI_ToolExecutor.
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

        if (tool == null) {
            throw new AI_ServiceException(
                'Tool is not registered or not active.'
            );
        }

        AI_ToolValidator.validateToolName(
            request.toolName
        );

        validateArguments(
            request.toolName,
            request.arguments
        );
    }


    /*
     * Tool-specific argument schemas.
     */
    public static void validateArguments(
        String toolName,
        Map<String, Object> arguments
    ) {

        if (String.isBlank(toolName)) {
            throw new AI_ServiceException(
                'Tool name is required.'
            );
        }

        AI_ToolValidator.validateToolName(
            toolName
        );

        if (arguments == null) {
            arguments =
                new Map<String, Object>();
        }

        switch on toolName {

            when 'search_customer' {

                validateRequired(
                    arguments,
                    'customer_name'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'customer_name'
                    }
                );
            }

            when 'get_customer_details' {

                validateRequired(
                    arguments,
                    'customer_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'customer_id'
                    }
                );
            }

            when 'get_open_cases' {

                validateRequired(
                    arguments,
                    'account_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'account_id'
                    }
                );
            }

            when 'get_case_details' {

                validateRequired(
                    arguments,
                    'case_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'case_id'
                    }
                );
            }

            when 'create_case' {

                validateRequired(
                    arguments,
                    'account_id'
                );

                validateRequired(
                    arguments,
                    'subject'
                );

                validateRequired(
                    arguments,
                    'description'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'account_id',
                        'subject',
                        'description',
                        'priority'
                    }
                );
            }

            when 'update_case' {

                validateRequired(
                    arguments,
                    'case_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'case_id',
                        'status',
                        'priority',
                        'subject'
                    }
                );

                validateAtLeastOneUpdateField(
                    arguments
                );
            }

            when 'create_task' {

                validateRequired(
                    arguments,
                    'what_id'
                );

                validateRequired(
                    arguments,
                    'subject'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'what_id',
                        'subject',
                        'due_date'
                    }
                );
            }

            when 'escalate_case' {

                validateRequired(
                    arguments,
                    'case_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'case_id'
                    }
                );
            }

            when 'search_knowledge' {

                validateRequired(
                    arguments,
                    'search_term'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'search_term'
                    }
                );
            }

            when 'get_order_status' {

                validateRequired(
                    arguments,
                    'order_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'order_id'
                    }
                );
            }

            when else {

                throw new AI_ServiceException(
                    'No schema is defined for tool: ' +
                    toolName
                );
            }
        }
    }


    /*
     * Required argument validation.
     */
    private static void validateRequired(
        Map<String, Object> arguments,
        String argumentName
    ) {

        if (
            !arguments.containsKey(argumentName) ||
            arguments.get(argumentName) == null
        ) {

            throw new AI_ServiceException(
                'Required argument missing: ' +
                argumentName
            );
        }

        String value =
            String.valueOf(
                arguments.get(argumentName)
            );

        if (String.isBlank(value)) {

            throw new AI_ServiceException(
                'Required argument is blank: ' +
                argumentName
            );
        }
    }


    /*
     * Prevent unexpected parameters from
     * being passed to a tool.
     */
    private static void validateAllowedArguments(
        Map<String, Object> arguments,
        Set<String> allowedArguments
    ) {

        for (String argumentName : arguments.keySet()) {

            if (!allowedArguments.contains(argumentName)) {

                throw new AI_ServiceException(
                    'Unexpected argument "' +
                    argumentName +
                    '" supplied to tool.'
                );
            }
        }
    }


    /*
     * update_case requires at least one
     * actual update field.
     */
    private static void validateAtLeastOneUpdateField(
        Map<String, Object> arguments
    ) {

        Boolean hasUpdateField =
            arguments.containsKey('status') ||
            arguments.containsKey('priority') ||
            arguments.containsKey('subject');

        if (!hasUpdateField) {

            throw new AI_ServiceException(
                'At least one case update field is required.'
            );
        }

        if (
            arguments.containsKey('status') &&
            arguments.get('status') == null
        ) {

            throw new AI_ServiceException(
                'Status cannot be null.'
            );
        }

        if (
            arguments.containsKey('priority') &&
            arguments.get('priority') == null
        ) {

            throw new AI_ServiceException(
                'Priority cannot be null.'
            );
        }

        if (
            arguments.containsKey('subject') &&
            arguments.get('subject') == null
        ) {

            throw new AI_ServiceException(
                'Subject cannot be null.'
            );
        }
    }
}