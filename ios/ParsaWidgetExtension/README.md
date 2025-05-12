# Parsa Finance Widget

This directory contains the iOS widget extension for Parsa Finance App. The widget displays:
- Available balance
- Income for the current period
- Expenses for the current period

## Setup in Xcode

After running `pod install`, you need to manually add the widget extension target in Xcode:

1. Open the `Runner.xcworkspace` in Xcode
2. Add a new target by clicking on the + button in the bottom-left corner of the Targets list
3. Select "Widget Extension" from the template list
4. Name it "ParsaWidgetExtension" and make sure "Include Configuration Intent" is NOT checked
5. When prompted to activate the new scheme, click "Activate"
6. Delete the auto-generated files and replace them with the ones from this directory

## Set up App Groups

1. Go to your main app target (Runner) settings
2. Select the "Signing & Capabilities" tab
3. Click "+ Capability" and add "App Groups"
4. Add the group: `group.com.parsaai.financetracker`
5. Similarly, add the same App Group capability to the ParsaWidgetExtension target
6. Ensure both targets' entitlements files include the App Group identifier

## Build Settings

Make sure both targets have:
- iOS Deployment Target set to iOS 14.0
- Same bundle identifier prefix (the widget should have a suffix like .ParsaWidgetExtension)
- Same version and build numbers

## Testing the Widget

1. Run the app first to initialize the data
2. Then run the widget extension target to test the widget
3. In the Simulator, long-press on the home screen to enter jiggle mode
4. Tap the "+" button to add a widget
5. Search for "Parsa" and add the widget to your home screen

## Troubleshooting

- If the widget shows default values (0.0), make sure the app has run and updated the shared UserDefaults
- Check that the App Group identifiers match exactly in both the main app and widget entitlements files
- Verify that the data is properly passed through the method channel 