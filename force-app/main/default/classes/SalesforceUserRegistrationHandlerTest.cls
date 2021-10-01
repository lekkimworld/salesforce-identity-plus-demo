@isTest
public with sharing class SalesforceUserRegistrationHandlerTest {
    public static testMethod void testUpdateUser() {
        new SalesforceUserRegistrationHandler().updateUser(null, null, null);
    }

    public static testMethod void testCreateUser_unknown() {
        try {
            Auth.UserData userData = new Auth.UserData(null, null, null, null, null, null, null, null, null, null, null);
            new SalesforceUserRegistrationHandler().createUser(null, userData);
            System.assert(false);
        } catch (Exception e) {
            // success
        }
    }

    public static testMethod void testCreateUser_known() {
        Profile p = [SELECT Id FROM profile WHERE name='Standard User' LIMIT 1];
        User u = new User();
        u.username = 'foo-dummy-test@example.com';
        u.email = 'foo@example.com';
        u.lastName = 'Doe';
        u.firstName = 'John';
        u.alias = 'jdoe';
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'da';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'Europe/Paris';
        u.profileId = p.Id;
        u.FederationIdentifier = 'foo@federation.example.com';
        insert u;

        Test.startTest();
        Auth.UserData userData = new Auth.UserData('foo@federation.example.com', null, null, null, null, null, null, null, null, null, null);
        User u2 = new SalesforceUserRegistrationHandler().createUser(null, userData);
        System.assertEquals(u.Id, u2.Id);
        Test.stopTest();
    }
}
