public with sharing class AI_AgentResponseFormatter {

    public static String format(
        AI_AgentRequest request,
        AI_AgentIntent intent,
        AI_AgentToolSelection selectedTool,
        AI_AgentArgumentResult argumentResult,
        AI_ToolResponse toolResponse
    ) {

        /*
         * ------------------------------------------------
         * Missing arguments
         * ------------------------------------------------
         */
        if (
            argumentResult != null &&
            !argumentResult.complete
        ) {

            if (
                !String.isBlank(
                    argumentResult.message
                )
            ) {
                return argumentResult.message;
            }

            if (
                !String.isBlank(
                    argumentResult.missingArgument
                )
            ) {
                return
                    'I need the following information before I can continue: ' +
                    argumentResult.missingArgument;
            }

            return
                'I need additional information before I can continue.';
        }

        /*
         * ------------------------------------------------
         * Null tool response
         * ------------------------------------------------
         */
        if (toolResponse == null) {

            return
                'I could not complete the request because the tool did not return a response.';
        }

        /*
         * ------------------------------------------------
         * Approval required
         * ------------------------------------------------
         */
        if (
            toolResponse.requiresApproval == true
        ) {

            if (
                !String.isBlank(
                    toolResponse.message
                )
            ) {
                return toolResponse.message;
            }

            return
                'Approval is required before this request can be completed.';
        }

        /*
         * ------------------------------------------------
         * Successful tool execution
         * ------------------------------------------------
         */
        if (
            toolResponse.success == true
        ) {

            /*
             * Special handling for customer search.
             *
             * An empty customer list is not an error.
             * The search completed successfully but
             * there were no matching customers.
             */
            if (
                selectedTool != null &&
                selectedTool.toolName == 'search_customer'
            ) {

                if (
                    toolResponse.data == null
                ) {
                    return
                        'I could not find a customer matching your search.';
                }

                if (
                    toolResponse.data instanceof List<Object>
                ) {

                    List<Object> customerResults =
                        (List<Object>) toolResponse.data;

                    if (customerResults.isEmpty()) {

                        String customerName;

                        if (
                            argumentResult != null &&
                            argumentResult.arguments != null
                        ) {

                            Object value =
                                argumentResult.arguments.get(
                                    'customer_name'
                                );

                            if (value != null) {
                                customerName =
                                    String.valueOf(value);
                            }
                        }

                        if (
                            !String.isBlank(customerName)
                        ) {
                            return
                                'I could not find a customer matching "' +
                                customerName +
                                '".';
                        }

                        return
                            'I could not find any matching customers.';
                    }
                }
            }

            /*
             * Use the tool's explicit success message
             * when available.
             */
            if (
                !String.isBlank(
                    toolResponse.message
                )
            ) {
                return toolResponse.message;
            }

            return
                'The request was completed successfully.';
        }

        /*
         * ------------------------------------------------
         * Tool failure
         * ------------------------------------------------
         */
        if (
            !String.isBlank(
                toolResponse.message
            )
        ) {
            return toolResponse.message;
        }

        return
            'I could not complete the request.';
    }
}