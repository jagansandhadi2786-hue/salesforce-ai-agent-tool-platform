public with sharing class AI_AgentAzureOpenAIService {

    private static final String NAMED_CREDENTIAL =
        'Azure_OpenAI';

    private static final String RESPONSES_PATH =
        '/openai/v1/responses';

    private static final Integer TIMEOUT_MS =
        30000;


    /*
     * Convenience overload.
     *
     * Allows callers and tests to provide the user message
     * directly while preserving the main request-object API.
     */
    public static AI_AgentLLMResponse generate(
        String userMessage
    ) {

        if (String.isBlank(userMessage)) {

            throw new AI_ServiceException(
                'User message is required.'
            );
        }

        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            userMessage;

        return generate(request);
    }


    /*
     * Main Azure OpenAI service entry point.
     */
    public static AI_AgentLLMResponse generate(
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
         * Build approved Salesforce tool definitions.
         */
        List<AI_AgentLLMToolDefinition> tools =
            AI_AgentLLMToolDefinitionBuilder.buildAll();

        /*
         * Build Azure OpenAI Responses API request.
         */
        Map<String, Object> requestBody =
            buildRequest(
                request.userMessage,
                tools
            );

        HttpRequest httpRequest =
            new HttpRequest();

        httpRequest.setMethod('POST');

        httpRequest.setEndpoint(
            'callout:' +
            NAMED_CREDENTIAL +
            RESPONSES_PATH
        );

        httpRequest.setHeader(
            'Content-Type',
            'application/json'
        );

        httpRequest.setTimeout(
            TIMEOUT_MS
        );

        httpRequest.setBody(
            JSON.serialize(requestBody)
        );

        Http http =
            new Http();

        HttpResponse httpResponse;

        try {

            httpResponse =
                http.send(httpRequest);

        } catch (System.CalloutException ex) {

            throw new AI_ServiceException(
                'Unable to connect to Azure OpenAI.'
            );
        }

        return handleResponse(
            httpResponse
        );
    }


    /*
     * Continue an existing Azure OpenAI Responses API
     * conversation after Salesforce has executed tool calls.
     *
     * previous_response_id identifies the previous
     * Azure Responses API response.
     */
    public static AI_AgentLLMResponse continueWithToolOutputs(
        String previousResponseId,
        List<AI_AgentLLMToolOutput> toolOutputs
    ) {

        if (String.isBlank(previousResponseId)) {

            throw new AI_ServiceException(
                'Previous Azure response ID is required.'
            );
        }

        if (
            toolOutputs == null ||
            toolOutputs.isEmpty()
        ) {

            throw new AI_ServiceException(
                'Tool output is required.'
            );
        }

        /*
         * Build continuation request.
         */
        Map<String, Object> requestBody =
            new Map<String, Object>();

        requestBody.put(
            'model',
            getModelDeployment()
        );

        requestBody.put(
            'previous_response_id',
            previousResponseId
        );

        requestBody.put(
            'input',
            buildToolOutputInput(
                toolOutputs
            )
        );

        /*
         * Execute tool calls sequentially.
         */
        requestBody.put(
            'parallel_tool_calls',
            false
        );

        HttpRequest httpRequest =
            new HttpRequest();

        httpRequest.setMethod('POST');

        httpRequest.setEndpoint(
            'callout:' +
            NAMED_CREDENTIAL +
            RESPONSES_PATH
        );

        httpRequest.setHeader(
            'Content-Type',
            'application/json'
        );

        httpRequest.setTimeout(
            TIMEOUT_MS
        );

        httpRequest.setBody(
            JSON.serialize(requestBody)
        );

        Http http =
            new Http();

        HttpResponse httpResponse;

        try {

            httpResponse =
                http.send(httpRequest);

        } catch (System.CalloutException ex) {

            throw new AI_ServiceException(
                'Unable to connect to Azure OpenAI.'
            );
        }

        return handleResponse(
            httpResponse
        );
    }


    /*
     * Build Azure OpenAI function_call_output items.
     *
     * Example:
     *
     * {
     *     "type": "function_call_output",
     *     "call_id": "call_123",
     *     "output": "{\"success\":true}"
     * }
     */
    private static List<Object> buildToolOutputInput(
        List<AI_AgentLLMToolOutput> toolOutputs
    ) {

        if (
            toolOutputs == null ||
            toolOutputs.isEmpty()
        ) {

            throw new AI_ServiceException(
                'Tool output is required.'
            );
        }

        List<Object> input =
            new List<Object>();

        for (
            AI_AgentLLMToolOutput toolOutput :
            toolOutputs
        ) {

            if (toolOutput == null) {

                throw new AI_ServiceException(
                    'Tool output cannot be null.'
                );
            }

            if (String.isBlank(toolOutput.callId)) {

                throw new AI_ServiceException(
                    'Tool call ID is required.'
                );
            }

            if (toolOutput.output == null) {

                throw new AI_ServiceException(
                    'Tool output value is required.'
                );
            }

            Map<String, Object> item =
                new Map<String, Object>();

            item.put(
                'type',
                'function_call_output'
            );

            item.put(
                'call_id',
                toolOutput.callId
            );

            item.put(
                'output',
                toolOutput.output
            );

            input.add(item);
        }

        return input;
    }


    /*
     * Build the Azure OpenAI initial request body.
     */
    private static Map<String, Object> buildRequest(
        String userMessage,
        List<AI_AgentLLMToolDefinition> tools
    ) {

        Map<String, Object> requestBody =
            new Map<String, Object>();

        requestBody.put(
            'model',
            getModelDeployment()
        );

        requestBody.put(
            'input',
            buildInput(userMessage)
        );

        requestBody.put(
            'tools',
            tools
        );

        requestBody.put(
            'parallel_tool_calls',
            false
        );

        return requestBody;
    }


    /*
     * Build Responses API input messages.
     */
    private static List<Object> buildInput(
        String userMessage
    ) {

        List<Object> input =
            new List<Object>();

        input.add(
            new Map<String, Object>{
                'role' => 'system',
                'content' =>
                    buildSystemInstructions()
            }
        );

        input.add(
            new Map<String, Object>{
                'role' => 'user',
                'content' =>
                    userMessage
            }
        );

        return input;
    }


    /*
     * System-level agent instructions.
     */
    private static String buildSystemInstructions() {

        return
            'You are an enterprise Salesforce customer service assistant. ' +
            'Interpret the user request and use only the supplied approved Salesforce tools. ' +
            'Never invent a tool or argument. ' +
            'Never execute Salesforce operations directly. ' +
            'Do not fabricate Salesforce IDs or Salesforce data. ' +
            'Follow the tool schema exactly.';
    }


    /*
     * Model deployment configuration.
     *
     * Replace with Custom Metadata / configuration
     * before production deployment.
     */
    private static String getModelDeployment() {

        return 'YOUR_MODEL_DEPLOYMENT_NAME';
    }


    /*
     * Process Azure OpenAI response.
     */
    private static AI_AgentLLMResponse handleResponse(
        HttpResponse response
    ) {

        if (response == null) {

            throw new AI_ServiceException(
                'Azure OpenAI returned no response.'
            );
        }

        Integer statusCode =
            response.getStatusCode();

        if (
            statusCode < 200 ||
            statusCode >= 300
        ) {

            throw new AI_ServiceException(
                'Azure OpenAI request failed.'
            );
        }

        String body =
            response.getBody();

        if (String.isBlank(body)) {

            throw new AI_ServiceException(
                'Azure OpenAI returned an empty response.'
            );
        }

        try {

            return AI_AgentAzureOpenAIResponseParser.parse(
                body
            );

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Azure OpenAI returned an invalid response.'
            );
        }
    }
}