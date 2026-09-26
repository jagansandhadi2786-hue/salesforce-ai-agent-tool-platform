insert new AI_Tool__c(
    Name = 'Search Customer',
    Tool_API_Name__c = 'search_customer',
    Description__c =
        'Search for a Salesforce customer.',
    Tool_Type__c = 'Salesforce',
    Active__c = true,
    Requires_Approval__c = false,
    Handler_Class__c = 'CustomerService',
    Allowed_Arguments__c =
        'customer_name',
    Required_Arguments__c =
        'customer_name',
    Permission_Name__c =
        'AI_Search_Customer',
    Argument_Schema__c =
        '{"customer_name":{"type":"string"}}'
);
For get_customer_details:
insert new AI_Tool__c(
    Name = 'Get Customer Details',
    Tool_API_Name__c = 'get_customer_details',
    Description__c =
        'Retrieve customer details.',
    Tool_Type__c = 'Salesforce',
    Active__c = true,
    Requires_Approval__c = false,
    Handler_Class__c = 'CustomerService',
    Allowed_Arguments__c =
        'customer_id',
    Required_Arguments__c =
        'customer_id',
    Permission_Name__c =
        'AI_Get_Customer_Details',
    Argument_Schema__c =
        '{"customer_id":{"type":"id"}}'
);
For get_open_cases:
insert new AI_Tool__c(
    Name = 'Get Open Cases',
    Tool_API_Name__c = 'get_open_cases',
    Description__c =
        'Retrieve open cases for a customer.',
    Tool_Type__c = 'Salesforce',
    Active__c = true,
    Requires_Approval__c = false,
    Handler_Class__c = 'CaseService',
    Allowed_Arguments__c =
        'account_id',
    Required_Arguments__c =
        'account_id',
    Permission_Name__c =
        'AI_Get_Open_Cases',
    Argument_Schema__c =
        '{"account_id":{"type":"id"}}'
);
