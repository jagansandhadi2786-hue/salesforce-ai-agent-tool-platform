public with sharing class AI_ToolResponseMapper {

    public static CustomerResponse
    toCustomerResponse(
        Account accountRecord
    ) {

        return new CustomerResponse(
            accountRecord
        );
    }


    public static List<CustomerResponse>
    toCustomerResponses(
        List<Account> accounts
    ) {

        List<CustomerResponse> results =
            new List<CustomerResponse>();

        if (accounts == null) {
            return results;
        }

        for (Account accountRecord :
             accounts) {

            results.add(
                toCustomerResponse(
                    accountRecord
                )
            );
        }

        return results;
    }


    public static CaseResponse
    toCaseResponse(
        Case caseRecord
    ) {

        return new CaseResponse(
            caseRecord
        );
    }


    public static List<CaseResponse>
    toCaseResponses(
        List<Case> cases
    ) {

        List<CaseResponse> results =
            new List<CaseResponse>();

        if (cases == null) {
            return results;
        }

        for (Case caseRecord :
             cases) {

            results.add(
                toCaseResponse(
                    caseRecord
                )
            );
        }

        return results;
    }


    public static TaskResponse
    toTaskResponse(
        Task taskRecord
    ) {

        return new TaskResponse(
            taskRecord
        );
    }


    public static OrderResponse
    toOrderResponse(
        OrderService.OrderResult result
    ) {

        if (result == null) {
            return null;
        }

        return new OrderResponse(
            result.orderNumber,
            result.status,
            result.message
        );
    }
}