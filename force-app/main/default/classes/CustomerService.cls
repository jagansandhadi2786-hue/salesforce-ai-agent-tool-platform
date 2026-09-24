public with sharing class CustomerService {

    // the service respects Salesforce record-sharing rules.
    // Why WITH USER_MODE?
        //This is an important security feature.
        //Instead of treating Apex as having unrestricted database access, 
        //user-mode database operations allow Salesforce's access controls to participate in the query.
    //Get customer details

    public static List<Account> searchCustomer(String customerName) {

        if (String.isBlank(customerName)) {
            throw new AI_ServiceException(
                'Customer name is required.'
            );
        }

        String searchPattern =
            '%' + customerName.trim() + '%';

        return [
            SELECT
                Id,
                Name,
                Phone,
                Website,
                Industry,
                Type,
                BillingCity,
                BillingCountry
            FROM Account
            WHERE Name LIKE :searchPattern
            WITH USER_MODE
            ORDER BY Name
            LIMIT 20
        ];
    }


    public static Account getCustomerDetails(Id customerId) {

        if (customerId == null) {
            throw new AI_ServiceException(
                'Customer ID is required.'
            );
        }

        List<Account> accounts = [
            SELECT
                Id,
                Name,
                Phone,
                Website,
                Industry,
                Type,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry
            FROM Account
            WHERE Id = :customerId
            WITH USER_MODE
            LIMIT 1
        ];

        if (accounts.isEmpty()) {
            throw new AI_ServiceException(
                'Customer was not found or is not accessible.'
            );
        }

        return accounts[0];
    }
}