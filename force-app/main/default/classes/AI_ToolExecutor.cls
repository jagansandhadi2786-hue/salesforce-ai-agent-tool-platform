public with sharing class AI_ToolExecutor {

// Tool Executor - Request, Validate, Registry, Authorization, Approval, Execute, Response
// However, there is an important Salesforce/Apex design issue here.
// We should not use arbitrary reflection to let an AI specify: Handler_Class__c = SomeClass
// and then dynamically invoke any method.
// That would create an unnecessarily dangerous execution model.
// Instead, we'll create a controlled dispatcher.
// For example:
// search_customer
// AI_ToolExecutor
// switch/tool mapping
// CustomerService.searchCustomer()
// The database configuration determines whether a tool exists and is active, while the Apex executor controls what code can actually execute.


    public static AI_ToolResponse execute(
        AI_ToolRequest request
    ) {

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

            AI_Tool__c tool =
                AI_ToolRegistry.getActiveTool(
                    request.toolName
                );

            if (tool.Requires_Approval__c) {

                return AI_ToolResponse
                    .approvalRequired(
                        request.toolName
                    );
            }

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

    private static AI_ToolResponse dispatch(
        AI_ToolRequest request,
        AI_Tool__c tool
    ) {

        switch on request.toolName {

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

            when else {

                return AI_ToolResponse.failure(
                    request.toolName,
                    'Tool is registered but no executor is configured.'
                );
            }
        }
    }

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
