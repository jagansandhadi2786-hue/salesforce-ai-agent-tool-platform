public with sharing class AI_ToolContractCatalog {

    public class ArgumentDefinition {
        public String name;
        public String dataType;
        public Boolean required;
        public List<String> allowedValues;

        public ArgumentDefinition(
            String name,
            String dataType,
            Boolean required
        ) {
            this.name = name;
            this.dataType = dataType;
            this.required = required;
            this.allowedValues = new List<String>();
        }

        public ArgumentDefinition(
            String name,
            String dataType,
            Boolean required,
            List<String> allowedValues
        ) {
            this.name = name;
            this.dataType = dataType;
            this.required = required;
            this.allowedValues = allowedValues == null
                ? new List<String>()
                : allowedValues;
        }
    }


    public class ToolContract {
        public String toolName;
        public String description;
        public String toolType;
        public Boolean active;
        public Boolean requiresApproval;
        public Map<String, ArgumentDefinition> arguments;

        public ToolContract(
            String toolName,
            String description,
            String toolType,
            Boolean active,
            Boolean requiresApproval
        ) {
            this.toolName = toolName;
            this.description = description;
            this.toolType = toolType;
            this.active = active;
            this.requiresApproval = requiresApproval;
            this.arguments = new Map<String, ArgumentDefinition>();
        }

        public ToolContract addArgument(ArgumentDefinition argumentDefinition) {
            if (argumentDefinition != null) {
                arguments.put(argumentDefinition.name, argumentDefinition);
            }

            return this;
        }
    }


    private static final Map<String, ToolContract> CONTRACTS =
        buildContracts();


    private static Map<String, ToolContract> buildContracts() {

        Map<String, ToolContract> contracts =
            new Map<String, ToolContract>();


        // ============================================================
        // 1. SEARCH CUSTOMER
        // ============================================================

        contracts.put(
            'search_customer',
            new ToolContract(
                'search_customer',
                'Search Salesforce customers by customer name.',
                'Salesforce',
                true,
                false
            )
            .addArgument(
                new ArgumentDefinition(
                    'customer_name',
                    'STRING',
                    true
                )
            )
        );


        // ============================================================
        // 2. GET CUSTOMER DETAILS
        // ============================================================

        contracts.put(
            'get_customer_details',
            new ToolContract(
                'get_customer_details',
                'Retrieve customer details using a Salesforce Account ID.',
                'Salesforce',
                true,
                false
            )
            .addArgument(
                new ArgumentDefinition(
                    'customer_id',
                    'ID',
                    true
                )
            )
        );


        // ============================================================
        // 3. GET OPEN CASES
        // ============================================================

        contracts.put(
            'get_open_cases',
            new ToolContract(
                'get_open_cases',
                'Retrieve open customer cases for a Salesforce Account.',
                'Salesforce',
                true,
                false
            )
            .addArgument(
                new ArgumentDefinition(
                    'account_id',
                    'ID',
                    true
                )
            )
        );


        // ============================================================
        // 4. GET CASE DETAILS
        // ============================================================

        contracts.put(
            'get_case_details',
            new ToolContract(
                'get_case_details',
                'Retrieve details for a Salesforce Case.',
                'Salesforce',
                true,
                false
            )
            .addArgument(
                new ArgumentDefinition(
                    'case_id',
                    'ID',
                    true
                )
            )
        );


        // ============================================================
        // 5. CREATE CASE
        // ============================================================

        contracts.put(
            'create_case',
            new ToolContract(
                'create_case',
                'Create a new Salesforce customer service case.',
                'Salesforce',
                true,
                true
            )
            .addArgument(
                new ArgumentDefinition(
                    'account_id',
                    'ID',
                    true
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'subject',
                    'STRING',
                    true
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'description',
                    'STRING',
                    true
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'priority',
                    'STRING',
                    false,
                    new List<String>{
                        'Low',
                        'Medium',
                        'High'
                    }
                )
            )
        );


        // ============================================================
        // 6. UPDATE CASE
        // ============================================================

        contracts.put(
            'update_case',
            new ToolContract(
                'update_case',
                'Update selected fields on an existing Salesforce Case.',
                'Salesforce',
                true,
                true
            )
            .addArgument(
                new ArgumentDefinition(
                    'case_id',
                    'ID',
                    true
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'status',
                    'STRING',
                    false
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'priority',
                    'STRING',
                    false,
                    new List<String>{
                        'Low',
                        'Medium',
                        'High'
                    }
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'subject',
                    'STRING',
                    false
                )
            )
        );


        // ============================================================
        // 7. CREATE TASK
        // ============================================================

        contracts.put(
            'create_task',
            new ToolContract(
                'create_task',
                'Create a Salesforce follow-up task associated with a record.',
                'Salesforce',
                true,
                true
            )
            .addArgument(
                new ArgumentDefinition(
                    'what_id',
                    'ID',
                    true
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'subject',
                    'STRING',
                    true
                )
            )
            .addArgument(
                new ArgumentDefinition(
                    'due_date',
                    'DATE',
                    false
                )
            )
        );


        // ============================================================
        // 8. ESCALATE CASE
        // ============================================================

        contracts.put(
            'escalate_case',
            new ToolContract(
                'escalate_case',
                'Escalate a Salesforce Case by applying the escalation business rules.',
                'Salesforce',
                true,
                true
            )
            .addArgument(
                new ArgumentDefinition(
                    'case_id',
                    'ID',
                    true
                )
            )
        );


        // ============================================================
        // 9. SEARCH KNOWLEDGE
        // ============================================================

        contracts.put(
            'search_knowledge',
            new ToolContract(
                'search_knowledge',
                'Search approved customer knowledge content.',
                'Knowledge',
                true,
                false
            )
            .addArgument(
                new ArgumentDefinition(
                    'search_term',
                    'STRING',
                    true
                )
            )
        );


        // ============================================================
        // 10. GET ORDER STATUS
        // ============================================================

        contracts.put(
            'get_order_status',
            new ToolContract(
                'get_order_status',
                'Retrieve order status from the order-management integration.',
                'REST',
                true,
                false
            )
            .addArgument(
                new ArgumentDefinition(
                    'order_number',
                    'STRING',
                    true
                )
            )
        );


        return contracts;
    }


    // ================================================================
    // PUBLIC API
    // ================================================================

    public static ToolContract getContract(String toolName) {

        if (String.isBlank(toolName)) {
            return null;
        }

        return CONTRACTS.get(toolName.trim());
    }


    public static Boolean isRegistered(String toolName) {

        return !String.isBlank(toolName)
            && CONTRACTS.containsKey(toolName.trim());
    }


    public static List<String> getToolNames() {

        List<String> toolNames =
            new List<String>();

        toolNames.addAll(CONTRACTS.keySet());
        toolNames.sort();

        return toolNames;
    }


    public static List<String> getRequiredArguments(String toolName) {

        List<String> requiredArguments =
            new List<String>();

        ToolContract contract =
            getContract(toolName);

        if (contract == null) {
            return requiredArguments;
        }

        for (ArgumentDefinition definition :
             contract.arguments.values()) {

            if (definition.required) {
                requiredArguments.add(definition.name);
            }
        }

        requiredArguments.sort();

        return requiredArguments;
    }


    public static List<String> getAllowedArguments(String toolName) {

        List<String> allowedArguments =
            new List<String>();

        ToolContract contract =
            getContract(toolName);

        if (contract == null) {
            return allowedArguments;
        }

        allowedArguments.addAll(
            contract.arguments.keySet()
        );

        allowedArguments.sort();

        return allowedArguments;
    }


    public static Boolean isArgumentAllowed(
        String toolName,
        String argumentName
    ) {

        ToolContract contract =
            getContract(toolName);

        if (contract == null || String.isBlank(argumentName)) {
            return false;
        }

        return contract.arguments.containsKey(
            argumentName.trim()
        );
    }


    public static ArgumentDefinition getArgumentDefinition(
        String toolName,
        String argumentName
    ) {

        ToolContract contract =
            getContract(toolName);

        if (
            contract == null ||
            String.isBlank(argumentName)
        ) {
            return null;
        }

        return contract.arguments.get(
            argumentName.trim()
        );
    }
}