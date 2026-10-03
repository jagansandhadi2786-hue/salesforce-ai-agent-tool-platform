public with sharing class AI_RAGService {

    private static final Integer DEFAULT_TOP_K = 5;
    private static final Integer MAX_TOP_K = 10;


    public static AI_RAGContext retrieve(
        String query,
        Integer topK
    ) {

        if (String.isBlank(query)) {

            throw new AI_ServiceException(
                'Knowledge search query is required.'
            );
        }


        if (topK == null || topK <= 0) {
            topK = DEFAULT_TOP_K;
        }


        if (topK > MAX_TOP_K) {
            topK = MAX_TOP_K;
        }


        AI_RAGContext context =
            new AI_RAGContext();


        context.query =
            query;


        context.topK =
            topK;


        context.results =
            AI_AzureSearchService.search(
                query,
                topK
            );


        context.grounded =
            context.hasResults();


        return context;
    }
}