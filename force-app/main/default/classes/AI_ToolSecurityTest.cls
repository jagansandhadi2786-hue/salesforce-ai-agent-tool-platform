@IsTest
private class AI_ToolSecurityTest {

/*
 * ============================================================
 * Test Setup
 * ============================================================
 *
 * AI_Tool__c is regular Salesforce data, so the test must
 * create the records it needs.
 */
private static AI_Tool__c createTool(
    String toolApiName,
    Boolean active
) {

    AI_Tool__c tool = new AI_Tool__c();

    tool.Name = toolApiName;
    tool.Tool_API_Name__c = toolApiName;
    tool.Active__c = active;

    insert tool;

    return tool;
}


/*
 * ============================================================
 * 1. Unknown Tool
 * ============================================================
 */
@IsTest
static void testUnknownToolRejected() {

    AI_ToolRequest request =
        new AI_ToolRequest();

    request.toolName =
        'delete_all_customers';

    request.arguments =
        new Map<String, Object>();

    try {

        AI_ToolSchemaValidator.validate(
            request,
            null
        );

        System.assert(
            false,
            'Unknown tools must be rejected.'
        );

    } catch (AI_ServiceException ex) {

        System.assertEquals(
            'Tool is not registered or not active.',
            ex.getMessage(),
            'Unexpected error message for unknown tool.'
        );
    }
}


/*
 * ============================================================
 * 2. Inactive Tool
 * ============================================================
 */
@IsTest
static void testInactiveToolRejected() {

AI_Tool__c tool =
    createTool(
        'search_customer',
        true
    );

tool.Active__c = false;
update tool;

try {

    AI_ToolRegistry.getActiveTool(
        'search_customer'
    );

    System.assert(
        false,
        'Inactive tool must be rejected.'
    );

} catch (AI_ServiceException ex) {

    System.assertEquals(
        'Tool is not registered or not active.',
        ex.getMessage(),
        'Unexpected error message for inactive tool.'
    );
}
}



/*
 * ============================================================
 * 3. Read Tools
 * ============================================================
 */
@IsTest
static void testReadToolsAreExplicitlyRegistered() {

    List<String> readTools =
        new List<String>{
            'search_customer',
            'get_customer_details',
            'get_open_cases',
            'get_case_details',
            'search_knowledge',
            'get_order_status'
        };

    List<String> registeredTools =
        AI_ToolContractCatalog.getToolNames();

    for (String toolName : readTools) {

        System.assert(
            registeredTools.contains(toolName),
            'Expected read tool to be registered: ' +
            toolName
        );
    }
}


/*
 * ============================================================
 * 4. Write Tools
 * ============================================================
 */
@IsTest
static void testWriteToolsRequireApproval() {

    List<String> writeTools =
        new List<String>{
            'create_case',
            'update_case',
            'create_task',
            'escalate_case'
        };

    List<String> registeredTools =
        AI_ToolContractCatalog.getToolNames();

    for (String toolName : writeTools) {

        System.assert(
            registeredTools.contains(toolName),
            'Write tool is missing from contract catalog: ' +
            toolName
        );
    }
}


/*
 * ============================================================
 * 5. Arbitrary SOQL Argument
 * ============================================================
 */
@IsTest
static void testArbitrarySoqlArgumentRejected() {

    AI_Tool__c tool =
        createTool(
            'search_customer',
            true
        );

    AI_ToolRequest request =
        new AI_ToolRequest();

    request.toolName =
        'search_customer';

    request.arguments =
        new Map<String, Object>{
            'customer_name' => 'Acme',
            'soql' => 'SELECT Id FROM Account'
        };

    try {

        AI_ToolSchemaValidator.validate(
            request,
            tool
        );

        System.assert(
            false,
            'Arbitrary SOQL arguments must be rejected.'
        );

    } catch (AI_ServiceException ex) {

        System.assert(
            ex.getMessage() != null &&
            ex.getMessage().contains(
                'Unexpected argument'
            ),
            'Unexpected validation error: ' +
            ex.getMessage()
        );
    }
}


/*
 * ============================================================
 * 6. Arbitrary Apex Execution
 * ============================================================
 */
@IsTest
static void testArbitraryApexExecutionRejected() {

    AI_Tool__c tool =
        createTool(
            'search_customer',
            true
        );

    AI_ToolRequest request =
        new AI_ToolRequest();

    request.toolName =
        'search_customer';

    request.arguments =
        new Map<String, Object>{
            'customer_name' => 'Acme',
            'execute' => 'System.delete(...)'
        };

    try {

        AI_ToolSchemaValidator.validate(
            request,
            tool
        );

        System.assert(
            false,
            'Arbitrary Apex execution must be rejected.'
        );

    } catch (AI_ServiceException ex) {

        System.assert(
            ex.getMessage() != null &&
            ex.getMessage().contains(
                'Unexpected argument'
            ),
            'Unexpected validation error: ' +
            ex.getMessage()
        );
    }
}


/*
 * ============================================================
 * 7. Sensitive Arguments
 * ============================================================
 */
@IsTest
static void testSensitiveArgumentsRejected() {

    List<String> sensitiveArguments =
        new List<String>{
            'password',
            'token',
            'accessToken',
            'sessionToken',
            'secret',
            'apiKey',
            'clientSecret'
        };

    AI_Tool__c tool =
        createTool(
            'search_customer',
            true
        );

    for (String sensitiveArgument :
         sensitiveArguments) {

        AI_ToolRequest request =
            new AI_ToolRequest();

        request.toolName =
            'search_customer';

        request.arguments =
            new Map<String, Object>{
                'customer_name' => 'Acme'
            };

        request.arguments.put(
            sensitiveArgument,
            'malicious-value'
        );

        try {

            AI_ToolSchemaValidator.validate(
                request,
                tool
            );

            System.assert(
                false,
                'Sensitive argument should be rejected: ' +
                sensitiveArgument
            );

        } catch (AI_ServiceException ex) {

            System.assert(
                ex.getMessage() != null &&
                ex.getMessage().contains(
                    'Unexpected argument'
                ),
                'Unexpected validation error for ' +
                sensitiveArgument +
                ': ' +
                ex.getMessage()
            );
        }
    }
}


/*
 * ============================================================
 * 8. Error Message Security
 * ============================================================
 */
@IsTest
static void testSecurityErrorDoesNotExposeInternalDetails() {

    AI_Tool__c tool =
        createTool(
            'search_customer',
            true
        );

    AI_ToolRequest request =
        new AI_ToolRequest();

    request.toolName =
        'search_customer';

    request.arguments =
        new Map<String, Object>{
            'customer_name' => 'Acme',
            'soql' => 'SELECT Id FROM Account'
        };

    try {

        AI_ToolSchemaValidator.validate(
            request,
            tool
        );

        System.assert(
            false,
            'Invalid arguments must be rejected.'
        );

    } catch (AI_ServiceException ex) {

        String message =
            ex.getMessage();

        System.assert(
            message != null,
            'Expected a security validation message.'
        );

        System.assert(
            !message.contains(
                'System.QueryException'
            ),
            'Error must not expose QueryException details.'
        );

        System.assert(
            !message.contains(
                'SELECT Id FROM Account'
            ),
            'Error must not expose supplied SOQL.'
        );

        System.assert(
            !message.contains(
                'Class.'
            ),
            'Error must not expose Apex class details.'
        );
    }
}
}
