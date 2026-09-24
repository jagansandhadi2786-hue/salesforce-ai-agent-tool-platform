System.debug('========================================');
System.debug('SERVICE LAYER SMOKE TEST');
System.debug('========================================');


/*
 * ========================================================
 * 1. CUSTOMER SERVICE - SEARCH CUSTOMER
 * ========================================================
 */

System.debug('--- 1. CustomerService.searchCustomer ---');

List<Account> customers =
    CustomerService.searchCustomer('Test Customer');

System.debug(
    'Customer count: ' + customers.size()
);

for (Account customer : customers) {

    System.debug(
        'Customer => ' +
        'Id=' + customer.Id +
        ', Name=' + customer.Name +
        ', Phone=' + customer.Phone +
        ', Website=' + customer.Website +
        ', Industry=' + customer.Industry +
        ', Type=' + customer.Type +
        ', BillingCity=' + customer.BillingCity +
        ', BillingCountry=' + customer.BillingCountry
    );
}


/*
 * ========================================================
 * 2. CUSTOMER SERVICE - GET CUSTOMER DETAILS
 * ========================================================
 */

if (!customers.isEmpty()) {

    System.debug(
        '--- 2. CustomerService.getCustomerDetails ---'
    );

    Account customerDetails =
        CustomerService.getCustomerDetails(
            customers[0].Id
        );

    System.debug(
        'Customer Details => ' +
        'Id=' + customerDetails.Id +
        ', Name=' + customerDetails.Name +
        ', Phone=' + customerDetails.Phone +
        ', Website=' + customerDetails.Website +
        ', Industry=' + customerDetails.Industry +
        ', Type=' + customerDetails.Type +
        ', BillingCity=' + customerDetails.BillingCity +
        ', BillingCountry=' + customerDetails.BillingCountry
    );
}


/*
 * ========================================================
 * 3. CUSTOMER SERVICE - VALIDATION
 * ========================================================
 */

System.debug(
    '--- 3. CustomerService validation ---'
);

try {

    CustomerService.searchCustomer('');

    System.debug(
        'ERROR: Expected AI_ServiceException was not thrown.'
    );

} catch (AI_ServiceException ex) {

    System.debug(
        'Expected exception: ' + ex.getMessage()
    );
}


try {

    CustomerService.getCustomerDetails(null);

    System.debug(
        'ERROR: Expected AI_ServiceException was not thrown.'
    );

} catch (AI_ServiceException ex) {

    System.debug(
        'Expected exception: ' + ex.getMessage()
    );
}


/*
 * ========================================================
 * 4. FIND TEST CUSTOMER
 * ========================================================
 */

System.debug(
    '--- 4. Find Test Customer ---'
);

List<Account> accounts = [
    SELECT Id, Name
    FROM Account
    WHERE Name = 'Test Customer'
    LIMIT 1
];

if (accounts.isEmpty()) {

    System.debug(
        'NO TEST CUSTOMER FOUND.'
    );

    System.debug(
        'CustomerService smoke tests completed.'
    );

    System.debug(
        'CaseService tests skipped.'
    );

} else {

    Account customerAccount = accounts[0];

    System.debug(
        'Customer Account => ' +
        'Id=' + customerAccount.Id +
        ', Name=' + customerAccount.Name
    );


    /*
     * ====================================================
     * 5. CASE SERVICE - GET OPEN CASES
     * ====================================================
     */

    System.debug(
        '--- 5. CaseService.getOpenCases ---'
    );

    List<Case> openCases =
        CaseService.getOpenCases(
            customerAccount.Id
        );

    System.debug(
        'Open case count: ' +
        openCases.size()
    );

    for (Case caseRecord : openCases) {

        System.debug(
            'Open Case => ' +
            'Id=' + caseRecord.Id +
            ', CaseNumber=' + caseRecord.CaseNumber +
            ', Subject=' + caseRecord.Subject +
            ', Status=' + caseRecord.Status +
            ', Priority=' + caseRecord.Priority +
            ', Origin=' + caseRecord.Origin +
            ', CreatedDate=' + caseRecord.CreatedDate
        );
    }


    /*
     * ====================================================
     * 6. CASE SERVICE - GET CASE DETAILS
     * ====================================================
     */

    if (!openCases.isEmpty()) {

        Case testCase = openCases[0];

        System.debug(
            '--- 6. CaseService.getCaseDetails ---'
        );

        Case caseDetails =
            CaseService.getCaseDetails(
                testCase.Id
            );

        System.debug(
            'Case Details => ' +
            'Id=' + caseDetails.Id +
            ', CaseNumber=' + caseDetails.CaseNumber +
            ', AccountId=' + caseDetails.AccountId +
            ', Subject=' + caseDetails.Subject +
            ', Status=' + caseDetails.Status +
            ', Priority=' + caseDetails.Priority +
            ', Origin=' + caseDetails.Origin +
            ', Reason=' + caseDetails.Reason +
            ', Type=' + caseDetails.Type
        );


        /*
         * =================================================
         * 7. CASE SERVICE - UPDATE CASE
         * =================================================
         */

        System.debug(
            '--- 7. CaseService.updateCase ---'
        );

        Case updatedCase =
            CaseService.updateCase(
                testCase.Id,
                'Working',
                'High',
                'Updated by Service Smoke Test'
            );

        System.debug(
            'Updated Case => ' +
            'Id=' + updatedCase.Id +
            ', Subject=' + updatedCase.Subject +
            ', Status=' + updatedCase.Status +
            ', Priority=' + updatedCase.Priority
        );


        /*
         * =================================================
         * 8. CASE SERVICE - CREATE TASK
         * =================================================
         */

        System.debug(
            '--- 8. CaseService.createTask ---'
        );

        Task createdTask =
            CaseService.createTask(
                testCase.Id,
                'Follow up with customer',
                Date.today().addDays(1)
            );

        System.debug(
            'Created Task => ' +
            'Id=' + createdTask.Id +
            ', Subject=' + createdTask.Subject +
            ', WhatId=' + createdTask.WhatId +
            ', ActivityDate=' + createdTask.ActivityDate +
            ', Status=' + createdTask.Status +
            ', Priority=' + createdTask.Priority
        );


        /*
         * =================================================
         * 9. CASE SERVICE - ESCALATE CASE
         * =================================================
         */

        System.debug(
            '--- 9. CaseService.escalateCase ---'
        );

        Case escalatedCase =
            CaseService.escalateCase(
                testCase.Id
            );

        System.debug(
            'Escalated Case => ' +
            'Id=' + escalatedCase.Id +
            ', Subject=' + escalatedCase.Subject +
            ', Status=' + escalatedCase.Status +
            ', Priority=' + escalatedCase.Priority
        );

    } else {

        System.debug(
            'No open cases found for Test Customer.'
        );

        System.debug(
            'Case details/update/task/escalation tests skipped.'
        );
    }


    /*
     * ====================================================
     * 10. CASE SERVICE - CREATE CASE
     * ====================================================
     */

    System.debug(
        '--- 10. CaseService.createCase ---'
    );

    Case createdCase =
        CaseService.createCase(
            customerAccount.Id,
            'Service Smoke Test Case',
            'Case created by service smoke test.',
            'Medium'
        );

    System.debug(
        'Created Case => ' +
        'Id=' + createdCase.Id +
        ', CaseNumber=' + createdCase.CaseNumber +
        ', Subject=' + createdCase.Subject +
        ', Description=' + createdCase.Description +
        ', Priority=' + createdCase.Priority +
        ', Origin=' + createdCase.Origin
    );
}


/*
 * ========================================================
 * FINAL RESULT
 * ========================================================
 */

System.debug('========================================');
System.debug('SERVICE LAYER SMOKE TEST COMPLETED');
System.debug('========================================');