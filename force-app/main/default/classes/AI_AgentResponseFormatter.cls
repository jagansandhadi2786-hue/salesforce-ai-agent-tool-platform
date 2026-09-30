public with sharing class AI_AgentResponseFormatter {

    /*
     * Format the final user-facing message.
     *
     * The orchestrator is responsible for building
     * AI_AgentResponse. This formatter is responsible
     * only for generating the natural-language message.
     */
    public static String format(
        AI_AgentRequest request,
        AI_AgentIntent intent,
        AI_AgentToolSelection selectedTool,
        AI_AgentArgumentResult argumentResult,
        AI_ToolResponse toolResponse
    ) {

        /*
         * ------------------------------------------------
         * 1. Argument validation
         * ------------------------------------------------
         */
        if (argumentResult != null &&
            !argumentResult.complete) {

            if (!String.isBlank(argumentResult.message)) {
                return argumentResult.message;
            }

            if (!String.isBlank(argumentResult.missingArgument)) {
                return
                    'I need the following information before I can continue: ' +
                    argumentResult.missingArgument;
            }

            return
                'I need additional information before I can continue.';
        }


        /*
         * ------------------------------------------------
         * 2. No tool response
         * ------------------------------------------------
         */
        if (toolResponse == null) {

            return
                'I could not complete the request because the tool did not return a response.';
        }


        /*
         * ------------------------------------------------
         * 3. Approval required
         * ------------------------------------------------
         */
        if (toolResponse.requiresApproval == true) {

            if (!String.isBlank(toolResponse.message)) {
                return toolResponse.message;
            }

            return
                'Approval is required before this request can be completed.';
        }


        /*
         * ------------------------------------------------
         * 4. Successful tool execution
         * ------------------------------------------------
         */
        if (toolResponse.success == true) {

            if (!String.isBlank(toolResponse.message)) {
                return toolResponse.message;
            }

            return
                'The request was completed successfully.';
        }


        /*
         * ------------------------------------------------
         * 5. Tool execution failure
         * ------------------------------------------------
         */
        if (!String.isBlank(toolResponse.message)) {
            return toolResponse.message;
        }


        /*
         * ------------------------------------------------
         * 6. Safe generic fallback
         * ------------------------------------------------
         */
        return
            'I could not complete the request.';
    }
}