on getHtmlBody(theSource, msgContentType)
	tell application "Mail"
		set boundaryMarker to fifth word of msgContentType
		set theOffset to offset of boundaryMarker in theSource
		set theSource to characters from (theOffset + (length of boundaryMarker)) to end of theSource as string
		set theOffset to offset of boundaryMarker in theSource
		set theSource to characters from (theOffset + (length of boundaryMarker)) to end of theSource as string
		set theOffset to offset of boundaryMarker in theSource
		set theSource to characters from (theOffset + (length of boundaryMarker)) to end of theSource as string
		set theOffset to offset of "<html" in theSource
		set theSource to characters from theOffset to end of theSource as string
		set endHTML to "</html>"
		set theOffset to offset of endHTML in theSource
		set theSource to characters from beginning to (theOffset + (length of endHTML)) of theSource as string
	end tell
	return theSource
end getHtmlBody

tell application "Mail"
	set theSelection to selection
	set theSelection to first item of theSelection
	set theSource to source of theSelection
	set msgContentType to content of header "content-type" of theSelection
	if msgContentType starts with "multipart/alternative;" then
		set theSource to getHtmlBody(theSource, msgContentType) of me
		-- convert theSource from quoted-printable to normal
		-- https://webcache.googleusercontent.com/search?q=cache:-3uwGmldi5UJ:https://digmymac.com/%3Fp%3D76+&cd=3&hl=en&ct=clnk&gl=us&client=safari
		-- run theSource through the shell script:  qprint -d < t.qp > t.html
		set theTitle to subject of theSelection
	end if
end tell

-- https://dev.evernote.com/doc/articles/applescript.php
tell application "Evernote"
	create note title theTitle with html theSource notebook "First Notebook"
	--set newNote to create note with text "foo"
	--set source URL of newNote to theLink
end tell
