public with sharing class AI_AgentOrchestrator {
  /*
   * ------------------------------------------------------------
   * Main Agent Entry Point
   * ------------------------------------------------------------
   */
  public static AI_AgentResponse process(AI_AgentRequest request) {
    AI_AgentResponse response = new AI_AgentResponse();

    try {
      /*
       * ------------------------------------------------
       * Validate request
       * ------------------------------------------------
       */
      if (request == null) {
        response.success = false;

        response.errorMessage = 'Agent request is required.';

        response.message = 'I could not process the request.';

        return response;
      }

      /*
       * ------------------------------------------------
       * Validate user message
       * ------------------------------------------------
       */
      if (String.isBlank(request.userMessage)) {
        response.success = false;

        response.errorMessage = 'User message is required.';

        response.message = 'User message is required.';

        return response;
      }

      /*
       * ------------------------------------------------
       * Resolve intent
       * ------------------------------------------------
       */
      AI_AgentIntent intent = AI_AgentIntentResolver.resolve(request);

      if (intent == null) {
        response.success = false;

        response.errorMessage = 'Unable to determine user intent.';

        response.message = 'I could not determine what you are trying to do.';

        return response;
      }

      response.intent = intent.intentName;

      /*
       * ------------------------------------------------
       * Select tool
       * ------------------------------------------------
       */
      AI_AgentToolSelection selection = AI_AgentToolSelector.selectTool(intent);

      if (selection == null) {
        response.success = false;

        response.errorMessage = 'Tool selection returned null.';

        response.message = 'I could not find a tool for this request.';

        return response;
      }

      if (!selection.isValid()) {
        response.success = false;

        response.errorMessage =
          'Invalid tool selection. ' +
          'Tool=' +
          selection.toolName +
          ', Intent=' +
          selection.intentName;

        response.message = 'The selected tool is not currently available.';

        return response;
      }

      response.selectedTool = selection.toolName;

      /*
       * ------------------------------------------------
       * Build tool arguments
       * ------------------------------------------------
       */
      AI_AgentArgumentResult argumentResult = AI_AgentArgumentBuilder.build(
        request,
        intent,
        selection
      );

      if (argumentResult == null) {
        response.success = false;

        response.errorMessage = 'Unable to build tool arguments.';

        response.message = 'I could not determine the information needed to execute this request.';

        return response;
      }

      /*
       * ------------------------------------------------
       * MULTI-STEP RESOLUTION PATH
       * ------------------------------------------------
       *
       * resolutionTool MUST be checked before complete.
       */
      if (!String.isBlank(argumentResult.resolutionTool)) {
        System.debug(
          LoggingLevel.DEBUG,
          'AI AGENT RESOLUTION TOOL = ' + argumentResult.resolutionTool
        );

        return processWithResolution(
          request,
          intent,
          selection,
          argumentResult
        );
      }

      /*
       * ------------------------------------------------
       * Missing arguments
       * ------------------------------------------------
       */
      if (!argumentResult.complete) {
        response.success = false;

        response.message = argumentResult.message;

        response.errorMessage =
          'Missing argument: ' + argumentResult.missingArgument;

        response.toolData = argumentResult.arguments;

        return response;
      }

      /*
       * ------------------------------------------------
       * Existing single-step behavior
       * ------------------------------------------------
       */
      return processSingleStep(request, intent, selection, argumentResult);
    } catch (AI_ServiceException ex) {
      response.success = false;

      response.message = 'I could not complete the request.';

      response.errorMessage = ex.getMessage();

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT SERVICE ERROR = ' + ex.getMessage()
      );

      return response;
    } catch (Exception ex) {
      response.success = false;

      response.message = 'I could not complete the request.';

      response.errorMessage = ex.getMessage();

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT UNEXPECTED ERROR = ' + ex.getMessage()
      );

      return response;
    }
  }

  /*
   * ============================================================
   * EXISTING SINGLE-STEP PROCESSING
   * ============================================================
   */
  private static AI_AgentResponse processSingleStep(
    AI_AgentRequest request,
    AI_AgentIntent intent,
    AI_AgentToolSelection selection,
    AI_AgentArgumentResult argumentResult
  ) {
    AI_AgentResponse response = new AI_AgentResponse();

    try {
      /*
       * ------------------------------------------------
       * Build Tool Request
       * ------------------------------------------------
       */
      AI_ToolRequest toolRequest = new AI_ToolRequest();

      toolRequest.toolName = selection.toolName;

      toolRequest.arguments = argumentResult.arguments;

      /*
       * ------------------------------------------------
       * Execute Tool
       * ------------------------------------------------
       */
      AI_ToolResponse toolResponse = AI_ToolExecutor.execute(toolRequest);

      /*
       * ------------------------------------------------
       * Diagnostic logging
       * ------------------------------------------------
       */
      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT TOOL RESPONSE = ' + JSON.serialize(toolResponse)
      );

      if (toolResponse == null) {
        response.success = false;

        response.message = 'The tool did not return a response.';

        response.errorMessage = 'Null AI_ToolResponse.';

        return response;
      }

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT TOOL SUCCESS = ' + String.valueOf(toolResponse.success)
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT TOOL MESSAGE = ' + String.valueOf(toolResponse.message)
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT TOOL ERROR CODE = ' + String.valueOf(toolResponse.errorCode)
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT TOOL DATA = ' + String.valueOf(toolResponse.data)
      );

      /*
       * ------------------------------------------------
       * Copy Tool Response
       * ------------------------------------------------
       */
      response.intent = intent.intentName;

      response.selectedTool = selection.toolName;

      response.success = toolResponse.success;

      response.toolData = toolResponse.data;

      response.approvalRequired = toolResponse.requiresApproval;

      response.errorMessage = toolResponse.errorCode;

      /*
       * If the tool failed but did not provide
       * an errorCode, use its message.
       */
      if (
        String.isBlank(response.errorMessage) && toolResponse.success != true
      ) {
        response.errorMessage = toolResponse.message;
      }

      /*
       * ------------------------------------------------
       * Format final response
       * ------------------------------------------------
       */
      response.message = AI_AgentResponseFormatter.format(
        request,
        intent,
        selection,
        argumentResult,
        toolResponse
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT FINAL RESPONSE = ' + JSON.serialize(response)
      );

      return response;
    } catch (Exception ex) {
      response.success = false;

      response.message = 'I could not complete the request.';

      response.errorMessage = ex.getMessage();

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT SINGLE STEP ERROR = ' + ex.getMessage()
      );

      return response;
    }
  }

  /*
   * ============================================================
   * MULTI-STEP RESOLUTION PROCESSING
   * ============================================================
   */
  private static AI_AgentResponse processWithResolution(
    AI_AgentRequest request,
    AI_AgentIntent intent,
    AI_AgentToolSelection selection,
    AI_AgentArgumentResult argumentResult
  ) {
    AI_AgentContext context = new AI_AgentContext();

    /*
     * ------------------------------------------------
     * Initialize Context
     * ------------------------------------------------
     */
    context.userMessage = request.userMessage;

    context.intent = intent;

    context.currentTool = selection.toolName;

    context.arguments = argumentResult.arguments;

    /*
     * ------------------------------------------------
     * Step 1: Identify Resolution Tool
     * ------------------------------------------------
     */
    String resolutionTool = argumentResult.resolutionTool;

    if (String.isBlank(resolutionTool)) {
      return buildFailureResponse(
        intent,
        selection,
        'No resolution tool was identified.'
      );
    }

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT CHAIN RESOLUTION TOOL = ' + resolutionTool
    );

    /*
     * ------------------------------------------------
     * Check Chain Limit
     * ------------------------------------------------
     */
    if (!context.canExecuteNextStep()) {
      return buildChainLimitResponse(context, intent, selection);
    }

    /*
     * ------------------------------------------------
     * Build Resolution Tool Request
     * ------------------------------------------------
     */
    AI_ToolRequest resolutionRequest = new AI_ToolRequest();

    resolutionRequest.toolName = resolutionTool;

    resolutionRequest.arguments = buildResolutionArguments(argumentResult);

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT RESOLUTION ARGUMENTS = ' +
      JSON.serialize(resolutionRequest.arguments)
    );

    /*
     * ------------------------------------------------
     * Execute Resolution Tool
     * ------------------------------------------------
     */
    context.stepNumber++;

    AI_ToolResponse resolutionResponse = AI_ToolExecutor.execute(
      resolutionRequest
    );

    context.recordToolResponse(resolutionResponse);

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT RESOLUTION RESPONSE = ' + JSON.serialize(resolutionResponse)
    );

    /*
     * ------------------------------------------------
     * Validate Resolution Response
     * ------------------------------------------------
     */
    if (resolutionResponse == null || !resolutionResponse.success) {
      return convertToolFailure(intent, selection, resolutionResponse);
    }

    /*
     * ------------------------------------------------
     * Step 2: Resolve Original Tool Arguments
     * ------------------------------------------------
     */
    Map<String, Object> nextArguments = AI_AgentToolResultResolver.resolveNextArguments(
      resolutionTool,
      resolutionResponse,
      selection.toolName
    );

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT NEXT ARGUMENTS = ' + JSON.serialize(nextArguments)
    );

    if (nextArguments == null) {
      return buildFailureResponse(
        intent,
        selection,
        'Unable to resolve arguments for the original tool.'
      );
    }

    /*
     * ------------------------------------------------
     * Step 3: Execute Original Tool
     * ------------------------------------------------
     */
    if (!context.canExecuteNextStep()) {
      return buildChainLimitResponse(context, intent, selection);
    }

    AI_ToolRequest finalRequest = new AI_ToolRequest();

    finalRequest.toolName = selection.toolName;

    finalRequest.arguments = nextArguments;

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT FINAL TOOL = ' + selection.toolName
    );

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT FINAL ARGUMENTS = ' + JSON.serialize(nextArguments)
    );

    /*
     * ------------------------------------------------
     * Execute Final Tool
     * ------------------------------------------------
     */
    context.stepNumber++;

    AI_ToolResponse finalResponse = AI_ToolExecutor.execute(finalRequest);

    context.recordToolResponse(finalResponse);

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT FINAL TOOL RESPONSE = ' + JSON.serialize(finalResponse)
    );

    /*
     * ------------------------------------------------
     * Build Final Agent Response
     * ------------------------------------------------
     *
     * IMPORTANT:
     *
     * Pass the resolved arguments into the final
     * response builder.
     */
    return buildFinalAgentResponse(
      request,
      intent,
      selection,
      argumentResult,
      nextArguments,
      finalResponse,
      context
    );
  }

  /*
   * ============================================================
   * BUILD RESOLUTION ARGUMENTS
   * ============================================================
   */
  private static Map<String, Object> buildResolutionArguments(
    AI_AgentArgumentResult argumentResult
  ) {
    Map<String, Object> arguments = new Map<String, Object>();

    if (argumentResult != null && argumentResult.arguments != null) {
      if (argumentResult.arguments.containsKey('customer_name')) {
        arguments.put(
          'customer_name',
          argumentResult.arguments.get('customer_name')
        );
      }
    }

    return arguments;
  }

  /*
   * ============================================================
   * BUILD FAILURE RESPONSE
   * ============================================================
   */
  private static AI_AgentResponse buildFailureResponse(
    AI_AgentIntent intent,
    AI_AgentToolSelection selection,
    String errorMessage
  ) {
    AI_AgentResponse response = new AI_AgentResponse();

    response.success = false;

    if (intent != null) {
      response.intent = intent.intentName;
    }

    if (selection != null) {
      response.selectedTool = selection.toolName;
    }

    response.message = 'I could not complete the request.';

    response.errorMessage = errorMessage;

    return response;
  }

  /*
   * ============================================================
   * CHAIN LIMIT RESPONSE
   * ============================================================
   */
  private static AI_AgentResponse buildChainLimitResponse(
    AI_AgentContext context,
    AI_AgentIntent intent,
    AI_AgentToolSelection selection
  ) {
    AI_AgentResponse response = new AI_AgentResponse();

    response.success = false;

    if (intent != null) {
      response.intent = intent.intentName;
    }

    if (selection != null) {
      response.selectedTool = selection.toolName;
    }

    response.message = 'The agent could not complete the request because the maximum tool execution chain was reached.';

    response.errorMessage = 'Maximum agent tool chain limit reached.';

    System.debug(
      LoggingLevel.ERROR,
      'AI AGENT CHAIN LIMIT REACHED. ' +
        'Step=' +
        String.valueOf(context.stepNumber)
    );

    return response;
  }

  /*
   * ============================================================
   * CONVERT TOOL FAILURE
   * ============================================================
   */
  private static AI_AgentResponse convertToolFailure(
    AI_AgentIntent intent,
    AI_AgentToolSelection selection,
    AI_ToolResponse toolResponse
  ) {
    AI_AgentResponse response = new AI_AgentResponse();

    response.success = false;

    if (intent != null) {
      response.intent = intent.intentName;
    }

    if (selection != null) {
      response.selectedTool = selection.toolName;
    }

    response.message = 'I could not complete the request.';

    if (toolResponse == null) {
      response.errorMessage = 'The resolution tool returned no response.';

      return response;
    }

    response.toolData = toolResponse.data;

    response.approvalRequired = toolResponse.requiresApproval;

    response.errorMessage = toolResponse.errorCode;

    if (String.isBlank(response.errorMessage)) {
      response.errorMessage = toolResponse.message;
    }

    return response;
  }

  /*
   * ============================================================
   * BUILD FINAL AGENT RESPONSE
   * ============================================================
   *
   * IMPORTANT FIX:
   *
   * The original argumentResult represents the state BEFORE
   * resolution:
   *
   *     complete = false
   *     missingArgument = account_id
   *
   * The final tool has already executed successfully.
   *
   * Therefore the formatter must receive a RESOLVED argument
   * result, otherwise it can incorrectly generate:
   *
   * "Account ID must be resolved from customer name..."
   *
   * even though the account ID was successfully resolved.
   */
  private static AI_AgentResponse buildFinalAgentResponse(
    AI_AgentRequest request,
    AI_AgentIntent intent,
    AI_AgentToolSelection selection,
    AI_AgentArgumentResult argumentResult,
    Map<String, Object> resolvedArguments,
    AI_ToolResponse finalResponse,
    AI_AgentContext context
  ) {
    AI_AgentResponse response = new AI_AgentResponse();

    response.intent = intent.intentName;

    response.selectedTool = selection.toolName;

    if (finalResponse == null) {
      response.success = false;

      response.message = 'The final tool did not return a response.';

      response.errorMessage = 'Null AI_ToolResponse.';

      return response;
    }

    /*
     * ------------------------------------------------
     * Copy final tool result
     * ------------------------------------------------
     */
    response.success = finalResponse.success;

    response.toolData = finalResponse.data;

    response.approvalRequired = finalResponse.requiresApproval;

    response.errorMessage = finalResponse.errorCode;

    if (
      String.isBlank(response.errorMessage) && finalResponse.success != true
    ) {
      response.errorMessage = finalResponse.message;
    }

    /*
     * ------------------------------------------------
     * Create resolved argument result
     * ------------------------------------------------
     *
     * Do not send the original incomplete argumentResult
     * to the formatter.
     */
    AI_AgentArgumentResult resolvedArgumentResult = new AI_AgentArgumentResult();

    /*
     * Preserve the arguments originally extracted from
     * the user's message.
     */
    resolvedArgumentResult.arguments = new Map<String, Object>();

    if (argumentResult != null && argumentResult.arguments != null) {
      resolvedArgumentResult.arguments.putAll(argumentResult.arguments);
    }

    /*
     * Add the arguments resolved by the resolution tool.
     *
     * Example:
     *
     * customer_name = Acme
     * account_id    = 001gK00001ZlHC1QAN
     */
    if (resolvedArguments != null) {
      resolvedArgumentResult.arguments.putAll(resolvedArguments);
    }

    /*
     * The final tool has now received all required
     * arguments successfully.
     */
    resolvedArgumentResult.complete = true;

    resolvedArgumentResult.missingArgument = null;

    resolvedArgumentResult.resolutionTool = null;

    resolvedArgumentResult.message = null;

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT RESOLVED ARGUMENTS = ' +
      JSON.serialize(resolvedArgumentResult.arguments)
    );

    /*
     * ------------------------------------------------
     * Format final response
     * ------------------------------------------------
     *
     * The formatter now receives the RESOLVED argument
     * state instead of the original incomplete state.
     */
    response.message = AI_AgentResponseFormatter.format(
      request,
      intent,
      selection,
      resolvedArgumentResult,
      finalResponse
    );

    /*
     * ------------------------------------------------
     * Safety fallback
     * ------------------------------------------------
     *
     * If a successful tool returned no data and the
     * formatter did not provide a meaningful message,
     * return a generic successful result rather than
     * an old missing-argument message.
     */
    if (finalResponse.success == true && String.isBlank(response.message)) {
      response.message = 'The request completed successfully, but no results were found.';
    }

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT CHAIN STEPS = ' + String.valueOf(context.stepNumber)
    );

    System.debug(
      LoggingLevel.DEBUG,
      'AI AGENT FINAL RESPONSE = ' + JSON.serialize(response)
    );

    return response;
  }
}
