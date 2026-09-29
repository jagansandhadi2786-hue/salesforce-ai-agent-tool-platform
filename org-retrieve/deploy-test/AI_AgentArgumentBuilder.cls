public with sharing class AI_AgentArgumentBuilder {

    /*
     * Build tool arguments from:
     *
     * 1. Agent request
     * 2. Detected intent
     * 3. Validated tool selection
     */
    public static AI_AgentArgumentResult build(
        AI_AgentRequest request,
        AI_AgentIntent intent,
        AI_AgentToolSelection selection
    ) {

        /*
         * ------------------------------------------------
         * Validate inputs
         * ------------------------------------------------
         */

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

        if (intent == null) {
            throw new AI_ServiceException(
                'Agent intent is required.'
            );
        }

        if (selection == null) {
            throw new AI_ServiceException(
                'Tool selection is required.'
            );
        }

        if (!selection.isValid()) {
            throw new AI_ServiceException(
                'Tool selection is invalid.'
            );
        }


        /*
         * Normalize user message.
         */
        String message =
            normalize(request.userMessage);


        /*
         * ------------------------------------------------
         * SEARCH_CUSTOMER
         *
         * Example:
         *
         * "Find customer Acme"
         *
         * =>
         *
         * customer_name = Acme
         * ------------------------------------------------
         */
        if (intent.intentName == 'SEARCH_CUSTOMER') {

    String customerName =
        extractCustomerName(
            request.userMessage
        );

    if (String.isBlank(customerName)) {

        return AI_AgentArgumentResult.missingArgumentResult(
            new Map<String, Object>(),
            'customer_name',
            null,
            'Customer name is required.'
        );
    }

    Map<String, Object> arguments =
        new Map<String, Object>();

    arguments.put(
        'customer_name',
        customerName
    );

    return AI_AgentArgumentResult.completeResult(arguments);
}


        /*
         * ------------------------------------------------
         * GET_CUSTOMER_DETAILS
         *
         * Tool requires customer_id.
         * ------------------------------------------------
         */
        if (intent.intentName == 'GET_CUSTOMER_DETAILS') {

            String customerId =
                extractSalesforceId(
                    request.userMessage
                );

            if (!String.isBlank(customerId)) {

                Map<String, Object> arguments =
                    new Map<String, Object>();

                arguments.put(
                    'customer_id',
                    customerId
                );

                return AI_AgentArgumentResult.completeResult(arguments);
            }

            return AI_AgentArgumentResult.missingArgumentResult(
                        new Map<String, Object>(),
                        'customer_id',
                        'search_customer',
                        'A Salesforce customer ID is required. ' +
                        'The customer name must be resolved first.'
                    );
        }


        /*
         * ------------------------------------------------
         * GET_OPEN_CASES
         *
         * Requires:
         *
         * account_id
         *
         * If only customer name exists, request:
         *
         * search_customer
         * ------------------------------------------------
         */
        if (intent.intentName == 'GET_OPEN_CASES') {

            String accountId =
                extractSalesforceId(
                    request.userMessage
                );

            if (!String.isBlank(accountId)) {

                Map<String, Object> arguments =
                    new Map<String, Object>();

                arguments.put(
                    'account_id',
                    accountId
                );

                return AI_AgentArgumentResult.completeResult(arguments);
            }


            String customerName =
                extractCustomerName(
                    request.userMessage
                );


            if (!String.isBlank(customerName)) {

                Map<String, Object> arguments =
                    new Map<String, Object>();

                arguments.put(
                    'customer_name',
                    customerName
                );

                return AI_AgentArgumentResult.missingArgumentResult(
                            arguments,
                            'account_id',
                            'search_customer',
                            'Account ID must be resolved ' +
                            'from customer name before ' +
                            'get_open_cases can execute.'
                        );
            }


            return AI_AgentArgumentResult.missingArgumentResult(
                        new Map<String, Object>(),
                        'account_id',
                        'search_customer',
                        'Customer or Account information ' +
                        'is required.'
                    );
        }


        /*
         * ------------------------------------------------
         * GET_CASE_DETAILS
         * ------------------------------------------------
         */
        if (intent.intentName == 'GET_CASE_DETAILS') {

            String caseId =
                extractSalesforceId(
                    request.userMessage
                );

            if (!String.isBlank(caseId)) {

                Map<String, Object> arguments =
                    new Map<String, Object>();

                arguments.put(
                    'case_id',
                    caseId
                );

                return AI_AgentArgumentResult.completeResult(arguments);
            }

            return AI_AgentArgumentResult.missingArgumentResult(
                        new Map<String, Object>(),
                        'case_id',
                        null,
                        'A Salesforce Case ID is required.'
                    );
        }


        /*
         * ------------------------------------------------
         * ESCALATE_CASE
         * ------------------------------------------------
         */
        if (intent.intentName == 'ESCALATE_CASE') {

            String caseId =
                extractSalesforceId(
                    request.userMessage
                );

            if (!String.isBlank(caseId)) {

                Map<String, Object> arguments =
                    new Map<String, Object>();

                arguments.put(
                    'case_id',
                    caseId
                );

                return AI_AgentArgumentResult.completeResult(arguments);
            }

            return AI_AgentArgumentResult.missingArgumentResult(
                        new Map<String, Object>(),
                        'case_id',
                        null,
                        'A Salesforce Case ID is required.'
                    );
        }


        /*
         * ------------------------------------------------
         * UPDATE_CASE
         * ------------------------------------------------
         */
        if (intent.intentName == 'UPDATE_CASE') {

            String caseId =
                extractSalesforceId(
                    request.userMessage
                );

            if (String.isBlank(caseId)) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            new Map<String, Object>(),
                            'case_id',
                            null,
                            'A Salesforce Case ID is required.'
                        );
            }


            Map<String, Object> arguments =
                new Map<String, Object>();

            arguments.put(
                'case_id',
                caseId
            );


            String priority =
                extractPriority(message);

            if (!String.isBlank(priority)) {

                arguments.put(
                    'priority',
                    priority
                );
            }


            String status =
                extractStatus(message);

            if (!String.isBlank(status)) {

                arguments.put(
                    'status',
                    status
                );
            }


            return AI_AgentArgumentResult.completeResult(arguments);
        }


        /*
         * ------------------------------------------------
         * CREATE_CASE
         * ------------------------------------------------
         */
        if (intent.intentName == 'CREATE_CASE') {

            Map<String, Object> arguments =
                new Map<String, Object>();


            String accountId =
                extractSalesforceId(
                    request.userMessage
                );

            if (!String.isBlank(accountId)) {

                arguments.put(
                    'account_id',
                    accountId
                );
            }


            String priority =
                extractPriority(message);

            if (!String.isBlank(priority)) {

                arguments.put(
                    'priority',
                    priority
                );
            }


            String subject =
                extractSubject(
                    request.userMessage
                );

            if (!String.isBlank(subject)) {

                arguments.put(
                    'subject',
                    subject
                );
            }


            String description =
                extractDescription(
                    request.userMessage
                );

            if (!String.isBlank(description)) {

                arguments.put(
                    'description',
                    description
                );
            }


            /*
             * Required:
             *
             * account_id
             * subject
             * description
             */
            if (!arguments.containsKey('account_id')) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            arguments,
                            'account_id',
                            'search_customer',
                            'Account ID is required ' +
                            'to create a case.'
                        );
            }


            if (!arguments.containsKey('subject')) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            arguments,
                            'subject',
                            null,
                            'Case subject is required.'
                        );
            }


            if (!arguments.containsKey('description')) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            arguments,
                            'description',
                            null,
                            'Case description is required.'
                        );
            }


            return AI_AgentArgumentResult.completeResult(arguments);
        }


        /*
         * ------------------------------------------------
         * CREATE_TASK
         * ------------------------------------------------
         */
        if (intent.intentName == 'CREATE_TASK') {

            Map<String, Object> arguments =
                new Map<String, Object>();


            String whatId =
                extractSalesforceId(
                    request.userMessage
                );

            if (!String.isBlank(whatId)) {

                arguments.put(
                    'what_id',
                    whatId
                );
            }


            String subject =
                extractTaskSubject(
                    request.userMessage
                );

            if (!String.isBlank(subject)) {

                arguments.put(
                    'subject',
                    subject
                );
            }


            if (!arguments.containsKey('what_id')) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            arguments,
                            'what_id',
                            null,
                            'A Salesforce record ID ' +
                            'is required for the task.'
                        );
            }


            if (!arguments.containsKey('subject')) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            arguments,
                            'subject',
                            null,
                            'Task subject is required.'
                        );
            }


            return AI_AgentArgumentResult.completeResult(arguments);
        }


        /*
         * ------------------------------------------------
         * SEARCH_KNOWLEDGE
         * ------------------------------------------------
         */
        if (intent.intentName == 'SEARCH_KNOWLEDGE') {

            String searchTerm =
                extractKnowledgeSearchTerm(
                    request.userMessage
                );

            if (String.isBlank(searchTerm)) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            new Map<String, Object>(),
                            'search_term',
                            null,
                            'Knowledge search term is required.'
                        );
            }


            Map<String, Object> arguments =
                new Map<String, Object>();

            arguments.put(
                'search_term',
                searchTerm
            );


            return AI_AgentArgumentResult.completeResult(arguments);
        }


        /*
         * ------------------------------------------------
         * GET_ORDER_STATUS
         * ------------------------------------------------
         */
        if (intent.intentName == 'GET_ORDER_STATUS') {

            String orderNumber =
                extractOrderNumber(
                    request.userMessage
                );

            if (String.isBlank(orderNumber)) {

                return AI_AgentArgumentResult.missingArgumentResult(
                            new Map<String, Object>(),
                            'order_number',
                            null,
                            'Order number is required.'
                        );
            }


            Map<String, Object> arguments =
                new Map<String, Object>();

            arguments.put(
                'order_number',
                orderNumber
            );


            return AI_AgentArgumentResult.completeResult(arguments);
        }


        /*
         * ------------------------------------------------
         * Unsupported intent
         * ------------------------------------------------
         */
        throw new AI_ServiceException(
            'No argument builder exists for intent: ' +
            intent.intentName
        );
    }


    /*
     * ----------------------------------------------------
     * CUSTOMER NAME
     * ----------------------------------------------------
     *
     * Supported examples:
     *
     * customer Acme
     * account Acme
     * for Acme
     *
     * The extraction intentionally remains conservative.
     */
    private static String extractCustomerName(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        /*
         * IMPORTANT:
         *
         * Do not name the local variable "pattern".
         *
         * Apex is case-insensitive and "pattern"
         * conflicts with the System.Pattern class.
         */
       Pattern customerNamePattern =
        Pattern.compile(
        '(?i)(?:customer|account)\\s+(?:for\\s+|named\\s+)?([A-Za-z0-9&._-]+)'
         );
        Matcher customerNameMatcher =
            customerNamePattern.matcher(message);

        if (customerNameMatcher.find()) {

            return
                customerNameMatcher
                    .group(1)
                    .trim();
        }


        Pattern forCustomerPattern =
            Pattern.compile(
                '(?i)\\bfor\\s+([A-Za-z0-9&._-]+)'
            );

        Matcher forCustomerMatcher =
            forCustomerPattern
                .matcher(message);

        if (forCustomerMatcher.find()) {

            return
                forCustomerMatcher
                    .group(1)
                    .trim();
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * SALESFORCE ID
     * ----------------------------------------------------
     *
     * Salesforce IDs can be 15 or 18 characters.
     */
    private static String extractSalesforceId(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        Pattern salesforceIdPattern =
            Pattern.compile(
                '\\b[0-9A-Za-z]{15}(?:[0-9A-Za-z]{3})?\\b'
            );

        Matcher salesforceIdMatcher =
            salesforceIdPattern.matcher(message);

        if (salesforceIdMatcher.find()) {

            return
                salesforceIdMatcher
                    .group(0);
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * PRIORITY
     * ----------------------------------------------------
     */
    private static String extractPriority(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        String normalized =
            normalize(message);


        if (normalized.contains('high priority')) {
            return 'High';
        }


        if (normalized.contains('medium priority')) {
            return 'Medium';
        }


        if (normalized.contains('low priority')) {
            return 'Low';
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * STATUS
     * ----------------------------------------------------
     */
    private static String extractStatus(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        String normalized =
            normalize(message);


        if (normalized.contains('status working') ||
            normalized.contains('set status to working')) {

            return 'Working';
        }


        if (normalized.contains('status closed') ||
            normalized.contains('set status to closed')) {

            return 'Closed';
        }


        if (normalized.contains('status new') ||
            normalized.contains('set status to new')) {

            return 'New';
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * CASE SUBJECT
     * ----------------------------------------------------
     */
    private static String extractSubject(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        Pattern subjectPattern =
        Pattern.compile(
        '(?i)subject\\s*[:=-]\\s*(.*?)(?=\\s+description\\s*[:=-]|\\s+priority\\s*[:=-]|$)'
       );

        Matcher subjectMatcher =
            subjectPattern.matcher(message);

        if (subjectMatcher.find()) {

            String subject =
                subjectMatcher
                    .group(1)
                    .trim();

            return
                removeTrailingPriority(subject);
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * CASE DESCRIPTION
     * ----------------------------------------------------
     */
    private static String extractDescription(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        Pattern descriptionPattern =
        Pattern.compile(
        '(?i)description\\s*[:=-]\\s*(.*?)(?=\\s+(?:high|medium|low)\\s+priority\\b|\\s+priority\\s*[:=-]|$)'
        );

        Matcher descriptionMatcher =
            descriptionPattern.matcher(message);

        if (descriptionMatcher.find()) {

            return
                descriptionMatcher
                    .group(1)
                    .trim();
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * TASK SUBJECT
     * ----------------------------------------------------
     */
    private static String extractTaskSubject(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        Pattern taskSubjectPattern =
            Pattern.compile(
                '(?i)(?:task|subject)\\s*[:=-]\\s*(.+)'
            );

        Matcher taskSubjectMatcher =
            taskSubjectPattern.matcher(message);

        if (taskSubjectMatcher.find()) {

            return
                taskSubjectMatcher
                    .group(1)
                    .trim();
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * KNOWLEDGE SEARCH TERM
     * ----------------------------------------------------
     */
    private static String extractKnowledgeSearchTerm(
        String message
    ) {

        if (String.isBlank(message)) {
            return null;
        }


        Pattern knowledgeSearchPattern =
            Pattern.compile(
                '(?i)(?:knowledge|documentation)\\s+(?:for|about|on)\\s+(.+)'
            );

        Matcher knowledgeSearchMatcher =
            knowledgeSearchPattern.matcher(message);

        if (knowledgeSearchMatcher.find()) {

            return
                knowledgeSearchMatcher
                    .group(1)
                    .trim();
        }


        Pattern howDoIPattern =
            Pattern.compile(
                '(?i)how\\s+do\\s+i\\s+(.+)'
            );

        Matcher howDoIMatcher =
            howDoIPattern.matcher(message);

        if (howDoIMatcher.find()) {

            return
                howDoIMatcher
                    .group(1)
                    .trim();
        }


        return null;
    }


    /*
     * ----------------------------------------------------
     * ORDER NUMBER
     * ----------------------------------------------------
     */
    private static String extractOrderNumber(
    String message
) {

    if (String.isBlank(message)) {
        return null;
    }

    List<String> tokens = message.split('\\s+');

    for (String token : tokens) {

        String cleanedToken =
            token.replaceAll(
                '[^A-Za-z0-9_-]',
                ''
            );

        if (
            cleanedToken.toUpperCase().startsWith('ORD-') ||
            cleanedToken.toUpperCase().startsWith('ORD_') ||
            cleanedToken.toUpperCase().startsWith('ORD')
        ) {

            if (cleanedToken.length() > 3) {
                return cleanedToken;
            }
        }
    }

    return null;
}
    /*
     * ----------------------------------------------------
     * REMOVE TRAILING PRIORITY
     * ----------------------------------------------------
     */
    private static String removeTrailingPriority(
        String value
    ) {

        if (String.isBlank(value)) {
            return value;
        }


        return value
            .replaceAll(
                '(?i)\\s+(?:high|medium|low)\\s+priority\\s*$',
                ''
            )
            .trim();
    }


    /*
     * ----------------------------------------------------
     * NORMALIZE
     * ----------------------------------------------------
     */
    private static String normalize(
        String message
    ) {

        if (String.isBlank(message)) {
            return '';
        }


        String normalized =
            message.toLowerCase();


        normalized =
            normalized.replaceAll(
                '[^a-z0-9\\s-]',
                ' '
            );


        normalized =
            normalized.replaceAll(
                '\\s+',
                ' '
            );


        return normalized.trim();
    }
}