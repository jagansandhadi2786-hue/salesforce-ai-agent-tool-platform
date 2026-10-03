public class AI_RAGContext {

    public String query;

    public List<AI_KnowledgeSearchResult>
        results;

    public Integer topK;

    public Boolean grounded;

    public AI_RAGContext() {

        results =
            new List<AI_KnowledgeSearchResult>();

        topK = 5;

        grounded = false;
    }


    public Boolean hasResults() {

        return
            results != null &&
            !results.isEmpty();
    }
}
