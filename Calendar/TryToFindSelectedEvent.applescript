(*
  TODO:
  Check/implement if view isn't day view
  Resolve what to do if more than one event matches
  Doesn't work for repeating events
  Runs too slow
  Doesn't actually form URL and put into pasteboard
*)
global calOfSelected
set calOfSelected to ""
global descOfSelected
set descOfSelected to ""
global theFocusedEvent
global theCalEvent
(* left hand calendar list: row 1..n of outline 1 of scroll area 1 of splitter group 1 of splitter group 1 of first window of theCalApp *)
(* center column of Day view (list): item 1 of group 1 of splitter group 1 of first window of theCalApp *)

(* Get calendar name and description of selected event *)
tell application "System Events"
	set theCalApp to application process "Calendar"
	set eventList to item 1 of group 1 of splitter group 1 of first window of theCalApp
	set theFocusedEvent to first static text of list 1 of eventList whose focused is true
	set tHelp to help of theFocusedEvent
	set calOfSelected to (characters ((get offset of "\"" in tHelp) + 1) through ((length of tHelp) - 2) of tHelp) as text
	set tStr to description of theFocusedEvent
	-- the help string contains the summary of the event, the location, and the time/date information; get a (pontentially) substring of the description, which ends at the beginning of "at <location>..."
	set descOfSelected to (characters 1 through ((get offset of "at" in tStr) - 1) of tStr) as text
end tell

(* Get date of selected event *)
tell application "System Events"
	set theCalApp to application process "Calendar"
	tell UI element 3 of group 1 of splitter group 1 of first window of theCalApp
		set theSelectedDOM to first static text whose selected is true
	end tell
	set monthYear to value of static text 1 of splitter group 1 of splitter group 1 of first window of theCalApp
end tell
set theStartDate to date (((1st word of monthYear) & " " & (name of theSelectedDOM) & ", " & (2nd word of monthYear)) as string)
set theEndDate to theStartDate + (1 * days) - (1 * minutes)

(* Search calendars with matching name for events on the selected date with matching descriptions *)
set eventList to {}
tell application "Calendar"
	set calList to (calendars where its title starts with calOfSelected)
	repeat with theCal in calList
		try
			--display dialog "Searching " & (name of theCal) & "/" & (description of theCal) & "/" & (uid of theCal)
			tell theCal
				set eventList to eventList & (events whose summary contains descOfSelected and start date is greater than or equal to theStartDate and end date is less than theEndDate)
			end tell
		on error errStr number errorNumber
			if errorNumber is not equal to -1712 then -- not AppleEvent timed out
				error errStr number errorNumber
			end if
		end try
		--display dialog ((count of eventList) as string) & " events found"
	end repeat
end tell
(* TODO: the above works for non-repeating events, now form the wacky URL *)

(* 
  example Applescripts for finding next event after a date for a given repeating event:
  http://macosxautomation.com/applescript/sbrt/pgs/sbrt.06.htm
  https://macscripter.net/viewtopic.php?id=29516
  Maybe try writing an Objective-C program then using AsObjcBridge (sp?)
*)
