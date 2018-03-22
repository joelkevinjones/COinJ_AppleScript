tell application "Mail"
	activate
	set theSelection to selection
	set theMessageId to message id of first item of theSelection
	set theLink to "message://<" & theMessageId & ">"
	set theSentDate to date sent of first item of theSelection
	-- 3/19/2018 4:58:00 PM
	set theSentDateString to ((month of theSentDate as integer) & "/" & (day of theSentDate) & "/" & (year of theSentDate) & " " & (time string of theSentDate)) as string
	set the clipboard to theSentDateString & tab & theLink
end tell
