public with sharing class AI_AgentToolSelector {

    /*
     * Resolve an Agent intent into a validated
     * Salesforce tool selection.
     */
    public static AI_AgentToolSelection selectTool(
        AI_AgentIntent intent
    ) {

        /*
         * Validate the intent object.
         */
        if (intent == null) {
            throw new AI_ServiceException(
                'Agent intent is required.'
            );
        }

        if (String.isBlank(intent.intentName)) {
            throw new AI_ServiceException(
                'Agent intent name is required.'
            );
        }

        if (String.isBlank(intent.toolName)) {
            throw new AI_ServiceException(
                'Agent tool name is required.'
            );
        }


        String toolName = intent.toolName.trim();


        /*
         * ------------------------------------------------
         * STEP 1
         * Check the Phase 6 contract catalog.
         * ------------------------------------------------
         */
        AI_ToolContractCatalog.ToolContract contract =
            AI_ToolContractCatalog.getContract(toolName);

        if (contract == null) {

            throw new AI_ServiceException(
                'Tool is not registered in the contract catalog: ' +
                toolName
            );
        }


        /*
         * ------------------------------------------------
         * STEP 2
         * Verify the contract is active.
         * ------------------------------------------------
         */
        if (contract.active != true) {

            throw new AI_ServiceException(
                'Tool is inactive in the contract catalog: ' +
                toolName
            );
        }


        /*
         ```apex
/*
 * ------------------------------------------------
 * STEP 3
 * Verify the Salesforce runtime registry.
 *
 * IMPORTANT:
 * We use the existing Phase 6 registry rather
 * than creating a second registry.
 *
 * AI_ToolRegistry.getActiveTool() is the runtime
 * security boundary. It rejects tools that are
 * missing or inactive.
 *
 * The selector translates that lower-level
 * registry error into the selector-specific
 * error message.
 * ------------------------------------------------
 */
AI_Tool__c registeredTool;

try {

    registeredTool =
        AI_ToolRegistry.getActiveTool(toolName);

} catch (AI_ServiceException ex) {

    throw new AI_ServiceException(
        'Tool is not active in the Salesforce registry: ' +
        toolName
    );
}

        /*
         * ------------------------------------------------
         * STEP 4
         * Build the validated selection object.
         * ------------------------------------------------
         */
        AI_AgentToolSelection selection =
            new AI_AgentToolSelection();

        selection.intentName =
            intent.intentName;

        selection.toolName =
            toolName;

        selection.description =
            contract.description;

        selection.toolType =
            contract.toolType;

        selection.contractActive =
            contract.active;

        selection.requiresApproval =
            contract.requiresApproval;

        selection.toolRecordId =
            registeredTool.Id;

        selection.registryActive =
            registeredTool.Active__c;


        /*
         * Final defensive validation.
         */
        if (!selection.isValid()) {

            throw new AI_ServiceException(
                'Selected tool failed validation: ' +
                toolName
            );
        }


        return selection;
    }
}
