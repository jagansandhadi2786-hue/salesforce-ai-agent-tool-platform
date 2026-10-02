public with sharing class AI_AgentAzureOpenAIResponseParser {

    public static AI_AgentLLMResponse parse(
        String responseBody
    ) {

        if (String.isBlank(responseBody)) {
            throw new AI_ServiceException(
                'Azure OpenAI response is empty.'
            );
        }

        Object rawResponse;

        try {

            rawResponse =
                JSON.deserializeUntyped(
                    responseBody
                );

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Azure OpenAI response format is invalid.'
            );
        }

        if (!(rawResponse instanceof Map<String, Object>)) {

            throw new AI_ServiceException(
                'Azure OpenAI response format is invalid.'
            );
        }

        Map<String, Object> response =
            (Map<String, Object>) rawResponse;

        AI_AgentLLMResponse result =
            new AI_AgentLLMResponse();

        result.success = true;

        /*
         * Response ID
         */
        if (response.containsKey('id')) {

            result.responseId =
                String.valueOf(
                    response.get('id')
                );
        }


        /*
         * Native Responses API output.
         *
         * Expected structure:
         *
         * output[]
         *   └── function_call
         *        ├── call_id
         *        ├── name
         *        └── arguments
         */
        Object outputValue =
            response.get('output');

        if (outputValue != null) {

            if (!(outputValue instanceof List<Object>)) {

                throw new AI_ServiceException(
                    'Azure OpenAI output format is invalid.'
                );
            }

            List<Object> output =
                (List<Object>) outputValue;

            for (Object itemValue : output) {

                if (
                    !(itemValue instanceof
                        Map<String, Object>)
                ) {
                    continue;
                }

                Map<String, Object> item =
                    (Map<String, Object>)
                        itemValue;

                String type =
                    item.containsKey('type')
                        ? String.valueOf(
                            item.get('type')
                        )
                        : null;

                /*
                 * Native function call
                 */
                if (type == 'function_call') {

                    AI_AgentLLMToolCall toolCall =
                        parseFunctionCall(
                            item
                        );

                    result.toolCalls.add(
                        toolCall
                    );

                    result.requiresToolCall =
                        true;

                    /*
                     * Maintain compatibility with
                     * the existing AI_AgentLLMResponse
                     * contract.
                     *
                     * Example:
                     * search_customer
                     *       ↓
                     * SEARCH_CUSTOMER
                     */
                    if (String.isBlank(result.toolName)) {

                        result.toolName =
                            toolCall.toolName;
                    }

                    if (result.arguments.isEmpty()) {

                        result.arguments =
                            toolCall.arguments;
                    }

                    if (String.isBlank(result.intent)) {

                        result.intent =
                            deriveIntent(
                                toolCall.toolName
                            );
                    }
                }

                /*
                 * Normal assistant message
                 */
                if (type == 'message') {

                    parseMessage(
                        item,
                        result
                    );
                }
            }

            /*
             * Native output was present.
             */
            if (
                result.requiresToolCall == true ||
                !String.isBlank(
                    result.assistantMessage
                )
            ) {
                return result;
            }
        }


        /*
         * Backward-compatible structured output.
         *
         * Existing tests and any older provider
         * response may return:
         *
         * {
         *   "output_text":
         *   "{\"intent\":\"GET_OPEN_CASES\",...}"
         * }
         */
        if (response.containsKey('output_text')) {

            parseStructuredOutputText(
                response.get('output_text'),
                result
            );

            return result;
        }


        /*
         * No usable response.
         */
        throw new AI_ServiceException(
            'Azure OpenAI returned no usable response.'
        );
    }


    /*
     * Parse native function_call.
     */
    private static AI_AgentLLMToolCall parseFunctionCall(
        Map<String, Object> item
    ) {

        AI_AgentLLMToolCall toolCall =
            new AI_AgentLLMToolCall();


        /*
         * call_id
         */
        if (item.containsKey('call_id')) {

            toolCall.callId =
                String.valueOf(
                    item.get('call_id')
                );
        }

        /*
         * function/tool name
         */
        if (item.containsKey('name')) {

            toolCall.toolName =
                String.valueOf(
                    item.get('name')
                );
        }


        if (String.isBlank(toolCall.callId)) {

            throw new AI_ServiceException(
                'Azure function call is missing call_id.'
            );
        }


        if (String.isBlank(toolCall.toolName)) {

            throw new AI_ServiceException(
                'Azure function call is missing tool name.'
            );
        }


        /*
         * Function arguments are returned as
         * a JSON string.
         */
        Object argumentsValue =
            item.get('arguments');


        if (argumentsValue == null) {

            toolCall.arguments =
                new Map<String, Object>();

            return toolCall;
        }


        String argumentsJson =
            String.valueOf(
                argumentsValue
            );


        try {

            Object parsedArguments =
                JSON.deserializeUntyped(
                    argumentsJson
                );


            if (
                !(parsedArguments instanceof
                    Map<String, Object>)
            ) {

                throw new AI_ServiceException(
                    'Function arguments must be a JSON object.'
                );
            }


            toolCall.arguments =
                (Map<String, Object>)
                    parsedArguments;


        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Azure function arguments are invalid.'
            );
        }


        return toolCall;
    }


    /*
     * Parse legacy structured output_text.
     */
    private static void parseStructuredOutputText(
        Object outputTextValue,
        AI_AgentLLMResponse result
    ) {

        if (outputTextValue == null) {

            throw new AI_ServiceException(
                'Azure OpenAI returned no structured output.'
            );
        }


        String outputText =
            String.valueOf(
                outputTextValue
            );


        if (String.isBlank(outputText)) {

            throw new AI_ServiceException(
                'Azure OpenAI returned no structured output.'
            );
        }


        /*
         * The expected output_text is a JSON string
         * containing the Agent response.
         */
        try {

            Object parsedValue =
                JSON.deserializeUntyped(
                    outputText
                );


            if (
                !(parsedValue instanceof
                    Map<String, Object>)
            ) {

                /*
                 * If it is plain text rather than
                 * structured JSON, treat it as an
                 * assistant response.
                 */
                result.assistantMessage =
                    outputText;

                result.requiresToolCall =
                    false;

                return;
            }


            Map<String, Object> parsed =
                (Map<String, Object>)
                    parsedValue;


            /*
             * intent
             */
            if (parsed.containsKey('intent')) {

                result.intent =
                    parsed.get('intent') == null
                        ? null
                        : String.valueOf(
                            parsed.get('intent')
                        );
            }


            /*
             * toolName
             */
            if (parsed.containsKey('toolName')) {

                result.toolName =
                    parsed.get('toolName') == null
                        ? null
                        : String.valueOf(
                            parsed.get('toolName')
                        );
            }


            /*
             * arguments
             */
            if (parsed.containsKey('arguments')) {

                Object argumentsValue =
                    parsed.get('arguments');


                if (
                    argumentsValue instanceof
                        Map<String, Object>
                ) {

                    result.arguments =
                        (Map<String, Object>)
                            argumentsValue;

                } else if (argumentsValue == null) {

                    result.arguments =
                        new Map<String, Object>();

                } else {

                    throw new AI_ServiceException(
                        'Structured arguments must be a JSON object.'
                    );
                }

            } else {

                result.arguments =
                    new Map<String, Object>();
            }


            /*
             * assistantMessage
             */
            if (
                parsed.containsKey(
                    'assistantMessage'
                )
            ) {

                result.assistantMessage =
                    parsed.get(
                        'assistantMessage'
                    ) == null
                        ? null
                        : String.valueOf(
                            parsed.get(
                                'assistantMessage'
                            )
                        );
            }


            /*
             * confidence
             */
            if (
                parsed.containsKey(
                    'confidence'
                )
            ) {

                Object confidenceValue =
                    parsed.get(
                        'confidence'
                    );


                if (confidenceValue != null) {

                    result.confidence =
                        Decimal.valueOf(
                            String.valueOf(
                                confidenceValue
                            )
                        );
                }
            }


            /*
             * This is structured assistant output,
             * not a native function call.
             */
            result.requiresToolCall =
                false;


        } catch (AI_ServiceException ex) {

            throw ex;

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Azure OpenAI returned invalid structured output.'
            );
        }
    }


    /*
     * Convert a native function/tool name into
     * the application's intent representation.
     */
    private static String deriveIntent(
        String toolName
    ) {

        if (String.isBlank(toolName)) {
            return null;
        }

        if (toolName == 'search_customer') {
            return 'SEARCH_CUSTOMER';
        }

        if (toolName == 'get_customer_details') {
            return 'GET_CUSTOMER_DETAILS';
        }

        if (toolName == 'get_open_cases') {
            return 'GET_OPEN_CASES';
        }

        if (toolName == 'get_case_details') {
            return 'GET_CASE_DETAILS';
        }

        if (toolName == 'create_case') {
            return 'CREATE_CASE';
        }

        if (toolName == 'update_case') {
            return 'UPDATE_CASE';
        }

        if (toolName == 'create_task') {
            return 'CREATE_TASK';
        }

        if (toolName == 'escalate_case') {
            return 'ESCALATE_CASE';
        }

        if (toolName == 'search_knowledge') {
            return 'SEARCH_KNOWLEDGE';
        }

        if (toolName == 'get_order_status') {
            return 'GET_ORDER_STATUS';
        }

        return null;
    }


    /*
     * Parse a normal assistant message.
     */
    private static void parseMessage(
        Map<String, Object> item,
        AI_AgentLLMResponse result
    ) {

        Object contentValue =
            item.get('content');


        if (
            !(contentValue instanceof
                List<Object>)
        ) {
            return;
        }


        List<Object> content =
            (List<Object>)
                contentValue;


        List<String> textParts =
            new List<String>();


        for (
            Object contentItemValue :
            content
        ) {

            if (
                !(contentItemValue instanceof
                    Map<String, Object>)
            ) {
                continue;
            }


            Map<String, Object> contentItem =
                (Map<String, Object>)
                    contentItemValue;


            String contentType =
                contentItem.containsKey('type')
                    ? String.valueOf(
                        contentItem.get('type')
                    )
                    : null;


            if (
                contentType == 'output_text' &&
                contentItem.containsKey('text')
            ) {

                textParts.add(
                    String.valueOf(
                        contentItem.get('text')
                    )
                );
            }
        }


        if (!textParts.isEmpty()) {

            result.assistantMessage =
                String.join(
                    textParts,
                    ' '
                );
        }
    }
}