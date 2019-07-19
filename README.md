# flutter-auth-ui (faui)
**faui** is an authentication library for flutter web applications. 
It registers users with email and password using Firebase security as a service 
( [SECaaS]( https://en.wikipedia.org/wiki/Security_as_a_service) ).
The library provides UI to register user, validate email, sign in, sign out and restore password.

The library works with [flutter for web tech preview](https://github.com/flutter/flutter_web),
 with intent to switch to production, and to start supporting iOS and Android, 
as soon as flutter for web gets released.

## Demo
Explore UX [here](https://flutter-auth-ui-demo.codemagic.app/#/).

Source code: [flutter-auth-ui-demo](https://github.com/polina-c/flutter-auth-ui-demo).

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
So, you need to setup submodule:

1. Run:
```
git submodule add https://github.com/polina-c/flutter-auth-ui ./lib/external/flutter-auth-ui
```

2. Update pubspec.yaml to make sure your project references necessary packages:
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
if (faui.User == null) {
  return faui.BuildAuthScreen(
    onSuccess: this.setState((){...}),
    onCancel: this.setState((){...}),
    firebaseApiKey: "...",
  );
}
```


Packages to import:
```
import 'package:<your app name>/external/flutter-auth-ui/lib/faui.dart';
import 'package:<your app name>/external/flutter-auth-ui/lib/faui_model.dart';
```


Get user email: `faui.User.email` 

Sign out: `faui.SignOut()`
 



