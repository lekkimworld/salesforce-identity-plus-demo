@isTest
public with sharing class ExperienceCloudRegistrationHandlerTest {
    public static testMethod void testUpdateUser() {
        new ExperienceCloudRegistrationHandler().updateUser(null, null, null);
    }

    public static testMethod void testCreateUser_unknown() {
        final String uuid = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 8);
        final String identifier = 'auth0:' + uuid;
        final String remoteUsername = uuid + '@auth0.example.com';
        final Map<String,String> attrs = new Map<String,String>();
        Auth.UserData userData = new Auth.UserData(identifier, 'John', 'Doe', 'John Doe', 'jdoe@example.com', null, remoteUsername, 'da', null, null, attrs);
        
        Test.startTest();
        User u = new ExperienceCloudRegistrationHandler().createUser(null, userData);
        Test.stopTest();

        Contact c = [SELECT AccountId, Name FROM Contact WHERE Id =: u.ContactId LIMIT 1];
        Account a = [SELECT Name FROM Account WHERE Id =: c.AccountId LIMIT 1];
        System.assertEquals('First (John) Last (Doe)', c.Name);
        System.assertEquals('First (John) Last (Doe) Account', a.Name);
        System.assertEquals(identifier, u.FederationIdentifier);
        System.assertEquals('First (John)', u.FirstName);
        System.assertEquals('Last (Doe)', u.LastName);
    }

    public static testMethod void testCreateUser_known() {
        // create owning user with role
        User owner = createOwnerUser();

        Account a = new Account();
        a.Name = 'Foo Inc.';
        a.OwnerId = owner.Id;
        INSERT a;

        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        c.AccountId = a.Id;
        c.OwnerId = owner.Id;
        INSERT c;

        // create experience cloud user
        final String uuid = ExperienceCloudRegistrationHandler.generateAlias();
        final Profile ccProfile = [SELECT Id FROM Profile WHERE Name =: ExperienceCloudRegistrationHandler.PROFILE_NAME LIMIT 1];
        User u = ExperienceCloudRegistrationHandler.insertUser(ccProfile.Id, 'John', 'Doe', uuid, null, c.Id, null);
        
        System.runAs(owner) {
            Auth.UserData userData = new Auth.UserData(uuid + '@federation.-example.com', null, null, null, null, null, null, null, null, null, null);
            User u2 = new ExperienceCloudRegistrationHandler().createUser(null, userData);
            System.assertEquals(u.Id, u2.Id);
        }
    }

    private static User createOwnerUser() {
        UserRole r = new UserRole();
        r.Name = 'CEO';
        INSERT r;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User owner = ExperienceCloudRegistrationHandler.insertUser(p.Id, 'Owner', 'User', null, null, null, r.Id);
        return owner;
    }
    
}
