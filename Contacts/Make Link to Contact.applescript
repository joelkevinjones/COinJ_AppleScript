tell application "Contacts"
	set theSelection to selection
	set theContactID to id of first item of theSelection
	set the clipboard to "addressbook://" & theContactID
end tell
