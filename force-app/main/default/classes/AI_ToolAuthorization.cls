public with sharing class AI_ToolAuthorization {

    /*
     * ============================================================
     * AI TOOL AUTHORIZATION
     * ============================================================
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
     * Authorization always fails closed.
     *
     * IMPORTANT:
     *
     * The LLM is never trusted to authorize itself.
     * The LLM cannot supply an Apex class, method,
     * endpoint, or implementation.
     */


    /*
     * ============================================================
     * BACKWARD-COMPATIBLE AUTHORIZATION API
     * ============================================================
     *
     * Existing callers use:
     *
     * AI_ToolAuthorization.authorize(tool);
     *
     * Keep this method because multiple existing classes depend
     * on this contract.
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
         * Delegate to the centralized authorization policy.
         */
        if (!isAuthorized(tool.Tool_API_Name__c)) {

            throw new AI_ServiceException(
                'Tool is not authorized.'
            );
        }
    }


    /*
     * ============================================================
     * TOOL-NAME AUTHORIZATION
     * ============================================================
     *
     * This method provides the explicit Apex allowlist.
     *
     * Unknown tools ALWAYS return false.
     */
    public static Boolean isAuthorized(
        String toolName
    ) {

        if (String.isBlank(toolName)) {
            return false;
        }


        /*
         * Establish the Salesforce execution context.
         */
        if (UserInfo.getUserId() == null) {
            return false;
        }


        /*
         * Explicit allowlist.
         *
         * The LLM cannot dynamically introduce a new tool.
         */
        switch on toolName {

            /*
             * ====================================================
             * READ TOOLS
             * ====================================================
             */

            when 'search_customer' {

                return authorizeReadOperation();
            }


            when 'get_customer_details' {

                return authorizeReadOperation();
            }


            when 'get_open_cases' {

                return authorizeReadOperation();
            }


            when 'get_case_details' {

                return authorizeReadOperation();
            }


            when 'search_knowledge' {

                return authorizeReadOperation();
            }


            when 'get_order_status' {

                return authorizeReadOperation();
            }


            /*
             * ====================================================
             * CREATE TOOLS
             * ====================================================
             */

            when 'create_case' {

                return authorizeCreateOperation();
            }


            when 'create_task' {

                return authorizeCreateOperation();
            }


            /*
             * ====================================================
             * UPDATE TOOLS
             * ====================================================
             */

            when 'update_case' {

                return authorizeUpdateOperation();
            }


            when 'escalate_case' {

                return authorizeUpdateOperation();
            }


            /*
             * ====================================================
             * UNKNOWN TOOL
             * ====================================================
             *
             * FAIL CLOSED
             * ====================================================
             */

            when else {

                return false;
            }
        }
    }


    /*
     * ============================================================
     * READ AUTHORIZATION
     * ============================================================
     *
     * Record-level access is enforced separately by:
     *
     * - with sharing
     * - USER_MODE queries
     * - CRUD/FLS
     */
    private static Boolean authorizeReadOperation() {

        return UserInfo.getUserId() != null;
    }


    /*
     * ============================================================
     * CREATE AUTHORIZATION
     * ============================================================
     *
     * CRUD/FLS and business authorization remain in the
     * service/execution layer.
     */
    private static Boolean authorizeCreateOperation() {

        return UserInfo.getUserId() != null;
    }


    /*
     * ============================================================
     * UPDATE AUTHORIZATION
     * ============================================================
     */
    private static Boolean authorizeUpdateOperation() {

        return UserInfo.getUserId() != null;
    }
}