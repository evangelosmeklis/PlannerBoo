# PlannerBoo Setup Instructions

## Required Info.plist Entries

To enable all permissions in PlannerBoo, you need to add the following entries to your Info.plist file through Xcode:

### How to Add Info.plist Entries:

1. Open your project in Xcode
2. Select the PlannerBoo target
3. Go to the "Info" tab
4. Click the "+" button to add new entries
5. Add each of the following keys with their descriptions:

### Required Entries:

| Key | Type | Value |
|-----|------|-------|
| `NSHealthShareUsageDescription` | String | `PlannerBoo would like to access your health data to display step counts and workout information in your daily planner.` |
| `NSHealthUpdateUsageDescription` | String | `PlannerBoo would like to update your health data to log activities from your planner.` |
| `NSCalendarsUsageDescription` | String | `PlannerBoo needs access to your calendar to create and sync events with your planner.` |
| `NSRemindersUsageDescription` | String | `PlannerBoo needs access to your reminders to create and manage tasks from your planner.` |
| `NSPhotoLibraryUsageDescription` | String | `PlannerBoo needs access to your photo library to add images to your planner pages.` |
| `NSPhotoLibraryAddUsageDescription` | String | `PlannerBoo needs permission to save images to your photo library from your planner.` |

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