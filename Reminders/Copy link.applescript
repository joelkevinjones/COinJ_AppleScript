-- Paste link to currently selected item in Reminders into the clipboard
-- See "URLs to application objects" evernote:///view/77035978/s435/9770ed42-593f-45ac-97cb-757786e9aa5f/9770ed42-593f-45ac-97cb-757786e9aa5f/ to determine what the URL schema (if any) to use
-- bundle id: Reminders ... claimed schemes: x-apple.reminderkit:
-- /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump | egrep '^(claim id|bindings):'
-- claim id:                   Reminders List (0xb7c)
-- bindings:                   com.apple.reminders.list
-- claim id:                   ReminderKit (0xb80)
-- bindings:                   x-apple-reminderkit:
-- ...
-- claim id:                   Reminders List (0xb9d8)
-- bindings:                   com.apple.reminders.list
-- ...
-- claim id:                   ReminderKit (0xb9dc)
-- bindings:                   x-apple-reminderkit:

-- Is Reminders App Linkable? - Discussion & Help - Hook Productivity Forum https://discourse.hookproductivity.com/t/is-reminders-app-linkable/2397/8
to findAndReplaceInText(theText, theSearchString, theReplacementString)
	set AppleScript's text item delimiters to theSearchString
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to theReplacementString
	set theText to theTextItems as string
	set AppleScript's text item delimiters to ""
	return theText
end findAndReplaceInText

tell application "System Events"
	set reminders to application process "Reminders"
	--tell reminders
	set theWindow to 1st window of reminders
	set isFocused to false
	repeat with theRow in rows of outline 1 of scroll area 1 of UI element 3 of splitter group 1 of theWindow
		try
			set uiElement to UI element 1 of theRow
			get UI elements of uiElement -- button 1, text field 1
			get properties of text field 1 of uiElement
			set isFocused to value of attribute "AXFocused" of text field 1 of uiElement
		on error the error_message number the error_number
			if not (error_number is equal to -1708 or error_number is equal to -1719) then
				display dialog "Error: " & the error_number & ". " & the error_message buttons {"OK"} default button 1
			end if
		end try
		if isFocused then
			get properties of uiElement
			--set reminderDescription to accessibility description of uiElement -- UI element 1 of reminderOutline
			set theReminderName to value of text field 1 of uiElement
			--set theReminderName to reminderDescription
			--if reminderDescription contains "Incomplete, " then
			--	set theReminderName to findAndReplaceInText(reminderDescription, "Incomplete, ", "") of me
			--end if
		end if
	end repeat
end tell
tell application "Reminders"
	-- TO DO modify to set lookupKey to min(length of theReminderName, 40)
	set lookupKey to characters 1 through 5 of theReminderName as string
	set theReminder to the first reminder whose name starts with lookupKey --is theReminderName
	set theURL to the id of theReminder as text
	set theURL to findAndReplaceInText(theURL, "x-apple-reminder://", "x-apple-reminderkit://REMCDReminder/") of me
end tell
set the clipboard to theURL