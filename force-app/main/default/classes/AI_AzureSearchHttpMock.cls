@IsTest
global class AI_AzureSearchHttpMock
    implements HttpCalloutMock {

    global String responseBody;
    global Integer responseStatusCode = 200;
    global Boolean throwException = false;

    global HttpResponse respond(
        HttpRequest request
    ) {
        if (throwException) {
            throw new CalloutException(
                'Simulated Azure AI Search timeout.'
            );
        }

        HttpResponse response =
            new HttpResponse();

        response.setStatusCode(
            responseStatusCode
        );

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

    public static String successfulResponse() {
        return JSON.serialize(
            new Map<String, Object>{
                'value' => new List<Object>{
                    new Map<String, Object>{
                        'id' => 'doc-001',
                        'articleId' => 'KB-001',
                        'title' => 'Password Reset',
                        'content' =>
                            'Instructions for resetting a password.',
                        'url' =>
                            'https://example.com/kb-001',
                        'category' => 'Account',
                        'score' => 0.95,
                        'chunkNumber' => 1
                    }
                }
            }
        );
    }

    public static String multipleResultsResponse() {
        return JSON.serialize(
            new Map<String, Object>{
                'value' => new List<Object>{
                    new Map<String, Object>{
                        'id' => 'doc-001',
                        'articleId' => 'KB-001',
                        'title' => 'Password Reset',
                        'content' =>
                            'Password reset instructions.',
                        'url' =>
                            'https://example.com/kb-001',
                        'category' => 'Account',
                        'score' => 0.95,
                        'chunkNumber' => 1
                    },
                    new Map<String, Object>{
                        'id' => 'doc-002',
                        'articleId' => 'KB-002',
                        'title' => 'Account Lockout',
                        'content' =>
                            'Instructions for locked accounts.',
                        'url' =>
                            'https://example.com/kb-002',
                        'category' => 'Security',
                        'score' => 0.88,
                        'chunkNumber' => 1
                    },
                    new Map<String, Object>{
                        'id' => 'doc-003',
                        'articleId' => 'KB-003',
                        'title' => 'Username Change',
                        'content' =>
                            'Instructions for changing usernames.',
                        'url' =>
                            'https://example.com/kb-003',
                        'category' => 'Account',
                        'score' => 0.81,
                        'chunkNumber' => 1
                    }
                }
            }
        );
    }

    public static String emptyResponse() {
        return JSON.serialize(
            new Map<String, Object>{
                'value' => new List<Object>()
            }
        );
    }
}