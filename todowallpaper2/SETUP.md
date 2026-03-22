# Setup Guide — TodoWallpaper Native

## Quick Start Checklist

Follow these steps to get your TodoWallpaper app fully functional:

### ✅ Step 1: Add Photo Library Permission

Your app needs permission to save wallpapers to the photo library.

**In Xcode:**
1. Select your project in the Project Navigator
2. Select the **todowallpaper2** target
3. Click the **Info** tab
4. Click the **+** button to add a new key
5. Choose **Privacy - Photo Library Additions Usage Description**
6. Enter this value:
   ```
   TodoWallpaper saves generated wallpapers to your photo library.
   ```

**Or edit Info.plist directly:**
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>TodoWallpaper saves generated wallpapers to your photo library.</string>
```

### ✅ Step 2: Build and Run

1. Connect your iPhone or use the simulator
2. Select your device in the Xcode toolbar
3. Press **⌘R** to build and run
4. The app should launch showing an empty todo list

### ✅ Step 3: Test Core Functionality

**Add some todos:**
- Type "Buy groceries" in the text field
- Tap the + button or press Return
- Add 3-5 more todos

**Mark some complete:**
- Tap the circle icon next to a todo
- Watch the progress bar update

**Generate your first wallpaper:**
- Tap the **photo icon** (top-right corner)
- Wait for the wallpaper to render
- Preview the result
- Tap **Save to Photos**
- Grant photo library permission when prompted
- Check the Photos app → Albums → TodoWallpaper

### ✅ Step 4: Set as Wallpaper (Manual)

1. Open the **Settings** app
2. Go to **Wallpaper**
3. Tap **Choose a New Wallpaper**
4. Select **Photos** → **Albums** → **TodoWallpaper**
5. Choose the generated image
6. Set as Lock Screen, Home Screen, or both

---

## Advanced Setup (Optional)

### Enable App Intents for Shortcuts Automation

The app already includes App Intents code, but for background execution you may need to verify capabilities:

**In Xcode:**
1. Select your project → Target → **Signing & Capabilities**
2. Ensure **App Intents** is listed (it should be auto-added)
3. Build and run the app once to register the intent

**Test the Shortcut:**
1. Open the **Shortcuts** app
2. Tap the **+** button to create a new shortcut
3. Search for "Generate Todo Wallpaper"
4. Add it to your shortcut
5. Tap the ▶️ button to test it
6. The wallpaper should generate without opening your app

### Create an Automation

**Automated daily wallpaper updates:**

1. Open **Shortcuts** app
2. Go to the **Automation** tab
3. Tap **+** → **Create Personal Automation**
4. Choose **Time of Day**
5. Set time to 7:00 AM (or whenever you want)
6. Choose **Daily**
7. Tap **Next**
8. Search for "Generate Todo Wallpaper"
9. Add it to the automation
10. **(Optional)** Add "Set Wallpaper" action after it:
    - Search for "Set Wallpaper"
    - Choose Lock Screen or Home Screen
    - Select the image from the previous action
11. Tap **Next**
12. **IMPORTANT:** Toggle OFF "Ask Before Running"
13. Tap **Done**

Now your wallpaper updates automatically every morning at 7 AM!

### Siri Voice Commands

Once you've run the app, you can use these Siri phrases:

- "Hey Siri, generate wallpaper with TodoWallpaper"
- "Hey Siri, update my TodoWallpaper"
- "Hey Siri, refresh TodoWallpaper wallpaper"

---

## Future: Widget Extension Setup

The current implementation includes all the core logic needed for widgets. To add Lock Screen widgets:

### Create Widget Extension

1. In Xcode: **File → New → Target**
2. Choose **Widget Extension**
3. Name it "TodoWidget"
4. Check "Include Configuration Intent" = **NO** (we're using static widgets)
5. Click **Finish**

### Add App Group (Required for Widget Data Sharing)

**In the main app target:**
1. Select project → **todowallpaper2** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** to add a new group
6. Enter: `group.com.yourapp.todowallpaper` (replace `yourapp` with your team/bundle ID)
7. Check the checkbox

**In the widget extension target:**
1. Select **TodoWidget** target
2. Repeat the same steps above
3. Use the **same** App Group identifier

### Update Model Container Configuration

In `todowallpaper2App.swift`, uncomment the App Group configuration:

```swift
let config = ModelConfiguration(
    schema: schema,
    url: URL.appGroupContainer.appending(path: "TodoWallpaper.sqlite"),
    cloudKitDatabase: .none
)
```

And comment out the default configuration.

### Create Widget Files

You'll need to create these files in the widget target:
- `TodoWidget.swift` — Widget configuration
- `TodoTimelineProvider.swift` — Timeline provider
- `TodoWidgetViews.swift` — Widget UI

Refer to the main architecture document for the complete widget implementation.

---

## Troubleshooting

### Issue: "Photo library access denied"
**Solution:** 
- Go to Settings → Privacy & Security → Photos
- Find "todowallpaper2"
- Select "Add Photos Only" or "Full Access"

### Issue: "Shortcuts not showing up"
**Solution:**
- Force-quit the Shortcuts app (swipe up from app switcher)
- Force-quit the TodoWallpaper app
- Relaunch TodoWallpaper
- Open Shortcuts app again
- Look for "Generate Todo Wallpaper" in the search

### Issue: "Wallpaper generation fails"
**Solution:**
- Make sure you have at least 1 todo in your list
- Check Xcode console for error messages
- Try deleting and reinstalling the app

### Issue: "Automation doesn't run"
**Solution:**
- Make sure "Ask Before Running" is toggled OFF
- Check that the automation is enabled (toggle at top of automation page)
- iOS may delay automations if battery is low or Low Power Mode is on
- Test manually by tapping "Run" in the automation details

### Issue: "App crashes on launch"
**Solution:**
- Check Xcode console for error messages
- Make sure you updated the SwiftData model from `Item` to `TodoItem`
- Try deleting the app and doing a clean build (⌘⇧K, then ⌘R)

---

## Next Steps

Once you have the basic app working:

1. **Customize the wallpaper design** in `WallpaperTemplateView.swift`
2. **Add more todo features** (categories, due dates, priorities)
3. **Implement widgets** for Lock Screen glanceable info
4. **Add themes** to customize colors and fonts
5. **Improve UI** with animations and haptics

Happy coding! 🎉
