public class AI_KnowledgeSearchResult {

    @AuraEnabled
    public String articleId;

    @AuraEnabled
    public String title;

    @AuraEnabled
    public String content;

    @AuraEnabled
    public String url;

    @AuraEnabled
    public String category;

    @AuraEnabled
    public Decimal score;

    @AuraEnabled
    public Integer chunkNumber;


    public AI_KnowledgeSearchResult() {
    }


    public AI_KnowledgeSearchResult(
        String articleId,
        String title,
        String content,
        String url,
        String category,
        Decimal score,
        Integer chunkNumber
    ) {

        this.articleId = articleId;
        this.title = title;
        this.content = content;
        this.url = url;
        this.category = category;
        this.score = score;
        this.chunkNumber = chunkNumber;
    }
}
