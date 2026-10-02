
public with sharing class AI_AgentAzureOrchestrator {

    /**
     * Execute an Azure AI agent request.
     *
     * Responsibilities:
     *  - Validate the execution context
     *  - Store the user message in the context
     *  - Track Azure response ID
     *  - Delegate actual Azure/tool-calling processing
     *    to AI_AgentAzureToolCallingService
     *  - Mark the execution context as completed or failed
     */
    public static AI_AgentLLMResponse execute(
        String userMessage,
        AI_AgentLLMExecutionContext context
    ) {

        if (String.isBlank(userMessage)) {

            if (context != null) {
                context.markFailed(
                    'User message is required.'
                );
            }

            throw new AI_ServiceException(
                'User message is required.'
            );
        }

        if (context == null) {

            throw new AI_ServiceException(
                'LLM execution context is required.'
            );
        }

        /*
         * Store request information in the execution context.
         */
        context.userMessage = userMessage;

        try {

            /*
             * ---------------------------------------------------------
             * Delegate Azure + tool-calling processing.
             *
             * AI_AgentAzureToolCallingService is responsible for:
             *
             * Azure OpenAI
             *      ↓
             * Tool call detection
             *      ↓
             * Tool validation
             *      ↓
             * Tool executor
             *      ↓
             * Tool output
             *      ↓
             * Azure continuation
             * ---------------------------------------------------------
             */
            AI_AgentLLMResponse response =
                AI_AgentAzureToolCallingService.process(
                    userMessage
                );

            if (response == null) {

                context.markFailed(
                    'Azure OpenAI returned no response.'
                );

                throw new AI_ServiceException(
                    'Azure OpenAI returned no response.'
                );
            }

            /*
             * Store Azure response ID for observability /
             * continuation tracking.
             */
            context.azureResponseId =
                response.responseId;

            /*
             * Mark execution as completed.
             */
            context.markCompleted();

            return response;

        } catch (AI_ServiceException ex) {

            context.markFailed(
                ex.getMessage()
            );

            throw ex;

        } catch (Exception ex) {

            context.markFailed(
                ex.getMessage()
            );

            throw new AI_ServiceException(
                'Azure orchestration failed: ' +
                ex.getMessage()
            );
        }
    }
}