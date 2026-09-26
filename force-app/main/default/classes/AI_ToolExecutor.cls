
public with sharing class AI_ToolExecutor {

    /*
     * Controlled Tool Executor
     *
     * Execution Flow:
     * Request
     *    |
     * Tool Registry
     *    |
     * Tool Validator
     *    |
     * Schema Validator
     *    |
     * Authorization
     *    |
     * Approval Check
     *    |
     * Controlled Dispatcher
     *    |
     * Salesforce Service
     *    |
     * Tool Response
     *
     * The LLM cannot dynamically invoke arbitrary Apex classes.
     * Only explicitly configured tools can be executed.
     */

    /**
     * Main Tool Execution Entry Point.
     */
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
             * Authorize the requested tool.
             */
            AI_ToolAuthorization.authorize(
                tool
            );

            /*
             * Step 5:
             * Check whether the tool requires approval.
             */
            if (tool.Requires_Approval__c) {

                return AI_ToolResponse.approvalRequired(
                    request.toolName
                );
            }

            /*
             * Step 6:
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
             * ---------------------------------------------------------
             * SEARCH CUSTOMER
             * ---------------------------------------------------------
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

                List<CustomerResponse> responseData =
                    AI_ToolResponseMapper.toCustomerResponses(
                        accounts
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * GET CUSTOMER DETAILS
             * ---------------------------------------------------------
             */
            when 'get_customer_details' {

                Id customerId =
                    getIdArgument(
                        request.arguments,
                        'customer_id'
                    );

                Account accountRecord =
                    CustomerService.getCustomerDetails(
                        customerId
                    );

                CustomerResponse responseData =
                    AI_ToolResponseMapper.toCustomerResponse(
                        accountRecord
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * GET OPEN CASES
             * ---------------------------------------------------------
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

                List<CaseResponse> responseData =
                    AI_ToolResponseMapper.toCaseResponses(
                        cases
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * GET CASE DETAILS
             * ---------------------------------------------------------
             */
            when 'get_case_details' {

                Id caseId =
                    getIdArgument(
                        request.arguments,
                        'case_id'
                    );

                Case caseRecord =
                    CaseService.getCaseDetails(
                        caseId
                    );

                CaseResponse responseData =
                    AI_ToolResponseMapper.toCaseResponse(
                        caseRecord
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * CREATE CASE
             * ---------------------------------------------------------
             */
            when 'create_case' {

                Id accountId =
                    getIdArgument(
                        request.arguments,
                        'account_id'
                    );

                String subject =
                    getStringArgument(
                        request.arguments,
                        'subject'
                    );

                String description =
                    getStringArgument(
                        request.arguments,
                        'description'
                    );

                String priority =
                    getOptionalStringArgument(
                        request.arguments,
                        'priority'
                    );

                Case newCase =
                    CaseService.createCase(
                        accountId,
                        subject,
                        description,
                        priority
                    );

                CaseResponse responseData =
                    AI_ToolResponseMapper.toCaseResponse(
                        newCase
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * UPDATE CASE
             * ---------------------------------------------------------
             */
            when 'update_case' {

                Id caseId =
                    getIdArgument(
                        request.arguments,
                        'case_id'
                    );

                String status =
                    getOptionalStringArgument(
                        request.arguments,
                        'status'
                    );

                String priority =
                    getOptionalStringArgument(
                        request.arguments,
                        'priority'
                    );

                String subject =
                    getOptionalStringArgument(
                        request.arguments,
                        'subject'
                    );

                Case updatedCase =
                    CaseService.updateCase(
                        caseId,
                        status,
                        priority,
                        subject
                    );

                CaseResponse responseData =
                    AI_ToolResponseMapper.toCaseResponse(
                        updatedCase
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * CREATE TASK
             * ---------------------------------------------------------
             */
            when 'create_task' {

                Id whatId =
                    getIdArgument(
                        request.arguments,
                        'what_id'
                    );

                String subject =
                    getStringArgument(
                        request.arguments,
                        'subject'
                    );

                Date dueDate =
                    getOptionalDateArgument(
                        request.arguments,
                        'due_date'
                    );

                Task taskRecord =
                    CaseService.createTask(
                        whatId,
                        subject,
                        dueDate
                    );

                TaskResponse responseData =
                    AI_ToolResponseMapper.toTaskResponse(
                        taskRecord
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * ESCALATE CASE
             * ---------------------------------------------------------
             */
            when 'escalate_case' {

                Id caseId =
                    getIdArgument(
                        request.arguments,
                        'case_id'
                    );

                Case escalatedCase =
                    CaseService.escalateCase(
                        caseId
                    );

                CaseResponse responseData =
                    AI_ToolResponseMapper.toCaseResponse(
                        escalatedCase
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * SEARCH KNOWLEDGE
             * ---------------------------------------------------------
             */
            when 'search_knowledge' {

                String searchTerm =
                    getStringArgument(
                        request.arguments,
                        'search_term'
                    );

                List<KnowledgeService.KnowledgeResult> results =
                    KnowledgeService.searchKnowledge(
                        searchTerm
                    );

                List<KnowledgeResponse> responseData =
                    new List<KnowledgeResponse>();

                for (
                    KnowledgeService.KnowledgeResult result :
                    results
                ) {

                    responseData.add(
                        new KnowledgeResponse(
                            result.title,
                            result.summary,
                            result.url
                        )
                    );
                }

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * GET ORDER STATUS
             * ---------------------------------------------------------
             */
            when 'get_order_status' {

                String orderNumber =
                    getStringArgument(
                        request.arguments,
                        'order_number'
                    );

                OrderService.OrderResult result =
                    OrderService.getOrderStatus(
                        orderNumber
                    );

                OrderResponse responseData =
                    AI_ToolResponseMapper.toOrderResponse(
                        result
                    );

                return AI_ToolResponse.success(
                    request.toolName,
                    responseData
                );
            }


            /*
             * ---------------------------------------------------------
             * UNKNOWN / UNCONFIGURED TOOL
             * ---------------------------------------------------------
             */
            when else {

                return AI_ToolResponse.failure(
                    request.toolName,
                    'Tool is registered but no executor is configured.'
                );
            }
        }
    }


    /*
     * ================================================================
     * ARGUMENT HELPERS
     * ================================================================
     */

    /**
     * Required String argument.
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
                'Required argument is missing: ' +
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
     * Optional String argument.
     */
    private static String getOptionalStringArgument(
        Map<String, Object> arguments,
        String argumentName
    ) {

        if (
            arguments == null ||
            !arguments.containsKey(argumentName) ||
            arguments.get(argumentName) == null
        ) {

            return null;
        }

        String value =
            String.valueOf(
                arguments.get(argumentName)
            );

        if (String.isBlank(value)) {

            return null;
        }

        return value.trim();
    }


    /**
     * Required Salesforce Id argument.
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
                'Invalid Salesforce Id for argument: ' +
                argumentName
            );
        }
    }


    /**
     * Optional Date argument.
     *
     * Expected format:
     * YYYY-MM-DD
     */
    private static Date getOptionalDateArgument(
        Map<String, Object> arguments,
        String argumentName
    ) {

        String value =
            getOptionalStringArgument(
                arguments,
                argumentName
            );

        if (String.isBlank(value)) {

            return null;
        }

        try {

            return Date.valueOf(value);

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Invalid date for argument: ' +
                argumentName
            );
        }
    }
}
