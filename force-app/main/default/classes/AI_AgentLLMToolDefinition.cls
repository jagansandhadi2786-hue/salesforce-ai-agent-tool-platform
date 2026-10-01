public class AI_AgentLLMToolDefinition {
    public String name;

    public String description;

    public List<ArgumentDefinition> arguments;

    public AI_AgentLLMToolDefinition() {

        arguments =
            new List<ArgumentDefinition>();
    }

    public class ArgumentDefinition {

        public String name;

        public String dataType;

        public Boolean required;

        public List<String> allowedValues;

        public ArgumentDefinition() {

            allowedValues =
                new List<String>();
        }
    }
}
