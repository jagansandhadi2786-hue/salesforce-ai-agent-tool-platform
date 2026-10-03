@IsTest
private class AI_ExternalIntegrationSecurityTest {

    private class SecurityMock
        implements HttpCalloutMock {

        private String capturedEndpoint;
        private String capturedMethod;
        private String authorizationHeader;
        private String apiKeyHeader;

        public HttpResponse respond(
            HttpRequest request
        ) {

            capturedEndpoint =
                request.getEndpoint();

            capturedMethod =
                request.getMethod();

            authorizationHeader =
                request.getHeader(
                    'Authorization'
                );

            apiKeyHeader =
                request.getHeader(
                    'x-api-key'
                );

            HttpResponse response =
                new HttpResponse();

            response.setStatusCode(200);

            response.setHeader(
                'Content-Type',
                'application/json'
            );

            response.setBody(
                JSON.serialize(
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
                )
            );

            return response;
        }
    }

    /*
     * Verify Named Credential is used.
     */
    @IsTest
    static void testNamedCredentialUsage() {

        SecurityMock mock =
            new SecurityMock();

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            'ORD-1001'
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            mock.capturedEndpoint
        );

        System.assert(
            mock.capturedEndpoint.startsWith(
                'callout:External_Order_API'
            ),
            'External integration must use the Named Credential.'
        );
    }

    /*
     * Verify GET is used.
     */
    @IsTest
    static void testHttpMethod() {

        SecurityMock mock =
            new SecurityMock();

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            'ORD-1001'
        );

        Test.stopTest();

        System.assertEquals(
            'GET',
            mock.capturedMethod
        );
    }

    /*
     * Verify Apex does not manually supply
     * an Authorization header.
     *
     * Authentication should be handled
     * by the Named Credential.
     */
    @IsTest
    static void testNoHardCodedAuthorizationHeader() {

        SecurityMock mock =
            new SecurityMock();

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            'ORD-1001'
        );

        Test.stopTest();

        System.assertEquals(
            null,
            mock.authorizationHeader,
            'Authorization should be managed by the Named Credential.'
        );
    }

    /*
     * Verify API key is not hard-coded
     * into the Apex request.
     */
    @IsTest
    static void testNoHardCodedApiKey() {

        SecurityMock mock =
            new SecurityMock();

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );

        Test.startTest();

        AI_OrderApiService.getOrderStatus(
            'ORD-1001'
        );

        Test.stopTest();

        System.assertEquals(
            null,
            mock.apiKeyHeader,
            'API keys should not be hard-coded in Apex.'
        );
    }

    /*
     * Verify blank input is rejected.
     */
    @IsTest
    static void testInputValidation() {

        Test.startTest();

        try {

            AI_OrderApiService.getOrderStatus(
                ''
            );

            System.assert(
                false,
                'Blank order numbers must be rejected.'
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
     * Verify the external response is mapped
     * into the controlled DTO.
     */
    @IsTest
    static void testExternalResponseMapping() {

        SecurityMock mock =
            new SecurityMock();

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );

        Test.startTest();

        AI_ExternalOrderResponse result =
            AI_OrderApiService.getOrderStatus(
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
            '2026-10-08',
            result.estimatedDelivery
        );

        System.assertEquals(
            'TRK123456789',
            result.trackingNumber
        );
    }
}