public with sharing class OrderService {

    public static OrderResult getOrderStatus(
        String orderNumber
    ) {

        if (String.isBlank(orderNumber)) {
            throw new AI_ServiceException(
                'Order number is required.'
            );
        }

        AI_ExternalOrderResponse externalResult =
            AI_OrderApiService.getOrderStatus(
                orderNumber
            );

        if (externalResult == null) {
            throw new AI_ServiceException(
                'Order service returned no order.'
            );
        }

        return new OrderResult(
            externalResult.orderNumber,
            externalResult.status,
            externalResult.message,
            externalResult.estimatedDelivery,
            externalResult.trackingNumber
        );
    }

    public class OrderResult {

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

        public OrderResult(
            String orderNumber,
            String status,
            String message
        ) {
            this.orderNumber = orderNumber;
            this.status = status;
            this.message = message;
        }

        public OrderResult(
            String orderNumber,
            String status,
            String message,
            String estimatedDelivery,
            String trackingNumber
        ) {
            this.orderNumber = orderNumber;
            this.status = status;
            this.message = message;
            this.estimatedDelivery = estimatedDelivery;
            this.trackingNumber = trackingNumber;
        }
    }
}