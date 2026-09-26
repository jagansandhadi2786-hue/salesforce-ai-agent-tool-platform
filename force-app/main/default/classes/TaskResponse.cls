public class TaskResponse {

    public String id;
    public String subject;
    public String status;
    public String priority;
    public Date dueDate;

    public TaskResponse() {
    }

    public TaskResponse(Task taskRecord) {

        if (taskRecord == null) {
            return;
        }

        this.id =
            String.valueOf(
                taskRecord.Id
            );

        this.subject =
            taskRecord.Subject;

        this.status =
            taskRecord.Status;

        this.priority =
            taskRecord.Priority;

        this.dueDate =
            taskRecord.ActivityDate;
    }
}