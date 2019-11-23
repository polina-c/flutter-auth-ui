# flutter-auth-ui (faui)
**faui** is an authentication UI for Flutter. 
It registers users with email and password using Firebase security as a service 
( [SECaaS]( https://en.wikipedia.org/wiki/Security_as_a_service) ).
The library provides UI to register user, validate email, sign in, sign out and restore password.
Also it supports silent sign in.


**faui** is regularly tested for Web by [polina-c](https://github.com/polina-c).

If you regularly test the library for one of the platforms, say this here, please.

## Links


[Demo1](https://flatter-auth-ui-demo1.codemagic.app/#/) - default layout and phrasing

[Demo2](https://flatter-auth-ui-demo2.codemagic.app/#/) - custom layout and phrasing

[Pub package](https://pub.dev/packages/faui)

[Demo source code](https://github.com/polina-c/flutter-auth-ui/tree/master/example)

[Package source code](https://github.com/polina-c/flutter-auth-ui)


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
2. Update pubspec.yaml to make sure your project references necessary packages:
```
dependencies:
  ...
  faui: <latest version>
```
Check `<latest version>` [here](https://pub.dev/packages/faui).

### Update Code

In the beginning of the method `build` of the widget that requires 
authentication (it should be stateful), add the code:
```
if (faui.User == null) {
  return faui.buildAuthScreen(
    onExit: this.setState((){...}),
    firebaseApiKey: "...",
  );
}
```


Import:
```
import 'package:faui/faui.dart';
```


Get user email:

```
faui.user.email
```


Sign out: 
```
faui.signOut()
```


Silent sign-in:
```

// Before runApp:
WidgetsFlutterBinding.ensureInitialized();
await faui.trySignInSilently(firebaseApiKey: '...');
...

// After sign in with dialog:
faui.saveUserLocallyForSilentSignIn();
``` 

# Custom Layout and Language

To customize UI and/or language, invoke buildCustomAuthScreen instead of buildAuthScreen.
See [demo2](https://github.com/polina-c/flutter-auth-ui/tree/master/example/demo2) for details.

# Run Tests

```
flutter pub run test
```