public with sharing class AI_AzureSearchService {

    private static final String NAMED_CREDENTIAL =
        'Azure_AI_Search';

    private static final String INDEX_NAME =
        'salesforce-knowledge-index';

    private static final Integer DEFAULT_TOP_K = 5;
    private static final Integer MAX_TOP_K = 10;


    /**
     * Search Azure AI Search.
     *
     * Named Credential:
     * Azure_AI_Search
     *
     * Index:
     * salesforce-knowledge-index
     */
    public static List<AI_KnowledgeSearchResult> search(
        String query,
        Integer topK
    ) {

        if (String.isBlank(query)) {

            throw new AI_ServiceException(
                'Search query is required.'
            );
        }

        if (topK == null || topK <= 0) {
            topK = DEFAULT_TOP_K;
        }

        if (topK > MAX_TOP_K) {
            topK = MAX_TOP_K;
        }


        /*
         * Build Azure AI Search endpoint.
         *
         * The Named Credential should contain
         * the Azure Search base URL.
         */
        String endpoint =
            'callout:' +
            NAMED_CREDENTIAL +
            '/indexes/' +
            INDEX_NAME +
            '/docs/search?api-version=2024-07-01';


        HttpRequest request =
            new HttpRequest();

        request.setEndpoint(endpoint);

        request.setMethod('POST');

        request.setHeader(
            'Content-Type',
            'application/json'
        );

        request.setTimeout(10000);


        /*
         * Azure AI Search request body.
         */
        Map<String, Object> searchRequest =
            new Map<String, Object>();

        searchRequest.put(
            'search',
            query
        );

        searchRequest.put(
            'top',
            topK
        );

        searchRequest.put(
            'count',
            true
        );


        request.setBody(
            JSON.serialize(searchRequest)
        );


        Http http =
            new Http();

        HttpResponse response;

        try {

            response =
                http.send(request);

        } catch (Exception e) {

            throw new AI_ServiceException(
                'Azure AI Search callout failed: ' +
                e.getMessage()
            );
        }


        /*
         * Handle HTTP errors.
         */
        Integer statusCode =
            response.getStatusCode();

        if (statusCode < 200 || statusCode >= 300) {

            throw new AI_ServiceException(
                'Azure AI Search returned HTTP ' +
                statusCode +
                ': ' +
                response.getBody()
            );
        }


        /*
         * Parse Azure response.
         */
        try {

            return parseSearchResponse(
                response.getBody()
            );

        } catch (Exception e) {

            throw new AI_ServiceException(
                'Invalid Azure AI Search response: ' +
                e.getMessage()
            );
        }
    }


    /**
     * Parse Azure AI Search response.
     */
    private static List<AI_KnowledgeSearchResult>
        parseSearchResponse(
            String responseBody
        ) {

        List<AI_KnowledgeSearchResult> results =
            new List<AI_KnowledgeSearchResult>();


        if (String.isBlank(responseBody)) {

            throw new AI_ServiceException(
                'Azure AI Search returned an empty response.'
            );
        }


        Object parsed =
            JSON.deserializeUntyped(
                responseBody
            );


        if (!(parsed instanceof Map<String, Object>)) {

            throw new AI_ServiceException(
                'Azure response must be a JSON object.'
            );
        }


        Map<String, Object> response =
            (Map<String, Object>) parsed;


        if (!response.containsKey('value')) {

            throw new AI_ServiceException(
                'Azure response does not contain the value array.'
            );
        }


        Object valueObject =
            response.get('value');


        if (!(valueObject instanceof List<Object>)) {

            throw new AI_ServiceException(
                'Azure response value must be an array.'
            );
        }


        List<Object> records =
            (List<Object>) valueObject;


        for (Object recordObject : records) {

            if (!(recordObject instanceof Map<String, Object>)) {
                continue;
            }


            Map<String, Object> record =
                (Map<String, Object>) recordObject;


            AI_KnowledgeSearchResult result =
                new AI_KnowledgeSearchResult();


            result.articleId =
                getString(
                    record,
                    'articleId'
                );

            result.title =
                getString(
                    record,
                    'title'
                );

            result.content =
                getString(
                    record,
                    'content'
                );

            result.url =
                getString(
                    record,
                    'url'
                );

            result.category =
                getString(
                    record,
                    'category'
                );


            result.score =
                getDecimal(
                    record,
                    'score'
                );


            result.chunkNumber =
                getInteger(
                    record,
                    'chunkNumber'
                );


            results.add(result);
        }


        return results;
    }


    /**
     * Safely read String field.
     */
    private static String getString(
        Map<String, Object> record,
        String fieldName
    ) {

        if (!record.containsKey(fieldName)) {
            return null;
        }

        Object value =
            record.get(fieldName);

        return value == null
            ? null
            : String.valueOf(value);
    }


    /**
     * Safely read Decimal field.
     */
    private static Decimal getDecimal(
        Map<String, Object> record,
        String fieldName
    ) {

        if (!record.containsKey(fieldName)) {
            return null;
        }

        Object value =
            record.get(fieldName);

        if (value == null) {
            return null;
        }

        return Decimal.valueOf(
            String.valueOf(value)
        );
    }


    /**
     * Safely read Integer field.
     */
    private static Integer getInteger(
        Map<String, Object> record,
        String fieldName
    ) {

        if (!record.containsKey(fieldName)) {
            return null;
        }

        Object value =
            record.get(fieldName);

        if (value == null) {
            return null;
        }

        return Integer.valueOf(
            String.valueOf(value)
        );
    }
}