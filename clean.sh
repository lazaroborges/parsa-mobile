clean the caches 

rm -rf ~/Library/Developer/Xcode/DerivedData
pod deintegrate
pod cache clean --all

cd android
./gradlew clean
cd ..

rm -rf ~/.android/avd/*
rm -rf ~/Library/Android/sdk/system-images

rm -rf ~/Library/Developer/CoreSimulator
xcrun simctl erase all
