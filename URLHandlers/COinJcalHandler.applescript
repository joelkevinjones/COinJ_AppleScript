-- Run this once as an application to register it with the system wide handler, then from a command line:
-- open coinjcal::show=8c906806-a9f1-4d53-83e6-eb7c603f6440
-- format coinjcal:cmd=args where cmd (for now) is "show"
-- Custom URL scheme handler: https://www.macosxautomation.com/applescript/linktrigger/
-- Calendar scripting guide: https://developer.apple.com/library/content/documentation/AppleApplications/Conceptual/CalendarScriptingGuide/index.html#//apple_ref/doc/uid/TP40016646-CH105-SW1
-- TODO
-- ¥ encode calendar name in arguments
-- ¥ use System Events Property List suite to auto-insert proper stuff, or use an installer so I can use in git repo
-- ¥ check that cmd is "show"
-- ¥ check that url scheme is "coinjcal"

on open location this_URL
	-- parse arguments
	set fstColon to the offset of ":" in this_URL
	set fstEqual to the offset of "=" in this_URL
	set cmd to characters from (fstColon + 1) to (fstEqual - 1) of this_URL
	set theUID to characters from (fstEqual + 1) to -1 of this_URL as text
	-- set theUID to uid of first event of calendar "Home"
	display dialog "cmd: " & cmd & " theUID: " & theUID
	tell application "Calendar"
		activate
		try
			tell calendar "Home"
				show (first event where its uid = theUID)
			end tell
		on error msg
			display dialog "error msg: " & msg
		end try
	end tell
end open location