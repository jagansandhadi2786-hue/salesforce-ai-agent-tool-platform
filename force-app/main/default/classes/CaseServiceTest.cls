@IsTest
private class CaseServiceTest {

    @TestSetup
    static void setupData() {

        Account accountRecord = new Account(
            Name = 'AI Case Test Customer'
        );

        insert accountRecord;

        insert new Case(
            AccountId = accountRecord.Id,
            Subject = 'Payment Failure',
            Description = 'Customer payment failed.',
            Status = 'New',
            Priority = 'Medium',
            Origin = 'Web'
        );
    }


    @IsTest
    static void testGetOpenCases() {

        Account accountRecord = [
            SELECT Id
            FROM Account
            WHERE Name = 'AI Case Test Customer'
            LIMIT 1
        ];

        Test.startTest();

        List<Case> results =
            CaseService.getOpenCases(
                accountRecord.Id
            );

        Test.stopTest();

        System.assertEquals(
            1,
            results.size()
        );
    }


    @IsTest
    static void testCreateCase() {

        Account accountRecord = [
            SELECT Id
            FROM Account
            WHERE Name = 'AI Case Test Customer'
            LIMIT 1
        ];

        Test.startTest();

        Case result =
            CaseService.createCase(
                accountRecord.Id,
                'AI Created Case',
                'Created through AI service test.',
                'High'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            result.Id
        );

        System.assertEquals(
            'High',
            result.Priority
        );
    }


    @IsTest
    static void testCreateCaseInvalidPriority() {

        Account accountRecord = [
            SELECT Id
            FROM Account
            WHERE Name = 'AI Case Test Customer'
            LIMIT 1
        ];

        try {

            CaseService.createCase(
                accountRecord.Id,
                'Invalid Case',
                'Testing invalid priority.',
                'Urgent'
            );

            System.assert(
                false,
                'Expected exception'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Invalid priority.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testUpdateCase() {

        Case caseRecord = [
            SELECT Id
            FROM Case
            WHERE Subject = 'Payment Failure'
            LIMIT 1
        ];

        Test.startTest();

        Case result =
            CaseService.updateCase(
                caseRecord.Id,
                'Working',
                'High',
                'Payment Failure - Updated'
            );

        Test.stopTest();

        System.assertEquals(
            'Working',
            result.Status
        );

        System.assertEquals(
            'High',
            result.Priority
        );
    }


    @IsTest
    static void testEscalateCase() {

        Case caseRecord = [
            SELECT Id
            FROM Case
            WHERE Subject = 'Payment Failure'
            LIMIT 1
        ];

        Test.startTest();

        Case result =
            CaseService.escalateCase(
                caseRecord.Id
            );

        Test.stopTest();

        System.assertEquals(
            'High',
            result.Priority
        );
    }
}