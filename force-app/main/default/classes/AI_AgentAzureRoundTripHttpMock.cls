@IsTest
global class AI_AgentAzureRoundTripHttpMock
    implements HttpCalloutMock {

    private Integer callCount = 0;
    private Id acmeAccountId;


    /*
     * Constructor receives the Account Id created
     * by the test method.
     */
    global AI_AgentAzureRoundTripHttpMock(
        Id accountId
    ) {
        this.acmeAccountId = accountId;
    }


    global HttpResponse respond(
        HttpRequest request
    ) {

        callCount++;

        HttpResponse response =
            new HttpResponse();

        response.setStatusCode(200);

        response.setHeader(
            'Content-Type',
            'application/json'
        );


        /*
         * =========================================================
         * ROUND 1
         * Azure requests search_customer
         * =========================================================
         */
        if (callCount == 1) {

            response.setBody(
                '{' +
                    '"id":"resp_001",' +
                    '"output":[' +
                        '{' +
                            '"type":"function_call",' +
                            '"call_id":"call_001",' +
                            '"name":"search_customer",' +
                            '"arguments":"{\\"customer_name\\":\\"Acme\\"}"' +
                        '}' +
                    ']' +
                '}'
            );

            return response;
        }


        /*
         * =========================================================
         * ROUND 2
         * Azure requests get_open_cases
         * =========================================================
         */
        if (callCount == 2) {

            response.setBody(
                '{' +
                    '"id":"resp_002",' +
                    '"output":[' +
                        '{' +
                            '"type":"function_call",' +
                            '"call_id":"call_002",' +
                            '"name":"get_open_cases",' +
                            '"arguments":"{\\"account_id\\":\\"' +
                                String.valueOf(
                                    acmeAccountId
                                ) +
                            '\\"}"' +
                        '}' +
                    ']' +
                '}'
            );

            return response;
        }


        /*
         * =========================================================
         * ROUND 3
         * Azure returns final assistant response.
         * =========================================================
         */
        response.setBody(
            '{' +
                '"id":"resp_003",' +
                '"output":[' +
                    '{' +
                        '"type":"message",' +
                        '"content":[' +
                            '{' +
                                '"type":"output_text",' +
                                '"text":"Acme has 2 open cases."' +
                            '}' +
                        ']' +
                    '}' +
                ']' +
            '}'
        );

        return response;
    }


    @IsTest
    static void testMultiStepAzureRoundTrip() {

        /*
         * =========================================================
         * 1. CREATE ACCOUNT
         * =========================================================
         */
        Account acme =
            new Account(
                Name = 'Acme'
            );

        insert acme;


        /*
         * =========================================================
         * 2. CREATE TWO OPEN CASES
         * =========================================================
         */
        List<Case> cases =
            new List<Case>{

                new Case(
                    AccountId = acme.Id,
                    Subject = 'Acme Case 1',
                    Status = 'New',
                    Priority = 'Medium'
                ),

                new Case(
                    AccountId = acme.Id,
                    Subject = 'Acme Case 2',
                    Status = 'Working',
                    Priority = 'High'
                )
            };

        insert cases;


        /*
         * =========================================================
         * 3. CREATE TOOL REGISTRY DATA
         * =========================================================
         *
         * AI_ToolSchemaValidator defines the argument schemas
         * in Apex. It does not depend on Allowed_Arguments__c.
         */
        insert new List<AI_Tool__c>{

            new AI_Tool__c(
                Name = 'Search Customer',
                Tool_API_Name__c = 'search_customer',
                Description__c =
                    'Search Salesforce customers by name.',
                Active__c = true,
                Requires_Approval__c = false,
                Tool_Type__c = 'Salesforce',
                Handler_Class__c = 'CustomerService'
            ),

            new AI_Tool__c(
                Name = 'Get Open Cases',
                Tool_API_Name__c = 'get_open_cases',
                Description__c =
                    'Retrieve open cases for a Salesforce account.',
                Active__c = true,
                Requires_Approval__c = false,
                Tool_Type__c = 'Salesforce',
                Handler_Class__c = 'CaseService'
            )
        };


        /*
         * =========================================================
         * 4. REGISTER HTTP MOCK
         * =========================================================
         *
         * Pass the real Account Id to the mock so that the
         * second Azure response contains a valid Salesforce Id.
         */
        Test.setMock(
            HttpCalloutMock.class,
            new AI_AgentAzureRoundTripHttpMock(
                acme.Id
            )
        );


        /*
         * =========================================================
         * 5. EXECUTE MULTI-STEP AGENT
         * =========================================================
         */
        Test.startTest();

        AI_AgentLLMResponse response =
            AI_AgentAzureToolCallingService.process(
                'Find the open cases for Acme'
            );

        Test.stopTest();


        /*
         * =========================================================
         * 6. ASSERT FINAL RESPONSE
         * =========================================================
         */
        System.assertNotEquals(
            null,
            response,
            'Azure response should not be null.'
        );

        System.assertEquals(
            false,
            response.requiresToolCall,
            'Final response should not require another tool call.'
        );

        System.assertNotEquals(
            null,
            response.assistantMessage,
            'Final assistant message should not be null.'
        );

        System.assert(
            response.assistantMessage.contains(
                'Acme has 2 open cases'
            ),
            'Final response should contain the expected message.'
        );
    }
}