
@IsTest
private class CustomerResponseTest {

    @IsTest
    static void testCustomerResponseFromAccount() {

        Account accountRecord = new Account(
            Name = 'Test Customer',
            Phone = '9876543210',
            Industry = 'Banking',
            BillingCity = 'Hyderabad'
        );

        CustomerResponse response =
            new CustomerResponse(accountRecord);

        System.assertEquals(
            null,
            response.id,
            'ID should be null before the Account is inserted.'
        );

        System.assertEquals(
            'Test Customer',
            response.name
        );

        System.assertEquals(
            '9876543210',
            response.phone
        );

        System.assertEquals(
            'Banking',
            response.industry
        );

        System.assertEquals(
            'Hyderabad',
            response.billingCity
        );
    }


    @IsTest
    static void testCustomerResponseWithNullAccount() {

        CustomerResponse response =
            new CustomerResponse(null);

        System.assertEquals(
            null,
            response.id
        );

        System.assertEquals(
            null,
            response.name
        );

        System.assertEquals(
            null,
            response.phone
        );

        System.assertEquals(
            null,
            response.industry
        );

        System.assertEquals(
            null,
            response.billingCity
        );
    }


    @IsTest
    static void testDefaultConstructor() {

        CustomerResponse response =
            new CustomerResponse();

        System.assertEquals(
            null,
            response.id
        );

        System.assertEquals(
            null,
            response.name
        );

        System.assertEquals(
            null,
            response.phone
        );

        System.assertEquals(
            null,
            response.industry
        );

        System.assertEquals(
            null,
            response.billingCity
        );
    }
}