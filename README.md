# fa
**fa** is an authentication library for flutter web applications. 
It registers users with email and password using Firebase security as a service 
( [SECaaS]( https://en.wikipedia.org/wiki/Security_as_a_service) ).
The library provides UI to register user, validate email, sign in, sign out and restore password.

The library works with [flutter for web tech preview](https://github.com/flutter/flutter_web),
 with intent to switch to production, and to start supporting iOS and Android, 
as soon as flutter for web gets released.

## Getting Started

### Create Project in Firebase
To test the library use demo project. 
  
`apiKey: "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4"`

Then you will want to create your project:

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


1. Clone **fa** into it:
```
cd lib/external
git clone https://github.com/pcherkasova/fa.git
```
3. Add line "lib/external/" to .gitignore of your project

4. Make sure your project references necessary packages in pubspec.yaml:
```
dependencies:
  ...
  http: ^0.12.0+2
  uuid: 2.0.1

dev_dependencies:
  ...
  test: any
```

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
import 'package:job_chat.ui/external/fa/lib/fa.dart';
import 'package:job_chat.ui/external/fa/lib/fa_model.dart';
```


Get user email: `fa.User.email` 

Sign out: `fa.SignOut()`
 



