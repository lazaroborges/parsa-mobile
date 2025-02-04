clean the caches 

rm -rf ~/Library/Developer/Xcode/DerivedData
pod deintegrate
pod cache clean --all

cd android
./gradlew clean
cd ..