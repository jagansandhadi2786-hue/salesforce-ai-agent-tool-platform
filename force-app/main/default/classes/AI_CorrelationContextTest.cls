@IsTest
private class AI_CorrelationContextTest {

    /*
     * =========================================================
     * 1. ID Generation
     * =========================================================
     */
    @IsTest
    static void testGenerateCorrelationId() {

        String id1 =
            AI_CorrelationContext.generateCorrelationId();

        String id2 =
            AI_CorrelationContext.generateCorrelationId();

        System.assertNotEquals(
            null,
            id1,
            'Correlation ID should not be null.'
        );

        System.assertNotEquals(
            null,
            id2,
            'Correlation ID should not be null.'
        );

        System.assert(
            !String.isBlank(id1),
            'Correlation ID should not be blank.'
        );

        System.assert(
            !String.isBlank(id2),
            'Correlation ID should not be blank.'
        );

        System.assert(
            id1.startsWith('AGT-'),
            'Correlation ID should start with AGT-.'
        );

        System.assert(
            id2.startsWith('AGT-'),
            'Correlation ID should start with AGT-.'
        );

        System.assertNotEquals(
            id1,
            id2,
            'Generated correlation IDs should be unique.'
        );
    }


    /*
     * =========================================================
     * 2. Multiple IDs Are Unique
     * =========================================================
     */
    @IsTest
    static void testCorrelationIdsAreUnique() {

        Set<String> ids =
            new Set<String>();

        for (Integer i = 0; i < 100; i++) {

            String correlationId =
                AI_CorrelationContext.generateCorrelationId();

            ids.add(correlationId);
        }

        System.assertEquals(
            100,
            ids.size(),
            'All generated correlation IDs should be unique.'
        );
    }


    /*
     * =========================================================
     * 3. Session ID Preserved
     * =========================================================
     */
    @IsTest
    static void testSessionIdPreserved() {

        String correlationId =
            AI_CorrelationContext.generateCorrelationId();

        String sessionId =
            'SESSION-TEST-001';

        Id userId =
            UserInfo.getUserId();

        AI_CorrelationContext context =
            new AI_CorrelationContext(
                correlationId,
                sessionId,
                userId
            );

        System.assertEquals(
            correlationId,
            context.correlationId,
            'Correlation ID should be preserved.'
        );

        System.assertEquals(
            sessionId,
            context.sessionId,
            'Session ID should be preserved.'
        );
    }


    /*
     * =========================================================
     * 4. User ID Preserved
     * =========================================================
     */
    @IsTest
    static void testUserIdPreserved() {

        String correlationId =
            AI_CorrelationContext.generateCorrelationId();

        String sessionId =
            'SESSION-USER-001';

        Id userId =
            UserInfo.getUserId();

        AI_CorrelationContext context =
            new AI_CorrelationContext(
                correlationId,
                sessionId,
                userId
            );

        System.assertEquals(
            userId,
            context.userId,
            'User ID should be preserved.'
        );

        System.assertEquals(
            correlationId,
            context.correlationId,
            'Correlation ID should be preserved.'
        );

        System.assertEquals(
            sessionId,
            context.sessionId,
            'Session ID should be preserved.'
        );
    }


    /*
     * =========================================================
     * 5. Correlation Context Contains All Values
     * =========================================================
     */
    @IsTest
    static void testContextContainsAllValues() {

        String correlationId =
            AI_CorrelationContext.generateCorrelationId();

        String sessionId =
            'SESSION-CONTEXT-001';

        Id userId =
            UserInfo.getUserId();

        AI_CorrelationContext context =
            new AI_CorrelationContext(
                correlationId,
                sessionId,
                userId
            );

        System.assertNotEquals(
            null,
            context,
            'Context should be created.'
        );

        System.assertNotEquals(
            null,
            context.correlationId,
            'Correlation ID should not be null.'
        );

        System.assert(
            !String.isBlank(context.correlationId),
            'Correlation ID should not be blank.'
        );

        System.assert(
            context.correlationId.startsWith('AGT-'),
            'Correlation ID should start with AGT-.'
        );

        System.assertEquals(
            correlationId,
            context.correlationId
        );

        System.assertEquals(
            sessionId,
            context.sessionId
        );

        System.assertEquals(
            userId,
            context.userId
        );
    }


    /*
     * =========================================================
     * 6. Default Constructor
     * =========================================================
     */
    @IsTest
    static void testDefaultConstructor() {

        AI_CorrelationContext context =
            new AI_CorrelationContext();

        System.assertNotEquals(
            null,
            context,
            'Default constructor should create a context.'
        );

        System.assertEquals(
            null,
            context.correlationId,
            'Default correlation ID should be null.'
        );

        System.assertEquals(
            null,
            context.sessionId,
            'Default session ID should be null.'
        );

        System.assertEquals(
            null,
            context.userId,
            'Default user ID should be null.'
        );
    }
}