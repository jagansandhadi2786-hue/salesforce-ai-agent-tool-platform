@IsTest
public class AI_AgentE2ETestDataFactory {

    public class TestData {

        public Account account;

        public List<Case> cases;

        public List<AI_Tool__c> tools;
    }


    public static TestData createCustomerScenario() {

        TestData data =
            new TestData();


        /*
         * --------------------------------------------------
         * ACCOUNT
         * --------------------------------------------------
         */
        Account account =
            new Account(
                Name = 'Acme'
            );

        insert account;

        data.account =
            account;


        /*
         * --------------------------------------------------
         * CASES
         * --------------------------------------------------
         */
        Case caseOne =
            new Case(
                AccountId = account.Id,
                Subject = 'Acme Case 1',
                Status = 'New',
                Priority = 'Medium'
            );

        Case caseTwo =
            new Case(
                AccountId = account.Id,
                Subject = 'Acme Case 2',
                Status = 'Working',
                Priority = 'High'
            );

        insert new List<Case>{
            caseOne,
            caseTwo
        };

        data.cases =
            new List<Case>{
                caseOne,
                caseTwo
            };


        /*
         * --------------------------------------------------
         * AI TOOL: SEARCH CUSTOMER
         * --------------------------------------------------
         */
        AI_Tool__c searchCustomerTool =
            new AI_Tool__c(
                Name = 'Search Customer',
                Tool_API_Name__c = 'search_customer',
                Description__c =
                    'Search Salesforce customers by name.',
                Active__c = true,
                Requires_Approval__c = false,
                Tool_Type__c = 'Salesforce',
                Handler_Class__c = 'CustomerService'
            );


        /*
         * --------------------------------------------------
         * AI TOOL: GET OPEN CASES
         * --------------------------------------------------
         */
        AI_Tool__c getOpenCasesTool =
            new AI_Tool__c(
                Name = 'Get Open Cases',
                Tool_API_Name__c = 'get_open_cases',
                Description__c =
                    'Retrieve open cases for a Salesforce account.',
                Active__c = true,
                Requires_Approval__c = false,
                Tool_Type__c = 'Salesforce',
                Handler_Class__c = 'CaseService'
            );


        insert new List<AI_Tool__c>{
            searchCustomerTool,
            getOpenCasesTool
        };

        data.tools =
            new List<AI_Tool__c>{
                searchCustomerTool,
                getOpenCasesTool
            };


        return data;
    }
}