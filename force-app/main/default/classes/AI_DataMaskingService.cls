public with sharing class AI_DataMaskingService {

    public static String maskPhone(
        String phone
    ) {

        if (String.isBlank(phone)) {
            return phone;
        }

        if (phone.length() <= 4) {
            return '****';
        }

        Integer visible =
            phone.length() - 4;

        return
            '*'.repeat(visible) +
            phone.substring(visible);
    }
}
