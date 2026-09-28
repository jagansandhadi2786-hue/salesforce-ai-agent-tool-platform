AI_Tool__c tool = AI_ToolRegistry.getActiveTool('create_case');

System.debug('=== REGISTRY TEST ===');
System.debug('Tool Id: ' + tool.Id);
System.debug('Tool Name: ' + tool.Name);
System.debug('Tool API Name: ' + tool.Tool_API_Name__c);
System.debug('Active: ' + tool.Active__c);
System.debug('Handler: ' + tool.Handler_Class__c);
