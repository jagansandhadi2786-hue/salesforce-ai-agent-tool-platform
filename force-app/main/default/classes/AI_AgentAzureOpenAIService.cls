public with sharing class AI_AgentAzureOpenAIService {

    private static final String NAMED_CREDENTIAL =
        'callout:Azure_OpenAI';

    private static final String RESPONSES_PATH =
        '/openai/v1/responses';

    private static final Integer TIMEOUT_MS =
        30000;


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


        HttpRequest httpRequest =
            buildRequest(request);


        Http http =
            new Http();

        HttpResponse httpResponse;


        try {

            httpResponse =
                http.send(httpRequest);

        } catch (CalloutException ex) {

            throw new AI_ServiceException(
                'Azure OpenAI callout failed.'
            );
        }


        return processResponse(
            httpResponse
        );
    }


    private static HttpRequest buildRequest(
        AI_AgentLLMRequest request
    ) {

        HttpRequest httpRequest =
            new HttpRequest();


        httpRequest.setEndpoint(
            NAMED_CREDENTIAL +
            RESPONSES_PATH
        );

        httpRequest.setMethod(
            'POST'
        );

        httpRequest.setHeader(
            'Content-Type',
            'application/json'
        );

        httpRequest.setTimeout(
            TIMEOUT_MS
        );


        Map<String, Object> body =
            new Map<String, Object>();


        body.put(
            'model',
            getModelDeployment()
        );


        body.put(
            'input',
            buildInput(request)
        );


        body.put(
            'text',
            buildStructuredOutputDefinition()
        );


        body.put(
            'parallel_tool_calls',
            false
        );


        httpRequest.setBody(
            JSON.serialize(body)
        );


        return httpRequest;
    }


    private static List<Object> buildInput(
        AI_AgentLLMRequest request
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
                    request.userMessage
            }
        );


        return input;
    }


    private static String buildSystemInstructions() {

        return
            'You are an enterprise Salesforce customer service assistant. ' +
            'Interpret the user request and select only an approved tool. ' +
            'Never invent a tool. ' +
            'Never execute Salesforce operations directly. ' +
            'Return only the required structured response. ' +
            'Do not fabricate Salesforce IDs or Salesforce data.';
    }


    private static Map<String, Object>
    buildStructuredOutputDefinition() {

        Map<String, Object> schema =
            new Map<String, Object>();


        schema.put(
            'type',
            'json_schema'
        );

        schema.put(
            'name',
            'AgentToolSelection'
        );

        schema.put(
            'strict',
            true
        );


        schema.put(
            'schema',
            new Map<String, Object>{
                'type' => 'object',

                'properties' => new Map<String, Object>{

                    'intent' => new Map<String, Object>{
                        'type' => 'string'
                    },

                    'toolName' => new Map<String, Object>{
                        'type' => 'string'
                    },

                    'arguments' => new Map<String, Object>{
                        'type' => 'object',
                        'additionalProperties' => true
                    },

                    'assistantMessage' => new Map<String, Object>{
                        'type' => 'string'
                    },

                    'confidence' => new Map<String, Object>{
                        'type' => 'number'
                    }
                },

                'required' => new List<String>{
                    'intent',
                    'toolName',
                    'arguments',
                    'assistantMessage',
                    'confidence'
                },

                'additionalProperties' => false
            }
        );


        return schema;
    }


    private static String getModelDeployment() {

        /*
         * Do not hard-code a production deployment name here.
         *
         * Replace this with Custom Metadata / configuration
         * before production deployment.
         */

        return 'YOUR_MODEL_DEPLOYMENT_NAME';
    }


    private static AI_AgentLLMResponse processResponse(
        HttpResponse httpResponse
    ) {

        if (httpResponse == null) {

            throw new AI_ServiceException(
                'Azure OpenAI returned no response.'
            );
        }


        Integer statusCode =
            httpResponse.getStatusCode();


        if (
            statusCode < 200 ||
            statusCode >= 300
        ) {

            /*
             * Do not return raw Azure error bodies to users.
             */
            throw new AI_ServiceException(
                'Azure OpenAI request failed.'
            );
        }


        Map<String, Object> responseBody;


        try {

            responseBody =
                (Map<String, Object>)
                JSON.deserializeUntyped(
                    httpResponse.getBody()
                );

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Azure OpenAI returned invalid JSON.'
            );
        }


        String outputText =
            extractOutputText(
                responseBody
            );


        if (String.isBlank(outputText)) {

            throw new AI_ServiceException(
                'Azure OpenAI returned no structured output.'
            );
        }


        try {

            return parseAgentResponse(
                outputText
            );

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Azure OpenAI returned an invalid Agent response.'
            );
        }
    }


    private static String extractOutputText(
        Map<String, Object> responseBody
    ) {

        /*
         * The exact response structure can evolve with the
         * selected Azure/OpenAI API version.
         *
         * Keep response parsing isolated here.
         */

        if (
            responseBody.containsKey(
                'output_text'
            )
        ) {

            Object outputText =
                responseBody.get(
                    'output_text'
                );

            return outputText == null
                ? null
                : String.valueOf(
                    outputText
                );
        }


        return null;
    }


    private static AI_AgentLLMResponse parseAgentResponse(
        String outputText
    ) {

        Map<String, Object> parsed =
            (Map<String, Object>)
            JSON.deserializeUntyped(
                outputText
            );


        AI_AgentLLMResponse response =
            new AI_AgentLLMResponse();


        response.success =
            true;


        response.intent =
            (String) parsed.get(
                'intent'
            );


        response.toolName =
            (String) parsed.get(
                'toolName'
            );


        response.arguments =
            parsed.containsKey(
                'arguments'
            )
            ? (Map<String, Object>)
                parsed.get('arguments')
            : new Map<String, Object>();


        response.assistantMessage =
            (String) parsed.get(
                'assistantMessage'
            );


        Object confidence =
            parsed.get(
                'confidence'
            );


        if (confidence != null) {

            response.confidence =
                Decimal.valueOf(
                    String.valueOf(
                        confidence
                    )
                );
        }


        return response;
    }
}