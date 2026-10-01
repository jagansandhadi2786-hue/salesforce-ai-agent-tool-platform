public class AI_AgentResponse {

    /*
     * Indicates whether the Agent successfully
     * processed the request.
     */
    public Boolean success;
    /*
     * Natural-language response returned to the user.
     */
    public String message;
    /*
     * Detected Agent intent.
     */
    public String intent;

    /*
     * Tool selected by the Agent.
     *
     * Example:
     * get_open_cases
     */
    public String selectedTool;

    /*
     * Tool result.
     *
     * This remains generic because different tools
     * return different DTO structures.
     */
    public Object toolData;

    /*
     * Indicates that human approval is required.
     */
    public Boolean approvalRequired;

    /*
     * Sanitized error message.
     *
     * Do not place stack traces, SOQL, tokens,
     * credentials, or internal implementation details here.
     */
    public String errorMessage;
    public String sessionId;
        //So the LWC/API can maintain the conversation.



    /*
     * Default constructor.
     */
    public AI_AgentResponse() {
        this.success = false;
        this.approvalRequired = false;
    }


    /*
     * Successful response.
     */
    public static AI_AgentResponse successResponse(
        String message,
        String intent,
        String selectedTool,
        Object toolData
    ) {
        AI_AgentResponse response = new AI_AgentResponse();

        response.success = true;
        response.message = message;
        response.intent = intent;
        response.selectedTool = selectedTool;
        response.toolData = toolData;
        response.approvalRequired = false;
        response.errorMessage = null;

        return response;
    }


    /*
     * Approval-required response.
     */
    public static AI_AgentResponse approvalRequiredResponse(
        String message,
        String intent,
        String selectedTool,
        Object toolData
    ) {
        AI_AgentResponse response = new AI_AgentResponse();

        response.success = false;
        response.message = message;
        response.intent = intent;
        response.selectedTool = selectedTool;
        response.toolData = toolData;
        response.approvalRequired = true;
        response.errorMessage = null;

        return response;
    }


    /*
     * Failure response.
     */
    public static AI_AgentResponse failureResponse(
        String message,
        String intent,
        String selectedTool,
        String errorMessage
    ) {
        AI_AgentResponse response = new AI_AgentResponse();

        response.success = false;
        response.message = message;
        response.intent = intent;
        response.selectedTool = selectedTool;
        response.toolData = null;
        response.approvalRequired = false;
        response.errorMessage = errorMessage;

        return response;
    }
}