(* � Joel Jones *)
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
	set theOpenTab to current tab of theWin
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
				-- TO DO: test this code further. How force a tab to have missing value for URL?
				set theURL to URL of theTab
				if theURL is equal to missing value then
					set prevTab to theTab
					set current tab of theWin to theTab
					set current tab of theWin to prevTab
				end if
				set URLs to URLs & theName & " " & theURL & (character id 10) -- new line
			on error
				display dialog "Tab " & theName & "  error getting URL"
			end try
		end if
	end repeat
	set current tab of theWin to theOpenTab
end tell
log URLs
set the clipboard to URLs