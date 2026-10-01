public with sharing class AI_AgentInteractionService {

    /**
     * Records one Agent/tool interaction.
     */
    public static AI_Agent_Interaction__c recordInteraction(
        Id sessionId,
        String userMessage,
        String aiResponse,
        String intent,
        String toolName,
        Object toolInput,
        Object toolOutput,
        String executionStatus,
        Decimal executionTime,
        String errorMessage
    ) {

        if (sessionId == null) {
            throw new AI_ServiceException(
                'Session record ID is required.'
            );
        }

        if (String.isBlank(userMessage)) {
            throw new AI_ServiceException(
                'User message is required.'
            );
        }

        AI_Agent_Interaction__c interaction =
            new AI_Agent_Interaction__c();

        interaction.Session__c =
            sessionId;

        interaction.User_Message__c =
            truncate(userMessage, 32000);

        interaction.AI_Response__c =
            truncate(aiResponse, 32000);

        interaction.Intent__c =
            truncate(intent, 100);

        interaction.Tool_Name__c =
            truncate(toolName, 100);

        interaction.Tool_Input__c =
            serializeValue(
                toolInput,
                32000
            );

        interaction.Tool_Output__c =
            serializeValue(
                toolOutput,
                32000
            );

        interaction.Execution_Status__c =
            truncate(
                executionStatus,
                100
            );

        interaction.Execution_Time__c =
            executionTime;
        interaction.Error_Message__c =
        truncate(
        errorMessage,
        32000
    );

        /*
         * Error_Message__c is intentionally not populated.
         *
         * The current AI_Agent_Interaction__c object does not
         * contain an Error_Message__c field.
         *
         * errorMessage remains part of the method signature for
         * API compatibility and future schema enhancement.
         */

        insert as user interaction;

        return interaction;
    }


    /**
     * Serializes an arbitrary Apex value into JSON.
     */
    private static String serializeValue(
        Object value,
        Integer maxLength
    ) {

        if (value == null) {
            return null;
        }

        String serialized;

        try {
            serialized =
                JSON.serialize(value);

        } catch (Exception ex) {

            serialized =
                String.valueOf(value);
        }

        return truncate(
            serialized,
            maxLength
        );
    }


    /**
     * Prevents long text values from exceeding
     * the application's configured storage limit.
     */
    private static String truncate(
        String value,
        Integer maxLength
    ) {

        if (String.isBlank(value)) {
            return value;
        }

        if (value.length() <= maxLength) {
            return value;
        }

        return value.substring(
            0,
            maxLength
        );
    }
}