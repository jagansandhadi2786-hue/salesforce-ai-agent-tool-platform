@IsTest
global class AI_OrderApiHttpMock implements HttpCalloutMock {

    global Integer responseStatusCode = 200;
    global String responseBody;

    global Boolean throwException = false;

    global HttpResponse respond(HttpRequest request) {

        if (throwException) {
            throw new CalloutException(
                'Simulated order service timeout.'
            );
        }

        HttpResponse response = new HttpResponse();

        response.setStatusCode(responseStatusCode);
        response.setHeader(
            'Content-Type',
            'application/json'
        );

        response.setBody(
            responseBody == null
                ? '{"value":[]}'
                : responseBody
        );

        return response;
    }
}