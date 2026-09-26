@IsTest
private class CaseResponseTest {

    @IsTest
    static void testCaseResponseFromCase() {

        Case caseRecord = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Priority = 'High',
            Origin = 'Phone'
        );

        insert caseRecord;

        Case insertedCase = [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Status,
                Priority,
                CreatedDate
            FROM Case
            WHERE Id = :caseRecord.Id
            LIMIT 1
        ];

        CaseResponse response =
            new CaseResponse(insertedCase);

        System.assertEquals(
            String.valueOf(insertedCase.Id),
            response.id
        );

        System.assertEquals(
            insertedCase.CaseNumber,
            response.caseNumber
        );

        System.assertEquals(
            'Test Case',
            response.subject
        );

        System.assertEquals(
            'New',
            response.status
        );

        System.assertEquals(
            'High',
            response.priority
        );

        System.assertEquals(
            insertedCase.CreatedDate,
            response.createdDate
        );
    }


    @IsTest
    static void testCaseResponseWithNullCase() {

        CaseResponse response =
            new CaseResponse(null);

        System.assertEquals(
            null,
            response.id
        );

        System.assertEquals(
            null,
            response.caseNumber
        );

        System.assertEquals(
            null,
            response.subject
        );

        System.assertEquals(
            null,
            response.status
        );

        System.assertEquals(
            null,
            response.priority
        );

        System.assertEquals(
            null,
            response.createdDate
        );
    }


    @IsTest
    static void testDefaultConstructor() {

        CaseResponse response =
            new CaseResponse();

        System.assertEquals(
            null,
            response.id
        );

        System.assertEquals(
            null,
            response.caseNumber
        );

        System.assertEquals(
            null,
            response.subject
        );

        System.assertEquals(
            null,
            response.status
        );

        System.assertEquals(
            null,
            response.priority
        );

        System.assertEquals(
            null,
            response.createdDate
        );
    }
}