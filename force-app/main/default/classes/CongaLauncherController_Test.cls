@isTest
private class CongaLauncherController_Test
{
    // Test Method: getSessionIdAndServerUrl
    public static testmethod void Test_getSessionIdAndServerUrl(){
        System.Assert(CongaLauncherController.getSessionIdAndServerUrl() != null);
    }
}