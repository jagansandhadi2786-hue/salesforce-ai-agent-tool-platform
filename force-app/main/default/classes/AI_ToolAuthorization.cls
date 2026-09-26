public with sharing class AI_ToolAuthorization {

    /*
     * Tool Authorization Layer
     *
     * Security Flow:
     *
     * AI Request
     *     |
     *     v
     * Tool Registry
     *     |
     *     v
     * Tool Validation
     *     |
     *     v
     * Schema Validation
     *     |
     *     v
     * Authorization
     *     |
     *     v
     * Approval
     *     |
     *     v
     * Controlled Execution
     *
     * Authorization fails closed.
     */


    /**
     * Authorize the registered tool.
     *
     * The current user is established by the
     * Salesforce execution context.
     */
    public static void authorize(
        AI_Tool__c tool
    ) {

        if (tool == null) {

            throw new AI_ServiceException(
                'Tool is required for authorization.'
            );
        }


        if (!tool.Active__c) {

            throw new AI_ServiceException(
                'Tool is not active.'
            );
        }


        if (String.isBlank(tool.Tool_API_Name__c)) {

            throw new AI_ServiceException(
                'Tool API name is required for authorization.'
            );
        }


        /*
         * The authorization policy is explicitly
         * controlled by Apex.
         *
         * The AI cannot supply an arbitrary class,
         * method, or Apex implementation.
         */
        switch on tool.Tool_API_Name__c {

            when 'search_customer' {

                authorizeReadOperation();
            }


            when 'get_customer_details' {

                authorizeReadOperation();
            }


            when 'get_open_cases' {

                authorizeReadOperation();
            }


            when 'get_case_details' {

                authorizeReadOperation();
            }


            when 'create_case' {

                authorizeCreateOperation();
            }


            when 'update_case' {

                authorizeUpdateOperation();
            }


            when 'create_task' {

                authorizeCreateOperation();
            }


            when 'escalate_case' {

                authorizeUpdateOperation();
            }


            when 'search_knowledge' {

                authorizeReadOperation();
            }


            when 'get_order_status' {

                authorizeReadOperation();
            }


            when else {

                throw new AI_ServiceException(
                    'Tool authorization is not configured.'
                );
            }
        }
    }


    /**
     * Authorization for read-only tools.
     *
     * Record-level access is subsequently enforced
     * by Salesforce sharing and USER_MODE queries.
     */
    private static void authorizeReadOperation() {

        if (UserInfo.getUserId() == null) {

            throw new AI_ServiceException(
                'Unable to establish current user.'
            );
        }
    }


    /**
     * Authorization for create operations.
     *
     * CRUD/FLS enforcement remains in the service
     * layer and Salesforce USER_MODE/DML AS USER.
     */
    private static void authorizeCreateOperation() {

        if (UserInfo.getUserId() == null) {

            throw new AI_ServiceException(
                'Unable to establish current user.'
            );
        }
    }


    /**
     * Authorization for update operations.
     */
    private static void authorizeUpdateOperation() {

        if (UserInfo.getUserId() == null) {

            throw new AI_ServiceException(
                'Unable to establish current user.'
            );
        }
    }
}