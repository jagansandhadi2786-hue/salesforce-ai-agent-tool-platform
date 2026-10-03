public class AI_TelemetryEvent {

    public String eventType;
    public String correlationId;
    public String sessionId;
    public String toolName;
    public String component;
    public String status;
    public Decimal durationMs;
    public String errorCode;
    public String message;
    public Datetime timestamp;

    public AI_TelemetryEvent() {
        timestamp = System.now();
    }
}
