@IsTest
private class AI_AgentLLMToolDefinitionBuilderTest {

    @IsTest
    static void testBuildSearchCustomer() {

        AI_AgentLLMToolDefinition definition =
            AI_AgentLLMToolDefinitionBuilder.build(
                'search_customer'
            );

        System.assertNotEquals(
            null,
            definition,
            'search_customer definition should be created.'
        );

        System.assertEquals(
            'function',
            definition.type,
            'Tool definition type should be function.'
        );

        System.assertEquals(
            'search_customer',
            definition.name,
            'Tool name should match.'
        );

        System.assertEquals(
            'object',
            (String) definition.parameters.get('type'),
            'Parameters type should be object.'
        );

        Map<String, Object> properties =
            (Map<String, Object>)
                definition.parameters.get('properties');

        System.assert(
            properties.containsKey('customer_name'),
            'customer_name should be defined as a tool argument.'
        );
    }


    @IsTest
    static void testUnknownToolReturnsNull() {

        AI_AgentLLMToolDefinition definition =
            AI_AgentLLMToolDefinitionBuilder.build(
                'execute_soql'
            );

        System.assertEquals(
            null,
            definition,
            'Unknown tools must return null.'
        );
    }


    @IsTest
    static void testBlankToolReturnsNull() {

        AI_AgentLLMToolDefinition definition =
            AI_AgentLLMToolDefinitionBuilder.build(
                ''
            );

        System.assertEquals(
            null,
            definition,
            'Blank tool names must return null.'
        );
    }


    @IsTest
    static void testNullToolReturnsNull() {

        AI_AgentLLMToolDefinition definition =
            AI_AgentLLMToolDefinitionBuilder.build(
                null
            );

        System.assertEquals(
            null,
            definition,
            'Null tool names must return null.'
        );
    }


    @IsTest
    static void testBuildAll() {

        List<AI_AgentLLMToolDefinition> definitions =
            AI_AgentLLMToolDefinitionBuilder.buildAll();

        System.assertNotEquals(
            null,
            definitions,
            'buildAll() should never return null.'
        );

        System.assert(
            definitions.size() > 0,
            'At least one registered tool should be returned.'
        );
    }
}