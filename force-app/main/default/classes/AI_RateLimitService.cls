public with sharing class AI_RateLimitService {

    public static void checkAgentLimit(
        String sessionId
    ) {

        if (String.isBlank(sessionId)) {
            throw new AI_ServiceException(
                'Session ID is required.'
            );
        }

        /*
         * Production implementation:
         * Platform Cache / persistent counter /
         * API gateway policy.
         */
    }
}
