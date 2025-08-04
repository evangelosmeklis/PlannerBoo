# PlannerBoo Setup Instructions

## 🚨 CRITICAL: Info.plist Configuration Required

**The app will crash when requesting Calendar, Reminders, and Health permissions without proper Info.plist entries.**

### Step-by-Step Setup:

#### 1. Open Xcode Project Settings
1. Open your project in Xcode
2. Select the **PlannerBoo** target (not the project)
3. Go to the **"Info"** tab
4. Look for the "Custom iOS Target Properties" section

#### 2. Add Required Permission Descriptions

Click the **"+"** button next to any existing entry and add these **exact** keys:

| Key | Type | Value |
|-----|------|-------|
| `NSHealthShareUsageDescription` | String | `PlannerBoo would like to access your health data to display step counts and workout information in your daily planner.` |
| `NSHealthUpdateUsageDescription` | String | `PlannerBoo would like to update your health data to log activities from your planner.` |
| `NSCalendarsUsageDescription` | String | `PlannerBoo needs access to your calendar to create and sync events with your planner.` |
| `NSRemindersUsageDescription` | String | `PlannerBoo needs access to your reminders to create and manage tasks from your planner.` |
| `NSPhotoLibraryUsageDescription` | String | `PlannerBoo needs access to your photo library to add images to your planner pages.` |
| `NSPhotoLibraryAddUsageDescription` | String | `PlannerBoo needs permission to save images to your photo library from your planner.` |

#### 3. Enable Permissions in Code

After adding Info.plist entries, uncomment the permission code in `PermissionsManager.swift`:

1. Find the `checkCalendarAccess()`, `checkRemindersAccess()`, and `checkHealthAccess()` methods
2. Uncomment the code inside each method
3. Find the `requestCalendarAccess()`, `requestRemindersAccess()`, and `requestHealthAccess()` methods  
4. Uncomment the code inside each method
5. Update the onboarding view to re-enable the permission rows

#### 4. Add HealthKit Entitlement (Optional)

For HealthKit to work, you also need to add the capability:

1. **Select PlannerBoo target** → **"Signing & Capabilities" tab**
2. **Click "+ Capability"**
3. **Search for "HealthKit"** and double-click to add
4. **Verify** it shows as "HealthKit ✓"

#### 5. Enable HealthKit in Code (After Adding Entitlement)

After adding the HealthKit entitlement, uncomment the HealthKit code in `PermissionsManager.swift`.

## Current Status

**✅ Working Permissions:**
- Photos
- Calendar  
- Reminders

**⚠️ Disabled Permissions (require HealthKit entitlement):**
- Health & Fitness

## Features

### Page Navigation
- **Edge Dragging**: Drag from left/right edges to turn pages like a real book
- **Visual Feedback**: Page curl effect shows when dragging from edges
- **Smooth Animation**: 0.3s transitions between pages

### Tool Modes
- **🖊️ Pen Mode**: Draw with Apple Pencil or finger
- **🧽 Eraser Mode**: Erase drawings with adjustable size
- **📝 Text Mode**: Tap anywhere to add resizable text
- **📋 Sticky Note Mode**: Tap anywhere to add colored sticky notes

### Permissions
- **Photos**: Add images to planner pages
- **Calendar**: Create and sync events
- **Reminders**: Create and manage tasks
- **Health & Fitness**: Display step counts and workout data

## Usage Tips

1. **First Launch**: Grant all permissions for full functionality
2. **Page Turning**: Drag from the very edge of the screen (first 50 points)
3. **Tool Selection**: Always select the appropriate tool from the toolbar before use
4. **Text Resizing**: Tap on existing text to see resize and delete options
5. **Sticky Note Colors**: Choose from 5 different colors when creating sticky notes

## Troubleshooting

- **Permissions Not Working**: Make sure all Info.plist entries are added correctly
- **Page Turning Not Responsive**: Ensure you're dragging from the very edge of the screen
- **Drawing Not Working**: Select the Pen tool from the toolbar first
- **Text Input Not Working**: Select the Text tool from the toolbar first