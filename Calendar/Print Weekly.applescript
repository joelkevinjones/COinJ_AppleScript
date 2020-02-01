(* Copyright 2018-2019 Joel Jones, joelkevinjones@gmail.com *)

-- TO DO;
-- + Disable the "continue" button until the script finishes. Is this possible?
-- + Modify specification of calls to print to include the calendar account, e.g. "commuting" => joelj@marvell.com:commuting"

global calsToPrint
set calsToPrint to {"Calendar", "teamjonesalameda@gmail.com", "US Holidays", "commuting"}

on clickButton(thePath, theValue)
	tell application "System Events"
		tell thePath
			click
			tell menu 1
				click menu item theValue
			end tell
		end tell
	end tell
end clickButton

on setCheckboxValue(thePath, desiredValue)
	tell application "System Events"
		tell thePath
			if value is not desiredValue then click
		end tell
	end tell
end setCheckboxValue

on setPopupValue(thePath, desiredValue)
	tell application "System Events"
		tell thePath
			if value is not desiredValue then
				click
				tell menu 1
					click menu item desiredValue
				end tell
			end if
		end tell
	end tell
end setPopupValue

on setTextFieldValue(thePath, desiredValue)
	tell application "System Events"
		tell thePath
			if value is not desiredValue then set value to desiredValue
		end tell
	end tell
end setTextFieldValue

on selectMenu(thePath)
	tell application "System Events"
		tell thePath
			click
		end tell
	end tell
end selectMenu

on clickIncrementor(thePath)
	tell application "System Events"
		tell thePath
			click
		end tell
	end tell
end clickIncrementor

on selectCalsToPrint()
	tell application "System Events"
		set theCal to application process "Calendar"
		ensurePrintOpen() of me
		set printWin to window "Print" of theCal
		local potentialMatchRows
		set potentialMatchRows to {}
		tell outline 1 of scroll area 1 of printWin
			set potentialMatchRows to every row whose (class of first UI element) = checkbox and (class of second UI element) = static text
		end tell
		local theName
		local thePath
		repeat with theRow in potentialMatchRows
			set theName to (name of item 1 of static text of theRow)
			set thePath to checkbox 1 of theRow
			if theName is not equal to "" then
				if theName is in calsToPrint then
					set desiredValue to 1
				else
					set desiredValue to 0
				end if
				setCheckboxValue(thePath, desiredValue) of me
			end if
		end repeat
	end tell
end selectCalsToPrint

on openPrint(theCal)
	tell application "System Events"
		selectMenu(menu item "Print…" of menu "File" of menu bar item "File" of menu bar 1 of theCal) of me
	end tell
end openPrint

on ensurePrintOpen()
	tell application "Calendar"
		local printNotOpen
		set printNotOpen to false
		activate
		try
			get window "Print"
		on error errstr number errnum
			if errnum is equal to -1728 then
				set printNotOpen to true
			else
				display dialog errstr
			end if
		end try
		if printNotOpen or not visible of window "Print" then
			tell application "System Events"
				set theCal to application process "Calendar"
				openPrint(theCal) of me
			end tell
			set visible of window "Print" to true
		end if
	end tell
end ensurePrintOpen

tell application "System Events"
	local textSizeButtonList
	local textSizeButton
	set theCal to application process "Calendar"
	ensurePrintOpen() of me
	set printWin to window "Print" of theCal
	setPopupValue(pop up button "View:" of printWin, "Week") of me
	setPopupValue(pop up button "Paper:" of printWin, "US Letter") of me
	setPopupValue(pop up button "Starts:" of printWin, "This week") of me
	setPopupValue(pop up button "Ends:" of printWin, "After") of me
	setTextFieldValue(text field 1 of printWin, "1") of me
	-- update "n weeks will be printed" string
	clickIncrementor(button 1 of incrementor 1 of printWin) of me
	clickIncrementor(button 2 of incrementor 1 of printWin) of me
	
	selectCalsToPrint() of me
	
	setCheckboxValue(checkbox "All-day events" of printWin, 1) of me
	setCheckboxValue(checkbox "Mini calendar" of printWin, 1) of me
	setCheckboxValue(checkbox "Calendar keys" of printWin, 1) of me
	setCheckboxValue(checkbox "Black and white" of printWin, 0) of me
	set textSizeButtonList to pop up buttons of printWin whose value is "Small" or value is "Medium" or value is "Big"
	set textSizeButton to first item of textSizeButtonList
	setPopupValue(textSizeButton, "Medium") of me
end tell
