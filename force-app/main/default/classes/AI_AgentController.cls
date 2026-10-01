public with sharing class AI_AgentController {

    @AuraEnabled
    public static AI_AgentResponse processMessage(String userMessage) {

        AI_AgentResponse response;

        try {

            /*
             * ------------------------------------------------
             * Validate incoming message
             * ------------------------------------------------
             */
            if (String.isBlank(userMessage)) {

                response = new AI_AgentResponse();

                response.success = false;

                /*
                 * Keep message and errorMessage consistent.
                 * This also satisfies AI_AgentControllerTest.
                 */
                response.message =
                    'User message is required.';

                response.errorMessage =
                    'User message is required.';

                return response;
            }

            /*
             * ------------------------------------------------
             * Normalize input
             * ------------------------------------------------
             */
            userMessage = userMessage.trim();

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT INPUT = [' + userMessage + ']'
            );

            /*
             * ------------------------------------------------
             * Build Agent Request
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
             * Execute Agent
             * ------------------------------------------------
             */
            response =
                AI_AgentOrchestrator.process(request);

            /*
             * Safety check
             */
            if (response == null) {

                response =
                    new AI_AgentResponse();

                response.success = false;

                response.message =
                    'I could not complete the request.';

                response.errorMessage =
                    'Agent returned a null response.';
            }

            return response;

        } catch (AI_ServiceException ex) {

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