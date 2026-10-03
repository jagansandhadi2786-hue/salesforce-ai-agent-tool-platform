@IsTest
private class AI_OrderApiServiceTest {

    /*
     * Expected behavior exposed by the service layer.
     * The test does not expose raw HTTP implementation details.
     */
    private static final String EXPECTED_ORDER_NUMBER = 'ORD-1001';

    /*
     * Generic configurable HTTP mock.
     */
    private class OrderApiMock implements HttpCalloutMock {

        private Integer statusCode;
        private String responseBody;
        private Boolean timeout;

        private String capturedMethod;
        private String capturedEndpoint;

        OrderApiMock(
            Integer statusCode,
            String responseBody
        ) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
            this.timeout = false;
        }

        OrderApiMock() {
            this.statusCode = 200;
            this.responseBody = '';
            this.timeout = false;
        }

        public HttpResponse respond(
            HttpRequest request
        ) {

            capturedMethod =
                request.getMethod();

            capturedEndpoint =
                request.getEndpoint();

            if (timeout) {
                throw new CalloutException(
                    'Simulated external order API timeout.'
                );
            }

            HttpResponse response =
                new HttpResponse();

            response.setStatusCode(
                statusCode
            );

            response.setHeader(
                'Content-Type',
                'application/json'
            );

            response.setBody(
                responseBody == null
                    ? ''
                    : responseBody
            );

            return response;
        }
    }

    /*
     * Standard successful external-order response.
     */
    private static String successfulResponse() {

        return JSON.serialize(
            new Map<String, Object>{
                'orderNumber' => 'ORD-1001',
                'status' => 'SHIPPED',
                'message' =>
                    'Order has been shipped.',
                'estimatedDelivery' =>
                    '2026-10-08',
                'trackingNumber' =>
                    'TRK123456789'
            }
        );
    }

    private static void registerMock(
        OrderApiMock mock
    ) {
        Test.setMock(
            HttpCalloutMock.class,
            mock
        );
    }

    /*
     * 1. Successful order
     */
    @IsTest
    static void testSuccessfulOrder() {

        OrderApiMock mock =
            new OrderApiMock(
                200,
                successfulResponse()
            );

        registerMock(mock);

        Test.startTest();

        AI_ExternalOrderResponse result =
            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'A successful order should return a response.'
        );

        System.assertEquals(
            'ORD-1001',
            result.orderNumber
        );

        System.assertEquals(
            'SHIPPED',
            result.status
        );

        System.assertEquals(
            'Order has been shipped.',
            result.message
        );

        System.assertEquals(
            '2026-10-08',
            result.estimatedDelivery
        );

        System.assertEquals(
            'TRK123456789',
            result.trackingNumber
        );
    }

    /*
     * 2. Blank order number
     */
    @IsTest
    static void testBlankOrderNumber() {

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus('');

            System.assert(
                false,
                'Blank order number should fail.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains(
                    'Order number'
                ),
                'Expected order-number validation error.'
            );
        }

        Test.stopTest();
    }

    /*
     * 3. HTTP 404
     */
    @IsTest
    static void test404OrderNotFound() {

        OrderApiMock mock =
            new OrderApiMock(
                404,
                '{"message":"Order not found"}'
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                'ORD-404'
            );

            System.assert(
                false,
                '404 should result in an integration exception.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains('not found') ||
                e.getMessage().contains('404'),
                'Expected order-not-found behavior.'
            );
        }

        Test.stopTest();
    }

    /*
     * 4. HTTP 500
     */
    @IsTest
    static void test500ServerError() {

        OrderApiMock mock =
            new OrderApiMock(
                500,
                '{"message":"Internal server error"}'
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                'ORD-500'
            );

            System.assert(
                false,
                '500 should result in an integration exception.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains('500') ||
                e.getMessage().contains('unavailable') ||
                e.getMessage().contains('service'),
                'Expected service-unavailable behavior.'
            );
        }

        Test.stopTest();
    }

    /*
     * 5. Empty response
     */
    @IsTest
    static void testEmptyResponse() {

        OrderApiMock mock =
            new OrderApiMock(
                200,
                ''
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

            System.assert(
                false,
                'Empty response should result in an integration error.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains(
                    'response'
                ),
                'Expected empty-response error.'
            );
        }

        Test.stopTest();
    }

    /*
     * 6. Invalid JSON
     */
    @IsTest
static void testInvalidJson() {
    OrderApiMock mock = new OrderApiMock();
    mock.statusCode = 200;
    mock.responseBody = '{invalid-json-response}';
    registerMock(mock);

    Test.startTest();

    try {
        AI_OrderApiService.getOrderStatus('ORD-1001');

        System.assert(
            false,
            'Invalid JSON should result in a controlled integration error.'
        );

    } catch (AI_ServiceException e) {

        System.assertEquals(
            'Order service returned invalid data.',
            e.getMessage(),
            'Invalid JSON should be converted to a controlled integration error.'
        );
    }

    Test.stopTest();
}

    /*
     * 7. Timeout
     */
    @IsTest
    static void testTimeout() {

        OrderApiMock mock =
            new OrderApiMock();

        mock.timeout = true;

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                'ORD-1001'
            );

            System.assert(
                false,
                'Timeout should result in an integration error.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
            'Unable to connect to the order service.',
            e.getMessage(),
            'Timeout should be converted to a controlled integration error.'
        );
        }

        Test.stopTest();
    }

    /*
     * 8. URL encoding
     */
    @IsTest
    static void testUrlEncoding() {

        String orderNumber =
            'ORD 1001/ABC';

        OrderApiMock mock =
            new OrderApiMock(
                200,
                successfulResponse()
            );

        registerMock(mock);

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            orderNumber
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            mock.capturedEndpoint,
            'Endpoint should be captured.'
        );

        /*
         * The order number must not be inserted into
         * the endpoint as a raw space or slash.
         */
        System.assert(
            !mock.capturedEndpoint.contains(
                'ORD 1001/ABC'
            ),
            'Order number should be URL encoded.'
        );

        System.assert(
            mock.capturedEndpoint.contains(
                'ORD+1001%2FABC'
            ) ||
            mock.capturedEndpoint.contains(
                'ORD%201001%2FABC'
            ),
            'Encoded order number should be present in the endpoint.'
        );
    }

    /*
     * 9. Correct HTTP method
     */
    @IsTest
    static void testCorrectHttpMethod() {

        OrderApiMock mock =
            new OrderApiMock(
                200,
                successfulResponse()
            );

        registerMock(mock);

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            EXPECTED_ORDER_NUMBER
        );

        Test.stopTest();

        System.assertEquals(
            'GET',
            mock.capturedMethod,
            'Order status lookup should use HTTP GET.'
        );
    }

    /*
     * 10. Named Credential endpoint
     */
    @IsTest
    static void testNamedCredentialEndpoint() {

        OrderApiMock mock =
            new OrderApiMock(
                200,
                successfulResponse()
            );

        registerMock(mock);

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            EXPECTED_ORDER_NUMBER
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            mock.capturedEndpoint,
            'Endpoint should be captured.'
        );

        System.assert(
            mock.capturedEndpoint.startsWith(
                'callout:'
            ),
            'External order API should use a Salesforce Named Credential.'
        );
    }

    /*
     * 11. HTTP 401
     */
    @IsTest
    static void test401AuthenticationFailure() {

        OrderApiMock mock =
            new OrderApiMock(
                401,
                '{"message":"Unauthorized"}'
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

            System.assert(
                false,
                '401 should result in an integration error.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains('401') ||
                e.getMessage().contains('authentication') ||
                e.getMessage().contains('integration'),
                'Expected authentication/integration failure.'
            );
        }

        Test.stopTest();
    }

    /*
     * 12. HTTP 403
     */
    @IsTest
    static void test403AccessDenied() {

        OrderApiMock mock =
            new OrderApiMock(
                403,
                '{"message":"Forbidden"}'
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

            System.assert(
                false,
                '403 should result in an integration error.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains('403') ||
                e.getMessage().contains('access') ||
                e.getMessage().contains('denied'),
                'Expected access-denied behavior.'
            );
        }

        Test.stopTest();
    }

    /*
     * 13. HTTP 429
     */
    @IsTest
    static void test429RateLimit() {

        OrderApiMock mock =
            new OrderApiMock(
                429,
                '{"message":"Too many requests"}'
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

            System.assert(
                false,
                '429 should result in an integration error.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains('429') ||
                e.getMessage().contains('temporary') ||
                e.getMessage().contains('unavailable'),
                'Expected temporary-service behavior.'
            );
        }

        Test.stopTest();
    }

    /*
     * 14. HTTP 503
     */
    @IsTest
    static void test503ServiceUnavailable() {

        OrderApiMock mock =
            new OrderApiMock(
                503,
                '{"message":"Service unavailable"}'
            );

        registerMock(mock);

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

            System.assert(
                false,
                '503 should result in an integration error.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains('503') ||
                e.getMessage().contains('unavailable') ||
                e.getMessage().contains('service'),
                'Expected service-unavailable behavior.'
            );
        }

        Test.stopTest();
    }

    /*
     * 15. Verify successful response fields are mapped.
     */
    @IsTest
    static void testResponseFieldMapping() {

        OrderApiMock mock =
            new OrderApiMock(
                200,
                successfulResponse()
            );

        registerMock(mock);

        Test.startTest();

        AI_ExternalOrderResponse result =
            AI_OrderApiService.getOrderStatus(
                EXPECTED_ORDER_NUMBER
            );

        Test.stopTest();

        System.assertEquals(
            'ORD-1001',
            result.orderNumber
        );

        System.assertEquals(
            'SHIPPED',
            result.status
        );

        System.assertEquals(
            'Order has been shipped.',
            result.message
        );

        System.assertEquals(
            '2026-10-08',
            result.estimatedDelivery
        );

        System.assertEquals(
            'TRK123456789',
            result.trackingNumber
        );
    }
}