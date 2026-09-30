public with sharing class AI_AgentOrchestrator {

    public static AI_AgentResponse process(
        AI_AgentRequest request
    ) {

        AI_AgentResponse response =
            new AI_AgentResponse();

        try {

            // --------------------------------------------------
            // 1. Validate agent request
            // --------------------------------------------------

            if (request == null) {

                response.success = false;

                response.errorMessage =
                    'Agent request is required.';

                response.message =
                    'I could not process the request.';

                return response;
            }

            if (String.isBlank(request.userMessage)) {

                response.success = false;

                response.errorMessage =
                    'User message is required.';

                response.message =
                    'Please provide a request.';

                return response;
            }


            // --------------------------------------------------
            // 2. Resolve user intent
            // --------------------------------------------------

            AI_AgentIntent intent =
                AI_AgentIntentResolver.resolve(
                    request
                );

            if (intent == null) {

                response.success = false;

                response.errorMessage =
                    'Unable to determine user intent.';

                response.message =
                    'I could not determine what you are trying to do.';

                return response;
            }

            response.intent =
                intent.intentName;


            // --------------------------------------------------
            // 3. Select approved tool
            // --------------------------------------------------

            AI_AgentToolSelection selection =
                AI_AgentToolSelector.selectTool(
                    intent
                );

            if (selection == null) {

                response.success = false;

                response.errorMessage =
                    'Tool selection returned null.';

                response.message =
                    'I could not find a tool for this request.';

                return response;
            }

            if (!selection.isValid()) {

                response.success = false;

                response.errorMessage =
                    'Invalid tool selection. ' +
                    'Tool=' + selection.toolName +
                    ', Intent=' + selection.intentName;

                response.message =
                    'The selected tool is not currently available.';

                return response;
            }

            response.selectedTool =
                selection.toolName;


            // --------------------------------------------------
            // 4. Build tool arguments
            // --------------------------------------------------

            AI_AgentArgumentResult argumentResult =
                AI_AgentArgumentBuilder.build(
                    request,
                    intent,
                    selection
                );


            // --------------------------------------------------
            // 5. Check whether argument resolution is required
            // --------------------------------------------------

            if (argumentResult == null) {

                response.success = false;

                response.errorMessage =
                    'Unable to build tool arguments.';

                response.message =
                    'I could not determine the information needed to execute this request.';

                return response;
            }

            if (!argumentResult.complete) {

                response.success = false;

                response.message =
                    argumentResult.message;

                response.errorMessage =
                    'Missing argument: ' +
                    argumentResult.missingArgument;

                response.toolData =
                    argumentResult.arguments;

                return response;
            }


            // --------------------------------------------------
            // 6. Build Phase 6 AI_ToolRequest
            // --------------------------------------------------

            AI_ToolRequest toolRequest =
                new AI_ToolRequest();

            toolRequest.toolName =
                selection.toolName;

            toolRequest.arguments =
                argumentResult.arguments;


            // --------------------------------------------------
            // 7. Execute through Phase 6 security boundary
            // --------------------------------------------------

            AI_ToolResponse toolResponse =
                AI_ToolExecutor.execute(
                    toolRequest
                );


            // --------------------------------------------------
            // 8. Convert tool response into agent response
            // --------------------------------------------------

            if (toolResponse == null) {

                response.success = false;

                response.message =
                    'The tool did not return a response.';

                response.errorMessage =
                    'Null AI_ToolResponse.';

                return response;
            }

            response.success =
                toolResponse.success;

            response.toolData =
                toolResponse.data;

            response.approvalRequired =
                toolResponse.requiresApproval;

            response.errorMessage =
                toolResponse.errorCode;

            if (
                String.isBlank(response.errorMessage) &&
                toolResponse.success != true
            ) {

                response.errorMessage =
                    toolResponse.message;
            }


            // --------------------------------------------------
            // 9. Format user-facing response
            // --------------------------------------------------

            response.message =
                AI_AgentResponseFormatter.format(
                    request,
                    intent,
                    selection,
                    argumentResult,
                    toolResponse
                );

            return response;


        } catch (AI_ServiceException ex) {

            response.success = false;

            /*
             * TEMPORARY DIAGNOSTIC
             *
             * This exposes the exact AI_ServiceException
             * so we can identify why tool selection or
             * another service-layer operation is failing.
             *
             * Remove the "DIAGNOSTIC:" prefix after the
             * root cause has been identified.
             */
            response.message =
                'DIAGNOSTIC: ' +
                ex.getMessage();

            response.errorMessage =
                ex.getMessage();

            return response;


        } catch (Exception ex) {

            response.success = false;

            response.message =
                'I could not complete the request.';

            response.errorMessage =
                'Unexpected agent processing error.';

            return response;
        }
    }
}