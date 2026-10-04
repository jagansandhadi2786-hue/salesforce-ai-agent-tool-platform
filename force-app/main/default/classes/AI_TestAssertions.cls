@IsTest
public class AI_TestAssertions {

    public static void assertSuccessfulResponse(
        AI_AgentResponse response
    ) {

        System.assertNotEquals(
            null,
            response
        );

        System.assertEquals(
            true,
            response.success
        );

        System.assert(
            !String.isBlank(
                response.message
            )
        );
    }
}
