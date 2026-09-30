public with sharing class AI_AgentController {

    @AuraEnabled
    public static AI_AgentResponse processMessage(
        String userMessage
    ) {

        AI_AgentRequest request =
            new AI_AgentRequest();

        request.userMessage =
            userMessage;

        return AI_AgentOrchestrator.process(
            request
        );
    }
}

