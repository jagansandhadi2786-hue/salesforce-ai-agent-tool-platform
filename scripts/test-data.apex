User currentUser = [
    SELECT Id
    FROM User
    WHERE Id = :UserInfo.getUserId()
];

AI_Agent_Session__c session = new AI_Agent_Session__c(
    Name = 'Demo AI Session',
    Session_ID__c = 'SESSION-DEMO-001',
    User__c = currentUser.Id,
    Agent_Name__c = 'Customer Service AI Agent',
    Start_Time__c = System.now(),
    Status__c = 'Active',
    Total_Tokens__c = 0
);

insert session;

AI_Agent_Interaction__c interaction = new AI_Agent_Interaction__c(
    Session__c = session.Id,
    User_Message__c = 'Find Acme Corporation.',
    AI_Response__c = 'I found Acme Corporation.',
    Intent__c = 'SEARCH_CUSTOMER',
    Tool_Name__c = 'search_customer',
    Tool_Input__c = '{"customer_name":"Acme Corporation"}',
    Tool_Output__c = '{"success":true,"customer_count":1}',
    Execution_Status__c = 'Success',
    Execution_Time__c = 125.500
);

insert interaction;