@IsTest
private class AI_AzureRESTEndToEndTest {

    private class EndToEndMock
        implements HttpCalloutMock {

        private Integer statusCode;
        private String responseBody;

        public EndToEndMock(
            Integer statusCode,
            String responseBody
        ) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(
            HttpRequest request
        ) {

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
                responseBody
            );

            return response;
        }
    }

    private static String successResponse() {

        return JSON.serialize(
            new Map<String, Object>{
                'orderNumber' => 'ORD-1001',
                'status' => 'DELIVERED',
                'message' =>
                    'Order has been delivered.',
                'estimatedDelivery' =>
                    '2026-10-08',
                'trackingNumber' =>
                    'TRK987654321'
            }
        );
    }

    /*
     * Complete successful flow.
     */
    @IsTest
    static void testEndToEndSuccessfulOrder() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                200,
                successResponse()
            )
        );

        Test.startTest();

        OrderService.OrderResult result =
            OrderService.getOrderStatus(
                'ORD-1001'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'Order result should be returned.'
        );

        System.assertEquals(
            'ORD-1001',
            result.orderNumber
        );

        System.assertEquals(
            'DELIVERED',
            result.status
        );

        System.assertEquals(
            'Order has been delivered.',
            result.message
        );

        System.assertEquals(
            '2026-10-08',
            result.estimatedDelivery
        );

        System.assertEquals(
            'TRK987654321',
            result.trackingNumber
        );
    }

    /*
     * Complete 404 flow.
     */
    @IsTest
    static void testEndToEndOrderNotFound() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                404,
                '{"message":"Order not found"}'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-404'
            );

            System.assert(
                false,
                'Order not found should throw an exception.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order was not found.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete 401 flow.
     */
    @IsTest
    static void testEndToEndAuthenticationFailure() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                401,
                '{"message":"Unauthorized"}'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-401'
            );

            System.assert(
                false,
                'Authentication failure should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service authentication failed.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete 403 flow.
     */
    @IsTest
    static void testEndToEndAccessDenied() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                403,
                '{"message":"Forbidden"}'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-403'
            );

            System.assert(
                false,
                'Access denied should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service access was denied.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete 429 flow.
     */
    @IsTest
    static void testEndToEndRateLimit() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                429,
                '{"message":"Too many requests"}'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-429'
            );

            System.assert(
                false,
                'Rate-limit response should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service is temporarily unavailable.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete 500 flow.
     */
    @IsTest
    static void testEndToEndServerError() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                500,
                '{"message":"Internal server error"}'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-500'
            );

            System.assert(
                false,
                'Server error should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service is currently unavailable.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete 503 flow.
     */
    @IsTest
    static void testEndToEndServiceUnavailable() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                503,
                '{"message":"Service unavailable"}'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-503'
            );

            System.assert(
                false,
                'Service unavailable should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service is currently unavailable.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete invalid JSON flow.
     */
    @IsTest
    static void testEndToEndInvalidJson() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                200,
                '{"orderNumber":'
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-1001'
            );

            System.assert(
                false,
                'Invalid JSON should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service returned invalid data.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * Complete empty response flow.
     */
    @IsTest
    static void testEndToEndEmptyResponse() {

        Test.setMock(
            HttpCalloutMock.class,
            new EndToEndMock(
                200,
                ''
            )
        );

        Test.startTest();

        try {

            OrderService.getOrderStatus(
                'ORD-1001'
            );

            System.assert(
                false,
                'Empty response should be handled.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order service returned an empty response.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }
}