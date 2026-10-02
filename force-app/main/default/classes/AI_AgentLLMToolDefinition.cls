public class AI_AgentLLMToolDefinition {

    public String type;
    public String name;
    public String description;
    public Map<String, Object> parameters;

    // Backward compatibility with existing tool-contract code
    public List<ArgumentDefinition> arguments;

    public AI_AgentLLMToolDefinition() {
        this.type = 'function';
        this.arguments = new List<ArgumentDefinition>();
    }

    public AI_AgentLLMToolDefinition(
        String name,
        String description,
        Map<String, Object> parameters
    ) {
        this.type = 'function';
        this.name = name;
        this.description = description;
        this.parameters = parameters;
        this.arguments = new List<ArgumentDefinition>();
    }

    public class ArgumentDefinition {

        public String name;
        public String dataType;
        public Boolean required;
        public List<String> allowedValues;

        public ArgumentDefinition() {
            this.allowedValues = new List<String>();
        }

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
    }
}