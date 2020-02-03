tell application "Safari"
	set theURL to URL of current tab of window 1
	set theTitle to name of current tab of window 1
end tell

set thePropertyListFilePath to choose file name default name (theTitle & ".webloc")
set thePath to thePropertyListFilePath as text

-- https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/WorkwithPropertyListFiles.html
tell application "System Events"
	set theParentDictionary to make new property list item with properties {kind:record}
	set thePropertyListFile to make new property list file with properties {contents:theParentDictionary, name:thePath}
	tell property list items of thePropertyListFile
		make new property list item at end with properties {kind:string, name:"URL", value:theURL}
	end tell
end tell

-- https://stackoverflow.com/questions/29010714/applescript-help-naming-plist-and-removing-extention
tell application "Finder"
	set name extension of (file (thePath & ".plist")) to ""
end tell
