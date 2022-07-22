# aicycle_insurance_plugin

## 🚀&nbsp; Overview

Flutter plugin to add AICycle Insurance Widget inside your project.

### Set permissions
   - **iOS** add these on ```ios/Runner/Info.plist``` file

```xml
<key>NSCameraUsageDescription</key>
<string>Your own description</string>

<key>NSMicrophoneUsageDescription</key>
<string>Your own description</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Your own description</string>
```

  - **Android**
    - Set permissions before ```<application>```
    <br />

    ```xml
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />
    ```

    - Change the minimum SDK version to 21 (or higher) in ```android/app/build.gradle```
    <br />

    ```
    minSdkVersion 21
    ```
### Screenshots
- **Claim Folder Page**
![empty claim folder](screenshots/1658461061996.JPEG)
![claim folder](screenshots/1658461245554.JPEG)

- **Camera View**
![camera view of over view tab](screenshots/1658461062123.JPEG)
![camera view of middle view tab](screenshots/1658461062097.JPEG)
![image with damage mask after ai detection](screenshots/1658461062060.JPEG)

- **Preview Image Page**
![preview image page](screenshots/1658461062155.JPEG)
### Import the package
```dart
import 'package:aicycle_insurance/aicycle_insurance.dart';
```
