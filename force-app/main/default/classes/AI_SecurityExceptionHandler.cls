public with sharing class AI_SecurityExceptionHandler {

    public static String sanitize(
        Exception ex
    ) {

        if (ex == null) {
            return 'An unexpected error occurred.';
        }

        return 'The requested operation could not be completed.';
    }
}
