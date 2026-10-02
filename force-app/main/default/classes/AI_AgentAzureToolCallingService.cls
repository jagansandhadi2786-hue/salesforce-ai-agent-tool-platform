public with sharing class AI_AgentAzureToolCallingService {

    private static final Integer MAX_ITERATIONS = 5;

    public static AI_AgentLLMResponse process(
        String userMessage
    ) {

        if (String.isBlank(userMessage)) {
            throw new AI_ServiceException(
                'User message is required.'
            );
        }

        AI_AgentLLMResponse response =
            AI_AgentAzureOpenAIService.generate(
                userMessage
            );

        if (response == null) {
            throw new AI_ServiceException(
                'Azure OpenAI returned no response.'
            );
        }

        Integer iteration = 0;

        while (
            response != null &&
            response.requiresToolCall == true
        ) {

            iteration++;

            if (iteration > MAX_ITERATIONS) {
                throw new AI_ServiceException(
                    'Maximum Azure tool-calling depth reached.'
                );
            }

            if (String.isBlank(response.responseId)) {
                throw new AI_ServiceException(
                    'Azure response ID is required for tool continuation.'
                );
            }

            List<AI_AgentLLMToolOutput> outputs =
                executeToolCalls(
                    response.toolCalls
                );

            if (
                outputs == null ||
                outputs.isEmpty()
            ) {
                throw new AI_ServiceException(
                    'No tool outputs were produced.'
                );
            }

            response =
                continueAzureConversation(
                    response.responseId,
                    outputs
                );

            if (response == null) {
                throw new AI_ServiceException(
                    'Azure OpenAI returned no response during tool continuation.'
                );
            }
        }

        return response;
    }


    private static AI_AgentLLMResponse continueAzureConversation(
        String responseId,
        List<AI_AgentLLMToolOutput> outputs
    ) {

        if (String.isBlank(responseId)) {
            throw new AI_ServiceException(
                'Azure response ID is required.'
            );
        }

        if (
            outputs == null ||
            outputs.isEmpty()
        ) {
            throw new AI_ServiceException(
                'Tool outputs are required.'
            );
        }

        return AI_AgentAzureOpenAIService.continueWithToolOutputs(
            responseId,
            outputs
        );
    }


    private static List<AI_AgentLLMToolOutput>
    executeToolCalls(
        List<AI_AgentLLMToolCall> toolCalls
    ) {

        List<AI_AgentLLMToolOutput> outputs =
            new List<AI_AgentLLMToolOutput>();

        if (
            toolCalls == null ||
            toolCalls.isEmpty()
        ) {
            throw new AI_ServiceException(
                'Azure requested a tool call without a tool definition.'
            );
        }

        for (
            AI_AgentLLMToolCall toolCall :
            toolCalls
        ) {

            if (toolCall == null) {
                throw new AI_ServiceException(
                    'Azure returned a null tool call.'
                );
            }

            /*
             * ---------------------------------------------------------
             * Step 1:
             * Validate the Azure tool call.
             * ---------------------------------------------------------
             */
            AI_AgentLLMToolCallValidationResult validation =
                AI_AgentLLMToolCallValidator.validate(
                    toolCall
                );

            if (validation == null) {
                throw new AI_ServiceException(
                    'Tool call validation returned no result.'
                );
            }

            if (validation.valid != true) {
                throw new AI_ServiceException(
                    validation.errorMessage
                );
            }


            /*
             * ---------------------------------------------------------
             * Step 2:
             * Handle tools that require human approval.
             * ---------------------------------------------------------
             */
            if (
                validation.approvalRequired == true
            ) {

                AI_AgentLLMToolOutput approvalOutput =
                    new AI_AgentLLMToolOutput(
                        toolCall.callId,
                        JSON.serialize(
                            new Map<String, Object>{
                                'status' =>
                                    'APPROVAL_REQUIRED',
                                'toolName' =>
                                    toolCall.toolName
                            }
                        )
                    );

                outputs.add(
                    approvalOutput
                );

                continue;
            }


            /*
             * ---------------------------------------------------------
             * Step 3:
             * Build the controlled Salesforce tool request.
             * ---------------------------------------------------------
             */
            AI_ToolRequest toolRequest =
                new AI_ToolRequest();

            toolRequest.toolName =
                toolCall.toolName;

            toolRequest.arguments =
                toolCall.arguments;


            /*
             * ---------------------------------------------------------
             * Step 4:
             * Execute through the controlled Tool Executor.
             *
             * IMPORTANT:
             * The LLM never directly invokes Apex.
             *
             * AI_ToolExecutor performs:
             *
             * Tool Registry
             * Tool Validation
             * Schema Validation
             * Authorization
             * Approval
             * Dispatcher
             * Salesforce Service
             * Tool Response
             * ---------------------------------------------------------
             */
            AI_ToolResponse toolResponse =
                AI_ToolExecutor.execute(
                    toolRequest
                );


            /*
             * ---------------------------------------------------------
             * Step 5:
             * Convert Salesforce tool response into the format
             * required by Azure Responses API.
             * ---------------------------------------------------------
             */
            if (toolResponse == null) {

                throw new AI_ServiceException(
                    'Tool executor returned no response for: ' +
                    toolCall.toolName
                );
            }


            /*
             * ---------------------------------------------------------
             * Step 6:
             * Serialize the complete tool result.
             *
             * Azure receives this as the function_call_output.
             * ---------------------------------------------------------
             */
            String outputJson =
                JSON.serialize(
                    toolResponse
                );


            AI_AgentLLMToolOutput toolOutput =
                new AI_AgentLLMToolOutput(
                    toolCall.callId,
                    outputJson
                );

            outputs.add(
                toolOutput
            );
        }

        return outputs;
    }
}