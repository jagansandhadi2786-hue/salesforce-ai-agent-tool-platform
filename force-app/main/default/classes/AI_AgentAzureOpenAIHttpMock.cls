
@IsTest
global class AI_AgentAzureOpenAIHttpMock
    implements HttpCalloutMock {

    private Integer statusCode;
    private String responseBody;

    public AI_AgentAzureOpenAIHttpMock(
        Integer statusCode,
        String responseBody
    ) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HttpResponse respond(
        HttpRequest request
    ) {

        // HTTP method
        System.assertEquals(
            'POST',
            request.getMethod(),
            'Azure OpenAI request must use POST.'
        );

        // Content type
        System.assertEquals(
            'application/json',
            request.getHeader('Content-Type'),
            'Azure OpenAI request must use application/json.'
        );

        // Named Credential
        System.assert(
            request.getEndpoint().contains('Azure_OpenAI'),
            'Request must use the Azure_OpenAI Named Credential.'
        );

        // Request body
        String requestBody = request.getBody();

        System.assert(
            !String.isBlank(requestBody),
            'Azure OpenAI request body must not be empty.'
        );

        // Model
        System.assert(
            requestBody.contains('"model"'),
            'Request must contain the model.'
        );

        // Input
        System.assert(
            requestBody.contains('"input"'),
            'Request must contain the input.'
        );

        // Function tools
        System.assert(
            requestBody.contains('"tools"'),
            'Request must contain function tools.'
        );

        // Parallel tool execution control
        System.assert(
            requestBody.contains('"parallel_tool_calls"'),
            'Request must explicitly control parallel tool calls.'
        );

        // Build mock response
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