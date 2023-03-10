# flutter_sample_app

Sample App - Flutter Plugin for Responsys SDK.

This project is a reference for integrating the Flutter plugin for Responsys Mobile SDK within your app.

## Getting Started

Before building the project, you must do a few things to setup the sample app.

### For Android
- [Get FCM Credentials](https://docs.oracle.com/en/cloud/saas/marketing/responsys-develop-mobile/android/gcm-credentials) 
- Log in to the [Responsys Mobile App Developer Console](https://docs.oracle.com/en/cloud/saas/marketing/responsys-develop-mobile/dev-console/login/) and enter your FCM credentials (Project ID and Server API Key) for your Android app.
- Get the `pushio_config.json` file generated from your credentials and place it in the project's `android/app/src/main/assets` folder.
- Download the native SDK from [here](https://www.oracle.com/downloads/applications/cx/responsys-mobile-sdk.html) and place it in the project's `android/app/libs` folder. 


### For iOS
- [Generate Auth Key](https://docs.oracle.com/en/cloud/saas/marketing/responsys-develop-mobile/ios/auth-key/) 
- Log in to the [Responsys Mobile App Developer Console](https://docs.oracle.com/en/cloud/saas/marketing/responsys-develop-mobile/dev-console/login/) and enter your Auth Key and other details for your iOS app.
- Download the `pushio_config.json` file generated from your credentials.
- Download the native SDK from [here](https://www.oracle.com/downloads/applications/cx/responsys-mobile-sdk.html)
- Copy `PushIOManager.xcframework` and place it in the plugin ios directory - `pushiomanager-flutter/ios/`. 
- run `flutter pub add pushiomanager_flutter --path=<path of plugin>` from command-line to install the plugin
- run `flutter build ios` from command-line to build on iOS devices.
- run `flutter run ios` from command-line to run on iOS devices.






