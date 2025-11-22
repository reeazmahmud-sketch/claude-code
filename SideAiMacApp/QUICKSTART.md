# Quick Start Guide

Welcome to SideAi! This guide will help you get started quickly.

## First Time Setup

### 1. Installation

**Option A: Build from Source (Xcode)**
```bash
cd SideAiMacApp
open Package.swift  # Opens in Xcode
```
Then press `Cmd+R` to build and run.

**Option B: Build from Terminal**
```bash
cd SideAiMacApp
swift build
swift run
```

### 2. First Launch

When you launch SideAi for the first time:

1. **Welcome Screen**: You'll see a welcome message
2. **Feature Tour**: Learn about the main features
3. **Notification Permissions**: Click "Enable Notifications" to allow alerts
4. **Get Started**: Click "Get Started" to begin using the app

### 3. Enable Notifications

For the best experience, enable notifications:
- Click "Enable Notifications" during onboarding, OR
- Go to System Settings → Notifications → SideAi → Allow Notifications

## Basic Operations

### Creating Your First Task

1. Look for the **Tasks** section in the sidebar (it's selected by default)
2. Click the **+** button in the top-right corner
3. Fill in the task details:
   - **Title**: "Finish project report" (required)
   - **Description**: "Complete Q4 analysis" (optional)
   - **Priority**: Choose Medium, High, etc.
   - **Due Date**: Toggle on and select a date
   - **Reminder**: Toggle on to get notified
4. Click **Add**

Your task now appears in the list!

### Managing Tasks

**Mark as Complete**:
- Click the circle icon next to the task

**Edit a Task**:
- Click on the task to open details
- Click "Edit" in the top-right
- Make changes and click "Done"

**Delete a Task**:
- Swipe left on the task
- Click the red "Delete" button

**Search Tasks**:
- Use the search bar at the top
- Type any part of the title or description

**Filter Tasks**:
- Click the filter icon (three horizontal lines)
- Select a priority level

### Scheduling Events

1. Click **Schedule** in the sidebar
2. The calendar appears on the left
3. Click any date to select it
4. Click the **+** button to add an event
5. Fill in event details:
   - **Title**: "Team meeting" (required)
   - **Description**: "Weekly sync" (optional)
   - **Location**: "Conference Room A" (optional)
   - **Time**: Set start and end times
   - **All Day**: Toggle if it's an all-day event
6. Click **Add**

The event appears in the list for that day!

### Setting Reminders

1. Click **Reminders** in the sidebar
2. Click the **+** button
3. Fill in reminder details:
   - **Title**: "Call dentist" (required)
   - **Notes**: "Schedule checkup" (optional)
   - **Date & Time**: When to be reminded
   - **Repeat**: Choose None, Daily, Weekly, or Monthly
4. Click **Add**

You'll get a notification at the specified time!

## Using Settings

### Accessing Settings

Press `Cmd+,` or go to the menu: **SideAi → Settings**

### Quick Settings Guide

**General Tab**:
- Change default task priority
- Toggle completed task visibility
- Enable auto-delete for old completed tasks
- Enable calendar integration (coming soon)

**Notifications Tab**:
- Enable/disable notifications
- Adjust default reminder time (5-60 minutes)
- Check notification authorization status

**Appearance Tab**:
- Choose theme: Light, Dark, or System
- Interface customization options

**Advanced Tab**:
- View data management options
- Check encryption status
- View app version and build
- Reset onboarding (for testing)

## Tips & Tricks

### Keyboard Shortcuts

- `Cmd+,` - Open Settings
- `Cmd+W` - Close Window
- `Cmd+Q` - Quit App
- `Enter` - Confirm/Save in dialogs
- `Escape` - Cancel/Close dialogs

### Productivity Tips

1. **Use Priority Colors**: Quick visual scanning
   - 🔴 Urgent: Do immediately
   - 🟠 High: Do today
   - 🟢 Medium: Do this week
   - 🔵 Low: Do when possible

2. **Set Reminders**: Never miss deadlines
   - Set task reminders for important items
   - Use repeating reminders for recurring tasks
   - Check "Show Completed" to review what you've done

3. **Schedule Everything**: Use the calendar
   - Block time for focused work
   - Add locations to events
   - Set all-day events for important dates

4. **Stay Organized**:
   - Use descriptive task titles
   - Add detailed descriptions for context
   - Filter by priority to focus on what matters

### Best Practices

**Daily Routine**:
1. Morning: Review today's tasks and events
2. Set priorities for the day
3. Add any new tasks that come up
4. Evening: Mark completed tasks and plan tomorrow

**Weekly Review**:
1. Check overdue reminders
2. Review completed tasks
3. Plan events for the upcoming week
4. Adjust priorities as needed

## Troubleshooting

### Notifications Not Working

**Problem**: Not receiving notifications

**Solutions**:
1. Check notification permissions:
   - Settings app → Notifications tab
   - Look for authorization status
2. Grant permission in macOS:
   - System Settings → Notifications
   - Find "SideAi" and enable notifications
3. Check notification settings:
   - Settings → Notifications tab
   - Ensure "Enable Notifications" is ON

### Data Not Saving

**Problem**: Tasks/events disappear after restart

**Solutions**:
1. Check file permissions:
   - Data is stored in your Documents folder
   - Ensure the app has write permissions
2. Check disk space:
   - Ensure you have available storage
3. Try resetting:
   - Settings → Advanced → Manage Data

### App Won't Launch

**Problem**: Application crashes or won't start

**Solutions**:
1. Check macOS version:
   - Requires macOS 13.0 (Ventura) or later
2. Rebuild the app:
   ```bash
   cd SideAiMacApp
   swift build --clean
   swift build
   ```
3. Check Console app for errors:
   - Open Console.app
   - Filter for "SideAi"

## Common Questions

**Q: Where is my data stored?**
A: In your Documents folder (`~/Documents/`), encrypted for security.

**Q: Is my data synced to the cloud?**
A: No, all data stays on your Mac. iCloud sync is planned for the future.

**Q: Can I export my data?**
A: Export functionality is coming soon. Currently, data is stored as encrypted JSON files.

**Q: How do I backup my data?**
A: Time Machine will backup your data automatically. You can also manually copy the encrypted files from your Documents folder.

**Q: Can I use this on multiple Macs?**
A: Currently, data is local to each Mac. Cloud sync is planned for future releases.

**Q: Is my data secure?**
A: Yes! All data is encrypted using macOS Keychain before being stored on disk.

## Getting Help

If you encounter issues:

1. **Check this guide**: Most common questions are answered here
2. **Review the documentation**:
   - `README.md` - Overview and features
   - `DEVELOPMENT.md` - Technical details
   - `FEATURES.md` - Complete feature list
3. **Check Console logs**: Open Console.app to see error messages

## Next Steps

Now that you're set up:

1. ✅ Create a few sample tasks
2. ✅ Add an event to your schedule
3. ✅ Set a reminder
4. ✅ Customize your settings
5. ✅ Explore the interface

Enjoy using SideAi to boost your productivity! 🚀
