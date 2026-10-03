@IsTest
private class AI_OrderServiceTest {

    /*
     * Mock external order API response.
     */
    private class OrderApiMock implements HttpCalloutMock {

        private Integer statusCode;
        private String responseBody;

        OrderApiMock(
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

    /*
     * 1. Successful order.
     */
    @IsTest
    static void testSuccessfulOrder() {

        Test.setMock(
            HttpCalloutMock.class,
            new OrderApiMock(
                200,
                successfulResponse()
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
            result
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
     * 2. Blank order number.
     */
    @IsTest
    static void testBlankOrderNumber() {

        Test.startTest();

        try {

            OrderService.getOrderStatus('');

            System.assert(
                false,
                'Blank order number should fail.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order number is required.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * 3. Null order number.
     */
    @IsTest
    static void testNullOrderNumber() {

        Test.startTest();

        try {

            OrderService.getOrderStatus(null);

            System.assert(
                false,
                'Null order number should fail.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Order number is required.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }

    /*
     * 4. External service returns 404.
     */
    @IsTest
    static void testOrderNotFound() {

        Test.setMock(
            HttpCalloutMock.class,
            new OrderApiMock(
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
                '404 should result in order-not-found error.'
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
     * 5. External service returns 500.
     */
    @IsTest
    static void testExternalServiceFailure() {

        Test.setMock(
            HttpCalloutMock.class,
            new OrderApiMock(
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
                '500 should result in service failure.'
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
     * 6. Verify additional order fields.
     */
    @IsTest
    static void testExtendedOrderResponse() {

        Test.setMock(
            HttpCalloutMock.class,
            new OrderApiMock(
                200,
                successfulResponse()
            )
        );

        Test.startTest();

        OrderService.OrderResult result =
            OrderService.getOrderStatus(
                'ORD-1001'
            );

        Test.stopTest();

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