@IsTest
private class AI_AgentSessionServiceTest {

    @TestSetup
    static void setupData() {

        User currentUser = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        System.assertNotEquals(
            null,
            currentUser.Id
        );
    }


    @IsTest
    static void testCreateSession() {

        Test.startTest();

        AI_Agent_Session__c session =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-001',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            session.Id
        );

        System.assertEquals(
            'TEST-SESSION-001',
            session.Session_ID__c
        );

        System.assertEquals(
            'Customer Service Agent',
            session.Agent_Name__c
        );

        System.assertEquals(
            'Active',
            session.Status__c
        );
    }


    @IsTest
    static void testGetSession() {

        AI_Agent_Session__c createdSession =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-002',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Test.startTest();

        AI_Agent_Session__c retrievedSession =
            AI_AgentSessionService.getSession(
                'TEST-SESSION-002'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            retrievedSession
        );

        System.assertEquals(
            createdSession.Id,
            retrievedSession.Id
        );
    }


    @IsTest
    static void testGetSessionNotFound() {

        Test.startTest();

        AI_Agent_Session__c session =
            AI_AgentSessionService.getSession(
                'DOES-NOT-EXIST'
            );

        Test.stopTest();

        System.assertEquals(
            null,
            session
        );
    }


    @IsTest
    static void testGetOrCreateSession() {

        Test.startTest();

        AI_Agent_Session__c firstSession =
            AI_AgentSessionService.getOrCreateSession(
                'TEST-SESSION-003',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        AI_Agent_Session__c secondSession =
            AI_AgentSessionService.getOrCreateSession(
                'TEST-SESSION-003',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            firstSession
        );

        System.assertEquals(
            firstSession.Id,
            secondSession.Id
        );
    }


    @IsTest
    static void testCreateInteraction() {

        AI_Agent_Session__c session =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-004',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Test.startTest();

        AI_Agent_Interaction__c interaction =
            AI_AgentSessionService.createInteraction(
                session.Id,
                'Find customer Acme'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            interaction.Id
        );

        System.assertEquals(
            session.Id,
            interaction.Session__c
        );

        System.assertEquals(
            'Find customer Acme',
            interaction.User_Message__c
        );

        System.assertEquals(
            'Pending',
            interaction.Execution_Status__c
        );
    }


    @IsTest
    static void testUpdateInteraction() {

        AI_Agent_Session__c session =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-005',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        AI_Agent_Interaction__c interaction =
            AI_AgentSessionService.createInteraction(
                session.Id,
                'Find customer Acme'
            );

        Test.startTest();

        AI_AgentSessionService.updateInteraction(
            interaction.Id,
            'SEARCH_CUSTOMER',
            'search_customer',
            '{"customer_name":"Acme"}',
            '{"name":"Acme"}',
            'I found Acme.',
            'Success',
            125.50,
            null
        );

        Test.stopTest();

        AI_Agent_Interaction__c result = [
            SELECT
                Intent__c,
                Tool_Name__c,
                Tool_Input__c,
                Tool_Output__c,
                AI_Response__c,
                Execution_Status__c,
                Execution_Time__c
            FROM AI_Agent_Interaction__c
            WHERE Id = :interaction.Id
        ];

        System.assertEquals(
            'SEARCH_CUSTOMER',
            result.Intent__c
        );

        System.assertEquals(
            'search_customer',
            result.Tool_Name__c
        );

        System.assertEquals(
            'Success',
            result.Execution_Status__c
        );

        System.assertEquals(
            Decimal.valueOf('125.50'),
            result.Execution_Time__c
        );
    }


    @IsTest
    static void testCompleteSession() {

        AI_Agent_Session__c session =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-006',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Test.startTest();

        AI_AgentSessionService.completeSession(
            session.Id,
            150
        );

        Test.stopTest();

        AI_Agent_Session__c result = [
            SELECT
                Status__c,
                //End_Time__c,
                Total_Tokens__c
            FROM AI_Agent_Session__c
            WHERE Id = :session.Id
        ];

        System.assertEquals(
            'Completed',
            result.Status__c
        );

        // System.assertNotEquals(
        //     null,
        //     result.End_Time__c
        // );

        System.assertEquals(
            Decimal.valueOf('150'),
            result.Total_Tokens__c
        );
    }


    @IsTest
    static void testFailSession() {

        AI_Agent_Session__c session =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-007',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Test.startTest();

        AI_AgentSessionService.failSession(
            session.Id,
            'Test failure'
        );

        Test.stopTest();

        AI_Agent_Session__c result = [
            SELECT
                Status__c
                //End_Time__c
            FROM AI_Agent_Session__c
            WHERE Id = :session.Id
        ];

        System.assertEquals(
            'Failed',
            result.Status__c
        );

        // System.assertNotEquals(
        //     null,
        //     result.End_Time__c
        // );
    }


    @IsTest
    static void testBlankSessionId() {

        Boolean exceptionThrown = false;

        try {

            AI_AgentSessionService.createSession(
                '',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;
        }

        System.assertEquals(
            true,
            exceptionThrown
        );
    }


    @IsTest
    static void testBlankUserMessage() {

        AI_Agent_Session__c session =
            AI_AgentSessionService.createSession(
                'TEST-SESSION-008',
                UserInfo.getUserId(),
                'Customer Service Agent'
            );

        Boolean exceptionThrown = false;

        try {

            AI_AgentSessionService.createInteraction(
                session.Id,
                ''
            );

        } catch (AI_ServiceException ex) {

            exceptionThrown = true;
        }

        System.assertEquals(
            true,
            exceptionThrown
        );
    }
}