public with sharing class OrderService {

    public class OrderResult {
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }

    public static OrderResult getOrderStatus(
        String orderNumber
    ) {

        if (String.isBlank(orderNumber)) {
            throw new AI_ServiceException(
                'Order number is required.'
            );
        }

        OrderResult result = new OrderResult();

        result.orderNumber = orderNumber.trim();
        result.status = 'UNKNOWN';
        result.message =
            'External order integration will be implemented in Phase 11.';

        return result;
    }
}

// Later will introduce:
// Salesforce
// Named Credential
// OAuth
// External REST API
// Order Service
