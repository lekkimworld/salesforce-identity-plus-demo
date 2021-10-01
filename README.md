# Demo Apex Registration Handlers for use with Salesforce Identity Plus

This repo has a number of Apex Registration Handlers for use with both the Salesforce Lightning UI (SalesCloud / ServiceCloud / Platform, `SalesforceUserRegistrationHandler.cls`) and with Experience Cloud (`ExperienceCloudRegistrationHandler.cls`). Both have unit tests as well so they may be deployed to a trial org as that's a production org that requires Apex unit tests.

The Salesforce Lightning UI Registration Handler will look up the user based on the Auth0 user ID in the `FederationIdentifier` field on the User record and does not support user creation. The Experience Cloud registration handler attempts to look up the user on `FederatiobnIdentifier` as well and does support user creation (account, contact and user records).

_Please Note:_ To create portal users the user executing the code _must_ have a role specified on the user record in Salesforce. If that's not set the code will fail. Ensure the user running the registration handler has a role set. If need be you might need to create a dummy role in the org and assign that role to your user. See the "Ensure current user has a role" below.

The project also contains an custom profile for Experience Cloud users (`Demo CC Plus`).

## Deploy to an org

The below snippet uses the Salesforce CLI to deploy the Apex classes in this project to the default org and run the tests in the org. If need be you may target a specific org using the `-u <username>` flag.

```
sfdx force:source:deploy -m ApexClass --testlevel=RunAllTestsInOrg --verbose
```

## Ensure current user has a role

```
UserRole r = new UserRole();
r.Name = 'Dummy';
INSERT r;
User u = [SELECT Id,UserRoleId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
u.UserRoleId = r.Id;
UPDATE u;
```
