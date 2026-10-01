public with sharing class AI_AgentLLMService {

    public static AI_AgentLLMResponse interpret(
        AI_AgentLLMRequest request
    ) {

        if (request == null) {

            throw new AI_ServiceException(
                'LLM request is required.'
            );
        }


        if (!request.isValid()) {

            throw new AI_ServiceException(
                'User message is required.'
            );
        }


        /*
         * STEP 12 INITIAL IMPLEMENTATION
         *
         * The external LLM provider will be connected
         * through a dedicated provider implementation.
         *
         * Until then, return a deterministic response
         * so the Agent architecture remains testable.
         */

        return deterministicFallback(
            request
        );
    }


    private static AI_AgentLLMResponse deterministicFallback(
        AI_AgentLLMRequest request
    ) {

        AI_AgentLLMResponse response =
            new AI_AgentLLMResponse();


        String message =
            request.userMessage.toLowerCase();


        if (
            message.contains('open cases') ||
            message.contains('open tickets') ||
            message.contains('unresolved cases')
        ) {

            response.success = true;

            response.intent =
                'GET_OPEN_CASES';

            response.toolName =
                'get_open_cases';

            response.confidence =
                0.90;

            response.assistantMessage =
                'I will look up the open cases.';
        }


        else if (
            message.contains('customer details') ||
            message.contains('customer information')
        ) {

            response.success = true;

            response.intent =
                'GET_CUSTOMER_DETAILS';

            response.toolName =
                'get_customer_details';

            response.confidence =
                0.90;

            response.assistantMessage =
                'I will retrieve the customer details.';
        }


        else if (
            message.contains('order status') ||
            message.contains('status of order')
        ) {

            response.success = true;

            response.intent =
                'GET_ORDER_STATUS';

            response.toolName =
                'get_order_status';

            response.confidence =
                0.90;

            response.assistantMessage =
                'I will check the order status.';
        }


        else {

            response.success = false;

            response.errorMessage =
                'The request could not be interpreted.';
        }


        return response;
    }
}
