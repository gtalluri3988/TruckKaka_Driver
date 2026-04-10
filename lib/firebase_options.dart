import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Values sourced from android/app/google-services.json (com.asva.truckkakadriver)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjYJgVUS4svmrHvYUcBuI0G5hrFBOoIBI',
    appId: '1:374485808141:android:abb06022933a36710a9144',
    messagingSenderId: '374485808141',
    projectId: 'asva-3bb8c',
    storageBucket: 'asva-3bb8c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '374485808141',
    projectId: 'asva-3bb8c',
    storageBucket: 'asva-3bb8c.firebasestorage.app',
    iosBundleId: 'com.asva.truckkakadriver',
  );
}
