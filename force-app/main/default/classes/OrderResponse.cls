public class OrderResponse {

    public String orderNumber;
    public String status;
    public String message;

    public OrderResponse() {
    }

    public OrderResponse(
        String orderNumber,
        String status,
        String message
    ) {

        this.orderNumber = orderNumber;
        this.status = status;
        this.message = message;
    }
}
