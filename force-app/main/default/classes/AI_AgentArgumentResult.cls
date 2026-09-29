public class AI_AgentArgumentResult {

    public Map<String, Object> arguments;
    public Boolean complete;
    public String missingArgument;
    public String resolutionTool;
    public String message;


    public AI_AgentArgumentResult() {

        arguments = new Map<String, Object>();
        complete = false;
        missingArgument = null;
        resolutionTool = null;
        message = null;
    }


    public static AI_AgentArgumentResult completeResult(
        Map<String, Object> arguments
    ) {

        AI_AgentArgumentResult result =
            new AI_AgentArgumentResult();

        if (arguments == null) {
            result.arguments =
                new Map<String, Object>();
        } else {
            result.arguments =
                arguments;
        }

        result.complete = true;
        result.missingArgument = null;
        result.resolutionTool = null;

        result.message =
            'All required tool arguments are available.';

        return result;
    }


    public static AI_AgentArgumentResult missingArgumentResult(
        Map<String, Object> arguments,
        String missingArgument,
        String resolutionTool,
        String message
    ) {

        AI_AgentArgumentResult result =
            new AI_AgentArgumentResult();

        if (arguments == null) {
            result.arguments =
                new Map<String, Object>();
        } else {
            result.arguments =
                arguments;
        }

        result.complete = false;

        result.missingArgument =
            missingArgument;

        result.resolutionTool =
            resolutionTool;

        result.message =
            message;

        return result;
    }
}