public with sharing class AI_AgentSessionService {

    public static final String DEFAULT_AGENT_NAME =
        'AI Customer Service Agent';


    /**
     * Creates a new agent session for the current user.
     *
     * If requestedSessionId is blank, a unique session ID
     * is generated automatically.
     */
    public static AI_Agent_Session__c createSession(
        String requestedSessionId
    ) {

        String sessionId =
            String.isBlank(requestedSessionId)
            ? generateSessionId()
            : requestedSessionId.trim();

        AI_Agent_Session__c sessionRecord =
            new AI_Agent_Session__c();

        sessionRecord.Session_ID__c =
            sessionId;

        sessionRecord.User__c =
            UserInfo.getUserId();

        sessionRecord.Agent_Name__c =
            DEFAULT_AGENT_NAME;

        sessionRecord.Start_Time__c =
            System.now();

        sessionRecord.Status__c =
            'Active';

        sessionRecord.Total_Tokens__c =
            0;

        insert as user sessionRecord;

        return sessionRecord;
    }


    /**
     * Backward-compatible createSession method.
     *
     * Retained because existing callers/tests may provide
     * user ID and agent name explicitly.
     */
    public static AI_Agent_Session__c createSession(
        String sessionId,
        Id userId,
        String agentName
    ) {

        if (String.isBlank(sessionId)) {
            throw new AI_ServiceException(
                'Session ID is required.'
            );
        }

        if (userId == null) {
            throw new AI_ServiceException(
                'User ID is required.'
            );
        }

        if (String.isBlank(agentName)) {
            agentName =
                DEFAULT_AGENT_NAME;
        }

        AI_Agent_Session__c sessionRecord =
            new AI_Agent_Session__c();

        sessionRecord.Session_ID__c =
            sessionId.trim();

        sessionRecord.User__c =
            userId;

        sessionRecord.Agent_Name__c =
            agentName;

        sessionRecord.Start_Time__c =
            System.now();

        sessionRecord.Status__c =
            'Active';

        sessionRecord.Total_Tokens__c =
            0;

        insert as user sessionRecord;

        return sessionRecord;
    }


    /**
     * Finds an existing session for the current user.
     */
    public static AI_Agent_Session__c getSession(
        String sessionId
    ) {

        if (String.isBlank(sessionId)) {
            return null;
        }

        List<AI_Agent_Session__c> sessions = [
            SELECT
                Id,
                Session_ID__c,
                User__c,
                Agent_Name__c,
                Start_Time__c,
                Status__c,
                Total_Tokens__c
            FROM AI_Agent_Session__c
            WHERE Session_ID__c = :sessionId
            AND User__c = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT 1
        ];

        if (sessions.isEmpty()) {
            return null;
        }

        return sessions[0];
    }


    /**
     * Gets an existing session or creates one.
     */
    public static AI_Agent_Session__c getOrCreateSession(
        String sessionId
    ) {

        AI_Agent_Session__c existingSession =
            getSession(sessionId);

        if (existingSession != null) {
            return existingSession;
        }

        return createSession(sessionId);
    }


    /**
     * Backward-compatible getOrCreateSession method.
     */
    public static AI_Agent_Session__c getOrCreateSession(
        String sessionId,
        Id userId,
        String agentName
    ) {

        AI_Agent_Session__c existingSession =
            getSession(sessionId);

        if (existingSession != null) {
            return existingSession;
        }

        return createSession(
            sessionId,
            userId,
            agentName
        );
    }


    /**
     * Creates an interaction for a user message.
     */
    public static AI_Agent_Interaction__c createInteraction(
        Id sessionId,
        String userMessage
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
            userMessage;

        interaction.Execution_Status__c =
            'Pending';

        insert as user interaction;

        return interaction;
    }


    /**
     * Updates interaction with agent processing details.
     */
    public static void updateInteraction(
        Id interactionId,
        String intent,
        String toolName,
        String toolInput,
        String toolOutput,
        String aiResponse,
        String executionStatus,
        Decimal executionTime,
        String errorMessage
    ) {

        if (interactionId == null) {
            throw new AI_ServiceException(
                'Interaction ID is required.'
            );
        }

        AI_Agent_Interaction__c interaction =
            new AI_Agent_Interaction__c(
                Id = interactionId
            );

        if (intent != null) {
            interaction.Intent__c =
                intent;
        }

        if (toolName != null) {
            interaction.Tool_Name__c =
                toolName;
        }

        if (toolInput != null) {
            interaction.Tool_Input__c =
                toolInput;
        }

        if (toolOutput != null) {
            interaction.Tool_Output__c =
                toolOutput;
        }

        if (aiResponse != null) {
            interaction.AI_Response__c =
                aiResponse;
        }

        if (executionStatus != null) {
            interaction.Execution_Status__c =
                executionStatus;
        }

        if (executionTime != null) {
            interaction.Execution_Time__c =
                executionTime;
        }

        if (errorMessage != null) {
            interaction.Error_Message__c =
                errorMessage;
        }

        update as user interaction;
    }


    /**
     * Completes the session.
     *
     * End_Time__c is intentionally not used because
     * AI_Agent_Session__c does not contain that field.
     */
    public static void completeSession(
        Id sessionId,
        Decimal totalTokens
    ) {

        if (sessionId == null) {
            throw new AI_ServiceException(
                'Session ID is required.'
            );
        }

        AI_Agent_Session__c sessionRecord =
            new AI_Agent_Session__c(
                Id = sessionId
            );

        sessionRecord.Status__c =
            'Completed';

        if (totalTokens != null) {
            sessionRecord.Total_Tokens__c =
                totalTokens;
        }

        update as user sessionRecord;
    }


    /**
     * Marks the session as failed.
     *
     * errorMessage is retained for API compatibility.
     * The current session object does not contain an
     * Error_Message__c field.
     */
    public static void failSession(
        Id sessionId,
        String errorMessage
    ) {

        if (sessionId == null) {
            throw new AI_ServiceException(
                'Session ID is required.'
            );
        }

        AI_Agent_Session__c sessionRecord =
            new AI_Agent_Session__c(
                Id = sessionId
            );

        sessionRecord.Status__c =
            'Failed';

        update as user sessionRecord;
    }


    /**
     * Generates a unique session identifier.
     */
    private static String generateSessionId() {

        return 'AI-SESSION-' +
            String.valueOf(
                Datetime.now().getTime()
            ) +
            '-' +
            String.valueOf(
                Math.abs(
                    Crypto.getRandomLong()
                )
            );
    }
}