set noteLinkClass to Çclass EV24È
tell application "Evernote"
	set theSelection to selection
	set theNote to ((properties of item 1 of theSelection) as note)
	set linkURL to note link of theNote
	set the clipboard to linkURL
end tell
