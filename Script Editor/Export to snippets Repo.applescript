-- TODO: 
-- Fix after saving as "text", the top window is now open on the Repo version, not the Libary version
tell application "Script Editor"
	set theScript to first document
	set thePath to path of theScript
	set scriptName to name of theScript
end tell
tell application "System Events"
	set scriptFolder to container of disk item (path of disk item thePath)
end tell
tell application "System Events" to set theUserLibary to library folder of user domain
set userLibraryPath to (path of theUserLibary as string)
if (path of scriptFolder) starts with userLibraryPath then
	tell application "System Events"
		set repoScriptPath to (POSIX path of home folder of user domain) & "/Repos/snippets/" & (name of scriptFolder) & "/" & scriptName & ".applescript"
	end tell
	set repoScriptFile to POSIX file (POSIX path of repoScriptPath)
	tell application "Script Editor"
		save theScript as "text" in repoScriptFile
	end tell
else
	display dialog ("'" & scriptName & "'" & " isn't in " & (POSIX path of userLibraryPath))
end if
