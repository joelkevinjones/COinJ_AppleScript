global noteContents
global theTitle
set dlyAmt to 0.1
tell application "Stickies" to activate
tell application "System Events"
	set stickiesApp to application process "Stickies"
	tell stickiesApp
		get value of text area 1 of scroll area 1 of 1st window
		set theTitle to title of 1st window
		keystroke "a" using command down
		keystroke "c" using command down
		delay dlyAmt
		set noteContents to the clipboard as Çclass RTF È
		key code 123 -- left arrow
	end tell
end tell
global newNote
tell application "Evernote"
	activate
	set newNote to create note title theTitle notebook "First Notebook" with text " "
	delay dlyAmt
	set newNoteWindow to open note window with newNote
	repeat until newNoteWindow is visible
	end repeat
end tell

tell application "System Events"
	tell process "Evernote"
		tell menu item "Edit Note Title" of menu of menu bar item "Note" of menu bar 1 to click
		delay dlyAmt
		key code 48 -- Tab to note text
		delay dlyAmt
		keystroke "a" using command down -- select any placeholder text
		delay dlyAmt
		set the clipboard to noteContents
		delay dlyAmt
		keystroke "v" using command down -- and replace it
	end tell
end tell
