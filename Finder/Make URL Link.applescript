tell application "Finder"
	set theSel to selection
	set theSel to first item of theSel
	set theURL to URL of theSel as string
	set the clipboard to theURL
end tell
