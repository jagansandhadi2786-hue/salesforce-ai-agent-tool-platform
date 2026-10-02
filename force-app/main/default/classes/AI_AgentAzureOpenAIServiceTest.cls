@IsTest
private class AI_AgentAzureOpenAIServiceTest {


    @IsTest
    static void testSuccessfulAzureResponse() {

        String responseBody =
            '{' +
            '"output_text":' +
            '"{\\"intent\\":\\"GET_OPEN_CASES\\",' +
            '\\"toolName\\":\\"get_open_cases\\",' +
            '\\"arguments\\":{' +
            '\\"customer_name\\":\\"Acme\\"},' +
            '\\"assistantMessage\\":' +
            '\\"I will check the open cases.\\",' +
            '\\"confidence\\":0.96}"' +
            '}';


        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureOpenAIHttpMock(
                200,
                responseBody
            )
        );


        AI_AgentLLMRequest request =
            new AI_AgentLLMRequest();

        request.userMessage =
            'Find the open cases for Acme';


        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentAzureOpenAIService.generate(
                request
            );

        Test.stopTest();


        System.assertEquals(
            true,
            response.success
        );


        System.assertEquals(
            'GET_OPEN_CASES',
            response.intent
        );


        System.assertEquals(
            'get_open_cases',
            response.toolName
        );


        System.assertEquals(
            'Acme',
            String.valueOf(
                response.arguments.get(
                    'customer_name'
                )
            )
        );


        System.assertEquals(
            Decimal.valueOf('0.96'),
            response.confidence
        );
    }


@IsTest
static void testAzureHttpError() {

    Test.setMock(
        HttpCalloutMock.class,
        new AI_AgentAzureOpenAIHttpMock(
            500,
            '{"error":{"message":"Internal error"}}'
        )
    );


    AI_AgentLLMRequest request =
        new AI_AgentLLMRequest();

    request.userMessage =
        'Find the open cases for Acme';


    Test.startTest();

    try {

        AI_AgentAzureOpenAIService.generate(
            request
        );

        System.assert(
            false,
            'Expected Azure error.'
        );

    } catch (AI_ServiceException ex) {

        System.assertEquals(
            'Azure OpenAI request failed.',
            ex.getMessage()
        );
    }

    Test.stopTest();
}
@IsTest
static void testInvalidAzureJson() {

    Test.setMock(
        HttpCalloutMock.class,
        new AI_AgentAzureOpenAIHttpMock(
            200,
            'NOT VALID JSON'
        )
    );


    AI_AgentLLMRequest request =
        new AI_AgentLLMRequest();

    request.userMessage =
        'Find Acme';


    Test.startTest();

    try {

        AI_AgentAzureOpenAIService.generate(
            request
        );

        System.assert(
            false,
            'Expected invalid JSON error.'
        );

    } catch (AI_ServiceException ex) {

        System.assertEquals(
            'Azure OpenAI returned invalid JSON.',
            ex.getMessage()
        );
    }

    Test.stopTest();
}

@IsTest
static void testMissingOutputText() {

    Test.setMock(
        HttpCalloutMock.class,
        new AI_AgentAzureOpenAIHttpMock(
            200,
            '{"id":"response-123"}'
        )
    );


    AI_AgentLLMRequest request =
        new AI_AgentLLMRequest();

    request.userMessage =
        'Find Acme';


    Test.startTest();

    try {

        AI_AgentAzureOpenAIService.generate(
            request
        );

        System.assert(
            false,
            'Expected missing output error.'
        );

    } catch (AI_ServiceException ex) {

        System.assertEquals(
            'Azure OpenAI returned no structured output.',
            ex.getMessage()
        );
    }

    Test.stopTest();
}


}
