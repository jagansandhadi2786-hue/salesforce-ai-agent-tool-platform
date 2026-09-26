public class KnowledgeResponse {

    public String title;
    public String summary;
    public String url;

    public KnowledgeResponse() {
    }

    public KnowledgeResponse(
        String title,
        String summary,
        String url
    ) {

        this.title = title;
        this.summary = summary;
        this.url = url;
    }
}

