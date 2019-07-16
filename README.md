# flutterAuth
**flutter_auth** is an authentication library for flutter web applications. 
Uses Firebase security as a service 
( [SECaaS]( https://en.wikipedia.org/wiki/Security_as_a_service) ) to sign in with email and password.
The library rovides UI to register user, validate email, sign in, sign out, restore password.

The library works with [flutter for web tech preview](https://github.com/flutter/flutter_web),
 with intent to switch to production, and to start supporting iOS and Android, 
as soon as flutter for web gets released.

## Getting Started

### Create Project in Firebase
To test the library you can use apiKey of the demo project:   
`"AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4"`.

Then you will want to switch to your own project:

1. Sign in to firebase console https://console.firebase.google.com/
1. Add, configure and open project
1. In the project open tab "Authentication" and then tab "Sign-in Method"
1. Click "Email/Password", set "Enable" and click "Save"
1. Select "Project Settings" (gear icon)
1. Copy your "Web API Key"
	
### Set Dependency
While flitter_web is not published in pub, the packages that depend on it, cannot be published too. 
So, you need to take co-development dependency:

1. Create folder 'external' under your 'lib'


1. Clone flutter_auth into it:
```
cd lib/external
git clone https://github.com/pcherkasova/flutter_auth.git
```
3. Add line "lib/external/" to .gitignore of your project

### Update Code

In the beginning of the method `build` of the widget that requires 
authentication (it should be stateful), add the code:
```
if (fa.User == null) {
  return fa.BuildAuthScreen(
    onSuccess: this.setState((){...}),
    onCancel: this.setState((){...}),
    firebaseApiKey: "...",
  );
}
```


Packages to import:
```
import 'package:job_chat.ui/external/flutter_auth/lib/flutter_auth.dart';
import 'package:job_chat.ui/external/flutter_auth/lib/flutter_auth_model.dart';
```


To get user email call `fa.User.email`. 

Sign out by calling `fa.SignOut()`.
 



