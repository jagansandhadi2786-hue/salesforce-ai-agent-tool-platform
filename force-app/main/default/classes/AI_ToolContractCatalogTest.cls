@IsTest
private class AI_ToolContractCatalogTest {

    @IsTest
    static void testAllTenToolsAreRegistered() {

        List<String> toolNames =
            AI_ToolContractCatalog.getToolNames();

        System.assertEquals(
            10,
            toolNames.size(),
            'Exactly 10 tools should be registered.'
        );

        System.assert(
            toolNames.contains('search_customer')
        );

        System.assert(
            toolNames.contains('get_customer_details')
        );

        System.assert(
            toolNames.contains('get_open_cases')
        );

        System.assert(
            toolNames.contains('get_case_details')
        );

        System.assert(
            toolNames.contains('create_case')
        );

        System.assert(
            toolNames.contains('update_case')
        );

        System.assert(
            toolNames.contains('create_task')
        );

        System.assert(
            toolNames.contains('escalate_case')
        );

        System.assert(
            toolNames.contains('search_knowledge')
        );

        System.assert(
            toolNames.contains('get_order_status')
        );
    }


    @IsTest
    static void testCreateCaseContract() {

        AI_ToolContractCatalog.ToolContract contract =
            AI_ToolContractCatalog.getContract(
                'create_case'
            );

        System.assertNotEquals(
            null,
            contract
        );

        System.assertEquals(
            'create_case',
            contract.toolName
        );

        System.assertEquals(
            'Salesforce',
            contract.toolType
        );

        System.assertEquals(
            true,
            contract.active
        );

        System.assertEquals(
            true,
            contract.requiresApproval
        );

        System.assertEquals(
            4,
            contract.arguments.size()
        );

        System.assert(
            contract.arguments.containsKey('account_id')
        );

        System.assert(
            contract.arguments.containsKey('subject')
        );

        System.assert(
            contract.arguments.containsKey('description')
        );

        System.assert(
            contract.arguments.containsKey('priority')
        );
    }


    @IsTest
    static void testCreateCaseRequiredArguments() {

        List<String> requiredArguments =
            AI_ToolContractCatalog.getRequiredArguments(
                'create_case'
            );

        System.assertEquals(
            3,
            requiredArguments.size()
        );

        System.assert(
            requiredArguments.contains('account_id')
        );

        System.assert(
            requiredArguments.contains('subject')
        );

        System.assert(
            requiredArguments.contains('description')
        );

        System.assert(
            !requiredArguments.contains('priority')
        );
    }


    @IsTest
    static void testPriorityContract() {

        AI_ToolContractCatalog.ArgumentDefinition definition =
            AI_ToolContractCatalog.getArgumentDefinition(
                'create_case',
                'priority'
            );

        System.assertNotEquals(
            null,
            definition
        );

        System.assertEquals(
            'STRING',
            definition.dataType
        );

        System.assertEquals(
            false,
            definition.required
        );

        System.assertEquals(
            3,
            definition.allowedValues.size()
        );

        System.assert(
            definition.allowedValues.contains('Low')
        );

        System.assert(
            definition.allowedValues.contains('Medium')
        );

        System.assert(
            definition.allowedValues.contains('High')
        );
    }


    @IsTest
    static void testArgumentAllowed() {

        System.assertEquals(
            true,
            AI_ToolContractCatalog.isArgumentAllowed(
                'search_customer',
                'customer_name'
            )
        );

        System.assertEquals(
            false,
            AI_ToolContractCatalog.isArgumentAllowed(
                'search_customer',
                'password'
            )
        );
    }


    @IsTest
    static void testUnknownTool() {

        System.assertEquals(
            false,
            AI_ToolContractCatalog.isRegistered(
                'delete_all_customers'
            )
        );

        System.assertEquals(
            null,
            AI_ToolContractCatalog.getContract(
                'delete_all_customers'
            )
        );
    }


    @IsTest
    static void testBlankToolName() {

        System.assertEquals(
            false,
            AI_ToolContractCatalog.isRegistered('')
        );

        System.assertEquals(
            null,
            AI_ToolContractCatalog.getContract('')
        );
    }
}
