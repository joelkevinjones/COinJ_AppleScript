-- Open tabs of frontmost Chrome window in a new Safari window
-- (c) 2021 Joel Jones joelkevinjones@gmail.com
global URLlist
set URLlist to {}
tell application "Google Chrome"
	set topWindow to window 1
	repeat with theTab in tabs of topWindow
		set URLlist to URLlist & (URL of theTab)
	end repeat
end tell

tell application "Safari"
	-- create a new window
	make new document with properties {URL:""}
	set newWin to first window
	-- for every URL, create a new tab and add it to the new window
	repeat with theURL in URLlist
		tell newWin to set current tab to make new tab with properties {URL:theURL}
	end repeat
	--if name of first tab of newWin is equal to "about:blank"
	close (every tab of newWin whose name is equal to "about:blank")
	--end if
end tell