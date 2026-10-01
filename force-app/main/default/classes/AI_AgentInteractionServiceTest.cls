@IsTest
private class AI_AgentInteractionServiceTest {


    private static AI_Agent_Session__c createSession() {

        return AI_AgentSessionService.createSession(
            'TEST-INTERACTION-001'
        );
    }


    @IsTest
    static void testRecordInteraction() {

        AI_Agent_Session__c sessionRecord =
            createSession();


        Map<String, Object> input =
            new Map<String, Object>{
                'customer_name' => 'Acme'
            };


        Map<String, Object> output =
            new Map<String, Object>{
                'id' => '001TEST',
                'name' => 'Acme'
            };


        Test.startTest();

        AI_Agent_Interaction__c interaction =
            AI_AgentInteractionService.recordInteraction(
                sessionRecord.Id,
                'Find customer Acme',
                'Customer found.',
                'SEARCH_CUSTOMER',
                'search_customer',
                input,
                output,
                'Success',
                85,
                null
            );

        Test.stopTest();


        System.assertNotEquals(
            null,
            interaction
        );

        System.assertNotEquals(
            null,
            interaction.Id
        );


        System.assertEquals(
            sessionRecord.Id,
            interaction.Session__c
        );


        System.assertEquals(
            'SEARCH_CUSTOMER',
            interaction.Intent__c
        );


        System.assertEquals(
            'search_customer',
            interaction.Tool_Name__c
        );


        System.assertEquals(
            'Success',
            interaction.Execution_Status__c
        );


        System.assertEquals(
            85,
            interaction.Execution_Time__c
        );


        System.assert(
            interaction.Tool_Input__c.contains(
                'customer_name'
            )
        );


        System.assert(
            interaction.Tool_Output__c.contains(
                'Acme'
            )
        );
    }
@IsTest
static void testFailedInteraction() {

    AI_Agent_Session__c sessionRecord =
        AI_AgentSessionService.createSession(
            'TEST-ERROR-001'
        );


    Test.startTest();

    AI_Agent_Interaction__c interaction =
        AI_AgentInteractionService.recordInteraction(
            sessionRecord.Id,
            'Find customer Unknown',
            'Request failed.',
            'SEARCH_CUSTOMER',
            'search_customer',
            new Map<String, Object>{
                'customer_name' => 'Unknown'
            },
            null,
            'Failed',
            42,
            'Customer was not found.'
        );

    Test.stopTest();


    System.assertEquals(
        'Failed',
        interaction.Execution_Status__c
    );

    System.assertEquals(
        'Customer was not found.',
        interaction.Error_Message__c
    );
}

}

