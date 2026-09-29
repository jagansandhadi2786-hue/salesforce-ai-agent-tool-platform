public class AI_AgentIntent {

    /*
     * Logical business intent.
     *
     * Example:
     * GET_OPEN_CASES
     */
    public String intentName;

    /*
     * Primary tool associated with this intent.
     *
     * Example:
     * get_open_cases
     */
    public String toolName;

    /*
     * Deterministic confidence score.
     *
     * This is NOT an ML probability.
     *
     * It represents how strongly the rule-based
     * resolver matched the user's message.
     */
    public Decimal confidence;


    /*
     * Default constructor.
     */
    public AI_AgentIntent() {
    }


    /*
     * Convenience constructor.
     */
    public AI_AgentIntent(
        String intentName,
        String toolName,
        Decimal confidence
    ) {
        this.intentName = intentName;
        this.toolName = toolName;
        this.confidence = confidence;
    }


    /*
     * Indicates whether the intent contains
     * the minimum required information.
     */
    public Boolean isValid() {
        return
            !String.isBlank(intentName) &&
            !String.isBlank(toolName) &&
            confidence != null;
    }
}