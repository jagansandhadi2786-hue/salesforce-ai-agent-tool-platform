public with sharing class AI_AgentLLMResponseValidator {

    public static void validate(
        AI_AgentLLMResponse response
    ) {

        if (response == null) {

            throw new AI_ServiceException(
                'LLM response is required.'
            );
        }


        if (!response.success) {

            throw new AI_ServiceException(
                String.isBlank(response.errorMessage)
                    ? 'LLM could not interpret the request.'
                    : response.errorMessage
            );
        }


        if (String.isBlank(response.intent)) {

            throw new AI_ServiceException(
                'LLM response did not contain an intent.'
            );
        }


        if (String.isBlank(response.toolName)) {

            throw new AI_ServiceException(
                'LLM response did not contain a tool.'
            );
        }


        if (
            !AI_ToolContractCatalog.isRegistered(
                response.toolName
            )
        ) {

            throw new AI_ServiceException(
                'LLM selected an unregistered tool.'
            );
        }


        AI_ToolContractCatalog.ToolContract contract =
            AI_ToolContractCatalog.getContract(
                response.toolName
            );


        if (
            contract == null ||
            contract.active != true
        ) {

            throw new AI_ServiceException(
                'LLM selected an inactive tool.'
            );
        }
    }
}
