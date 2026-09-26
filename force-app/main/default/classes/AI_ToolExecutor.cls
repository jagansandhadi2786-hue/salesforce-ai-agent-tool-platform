public with sharing class AI_ToolExecutor {

    /*
     * Controlled Tool Executor
     * Execution Flow:
     * Request
     * Tool Registry   |
     * Tool Validator
     * Schema Validator
     * Approval Check
     * Controlled Dispatcher
     * Salesforce Service
     * Tool Response
     * The LLM cannot dynamically invoke arbitrary Apex classes.
     *
     * The database configuration determines whether a tool
     * exists and is active.
     *
     * The Apex dispatcher determines what code can actually execute.
     */


    /**
     * Main Tool Execution Entry Point.
     */
    public static AI_ToolResponse execute(
        AI_ToolRequest request
    ) {

        /*
         * Validate request before entering the main
         * execution pipeline.
         */
        if (request == null) {

            return AI_ToolResponse.failure(
                null,
                'Tool request is required.'
            );
        }


        if (!request.isValid()) {

            return AI_ToolResponse.failure(
                request.toolName,
                'Tool name is required.'
            );
        }


        try {

            /*
             * Step 1:
             * Retrieve the active tool from the registry.
             */
            AI_Tool__c tool =
                AI_ToolRegistry.getActiveTool(
                    request.toolName
                );

            /*
             * Step 2:
             * Validate the registered tool and request.
             */
            AI_ToolValidator.validate(
                request,
                tool
            );

            /*
             * Step 3:
             * Validate the tool argument schema.
             */
            AI_ToolSchemaValidator.validate(
                request,
                tool
            );


            /*
             * Step 4:
             * Check whether the tool requires approval.
             */
            if (tool.Requires_Approval__c) {

                return AI_ToolResponse.approvalRequired(
                    request.toolName
                );
            }


            /*
             * Step 5:
             * Execute through the controlled dispatcher.
             */
            return dispatch(
                request,
                tool
            );


        } catch (AI_ServiceException ex) {

            return AI_ToolResponse.failure(
                request.toolName,
                ex.getMessage()
            );


        } catch (Exception ex) {

            return AI_ToolResponse.failure(
                request.toolName,
                'Unexpected tool execution error.'
            );
        }
    }


    /**
     * Controlled dispatcher.
     *
     * Only explicitly approved tools can reach
     * Salesforce service methods.
     */
    private static AI_ToolResponse dispatch(
        AI_ToolRequest request,
        AI_Tool__c tool
    ) {

        switch on request.toolName {


            /*
             * search_customer
             */
            when 'search_customer' {

                String customerName =
                    getStringArgument(
                        request.arguments,
                        'customer_name'
                    );


                List<Account> accounts =
                    CustomerService.searchCustomer(
                        customerName
                    );


                return AI_ToolResponse.success(
                    request.toolName,
                    accounts
                );
            }

            /*
             * get_customer_details
             */
            when 'get_customer_details' {

                Id customerId =
                    getIdArgument(
                        request.arguments,
                        'customer_id'
                    );


                Account account =
                    CustomerService.getCustomerDetails(
                        customerId
                    );


                return AI_ToolResponse.success(
                    request.toolName,
                    account
                );
            }


            /*
             * get_open_cases
             */
            when 'get_open_cases' {

                Id accountId =
                    getIdArgument(
                        request.arguments,
                        'account_id'
                    );


                List<Case> cases =
                    CaseService.getOpenCases(
                        accountId
                    );


                return AI_ToolResponse.success(
                    request.toolName,
                    cases
                );
            }


            /*
             * Tools that are registered but not yet
             * connected to the controlled dispatcher.
             */
            when else {

                return AI_ToolResponse.failure(
                    request.toolName,
                    'Tool is registered but no executor is configured.'
                );
            }
        }
    }

    /**
     * Retrieve a String argument.
     */
    private static String getStringArgument(
        Map<String, Object> arguments,
        String argumentName
    ) {

        if (
            arguments == null ||
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


        return value.trim();
    }


    /**
     * Retrieve and validate a Salesforce Id argument.
     */
    private static Id getIdArgument(
        Map<String, Object> arguments,
        String argumentName
    ) {

        String value =
            getStringArgument(
                arguments,
                argumentName
            );


        try {

            return (Id)value;

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Invalid Salesforce ID for argument: ' +
                argumentName
            );
        }
    }
}