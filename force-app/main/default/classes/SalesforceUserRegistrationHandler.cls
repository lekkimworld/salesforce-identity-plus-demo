public with sharing class SalesforceUserRegistrationHandler implements Auth.RegistrationHandler{
    public User createUser(ID portalId, Auth.UserData userData) {
        List<User> users = [SELECT Id FROM User WHERE FederationIdentifier =: userData.identifier];
        if (users.size() == 1) return users[0];
        throw new RegHandlerException('Cannot find user with FederationIdentitier <' + userData.identifier + '>'); 
    }

    public void updateUser(ID userId, ID portalId, Auth.UserData userData) {
        // nothing to do here
    }

    class RegHandlerException extends Exception {}
}
