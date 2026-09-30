public with sharing class AI_AgentIntentResolver {

    /*
     * Minimum confidence assigned to a recognized intent.
     *
     * This is a deterministic rule-match score,
     * not an AI/ML probability.
     */
    private static final Decimal DEFAULT_CONFIDENCE = 0.95;

    /*
     * Resolve the user's natural-language message
     * into a structured Agent intent.
     */
    public static AI_AgentIntent resolve(
        AI_AgentRequest request
    ) {

        if (request == null) {
            throw new AI_ServiceException(
                'Agent request is required.'
            );
        }

        if (String.isBlank(request.userMessage)) {
            throw new AI_ServiceException(
                'User message is required.'
            );
        }

        String message = normalize(request.userMessage);


        /*
         * Order status
         *
         * Examples:
         * "What is the status of order ORD-1001?"
         * "Check order ORD-1001"
         * "Where is my order?"
         */
        if (isOrderStatusIntent(message)) {
            return buildIntent(
                'GET_ORDER_STATUS',
                'get_order_status'
            );
        }

        /*
         * Open cases
         *
         * Examples:
         * "Find the open cases for Acme"
         * "Show open tickets for Acme"
         * "What open cases does Acme have?"
         */
        if (isOpenCasesIntent(message)) {
            return buildIntent(
                'GET_OPEN_CASES',
                'get_open_cases'
            );
        }


        /*
         * Case details
         *
         * Examples:
         * "Show case details"
         * "Get details for case 00001001"
         */
        if (isCaseDetailsIntent(message)) {
            return buildIntent(
                'GET_CASE_DETAILS',
                'get_case_details'
            );
        }


        /*
         * Escalate case
         */
        if (isEscalateCaseIntent(message)) {
            return buildIntent(
                'ESCALATE_CASE',
                'escalate_case'
            );
        }


        /*
         * Update case
         */
        if (isUpdateCaseIntent(message)) {
            return buildIntent(
                'UPDATE_CASE',
                'update_case'
            );
        }


        /*
         * Create case
         *
         * Examples:
         * "Create a case for Acme"
         * "Create case for Acme"
         * "Please create a case"
         * "Raise a case for Acme"
         * "Raise case for Acme"
         * "Open a case for Acme"
         * "Log a case for Acme"
         */
        if (isCreateCaseIntent(message)) {
            return buildIntent(
                'CREATE_CASE',
                'create_case'
            );
        }


        /*
         * Create task
         */
        if (isCreateTaskIntent(message)) {
            return buildIntent(
                'CREATE_TASK',
                'create_task'
            );
        }


        /*
         * Knowledge search
         */
        if (isKnowledgeSearchIntent(message)) {
            return buildIntent(
                'SEARCH_KNOWLEDGE',
                'search_knowledge'
            );
        }


        /*
         * Customer details
         */
        if (isCustomerDetailsIntent(message)) {
            return buildIntent(
                'GET_CUSTOMER_DETAILS',
                'get_customer_details'
            );
        }


        /*
         * Customer search
         */
        if (isCustomerSearchIntent(message)) {
            return buildIntent(
                'SEARCH_CUSTOMER',
                'search_customer'
            );
        }


        /*
         * No deterministic rule matched.
         */
        throw new AI_ServiceException(
            'Unable to determine user intent.'
        );
    }


    /*
     * Normalize user input before matching.
     */
    private static String normalize(String message) {

        String normalized = message.toLowerCase();

        normalized = normalized
            .replaceAll('[^a-z0-9\\s-]', ' ');

        normalized = normalized.replaceAll(
            '\\s+',
            ' '
        );

        return normalized.trim();
    }


    /*
     * Build an intent object.
     */
    private static AI_AgentIntent buildIntent(
        String intentName,
        String toolName
    ) {

        return new AI_AgentIntent(
            intentName,
            toolName,
            DEFAULT_CONFIDENCE
        );
    }


    /*
     * GET_ORDER_STATUS
     */
    private static Boolean isOrderStatusIntent(
        String message
    ) {

        return
            message.contains('order') &&
            (
                message.contains('status') ||
                message.contains('track') ||
                message.contains('tracking') ||
                message.contains('where is')
            );
    }


    /*
     * GET_OPEN_CASES
     */
    private static Boolean isOpenCasesIntent(
        String message
    ) {

        return
            (
                message.contains('open case') ||
                message.contains('open cases') ||
                message.contains('open ticket') ||
                message.contains('open tickets')
            );
    }


    /*
     * GET_CASE_DETAILS
     */
    private static Boolean isCaseDetailsIntent(
        String message
    ) {

        return
            (
                message.contains('case detail') ||
                message.contains('case details') ||
                message.contains('details of case') ||
                message.contains('details for case')
            );
    }


    /*
     * ESCALATE_CASE
     */
    private static Boolean isEscalateCaseIntent(
        String message
    ) {

        return
            message.contains('escalate') &&
            message.contains('case');
    }


    /*
     * UPDATE_CASE
     */
    private static Boolean isUpdateCaseIntent(
        String message
    ) {

        return
            (
                message.contains('update case') ||
                message.contains('update a case') ||
                message.contains('change case') ||
                message.contains('change a case') ||
                message.contains('modify case') ||
                message.contains('modify a case')
            );
    }


    /*
     * CREATE_CASE
     *
     * Supports both forms:
     *
     * "create case"
     * "create a case"
     *
     * Also supports common business terminology:
     *
     * "raise a case"
     * "open a case"
     * "log a case"
     */
    private static Boolean isCreateCaseIntent(
        String message
    ) {

        return
            (
                message.contains('create case') ||
                message.contains('create a case') ||
                message.contains('raise case') ||
                message.contains('raise a case') ||
                message.contains('open case') ||
                message.contains('open a case') ||
                message.contains('log case') ||
                message.contains('log a case')
            );
    }


    /*
     * CREATE_TASK
     */
    private static Boolean isCreateTaskIntent(
        String message
    ) {

        return
            (
                message.contains('create task') ||
                message.contains('create a task') ||
                message.contains('add task') ||
                message.contains('add a task')
            );
    }


    /*
     * SEARCH_KNOWLEDGE
     */
    private static Boolean isKnowledgeSearchIntent(
        String message
    ) {

        return
            (
                message.contains('knowledge') ||
                message.contains('knowledge article') ||
                message.contains('knowledge articles') ||
                message.contains('documentation') ||
                message.contains('how do i')
            );
    }


    /*
     * GET_CUSTOMER_DETAILS
     */
    private static Boolean isCustomerDetailsIntent(
        String message
    ) {

        return
            (
                message.contains('customer details') ||
                message.contains('customer information') ||
                message.contains('customer info') ||
                message.contains('details for customer') ||
                message.contains('details of customer')
            );
    }

    /*
     * SEARCH_CUSTOMER
     */
    private static Boolean isCustomerSearchIntent(
        String message
    ) {

        return
            (
                message.contains('find customer') ||
                message.contains('search customer') ||
                message.contains('look up customer') ||
                message.contains('lookup customer') ||
                message.contains('find account') ||
                message.contains('search account')
            );
    }
}