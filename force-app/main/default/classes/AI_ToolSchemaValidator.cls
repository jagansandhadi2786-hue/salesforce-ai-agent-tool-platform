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

            // =====================================================
            // search_customer
            // =====================================================
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


            // =====================================================
            // get_customer_details
            // =====================================================
            when 'get_customer_details' {

                validateRequired(
                    arguments,
                    'customer_id'
                );

                validateSalesforceId(
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


            // =====================================================
            // get_open_cases
            // =====================================================
            when 'get_open_cases' {

                validateRequired(
                    arguments,
                    'account_id'
                );

                validateSalesforceId(
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


            // =====================================================
            // get_case_details
            // =====================================================
            when 'get_case_details' {

                validateRequired(
                    arguments,
                    'case_id'
                );

                validateSalesforceId(
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


            // =====================================================
            // create_case
            // =====================================================
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

                validateSalesforceId(
                    arguments,
                    'account_id'
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

                /*
                 * priority is optional,
                 * but if supplied it must be valid.
                 */
                validatePriority(
                    arguments
                );
            }


            // =====================================================
            // update_case
            // =====================================================
            when 'update_case' {

                validateRequired(
                    arguments,
                    'case_id'
                );

                validateSalesforceId(
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

                /*
                 * If priority is supplied,
                 * validate its allowed value.
                 */
                validatePriority(
                    arguments
                );
            }


            // =====================================================
            // create_task
            // =====================================================
            when 'create_task' {

                validateRequired(
                    arguments,
                    'what_id'
                );

                validateRequired(
                    arguments,
                    'subject'
                );

                validateSalesforceId(
                    arguments,
                    'what_id'
                );

                validateAllowedArguments(
                    arguments,
                    new Set<String>{
                        'what_id',
                        'subject',
                        'due_date'
                    }
                );

                /*
                 * due_date is optional,
                 * but if supplied it must be a valid date.
                 */
                validateDate(
                    arguments,
                    'due_date'
                );
            }


            // =====================================================
            // escalate_case
            // =====================================================
            when 'escalate_case' {

                validateRequired(
                    arguments,
                    'case_id'
                );

                validateSalesforceId(
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


            // =====================================================
            // search_knowledge
            // =====================================================
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


            // =====================================================
            // get_order_status
            // =====================================================
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


            // =====================================================
            // Unknown tool schema
            // =====================================================
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
     * Salesforce ID format validation.
     *
     * Supports Salesforce 15-character
     * and 18-character ID formats.
     */
    private static void validateSalesforceId(
        Map<String, Object> arguments,
        String argumentName
    ) {

        Object value =
            arguments.get(argumentName);

        if (value == null) {

            throw new AI_ServiceException(
                'Invalid ID argument: ' +
                argumentName
            );
        }

        String idValue =
            String.valueOf(value).trim();

        if (
            !Pattern.matches(
                '^[a-zA-Z0-9]{15}([a-zA-Z0-9]{3})?$',
                idValue
            )
        ) {

            throw new AI_ServiceException(
                'Invalid ID argument: ' +
                argumentName
            );
        }
    }


    /*
     * Date validation.
     *
     * Expected format:
     * yyyy-MM-dd
     */
    private static void validateDate(
        Map<String, Object> arguments,
        String argumentName
    ) {

        if (!arguments.containsKey(argumentName)) {
            return;
        }

        Object value =
            arguments.get(argumentName);

        if (value == null) {

            throw new AI_ServiceException(
                'Invalid date for argument: ' +
                argumentName
            );
        }

        String dateValue =
            String.valueOf(value).trim();

        try {

            Date.valueOf(dateValue);

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Invalid date for argument: ' +
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
     * Validates the allowed Case priority values.
     *
     * Salesforce Case Priority values supported
     * by this application contract are:
     *
     * Low
     * Medium
     * High
     */
    private static void validatePriority(
        Map<String, Object> arguments
    ) {

        if (!arguments.containsKey('priority')) {
            return;
        }

        Object priorityValue =
            arguments.get('priority');

        if (priorityValue == null) {

            throw new AI_ServiceException(
                'Priority cannot be null.'
            );
        }

        String priority =
            String.valueOf(priorityValue);

        Set<String> allowedPriorities =
            new Set<String>{
                'Low',
                'Medium',
                'High'
            };

        if (!allowedPriorities.contains(priority)) {

            throw new AI_ServiceException(
                'Invalid value for priority: ' +
                priority
            );
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