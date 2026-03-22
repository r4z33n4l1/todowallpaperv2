# TodoWallpaper — Native SwiftUI Implementation

A native iOS app that generates beautiful wallpapers from your todo list using SwiftData, ImageRenderer, and App Intents.

## Features

✅ **SwiftData Persistence** — Your todos are stored locally and sync across the app  
✅ **Wallpaper Generation** — Use `ImageRenderer` to create high-quality wallpaper images  
✅ **Photo Library Integration** — Automatically saves to a dedicated "TodoWallpaper" album  
✅ **Shortcuts Integration** — Automate wallpaper generation via Siri, Shortcuts, or automation  
✅ **Clean UI** — Progress tracking, drag-to-reorder, swipe-to-delete  
✅ **iOS 17+ Ready** — Built for modern iOS with Swift 6 features  

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later deployment target
- Physical device or simulator (Photos access requires device for full testing)

### Installation

1. Open `todowallpaper2.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run (⌘R)

### Required Info.plist Configuration

Add the following key to your `Info.plist` to request photo library access:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>TodoWallpaper saves generated wallpapers to your photo library.</string>
```

**How to add this in Xcode:**
1. Select your project in the navigator
2. Select the **todowallpaper2** target
3. Go to the **Info** tab
4. Click the **+** button
5. Add "Privacy - Photo Library Additions Usage Description"
6. Set the value to the description above

## Usage

### Basic Todo Management

1. **Add todos** — Type in the text field at the bottom and press return or tap the + button
2. **Complete todos** — Tap the circle icon to mark as complete
3. **Edit todos** — Double-tap a todo to edit its title
4. **Delete todos** — Swipe left and tap Delete
5. **Reorder todos** — Tap Edit, then drag todos to reorder

### Generate Wallpaper Manually

1. Add some todos to your list
2. Tap the **photo icon** in the top-right toolbar
3. Preview the generated wallpaper
4. Tap **Save to Photos**
5. Go to Settings → Wallpaper → Choose a New Wallpaper
6. Select the image from the **TodoWallpaper** album
7. Set as Lock Screen, Home Screen, or both

### Automate with Shortcuts (Recommended!)

This is where the magic happens — automated wallpaper updates every morning.

**One-time setup:**

1. Open the **Shortcuts** app
2. Create a new **Automation** (not a Shortcut)
3. Choose **Time of Day** trigger (e.g., every day at 7:00 AM)
4. Tap **Add Action**
5. Search for "Generate Todo Wallpaper" (this is your app's intent)
6. Add it to the automation
7. (Optional) Add the system **Set Wallpaper** action to automatically apply it
8. Toggle off "Ask Before Running" for fully silent automation
9. Done!

Now your wallpaper will automatically update every morning with your current todo list.

**Siri Integration:**

You can also trigger wallpaper generation by saying:
- "Hey Siri, generate wallpaper with TodoWallpaper"
- "Hey Siri, update my TodoWallpaper"
- "Hey Siri, refresh TodoWallpaper wallpaper"

## Architecture

The app follows a clean architecture with clear separation of concerns:

```
todowallpaper2/
├── Models/
│   └── TodoItem.swift          # SwiftData model
├── Services/
│   ├── WallpaperGenerator.swift    # ImageRenderer wrapper
│   ├── PhotoLibraryManager.swift   # Photos framework wrapper
│   └── TodoStore.swift             # Shared business logic
├── Views/
│   ├── TodoListView.swift          # Main UI
│   ├── WallpaperTemplateView.swift # Wallpaper layout design
│   └── WallpaperPreviewView.swift  # Preview sheet
├── Intents/
│   ├── GenerateWallpaperIntent.swift   # AppIntent for Shortcuts
│   └── TodoShortcutsProvider.swift     # Auto-registration
├── Shared/
│   └── AppGroupContainer.swift     # App Group support (for widgets)
└── Extensions/
    └── Color+Hex.swift             # Hex color support
```

## Roadmap

### Phase 1: Core Features (✅ Complete)
- [x] Todo list with SwiftData persistence
- [x] Wallpaper generation with ImageRenderer
- [x] Photo library integration
- [x] App Intents for Shortcuts
- [x] Basic UI with progress tracking

### Phase 2: Widget Support (Coming Soon)
- [ ] Lock Screen widget showing top 3 todos
- [ ] Circular gauge widget showing completion %
- [ ] Inline widget showing remaining tasks
- [ ] App Group data sharing

### Phase 3: Advanced Features
- [ ] Multiple wallpaper themes/templates
- [ ] Custom colors and fonts
- [ ] Subtasks and categories
- [ ] iCloud sync via CloudKit

### Phase 4: Polish
- [ ] Onboarding flow
- [ ] Help/tutorial screens
- [ ] App icon and splash screen
- [ ] Haptic feedback

## Technical Details

### SwiftData
- Uses `@Model` macro for automatic persistence
- `@Query` for reactive UI updates
- Single source of truth via `ModelContext`

### ImageRenderer
- Renders SwiftUI views to high-quality images
- Full device pixel resolution (no quality loss)
- No hidden off-screen view hacks

### App Intents
- Registered automatically via `AppShortcutsProvider`
- Returns `IntentFile` for chaining with system actions
- Runs without opening the app (`openAppWhenRun = false`)

### Photo Library
- Uses `.addOnly` authorization (minimal permissions)
- Creates dedicated "TodoWallpaper" album
- Handles both authorization states gracefully

## Troubleshooting

### Wallpaper generation fails
- Ensure you have at least one todo in your list
- Check that the app has background processing capability
- Try force-quitting and relaunching the app

### Photos permission denied
- Go to Settings → Privacy & Security → Photos
- Find TodoWallpaper and grant "Add Photos Only" permission

### Shortcuts not appearing
- Shortcuts auto-register on first launch
- Force-quit the Shortcuts app and relaunch
- Make sure the app has been launched at least once

### Widget not updating (future feature)
- Ensure App Group is configured in both targets
- Widget updates are throttled by the system
- Call `WidgetCenter.shared.reloadAllTimelines()` after changes

## Contributing

This is a reference implementation based on the TodoWallpaper architecture spec. Feel free to:
- Add new wallpaper templates
- Improve the UI/UX
- Add more automation capabilities
- Implement the widget extension

## License

MIT License - feel free to use this as a template for your own projects.

## Acknowledgments

- Inspired by the Expo TodoWallpaper app
- Built with SwiftUI, SwiftData, and App Intents
- Uses iOS 17+ features for modern native experience
