public class AI_AgentToolSelection {

    /*
     * Logical Agent intent.
     *
     * Example:
     * GET_OPEN_CASES
     */
    public String intentName;

    /*
     * Selected tool API name.
     *
     * Example:
     * get_open_cases
     */
    public String toolName;

    /*
     * Tool description from the contract catalog.
     */
    public String description;

    /*
     * Tool type.
     *
     * Examples:
     * Salesforce
     * REST
     * Knowledge
     * Function
     */
    public String toolType;

    /*
     * Whether the tool is active according
     * to the contract catalog.
     */
    public Boolean contractActive;

    /*
     * Whether the tool requires approval.
     */
    public Boolean requiresApproval;

    /*
     * Salesforce AI_Tool__c record Id.
     */
    public Id toolRecordId;

    /*
     * Salesforce registry active status.
     */
    public Boolean registryActive;


    /*
     * Default constructor.
     */
    public AI_AgentToolSelection() {
    }


    /*
     * Indicates whether the selected tool
     * has passed all required checks.
     */
    public Boolean isValid() {

        return
            !String.isBlank(intentName) &&
            !String.isBlank(toolName) &&
            contractActive == true &&
            toolRecordId != null &&
            registryActive == true;
    }
}