(* © Joel Jones *)
set theWinName to ""
set URLs to ""
tell application "System Events"
	tell application process "Safari"
		activate
		set theWinName to name of (1st window whose value of attribute "AXMain" is true)
	end tell
	log theWinName
end tell
tell application "Safari"
	set theWin to window theWinName
	set theTabs to tabs of theWin as list
	repeat with theTab in theTabs
		set ok to true
		try
			get name of theTab
		on error
			set ok to false
		end try
		if ok then
			set theName to name of theTab
			set theURL to ""
			try
				-- TO DO: check if URL of theTab is missing value and if so, try reloading theTab
				set URLs to URLs & theName & " " & URL of theTab & (character id 10) -- new line
			on error
				display dialog "Tab " & theName & " has no URL"
			end try
		end if
	end repeat
end tell
log URLs
set the clipboard to URLs