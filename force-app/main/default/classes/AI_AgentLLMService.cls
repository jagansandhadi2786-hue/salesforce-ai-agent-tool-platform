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
         * Primary LLM provider
         *
         * Azure OpenAI is responsible for interpreting
         * the user's request and returning the structured
         * AI_AgentLLMResponse.
         */
        return AI_AgentAzureOpenAIService.generate(
            request
        );
    }
}