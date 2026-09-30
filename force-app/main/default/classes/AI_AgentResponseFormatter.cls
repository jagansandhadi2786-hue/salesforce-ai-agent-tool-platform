public with sharing class AI_AgentResponseFormatter {

    public static String format(
        AI_AgentRequest request,
        AI_AgentIntent intent,
        AI_AgentToolSelection selection,
        AI_AgentArgumentResult argumentResult,
        AI_ToolResponse toolResponse
    ) {

        if (toolResponse == null) {
            return 'I could not complete the request.';
        }

        /*
         * Approval takes precedence over normal success/failure.
         */
        if (toolResponse.requiresApproval == true) {
            return 'This action requires approval before it can be executed.';
        }

        /*
         * Tool execution failed.
         */
        if (toolResponse.success != true) {
            return 'I could not complete the requested action.';
        }

        /*
         * Successful execution without a specific intent.
         */
        if (intent == null) {
            return 'The request was completed successfully.';
        }

        /*
         * Customer search.
         */
        if (intent.intentName == 'SEARCH_CUSTOMER') {
            return 'Customer search completed successfully.';
        }

        /*
         * Customer details.
         */
        if (intent.intentName == 'GET_CUSTOMER_DETAILS') {
            return 'Customer details were retrieved successfully.';
        }

        /*
         * Open cases.
         */
        if (intent.intentName == 'GET_OPEN_CASES') {
            return 'Open cases were retrieved successfully.';
        }

        /*
         * Case details.
         */
        if (intent.intentName == 'GET_CASE_DETAILS') {
            return 'Case details were retrieved successfully.';
        }

        /*
         * Create case.
         */
        if (intent.intentName == 'CREATE_CASE') {
            return 'The case request was submitted successfully.';
        }

        /*
         * Update case.
         */
        if (intent.intentName == 'UPDATE_CASE') {
            return 'The case update was completed successfully.';
        }

        /*
         * Create task.
         */
        if (intent.intentName == 'CREATE_TASK') {
            return 'The task was created successfully.';
        }

        /*
         * Escalate case.
         */
        if (intent.intentName == 'ESCALATE_CASE') {
            return 'The case was escalated successfully.';
        }

        /*
         * Knowledge search.
         */
        if (intent.intentName == 'SEARCH_KNOWLEDGE') {
            return 'Knowledge search completed successfully.';
        }

        /*
         * Order status.
         */
        if (intent.intentName == 'GET_ORDER_STATUS') {
            return 'Order status was retrieved successfully.';
        }

        /*
         * Default success message.
         */
        return 'The request was completed successfully.';
    }
}