public with sharing class AI_TelemetryService {

    public static void record(
        AI_TelemetryEvent event
    ) {

        if (event == null) {
            return;
        }

        /*
         * Central telemetry entry point.
         *
         * Production implementation can publish
         * Platform Events and/or persist selected
         * audit information.
         */
    }


    public static AI_TelemetryEvent createEvent(
        String eventType,
        String correlationId,
        String sessionId,
        String component
    ) {

        AI_TelemetryEvent event =
            new AI_TelemetryEvent();

        event.eventType =
            eventType;

        event.correlationId =
            correlationId;

        event.sessionId =
            sessionId;

        event.component =
            component;

        return event;
    }
}
