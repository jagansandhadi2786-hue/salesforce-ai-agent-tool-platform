public class AI_RAGCitation {

    @AuraEnabled
    public Integer citationNumber;

    @AuraEnabled
    public String articleId;

    @AuraEnabled
    public String title;

    @AuraEnabled
    public String url;


    public AI_RAGCitation() {
    }


    public AI_RAGCitation(
        Integer citationNumber,
        String articleId,
        String title,
        String url
    ) {

        this.citationNumber =
            citationNumber;

        this.articleId =
            articleId;

        this.title =
            title;

        this.url =
            url;
    }
}
