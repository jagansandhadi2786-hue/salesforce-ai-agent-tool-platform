public class AI_ToolResponse {

// Why Standardize Responses?
// Without a standard response, every tool might return something different.
// example:
// CustomerService → List<Account>
// CaseService → Case
// OrderService → OrderResult
// KnowledgeService → List<KnowledgeResult>
// That becomes difficult for an AI agent to process.
// Instead:
//                     AI_ToolResponse
//                          │
//           ┌──────────────┼──────────────┐
//           ▼              ▼              ▼
//        Customer         Case          Order
//          data            data           data
// The outer contract remains consistent.


    public Boolean success;
    public String toolName;
    public String message;
    public Object data;
    public Boolean requiresApproval;
    public String errorCode;

    public AI_ToolResponse() {
        success = false;
        requiresApproval = false;
    }

    public static AI_ToolResponse success(
        String toolName,
        Object data
    ) {

        AI_ToolResponse response =
            new AI_ToolResponse();

        response.success = true;
        response.toolName = toolName;
        response.data = data;
        response.message =
            'Tool executed successfully.';

        return response;
    }

    public static AI_ToolResponse failure(
        String toolName,
        String message
    ) {

        AI_ToolResponse response =
            new AI_ToolResponse();

        response.success = false;
        response.toolName = toolName;
        response.message = message;

        return response;
    }

    public static AI_ToolResponse approvalRequired(
        String toolName
    ) {

        AI_ToolResponse response =
            new AI_ToolResponse();

        response.success = false;
        response.toolName = toolName;
        response.requiresApproval = true;
        response.message =
            'Approval is required before this tool can be executed.';

        return response;
    }
}

