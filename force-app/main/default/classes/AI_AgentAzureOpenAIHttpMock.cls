@IsTest
global class AI_AgentAzureOpenAIHttpMock
    implements HttpCalloutMock {

    private Integer statusCode;

    private String responseBody;


    public AI_AgentAzureOpenAIHttpMock(
        Integer statusCode,
        String responseBody
    ) {

        this.statusCode =
            statusCode;

        this.responseBody =
            responseBody;
    }


    global HttpResponse respond(
        HttpRequest request
    ) {

        System.assertEquals(
            'POST',
            request.getMethod()
        );


        System.assert(
            request.getEndpoint().contains(
                'Azure_OpenAI'
            )
        );


        System.assertEquals(
            'application/json',
            request.getHeader(
                'Content-Type'
            )
        );


        HttpResponse response =
            new HttpResponse();


        response.setStatusCode(
            statusCode
        );


        response.setBody(
            responseBody
        );


        return response;
    }
}