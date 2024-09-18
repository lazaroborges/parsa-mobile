const String flutterPluggyConnectSdkPackageName = 'flutter-pluggy-connect';

// TODO this should always reflect the version of the released pubspec.yaml! find a way to automatize this?
//  maybe something like this? https://stackoverflow.com/a/69048343/6279385
const String flutterPluggyConnectSdkPackageVersion = '2.0.0';

getSdkVersion() {
  return '$flutterPluggyConnectSdkPackageName@$flutterPluggyConnectSdkPackageVersion';
}
