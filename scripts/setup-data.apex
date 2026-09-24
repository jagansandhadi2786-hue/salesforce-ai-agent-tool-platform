List<AI_Tool__c> tools = new List<AI_Tool__c>{

    new AI_Tool__c(
        Name = 'Search Customer',
        Tool_API_Name__c = 'search_customer',
        Description__c = 'Search for a Salesforce customer by name.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = false,
        Handler_Class__c = 'CustomerService'
    ),

    new AI_Tool__c(
        Name = 'Get Customer Details',
        Tool_API_Name__c = 'get_customer_details',
        Description__c = 'Retrieve detailed information about a Salesforce customer.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = false,
        Handler_Class__c = 'CustomerService'
    ),

    new AI_Tool__c(
        Name = 'Get Open Cases',
        Tool_API_Name__c = 'get_open_cases',
        Description__c = 'Retrieve open cases for a customer.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = false,
        Handler_Class__c = 'CaseService'
    ),

    new AI_Tool__c(
        Name = 'Get Case Details',
        Tool_API_Name__c = 'get_case_details',
        Description__c = 'Retrieve detailed information about a Salesforce case.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = false,
        Handler_Class__c = 'CaseService'
    ),

    new AI_Tool__c(
        Name = 'Create Case',
        Tool_API_Name__c = 'create_case',
        Description__c = 'Create a Salesforce case for a customer.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = true,
        Handler_Class__c = 'CaseService'
    ),

    new AI_Tool__c(
        Name = 'Update Case',
        Tool_API_Name__c = 'update_case',
        Description__c = 'Update an existing Salesforce case.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = true,
        Handler_Class__c = 'CaseService'
    ),

    new AI_Tool__c(
        Name = 'Create Task',
        Tool_API_Name__c = 'create_task',
        Description__c = 'Create a Salesforce follow-up task.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = true,
        Handler_Class__c = 'CaseService'
    ),

    new AI_Tool__c(
        Name = 'Escalate Case',
        Tool_API_Name__c = 'escalate_case',
        Description__c = 'Escalate a Salesforce case according to business rules.',
        Tool_Type__c = 'Salesforce',
        Active__c = true,
        Requires_Approval__c = true,
        Handler_Class__c = 'CaseService'
    ),

    new AI_Tool__c(
        Name = 'Search Knowledge',
        Tool_API_Name__c = 'search_knowledge',
        Description__c = 'Search approved Salesforce knowledge content.',
        Tool_Type__c = 'Knowledge',
        Active__c = true,
        Requires_Approval__c = false,
        Handler_Class__c = 'KnowledgeService'
    ),

    new AI_Tool__c(
        Name = 'Get Order Status',
        Tool_API_Name__c = 'get_order_status',
        Description__c = 'Retrieve order status from an external REST service.',
        Tool_Type__c = 'REST',
        Active__c = true,
        Requires_Approval__c = false,
        Handler_Class__c = 'OrderService'
    )
};

insert tools;