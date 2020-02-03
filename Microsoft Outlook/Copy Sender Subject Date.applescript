tell application "Microsoft Outlook"
	set msgs to current messages
	set fstMsg to first item of msgs
	set theSender to sender of fstMsg
	set clip to name of theSender
	set clip to clip & " " & subject of fstMsg
	set clip to clip & " " & (time sent of fstMsg as string)
	set the clipboard to clip
end tell
