public with sharing class ExperienceCloudRegistrationHandler implements Auth.RegistrationHandler{
    public final static String PROFILE_NAME = 'Demo CC Plus';
    public User createUser(ID portalId, Auth.UserData userData) {
        final List<User> users = [SELECT Id, ContactId, FederationIdentifier, Email, Username FROM User WHERE FederationIdentifier =: userData.identifier];
        if (users.size() == 1) return users[0];

        // get profile
        final List<Profile> profiles = [SELECT Id FROM Profile WHERE Name =: PROFILE_NAME];
        if (profiles.size() != 1) {
            throw new RegHandlerException('Unable to find profile with Name <' + PROFILE_NAME + '>');
        }
        final Profile p = profiles[0];

        // generate names
        final String fn = 'First (' + userData.firstName + ')';
        final String ln = 'Last (' + userData.lastName + ')';

        // create account and contact
        final Account a = new Account();
        a.Name = fn + ' ' + ln + ' Account';
        insert a;
        final Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = fn;
        c.LastName = ln;
        insert c;

        // create user
        final String alias = generateAlias();
        User u = insertUser(p.Id, fn, ln, alias, userData.identifier, c.Id, null);
        return u;
    }

    public void updateUser(ID userId, ID portalId, Auth.UserData userData) {
        // nothing to do here
    }

    public static String generateAlias() {
        return EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 8);
    }

    public static User insertUser(String profileId, String fn, String ln, String alias, String federationId, String contactId, String roleId) {
        String useAlias = alias;
        String useFederationId = federationId;
        if (String.isEmpty(useAlias)) {
            useAlias = generateAlias();
        }
        if (String.isEmpty(useFederationId)) {
            useFederationId = useAlias + '@federation.-example.com';
        }
        final String username = useAlias + '@username.example.com';
        final String email = useAlias + '@example.com';

        User u = new User();
        u.username = username;
        u.email = email;
        u.lastName = ln;
        u.firstName = fn;
        u.alias = useAlias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'da';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'Europe/Paris';
        u.profileId = profileId;
        u.FederationIdentifier = useFederationId;
        if (!String.isEmpty(contactId)) u.ContactId = contactId;
        if (!String.isEmpty(roleId)) u.UserRoleId = roleId;
        insert u;
        return u;
    }

    class RegHandlerException extends Exception {}
}
