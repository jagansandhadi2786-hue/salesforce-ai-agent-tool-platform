@IsTest
private class AI_RAGServiceTest {

    private static final Integer DEFAULT_TOP_K = 5;
    private static final Integer MAX_TOP_K = 10;


    // ============================================================
    // Helper: Configure HTTP Mock
    // ============================================================

    private static void setupMock(
        String responseBody,
        Integer statusCode
    ) {

        AI_AzureSearchHttpMock mock =
            new AI_AzureSearchHttpMock();

        mock.responseBody =
            responseBody;

        mock.responseStatusCode =
            statusCode;

        mock.throwException =
            false;

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );
    }


    // ============================================================
    // Helper: Successful Azure Response
    // ============================================================

    private static String successfulResponse() {

        return JSON.serialize(
            new Map<String, Object>{
                'value' => new List<Object>{

                    new Map<String, Object>{

                        'id' =>
                            'doc-001',

                        'articleId' =>
                            'KB-001',

                        'title' =>
                            'Password Reset',

                        'content' =>
                            'Instructions for resetting a password.',

                        'url' =>
                            'https://example.com/kb-001',

                        'category' =>
                            'Account',

                        'score' =>
                            0.95,

                        'chunkNumber' =>
                            1
                    }
                }
            }
        );
    }


    // ============================================================
    // Helper: Multiple Results
    // ============================================================

    private static String multipleResultsResponse() {

        return JSON.serialize(
            new Map<String, Object>{
                'value' => new List<Object>{

                    new Map<String, Object>{

                        'id' =>
                            'doc-001',

                        'articleId' =>
                            'KB-001',

                        'title' =>
                            'Password Reset',

                        'content' =>
                            'Password reset instructions.',

                        'url' =>
                            'https://example.com/kb-001',

                        'category' =>
                            'Account',

                        'score' =>
                            0.95,

                        'chunkNumber' =>
                            1
                    },

                    new Map<String, Object>{

                        'id' =>
                            'doc-002',

                        'articleId' =>
                            'KB-002',

                        'title' =>
                            'Account Lockout',

                        'content' =>
                            'Instructions for locked accounts.',

                        'url' =>
                            'https://example.com/kb-002',

                        'category' =>
                            'Security',

                        'score' =>
                            0.88,

                        'chunkNumber' =>
                            1
                    },

                    new Map<String, Object>{

                        'id' =>
                            'doc-003',

                        'articleId' =>
                            'KB-003',

                        'title' =>
                            'Username Change',

                        'content' =>
                            'Instructions for changing usernames.',

                        'url' =>
                            'https://example.com/kb-003',

                        'category' =>
                            'Account',

                        'score' =>
                            0.81,

                        'chunkNumber' =>
                            1
                    }
                }
            }
        );
    }


    // ============================================================
    // Helper: Empty Response
    // ============================================================

    private static String emptyResponse() {

        return JSON.serialize(
            new Map<String, Object>{
                'value' =>
                    new List<Object>()
            }
        );
    }


    // ============================================================
    // 1. Blank Query
    // ============================================================

    @IsTest
    static void testBlankQuery() {

        Test.startTest();

        try {

            AI_RAGService.retrieve(
                '',
                DEFAULT_TOP_K
            );

            System.assert(
                false,
                'Blank query should throw AI_ServiceException.'
            );

        } catch (AI_ServiceException e) {

            System.assertEquals(
                'Knowledge search query is required.',
                e.getMessage()
            );
        }

        Test.stopTest();
    }


    // ============================================================
    // 2. Null topK
    // ============================================================

    @IsTest
    static void testNullTopK() {

        setupMock(
            successfulResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'password reset',
                null
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            context,
            'RAG context should be created.'
        );

        System.assertEquals(
            DEFAULT_TOP_K,
            context.topK,
            'Null topK should default to 5.'
        );
    }


    // ============================================================
    // 3. topK > Maximum
    // ============================================================

    @IsTest
    static void testTopKAboveMaximum() {

        setupMock(
            successfulResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'password reset',
                100
            );

        Test.stopTest();

        System.assertEquals(
            MAX_TOP_K,
            context.topK,
            'topK should be capped at 10.'
        );
    }


    // ============================================================
    // 4. Successful Retrieval
    // ============================================================

    @IsTest
    static void testSuccessfulRetrieval() {

        setupMock(
            successfulResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'password reset',
                5
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            context,
            'Context should not be null.'
        );

        System.assertEquals(
            'password reset',
            context.query
        );

        System.assertEquals(
            5,
            context.topK
        );

        System.assertNotEquals(
            null,
            context.results
        );

        System.assertEquals(
            1,
            context.results.size()
        );

        System.assertEquals(
            true,
            context.grounded
        );
    }


    // ============================================================
    // 5. No Results
    // ============================================================

    @IsTest
    static void testNoResults() {

        setupMock(
            emptyResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'unknown question',
                5
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            context
        );

        System.assertNotEquals(
            null,
            context.results
        );

        System.assertEquals(
            0,
            context.results.size()
        );

        System.assertEquals(
            false,
            context.grounded
        );

        System.assertEquals(
            false,
            context.hasResults()
        );
    }


    // ============================================================
    // 6. Multiple Results
    // ============================================================

    @IsTest
    static void testMultipleResults() {

        setupMock(
            multipleResultsResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'account',
                5
            );

        Test.stopTest();

        System.assertEquals(
            3,
            context.results.size()
        );

        System.assertEquals(
            true,
            context.grounded
        );

        System.assertEquals(
            'KB-001',
            context.results[0].articleId
        );

        System.assertEquals(
            'KB-002',
            context.results[1].articleId
        );

        System.assertEquals(
            'KB-003',
            context.results[2].articleId
        );
    }


    // ============================================================
    // 7. Citation / Result Mapping
    // ============================================================

    @IsTest
    static void testCitationMapping() {

        setupMock(
            successfulResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'password reset',
                5
            );

        Test.stopTest();

        System.assertEquals(
            1,
            context.results.size()
        );

        AI_KnowledgeSearchResult result =
            context.results[0];

        System.assertEquals(
            'KB-001',
            result.articleId
        );

        System.assertEquals(
            'Password Reset',
            result.title
        );

        System.assertEquals(
            'Instructions for resetting a password.',
            result.content
        );

        System.assertEquals(
            'https://example.com/kb-001',
            result.url
        );

        System.assertEquals(
            'Account',
            result.category
        );

        System.assertEquals(
            Decimal.valueOf('0.95'),
            result.score
        );

        System.assertEquals(
            1,
            result.chunkNumber
        );
    }


    // ============================================================
    // 8. Search Service Error
    // ============================================================

    @IsTest
    static void testSearchServiceError() {

        setupMock(
            '{"error":{"message":"Azure Search service error"}}',
            500
        );

        Test.startTest();

        try {

            AI_RAGService.retrieve(
                'password reset',
                5
            );

            System.assert(
                false,
                'HTTP 500 should throw AI_ServiceException.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains(
                    'Azure AI Search returned HTTP 500'
                ),
                'Expected HTTP 500 error.'
            );
        }

        Test.stopTest();
    }


    // ============================================================
    // 9. Invalid Azure Response
    // ============================================================

    @IsTest
    static void testInvalidAzureResponse() {

        setupMock(
            '{"invalid":"response"}',
            200
        );

        Test.startTest();

        try {

            AI_RAGService.retrieve(
                'password reset',
                5
            );

            System.assert(
                false,
                'Invalid Azure response should throw an exception.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains(
                    'Invalid Azure AI Search response'
                ),
                'Expected invalid-response error.'
            );
        }

        Test.stopTest();
    }


    // ============================================================
    // 10. Timeout
    // ============================================================

    @IsTest
    static void testTimeout() {

        AI_AzureSearchHttpMock mock =
            new AI_AzureSearchHttpMock();

        mock.throwException = true;

        Test.setMock(
            HttpCalloutMock.class,
            mock
        );

        Test.startTest();

        try {

            AI_RAGService.retrieve(
                'password reset',
                5
            );

            System.assert(
                false,
                'Timeout should throw AI_ServiceException.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains(
                    'Azure AI Search callout failed'
                ),
                'Expected callout failure.'
            );
        }

        Test.stopTest();
    }


    // ============================================================
    // 11. Unauthorized Search
    // ============================================================

    @IsTest
    static void testUnauthorizedSearch() {

        setupMock(
            '{"error":{"code":"Unauthorized","message":"Access denied"}}',
            401
        );

        Test.startTest();

        try {

            AI_RAGService.retrieve(
                'password reset',
                5
            );

            System.assert(
                false,
                'HTTP 401 should throw AI_ServiceException.'
            );

        } catch (AI_ServiceException e) {

            System.assert(
                e.getMessage().contains(
                    'Azure AI Search returned HTTP 401'
                ),
                'Expected unauthorized error.'
            );
        }

        Test.stopTest();
    }


    // ============================================================
    // 12. Metadata Filtering
    // ============================================================
    //
    // Metadata filtering is intentionally NOT implemented here.
    //
    // Current API:
    //
    // AI_AzureSearchService.search(
    //     String query,
    //     Integer topK
    // )
    //
    // Therefore a three-argument search() call would not compile.
    //
    // This test currently validates that metadata fields are
    // correctly returned from Azure Search.
    //
    // Once the filter API is added, this test should be expanded
    // to verify the generated Azure $filter expression.
    // ============================================================

    @IsTest
    static void testMetadataFieldsReturned() {

        setupMock(
            multipleResultsResponse(),
            200
        );

        Test.startTest();

        AI_RAGContext context =
            AI_RAGService.retrieve(
                'account',
                5
            );

        Test.stopTest();

        System.assertEquals(
            3,
            context.results.size()
        );

        System.assertEquals(
            'Account',
            context.results[0].category
        );

        System.assertEquals(
            'Security',
            context.results[1].category
        );

        System.assertEquals(
            'Account',
            context.results[2].category
        );
    }
}