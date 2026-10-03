@IsTest
private class AI_TelemetryServiceTest {

    /*
     * =========================================================
     * Event Creation
     * =========================================================
     */
    @IsTest
    static void testEventCreation() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.correlationId = 'AGT-TEST-001';
        event.sessionId = 'SESSION-001';
        event.toolName = 'get_order_status';
        event.eventType = 'TOOL_EXECUTION';
        event.durationMs = 125;
        event.status = 'SUCCESS';
        event.errorCode = null;

        System.assertNotEquals(
            null,
            event,
            'Telemetry event should be created.'
        );

        System.assertEquals(
            'AGT-TEST-001',
            event.correlationId
        );

        System.assertEquals(
            'SESSION-001',
            event.sessionId
        );

        System.assertEquals(
            'get_order_status',
            event.toolName
        );

        System.assertEquals(
            'TOOL_EXECUTION',
            event.eventType
        );

        System.assertEquals(
            125,
            event.durationMs
        );

        System.assertEquals(
            'SUCCESS',
            event.status
        );

        System.assertEquals(
            null,
            event.errorCode
        );
    }


    /*
     * =========================================================
     * Correlation ID
     * =========================================================
     */
    @IsTest
    static void testCorrelationId() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.correlationId =
            AI_CorrelationContext.generateCorrelationId();

        System.assertNotEquals(
            null,
            event.correlationId
        );

        System.assert(
            event.correlationId.startsWith('AGT-'),
            'Correlation ID should start with AGT-.'
        );
    }


    /*
     * =========================================================
     * Session ID
     * =========================================================
     */
    @IsTest
    static void testSessionId() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.sessionId = 'SESSION-12345';

        System.assertEquals(
            'SESSION-12345',
            event.sessionId,
            'Session ID should be preserved.'
        );
    }


    /*
     * =========================================================
     * Tool Name
     * =========================================================
     */
    @IsTest
    static void testToolName() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.toolName = 'get_order_status';

        System.assertEquals(
            'get_order_status',
            event.toolName
        );
    }


    /*
     * =========================================================
     * Event Type
     * =========================================================
     */
    @IsTest
    static void testEventType() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.eventType = 'TOOL_EXECUTION';

        System.assertEquals(
            'TOOL_EXECUTION',
            event.eventType
        );
    }


    /*
     * =========================================================
     * Duration
     * =========================================================
     */
    @IsTest
    static void testDuration() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.durationMs = 850;

        System.assertEquals(
            850,
            event.durationMs,
            'Duration should be captured.'
        );
    }


    /*
     * =========================================================
     * Status
     * =========================================================
     */
    @IsTest
    static void testStatus() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.status = 'FAILED';

        System.assertEquals(
            'FAILED',
            event.status
        );
    }


    /*
     * =========================================================
     * Error Code
     * =========================================================
     */
    @IsTest
    static void testErrorCode() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.status = 'FAILED';
        event.errorCode = 'AI-SEC-001';

        System.assertEquals(
            'AI-SEC-001',
            event.errorCode
        );
    }


    /*
     * =========================================================
     * Null Event
     *
     * Telemetry service should safely handle a null event.
     * =========================================================
     */
    @IsTest
    static void testNullEvent() {

        Test.startTest();

        try {

            AI_TelemetryService.record(null);

            System.assert(
                true,
                'Null telemetry event should be handled safely.'
            );

        } catch (Exception ex) {

            System.assert(
                false,
                'Telemetry service should not fail on null event. ' +
                ex.getMessage()
            );
        }

        Test.stopTest();
    }


    /*
     * =========================================================
     * Sensitive Data Exclusion
     *
     * Telemetry must not contain passwords, tokens,
     * authorization headers, or raw customer-sensitive data.
     * =========================================================
     */
    @IsTest
    static void testSensitiveDataExclusion() {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.correlationId = 'AGT-SEC-001';
        event.sessionId = 'SESSION-SEC-001';
        event.toolName = 'get_order_status';
        event.eventType = 'TOOL_EXECUTION';
        event.durationMs = 200;
        event.status = 'SUCCESS';

        /*
         * Telemetry should contain identifiers and operational
         * metadata only. Do not add:
         *
         * - Password
         * - Access token
         * - Authorization header
         * - API key
         * - Full customer record
         * - Raw prompt
         * - Raw LLM response
         */

        String serializedEvent =
            JSON.serialize(event);

        System.assert(
            !serializedEvent.contains('password'),
            'Telemetry must not contain passwords.'
        );

        System.assert(
            !serializedEvent.contains('access_token'),
            'Telemetry must not contain access tokens.'
        );

        System.assert(
            !serializedEvent.contains('Authorization'),
            'Telemetry must not contain authorization headers.'
        );

        System.assert(
            !serializedEvent.contains('apiKey'),
            'Telemetry must not contain API keys.'
        );
    }
}