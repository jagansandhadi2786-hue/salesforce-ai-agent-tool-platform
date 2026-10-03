public class AI_AgentRequest {

    /*
     * Unique identifier for the agent session.
     * Example:
     * SESSION-20260919-001
     */
    public String sessionId;

    /*
     * Natural-language message entered by the user.
     *
     * Example:
     * "Find the open cases for Acme."
     */
    public String userMessage;

    /*
     * Salesforce User Id.
     *
     * The value can be populated by the controller/orchestrator.
     */
    public String userId;

    /*
     * Conversation identifier.
     *
     * Useful when multiple messages belong to
     * the same conversational interaction.
     */
    public String conversationId;
    public String correlationId;


    /*
     * Default constructor.
     */
    public AI_AgentRequest() {
    }


    /*
     * Convenience constructor.
     */
    public AI_AgentRequest(String userMessage) {
        this.userMessage = userMessage;
    }


    /*
     * Full constructor.
     */
    public AI_AgentRequest(
        String sessionId,
        String userMessage,
        String userId,
        String conversationId
    ) {
        this.sessionId = sessionId;
        this.userMessage = userMessage;
        this.userId = userId;
        this.conversationId = conversationId;
    }


    /*
     * Basic validation.
     *
     * The minimum requirement for an Agent request
     * is a non-empty user message.
     */
    public Boolean isValid() {
        return !String.isBlank(userMessage);
    }
}
