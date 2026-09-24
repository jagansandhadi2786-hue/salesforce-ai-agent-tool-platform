@IsTest
private class CustomerServiceTest {

    @TestSetup
    static void setupData() {

        insert new Account(
            Name = 'AI Test Customer',
            Phone = '1234567890',
            Industry = 'Technology'
        );
    }


    @IsTest
    static void testSearchCustomer() {

        Test.startTest();

        List<Account> results =
            CustomerService.searchCustomer(
                'AI Test Customer'
            );

        Test.stopTest();

        System.assertEquals(
            1,
            results.size()
        );

        System.assertEquals(
            'AI Test Customer',
            results[0].Name
        );
    }


    @IsTest
    static void testSearchCustomerBlank() {

        try {

            CustomerService.searchCustomer('');

            System.assert(
                false,
                'Expected AI_ServiceException'
            );

        } catch (AI_ServiceException ex) {

            System.assertEquals(
                'Customer name is required.',
                ex.getMessage()
            );
        }
    }


    @IsTest
    static void testGetCustomerDetails() {

        Account accountRecord = [
            SELECT Id
            FROM Account
            WHERE Name = 'AI Test Customer'
            LIMIT 1
        ];

        Test.startTest();

        Account result =
            CustomerService.getCustomerDetails(
                accountRecord.Id
            );

        Test.stopTest();

        System.assertEquals(
            accountRecord.Id,
            result.Id
        );
    }
}
