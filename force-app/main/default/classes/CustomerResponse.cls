public class CustomerResponse {

    public String id;
    public String name;
    public String phone;
    public String industry;
    public String billingCity;

    public CustomerResponse() {
    }

    public CustomerResponse(Account accountRecord) {

        if (accountRecord == null) {
            return;
        }

        this.id =
            String.valueOf(
                accountRecord.Id
            );

        this.name =
            accountRecord.Name;

        this.phone =
            accountRecord.Phone;

        this.industry =
            accountRecord.Industry;

        this.billingCity =
            accountRecord.BillingCity;
    }
}
