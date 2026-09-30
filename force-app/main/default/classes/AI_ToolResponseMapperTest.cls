@IsTest
private class AI_ToolResponseMapperTest {

    @IsTest
    static void testToCustomerResponse() {

        Account accountRecord = new Account(
            Name = 'Acme Corporation',
            Phone = '1234567890'
        );

        Test.startTest();

        CustomerResponse response =
            AI_ToolResponseMapper.toCustomerResponse(
                accountRecord
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response,
            'Customer response should not be null.'
        );
    }


    @IsTest
    static void testToCustomerResponses() {

        List<Account> accounts =
            new List<Account>{
                new Account(
                    Name = 'Acme Corporation'
                ),
                new Account(
                    Name = 'Global Industries'
                )
            };

        Test.startTest();

        List<CustomerResponse> responses =
            AI_ToolResponseMapper.toCustomerResponses(
                accounts
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            responses,
            'Customer response list should not be null.'
        );

        System.assertEquals(
            2,
            responses.size(),
            'Two customer responses should be created.'
        );
    }


    @IsTest
    static void testToCustomerResponsesWithNull() {

        Test.startTest();

        List<CustomerResponse> responses =
            AI_ToolResponseMapper.toCustomerResponses(
                null
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            responses,
            'Mapper should return an empty list.'
        );

        System.assertEquals(
            0,
            responses.size(),
            'Null input should produce an empty list.'
        );
    }


    @IsTest
    static void testToCaseResponse() {

        Case caseRecord = new Case(
            Subject = 'Login issue',
            Status = 'New',
            Origin = 'Phone'
        );

        Test.startTest();

        CaseResponse response =
            AI_ToolResponseMapper.toCaseResponse(
                caseRecord
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response,
            'Case response should not be null.'
        );
    }


    @IsTest
    static void testToCaseResponses() {

        List<Case> cases =
            new List<Case>{
                new Case(
                    Subject = 'Login issue',
                    Status = 'New',
                    Origin = 'Phone'
                ),
                new Case(
                    Subject = 'Payment issue',
                    Status = 'Working',
                    Origin = 'Email'
                )
            };

        Test.startTest();

        List<CaseResponse> responses =
            AI_ToolResponseMapper.toCaseResponses(
                cases
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            responses,
            'Case response list should not be null.'
        );

        System.assertEquals(
            2,
            responses.size(),
            'Two case responses should be created.'
        );
    }


    @IsTest
    static void testToCaseResponsesWithNull() {

        Test.startTest();

        List<CaseResponse> responses =
            AI_ToolResponseMapper.toCaseResponses(
                null
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            responses,
            'Mapper should return an empty list.'
        );

        System.assertEquals(
            0,
            responses.size(),
            'Null input should produce an empty list.'
        );
    }


    @IsTest
    static void testToTaskResponse() {

        Task taskRecord = new Task(
            Subject = 'Call customer',
            Status = 'Not Started'
        );

        Test.startTest();

        TaskResponse response =
            AI_ToolResponseMapper.toTaskResponse(
                taskRecord
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response,
            'Task response should not be null.'
        );
    }


    @IsTest
    static void testToOrderResponseWithNull() {

        Test.startTest();

        OrderResponse response =
            AI_ToolResponseMapper.toOrderResponse(
                null
            );

        Test.stopTest();

        System.assertEquals(
            null,
            response,
            'Null OrderResult should return null.'
        );
    }
}