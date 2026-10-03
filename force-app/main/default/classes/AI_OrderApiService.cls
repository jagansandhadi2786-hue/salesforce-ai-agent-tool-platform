public with sharing class AI_OrderApiService {

    private static final String NAMED_CREDENTIAL =
        'External_Order_API';

    private static final Integer TIMEOUT_MS =
        15000;

    public static AI_ExternalOrderResponse getOrderStatus(
        String orderNumber
    ) {

        if (String.isBlank(orderNumber)) {
            throw new AI_ServiceException(
                'Order number is required.'
            );
        }

        String encodedOrder =
            EncodingUtil.urlEncode(
                orderNumber.trim(),
                'UTF-8'
            );

        HttpRequest request =
            new HttpRequest();

        request.setMethod('GET');

        request.setEndpoint(
            'callout:' +
            NAMED_CREDENTIAL +
            '/orders/' +
            encodedOrder
        );

        request.setHeader(
            'Accept',
            'application/json'
        );

        request.setTimeout(
            TIMEOUT_MS
        );

        Http http = new Http();

        HttpResponse response;

        try {

            response =
                http.send(request);

        } catch (System.CalloutException ex) {

            throw new AI_ServiceException(
                'Unable to connect to the order service.'
            );
        }

        return parseResponse(response);
    }

    private static AI_ExternalOrderResponse parseResponse(
        HttpResponse response
    ) {

        if (response == null) {
            throw new AI_ServiceException(
                'Order service returned no response.'
            );
        }

        Integer statusCode =
            response.getStatusCode();

        /*
         * Keep the user-facing message business-oriented.
         * Do not expose raw HTTP implementation details.
         */
        if (statusCode == 404) {

            throw new AI_ServiceException(
                'Order was not found.'
            );
        }

        if (statusCode == 401) {

            throw new AI_ServiceException(
                'Order service authentication failed.'
            );
        }

        if (statusCode == 403) {

            throw new AI_ServiceException(
                'Order service access was denied.'
            );
        }

        if (statusCode == 429) {

            throw new AI_ServiceException(
                'Order service is temporarily unavailable.'
            );
        }

        if (statusCode == 500 ||
            statusCode == 503) {

            throw new AI_ServiceException(
                'Order service is currently unavailable.'
            );
        }

        if (statusCode < 200 ||
            statusCode >= 300) {

            throw new AI_ServiceException(
                'Unable to retrieve order information.'
            );
        }

        String body =
            response.getBody();

        if (String.isBlank(body)) {

            throw new AI_ServiceException(
                'Order service returned an empty response.'
            );
        }

        try {

            AI_ExternalOrderResponse result =
                (AI_ExternalOrderResponse)
                    JSON.deserialize(
                        body,
                        AI_ExternalOrderResponse.class
                    );

            if (result == null) {

                throw new AI_ServiceException(
                    'Order service returned invalid data.'
                );
            }

            return result;

        } catch (AI_ServiceException ex) {

            throw ex;

        } catch (Exception ex) {

            throw new AI_ServiceException(
                'Order service returned invalid data.'
            );
        }
    }
}