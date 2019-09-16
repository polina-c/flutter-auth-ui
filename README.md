# flutter-auth-ui (faui)
**faui** is an authentication UI for Flutter. 
It registers users with email and password using Firebase security as a service 
( [SECaaS]( https://en.wikipedia.org/wiki/Security_as_a_service) ).
The library provides UI to register user, validate email, sign in, sign out and restore password.
Also it supports silent sign in.

## Links

[Pub pakage](https://pub.dev/packages/faui)

[Package source code](https://github.com/polina-c/flutter-auth-ui)

[Demo](http://teeny-tiny-stranger.surge.sh/#/)

[Demo source code](https://github.com/polina-c/flutter-auth-ui/tree/master/example)


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

### Update Code

In the beginning of the method `build` of the widget that requires 
authentication (it should be stateful), add the code:
```
if (faui.User == null) {
  return faui.BuildAuthScreen(
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
faui.User.email
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



