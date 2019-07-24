(*
Try to fix external display not showing anything even though it is on and recognized when reconnecting to laptop. Do this by toggling the mirror display status and then setting the mirror display status to off.
Note that due to the way the number of windows changes when changing mirror display modes, after every change, the window with the "Arrangment" tab has be searched for again.
joelkevinjones@gmail.com
*)
on findArrangmentWindow()
	tell application "System Events"
		set sysPrefs to application process "System Preferences"
		tell sysPrefs
			set arrWin to missing value
			set winIdx to 1
			repeat with theWin in windows
				repeat with theButton in radio buttons of tab group of theWin
					if name of theButton is "Arrangement" then
						return winIdx
					end if
				end repeat
				set winIdx to winIdx + 1
			end repeat
		end tell
	end tell
	return 0
end findArrangmentWindow

on clickMirrorDisplays()
	tell application "System Events"
		set sysPrefs to application process "System Preferences"
		set winIdx to findArrangmentWindow() of me
		if winIdx is not equal to 0 then
			set mirDispCheckbox to checkbox "Mirror Displays" of tab group 1 of window winIdx of sysPrefs
			tell mirDispCheckbox to click
		end if
	end tell
end clickMirrorDisplays

on clearMirrorDisplays()
	tell application "System Events"
		set sysPrefs to application process "System Preferences"
		set winIdx to findArrangmentWindow() of me
		if winIdx is not equal to 0 then
			set mirDispCheckbox to checkbox "Mirror Displays" of tab group 1 of window winIdx of sysPrefs
			tell mirDispCheckbox
				if value is not 0 then click
			end tell
		end if
	end tell
end clearMirrorDisplays

on waitClearMirrorDisplays()
	tell application "System Events"
		set sysPrefs to application process "System Preferences"
		set winIdx to findArrangmentWindow() of me
		if winIdx is not equal to 0 then
			set mirDispCheckbox to checkbox "Mirror Displays" of tab group 1 of window winIdx of sysPrefs
			tell mirDispCheckbox
				set curValue to value
				repeat while (curValue is not equal to 0)
					set curValue to value
				end repeat
			end tell
		end if
	end tell
end waitClearMirrorDisplays

tell application "System Events"
	local mirDispCheckbox
	set sysPrefs to application process "System Preferences"
	tell application "System Preferences"
		reveal anchor "displaysArrangementTab" of pane "com.apple.preference.displays"
	end tell
	clickMirrorDisplays() of me
	clearMirrorDisplays() of me
	waitClearMirrorDisplays() of me
end tell