tell application "Mail"
	activate
	set theSelection to selection
	set theMessageId to message id of first item of theSelection
	set theLink to "message://<" & theMessageId & ">"
	set the clipboard to theLink
end tell