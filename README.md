# flutter-auth-ui (faui)
**faui** is an authentication UI for Flutter. 
It registers users with email and password using Firebase security as a service 
( [SECaaS]( https://en.wikipedia.org/wiki/Security_as_a_service) ).
The library provides UI to register user, validate email, sign in, sign out and restore password.
Also it supports silent sign in.

## Demos

[Sign in on application load](https://flatter-auth-ui-demo0.codemagic.app/#/)

[Sign in on button click](https://flatter-auth-ui-demo1.codemagic.app/#/)

[Custom layout and phrasing](https://flatter-auth-ui-demo2.codemagic.app/#/)

[Use token to access Firestore](https://flatter-auth-ui-demo3.codemagic.app/#/)

Find the source code [here](https://github.com/polina-c/flutter-auth-ui/tree/master/example)

## Links

[Pub package](https://pub.dev/packages/faui)

[Demo source code](https://github.com/polina-c/flutter-auth-ui/tree/master/example)

[Package source code](https://github.com/polina-c/flutter-auth-ui)


## Usage


### Create Project in Firebase
If you want to test the library, use the demo project:
  
`apiKey: "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4"`

To create your own Firebase project:

1. Sign in to firebase console https://console.firebase.google.com/
1. Add, configure and open project
1. In the project open tab "Authentication" and then tab "Sign-in Method"
1. Click "Email/Password", set "Enable" and click "Save"
1. Select "Project Settings" (gear icon)
1. Copy your "Web API Key"
	
### Set Dependency
Update pubspec.yaml to make sure your project references necessary packages:
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
if (fauiUser == null) {
  return fauiBuildAuthScreen(
    onExit: this.setState((){...}),
    firebaseApiKey: "...",
  );
}
```


Import you need:
```
import 'package:faui/faui.dart';
```


Get user email:

```
fauiUser.email
```


Sign out: 
```
fauiSignOut()
```


Silent sign-in:
```

// Before runApp:
WidgetsFlutterBinding.ensureInitialized();
await fauiTrySignInSilently(firebaseApiKey: '...');
...

// After sign in with dialog:
fauiSaveUserLocallyForSilentSignIn();
``` 

## Custom Layout and Language

To customize UI and/or language, invoke fauiBuildCustomAuthScreen instead of fauiBuildAuthScreen.

See [the demo](https://github.com/polina-c/flutter-auth-ui/tree/master/example/custom_ui) for the details.

## Use the Retrieved Token to Access Your Data to Database

Utilize methods loadDoc and saveDoc of the class FauiDbAccess.

See [the demo](https://github.com/polina-c/flutter-auth-ui/tree/master/example/access_data) for the details.


# Contribute

## Run Tests

```
flutter pub run test
```

## Meet Coding Style

We follow [dart styling](export).
