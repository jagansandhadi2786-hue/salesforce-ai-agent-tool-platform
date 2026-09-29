@IsTest
private class AI_AgentToolSelectorTest {


    /*
     * Create a Salesforce AI tool registry record.
     */
    private static AI_Tool__c createTool(
        String toolName,
        Boolean active,
        Boolean requiresApproval
    ) {

        AI_Tool__c tool = new AI_Tool__c();

        tool.Name = toolName;
        tool.Tool_API_Name__c = toolName;
        tool.Description__c =
            'Test tool for ' + toolName;
        tool.Tool_Type__c = 'Salesforce';
        tool.Active__c = active;
        tool.Requires_Approval__c =
            requiresApproval;
        tool.Handler_Class__c =
            'TestHandler';

        insert tool;

        return tool;
    }


    /*
     * Build an Agent intent.
     */
    private static AI_AgentIntent buildIntent(
        String intentName,
        String toolName
    ) {

        return new AI_AgentIntent(
            intentName,
            toolName,
            0.95
        );
    }


    /*
     * ----------------------------------------------------
     * VALID TOOL
     * ----------------------------------------------------
     */
    @IsTest
    static void testValidToolSelection() {

        AI_Tool__c tool =
            createTool(
                'get_open_cases',
                true,
                false
            );

        AI_AgentIntent intent =
            buildIntent(
                'GET_OPEN_CASES',
                'get_open_cases'
            );


        Test.startTest();

        AI_AgentToolSelection selection =
            AI_AgentToolSelector.selectTool(
                intent
            );

        Test.stopTest();


        System.assertEquals(
            'GET_OPEN_CASES',
            selection.intentName
        );

        System.assertEquals(
            'get_open_cases',
            selection.toolName
        );

        System.assertEquals(
            true,
            selection.contractActive
        );

        System.assertEquals(
            false,
            selection.requiresApproval
        );

        System.assertEquals(
            tool.Id,
            selection.toolRecordId
        );

        System.assertEquals(
            true,
            selection.registryActive
        );

        System.assertEquals(
            true,
            selection.isValid()
        );
    }


    /*
     * ----------------------------------------------------
     * APPROVAL-REQUIRED TOOL
     * ----------------------------------------------------
     */
    @IsTest
    static void testApprovalRequiredTool() {

        AI_Tool__c tool =
            createTool(
                'create_case',
                true,
                true
            );

        AI_AgentIntent intent =
            buildIntent(
                'CREATE_CASE',
                'create_case'
            );


        AI_AgentToolSelection selection =
            AI_AgentToolSelector.selectTool(
                intent
            );


        System.assertEquals(
            'create_case',
            selection.toolName
        );

        System.assertEquals(
            true,
            selection.requiresApproval
        );

        System.assertEquals(
            tool.Id,
            selection.toolRecordId
        );

        System.assertEquals(
            true,
            selection.isValid()
        );
    }


    /*
     * ----------------------------------------------------
     * NULL INTENT
     * ----------------------------------------------------
     */
    @IsTest
    static void testNullIntent() {

        try {

            AI_AgentToolSelector.selectTool(
                null
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Agent intent is required.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * BLANK INTENT NAME
     * ----------------------------------------------------
     */
    @IsTest
    static void testBlankIntentName() {

        AI_AgentIntent intent =
            buildIntent(
                '',
                'get_open_cases'
            );


        try {

            AI_AgentToolSelector.selectTool(
                intent
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Agent intent name is required.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * BLANK TOOL NAME
     * ----------------------------------------------------
     */
    @IsTest
    static void testBlankToolName() {

        AI_AgentIntent intent =
            buildIntent(
                'GET_OPEN_CASES',
                ''
            );


        try {

            AI_AgentToolSelector.selectTool(
                intent
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Agent tool name is required.',
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * UNKNOWN TOOL
     *
     * The Agent cannot invent arbitrary tools.
     * ----------------------------------------------------
     */
    @IsTest
    static void testUnknownTool() {

        AI_AgentIntent intent =
            buildIntent(
                'UNKNOWN_INTENT',
                'delete_everything'
            );


        try {

            AI_AgentToolSelector.selectTool(
                intent
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Tool is not registered in the contract catalog'
                ),
                'Unexpected error: ' +
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * REGISTERED CONTRACT BUT NO ACTIVE SALESFORCE TOOL
     * ----------------------------------------------------
     */
    @IsTest
    static void testMissingRuntimeRegistryTool() {

        /*
         * We intentionally do NOT create an AI_Tool__c
         * record.
         *
         * The contract exists, but the runtime registry
         * does not contain an active tool.
         */

        AI_AgentIntent intent =
            buildIntent(
                'GET_OPEN_CASES',
                'get_open_cases'
            );


        try {

            AI_AgentToolSelector.selectTool(
                intent
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Tool is not active in the Salesforce registry'
                ),
                'Unexpected error: ' +
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * INACTIVE SALESFORCE TOOL
     * ----------------------------------------------------
     */
    @IsTest
    static void testInactiveRuntimeTool() {

        createTool(
            'get_open_cases',
            false,
            false
        );


        AI_AgentIntent intent =
            buildIntent(
                'GET_OPEN_CASES',
                'get_open_cases'
            );


        try {

            AI_AgentToolSelector.selectTool(
                intent
            );

            System.assert(
                false,
                'Expected AI_ServiceException.'
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Tool is not active in the Salesforce registry'
                ),
                'Unexpected error: ' +
                ex.getMessage()
            );
        }
    }


    /*
     * ----------------------------------------------------
     * CASE-INSENSITIVE TOOL NAME
     * ----------------------------------------------------
     */
    @IsTest
    static void testToolNameTrimmed() {

        AI_Tool__c tool =
            createTool(
                'get_open_cases',
                true,
                false
            );


        AI_AgentIntent intent =
            buildIntent(
                'GET_OPEN_CASES',
                '  get_open_cases  '
            );


        AI_AgentToolSelection selection =
            AI_AgentToolSelector.selectTool(
                intent
            );


        System.assertEquals(
            'get_open_cases',
            selection.toolName
        );

        System.assertEquals(
            tool.Id,
            selection.toolRecordId
        );
    }
}