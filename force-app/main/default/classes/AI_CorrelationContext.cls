public class AI_CorrelationContext {

    public String correlationId;
    public String sessionId;
    public Id userId;

    public AI_CorrelationContext() {
    }

    public AI_CorrelationContext(
        String correlationId,
        String sessionId,
        Id userId
    ) {
        this.correlationId = correlationId;
        this.sessionId = sessionId;
        this.userId = userId;
    }

    public static String generateCorrelationId() {

        String timestamp =
            Datetime.now()
                .formatGMT('yyyyMMddHHmmss');

        String randomPart =
            EncodingUtil.convertToHex(
                Crypto.generateAesKey(128)
            ).substring(0, 8);

        return
            'AGT-' +
            timestamp +
            '-' +
            randomPart;
    }
}