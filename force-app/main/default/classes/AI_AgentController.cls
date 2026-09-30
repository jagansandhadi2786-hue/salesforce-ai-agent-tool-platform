public with sharing class AI_AgentController {

    @AuraEnabled
    public static AI_AgentResponse processMessage(String userMessage) {

        AI_AgentResponse response;

        try {

            /*
             * ------------------------------------------------
             * STEP 1
             * Validate the message received from the UI.
             * ------------------------------------------------
             */
            if (String.isBlank(userMessage)) {

                response = new AI_AgentResponse();

                response.success = false;

                response.message =
                    'User message is required.';

                response.errorMessage =
                    'User message is required.';

                return response;
            }


            /*
             * ------------------------------------------------
             * STEP 2
             * Preserve the actual natural-language message.
             *
             * IMPORTANT:
             * Do NOT replace this with GENERAL_CHAT.
             * ------------------------------------------------
             */
            userMessage = userMessage.trim();

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT INPUT = [' + userMessage + ']'
            );


            /*
             * ------------------------------------------------
             * STEP 3
             * Build the agent request.
             * ------------------------------------------------
             */
            AI_AgentRequest request =
                new AI_AgentRequest();

            request.userMessage =
                userMessage;

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT REQUEST.userMessage = [' +
                request.userMessage +
                ']'
            );


            /*
             * ------------------------------------------------
             * STEP 4
             * Send request to the Agent Orchestrator.
             *
             * AI_AgentOrchestrator.process() is STATIC
             * in the existing implementation.
             * ------------------------------------------------
             */
            response =
                AI_AgentOrchestrator.process(request);

            return response;


        } catch (AI_ServiceException ex) {

            /*
             * ------------------------------------------------
             * SERVICE ERROR
             * ------------------------------------------------
             */
            response =
                new AI_AgentResponse();

            response.success = false;

            response.message =
                'I could not complete the request.';

            response.errorMessage =
                ex.getMessage();

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT SERVICE ERROR = ' +
                ex.getMessage()
            );

            return response;


        } catch (Exception ex) {

            /*
             * ------------------------------------------------
             * UNEXPECTED ERROR
             * ------------------------------------------------
             */
            response =
                new AI_AgentResponse();

            response.success = false;

            response.message =
                'I could not complete the request.';

            response.errorMessage =
                ex.getMessage();

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT UNEXPECTED ERROR = ' +
                ex.getMessage()
            );

            return response;
        }
    }
}