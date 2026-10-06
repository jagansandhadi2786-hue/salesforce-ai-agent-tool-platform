public with sharing class AI_AgentController {
  /*
   * ================================================================
   * PROCESS MESSAGE - REQUEST OBJECT
   * ================================================================
   *
   * Primary controller entry point used by the LWC / application
   * layer.
   *
   * Existing architecture:
   *
   * AI_AgentController
   *        |
   *        v
   * AI_AgentOrchestrator
   *        |
   *        v
   * AI_AgentArgumentBuilder
   *        |
   *        v
   * AI Tool Execution
   *
   * ================================================================
   */
  @AuraEnabled
  public static AI_AgentResponse processMessage(AI_AgentRequest request) {
    AI_AgentResponse response;

    try {
      /*
       * ------------------------------------------------
       * Validate request
       * ------------------------------------------------
       */
      if (request == null) {
        response = new AI_AgentResponse();

        response.success = false;

        response.message = 'Agent request is required.';

        response.errorMessage = 'Agent request is required.';

        return response;
      }

      /*
       * ------------------------------------------------
       * Validate user message
       * ------------------------------------------------
       */
      if (String.isBlank(request.userMessage)) {
        response = new AI_AgentResponse();

        response.success = false;

        response.message = 'User message is required.';

        response.errorMessage = 'User message is required.';

        return response;
      }

      /*
       * ------------------------------------------------
       * Normalize user message
       * ------------------------------------------------
       */
      request.userMessage = request.userMessage.trim();

      System.debug(
        LoggingLevel.ERROR,
        '=== NEW AI AGENT CONTROLLER VERSION ==='
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT REQUEST = ' + JSON.serialize(request)
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT SESSION ID = [' + request.sessionId + ']'
      );

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT INPUT = [' + request.userMessage + ']'
      );

      /*
       * ------------------------------------------------
       * Execute Agent Orchestrator
       * ------------------------------------------------
       */
      response = AI_AgentOrchestrator.process(request);

      /*
       * ------------------------------------------------
       * Safety check
       * ------------------------------------------------
       */
      if (response == null) {
        response = new AI_AgentResponse();

        response.success = false;

        response.message = 'I could not complete the request.';

        response.errorMessage = 'Agent returned a null response.';
      }

      return response;
    }
    /*
     * ----------------------------------------------------
     * AI Service Exception
     * ----------------------------------------------------
     */
    catch (AI_ServiceException ex) {
      response = new AI_AgentResponse();

      response.success = false;

      response.message = 'I could not complete the request.';

      response.errorMessage = ex.getMessage();

      System.debug(
        LoggingLevel.ERROR,
        'AI AGENT SERVICE ERROR = ' + ex.getMessage()
      );

      return response;
    }
    /*
     * ----------------------------------------------------
     * Unexpected Exception
     * ----------------------------------------------------
     */
    catch (Exception ex) {
      response = new AI_AgentResponse();

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
   * ================================================================
   * PROCESS MESSAGE - STRING OVERLOAD
   * ================================================================
   *
   * Backward-compatible entry point.
   *
   * Existing Apex tests currently call:
   *
   *     AI_AgentController.processMessage(
   *         'Find the open cases for Acme.'
   *     );
   *
   * The current controller architecture expects an
   * AI_AgentRequest instead.
   *
   * This overload converts the String into an AI_AgentRequest and
   * delegates to the primary processMessage(AI_AgentRequest) method.
   *
   * This avoids duplicating agent processing logic.
   * ================================================================
   */
  public static AI_AgentResponse processMessage(String userMessage) {
    /*
     * ------------------------------------------------
     * Create request
     * ------------------------------------------------
     */
    AI_AgentRequest request = new AI_AgentRequest();

    /*
     * ------------------------------------------------
     * Populate user message
     * ------------------------------------------------
     */
    request.userMessage = userMessage;

    /*
     * ------------------------------------------------
     * Delegate to primary controller method
     * ------------------------------------------------
     */
    return processMessage(request);
  }
}
