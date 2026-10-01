public with sharing class AI_AgentToolResultResolver {

    public static Map<String, Object> resolveNextArguments(
        String previousTool,
        AI_ToolResponse response,
        String nextTool
    ) {

        if (response == null) {
            throw new AI_ServiceException(
                'Tool response is required for result resolution.'
            );
        }


        if (!response.success) {
            throw new AI_ServiceException(
                'Cannot continue tool chain because the previous tool failed.'
            );
        }


        if (
            previousTool == 'search_customer' &&
            nextTool == 'get_open_cases'
        ) {

            return resolveCustomerToOpenCases(
                response
            );
        }


        throw new AI_ServiceException(
            'No result-resolution rule exists for ' +
            previousTool +
            ' -> ' +
            nextTool
        );
    }


    private static Map<String, Object> resolveCustomerToOpenCases(
        AI_ToolResponse response
    ) {

        Map<String, Object> arguments =
            new Map<String, Object>();


        if (response.data == null) {

            throw new AI_ServiceException(
                'Customer search returned no data.'
            );
        }


        List<CustomerResponse> customers =
            extractCustomers(response.data);


        if (customers.isEmpty()) {

            throw new AI_ServiceException(
                'No customer was found.'
            );
        }


        if (customers.size() > 1) {

            throw new AI_ServiceException(
                'Multiple customers matched the request. ' +
                'A more specific customer name is required.'
            );
        }


        CustomerResponse customer =
            customers[0];


        if (String.isBlank(customer.id)) {

            throw new AI_ServiceException(
                'Customer result did not contain an Account Id.'
            );
        }


        arguments.put(
            'account_id',
            customer.id
        );


        return arguments;
    }


    private static List<CustomerResponse> extractCustomers(
        Object data
    ) {

        List<CustomerResponse> customers =
            new List<CustomerResponse>();

        if (data instanceof List<CustomerResponse>) {

            customers =
                (List<CustomerResponse>) data;
        }

        return customers;
    }
}