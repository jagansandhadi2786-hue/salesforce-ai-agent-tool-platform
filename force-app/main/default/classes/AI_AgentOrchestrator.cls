public with sharing class AI_AgentOrchestrator {

    public static AI_AgentResponse process(
        AI_AgentRequest request
    ) {

        AI_AgentResponse response =
            new AI_AgentResponse();

        try {

            /*
             * ------------------------------------------------
             * Validate request
             * ------------------------------------------------
             */
            if (request == null) {

                response.success = false;

                response.errorMessage =
                    'Agent request is required.';

                response.message =
                    'I could not process the request.';

                return response;
            }

            /*
             * ------------------------------------------------
             * Validate user message
             * ------------------------------------------------
             */
            if (
                String.isBlank(
                    request.userMessage
                )
            ) {

                response.success = false;

                response.errorMessage =
                    'User message is required.';

                response.message =
                    'User message is required.';

                return response;
            }

            /*
             * ------------------------------------------------
             * Resolve intent
             * ------------------------------------------------
             */
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

            /*
             * ------------------------------------------------
             * Select tool
             * ------------------------------------------------
             */
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

            /*
             * ------------------------------------------------
             * Build tool arguments
             * ------------------------------------------------
             */
            AI_AgentArgumentResult argumentResult =
                AI_AgentArgumentBuilder.build(
                    request,
                    intent,
                    selection
                );

            if (argumentResult == null) {

                response.success = false;

                response.errorMessage =
                    'Unable to build tool arguments.';

                response.message =
                    'I could not determine the information needed to execute this request.';

                return response;
            }

            /*
             * ------------------------------------------------
             * Missing arguments
             * ------------------------------------------------
             */
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

            /*
             * ------------------------------------------------
             * Build Tool Request
             * ------------------------------------------------
             */
            AI_ToolRequest toolRequest =
                new AI_ToolRequest();

            toolRequest.toolName =
                selection.toolName;

            toolRequest.arguments =
                argumentResult.arguments;

            /*
             * ------------------------------------------------
             * Execute Tool
             * ------------------------------------------------
             */
            AI_ToolResponse toolResponse =
                AI_ToolExecutor.execute(
                    toolRequest
                );

            /*
             * Diagnostic logging
             */
            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT TOOL RESPONSE = ' +
                JSON.serialize(toolResponse)
            );

            if (toolResponse == null) {

                response.success = false;

                response.message =
                    'The tool did not return a response.';

                response.errorMessage =
                    'Null AI_ToolResponse.';

                return response;
            }

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT TOOL SUCCESS = ' +
                String.valueOf(
                    toolResponse.success
                )
            );

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT TOOL MESSAGE = ' +
                String.valueOf(
                    toolResponse.message
                )
            );

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT TOOL ERROR CODE = ' +
                String.valueOf(
                    toolResponse.errorCode
                )
            );

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT TOOL DATA = ' +
                String.valueOf(
                    toolResponse.data
                )
            );

            /*
             * ------------------------------------------------
             * Copy Tool Response
             * ------------------------------------------------
             */
            response.success =
                toolResponse.success;

            response.toolData =
                toolResponse.data;

            response.approvalRequired =
                toolResponse.requiresApproval;

            response.errorMessage =
                toolResponse.errorCode;

            /*
             * If the tool failed but did not provide
             * an errorCode, use its message.
             */
            if (
                String.isBlank(
                    response.errorMessage
                ) &&
                toolResponse.success != true
            ) {

                response.errorMessage =
                    toolResponse.message;
            }

            /*
             * ------------------------------------------------
             * Format final response
             * ------------------------------------------------
             */
            response.message =
                AI_AgentResponseFormatter.format(
                    request,
                    intent,
                    selection,
                    argumentResult,
                    toolResponse
                );

            System.debug(
                LoggingLevel.ERROR,
                'AI AGENT FINAL RESPONSE = ' +
                JSON.serialize(response)
            );

            return response;

        } catch (AI_ServiceException ex) {

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