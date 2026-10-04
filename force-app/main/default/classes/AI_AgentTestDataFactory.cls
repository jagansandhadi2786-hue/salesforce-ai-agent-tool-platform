@IsTest
public class AI_AgentTestDataFactory {

    public static Account createAccount(
        String accountName
    ) {
        Account accountRecord =
            new Account(
                Name = accountName,
                Phone = '9999999999',
                Industry = 'Technology'
            );

        insert accountRecord;

        return accountRecord;
    }


    public static Case createCase(
        Id accountId,
        String subject,
        String status,
        String priority
    ) {
        Case caseRecord =
            new Case(
                AccountId = accountId,
                Subject = subject,
                Description = 'Automated test case',
                Status = status,
                Priority = priority,
                Origin = 'Web'
            );

        insert caseRecord;

        return caseRecord;
    }
}
