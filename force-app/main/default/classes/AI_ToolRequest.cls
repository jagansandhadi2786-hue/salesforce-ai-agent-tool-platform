public class AI_ToolRequest {

// What this does
// The request contains: String toolName;
// Example: search_customer
// and: Map<String, Object> arguments;
// Example: customer_name → Acme Corporation


    public String toolName;
    public Map<String, Object> arguments;

    public AI_ToolRequest() {
        arguments = new Map<String, Object>();
    }

    public AI_ToolRequest(
        String toolName,
        Map<String, Object> arguments
    ) {
        this.toolName = toolName;
        this.arguments = arguments != null
            ? arguments
            : new Map<String, Object>();
    }

    public Boolean isValid() {

        return !String.isBlank(toolName);
    }
}
