public class OrderResponse {

    @AuraEnabled
    public String orderNumber;

    @AuraEnabled
    public String status;

    @AuraEnabled
    public String message;

    @AuraEnabled
    public String estimatedDelivery;

    @AuraEnabled
    public String trackingNumber;

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