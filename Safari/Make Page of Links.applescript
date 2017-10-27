(* © Joel Jones joelkevinjones@gmail.com *)
(* I need an open source license *)
global htmlFile
set htmlFile to -1

on getDateStr()
	set theDate to current date
	set theMonth to month of theDate as number
	set theYear to year of theDate as number
	set theDay to day of theDate as number
	return (theYear as string) & "-" & (theMonth as string) & "-" & (theDay as string)
end getDateStr

on openHTMLfile()
	local outFile
	local outFD
	local fileName
	set fileName to "webPageCapture" & (getDateStr() of me) & ".html"
	set outFile to choose file name default name fileName default location (path to home folder) with prompt "Choose a name and a location to save to."
	set outFD to open for access outFile with write permission
	set eof outFD to 0
	return outFD
end openHTMLfile

on closeHTMLfile(outFD)
	if outFD is not equal to -1 then
		close access outFD
	end if
end closeHTMLfile

on writeLine(outFD, str)
	local outBuf
	set outBuf to str & (character id 10) -- new line
	write outBuf to outFD as Çclass utf8È
end writeLine

on writeHTMLheader(htmlFile)
	writeLine(htmlFile, "<!DOCTYPE html>") of me
	writeLine(htmlFile, "<meta charset=\"UTF-8\" />") of me
	writeLine(htmlFile, "<html>") of me
	writeLine(htmlFile, "<body>") of me
end writeHTMLheader

on writeHTMLfooter(htmlFile)
	writeLine(htmlFile, "</body>") of me
	writeLine(htmlFile, "</html>") of me
end writeHTMLfooter

on writeNewWindow(htmlFile, windowName)
	writeLine(htmlFile, "<H1>" & windowName & "</H1>")
end writeNewWindow

on writeTab(htmlFile, tabName, tabURL)
	writeLine(htmlFile, "<A href=\"" & tabURL & "\">" & tabName & "</A><BR/>")
end writeTab

on main()
	try
		set htmlFile to openHTMLfile()
		writeHTMLheader(htmlFile) of me
		tell application "Safari"
			repeat with theWindow in windows
				set ok to true
				try
					set windowName to name of theWindow
					set tabsList to tabs of theWindow as list
					writeNewWindow(htmlFile, windowName) of me
				on error
					set ok to false
					writeNewWindow(htmlFile, "Unknown Window name") of me
				end try
				if ok then
					repeat with theTab in tabsList
						set ok to true
						try
							get name of theTab
						on error
							set ok to false
						end try
						if ok then
							set theName to name of theTab
							set theURL to ""
							try
								set theURL to URL of theTab
							on error
								display dialog "Tab " & theName & " has no URL"
							end try
							writeTab(htmlFile, theName, theURL) of me
						end if
					end repeat
				end if
			end repeat
		end tell
		writeHTMLfooter(htmlFile) of me
		closeHTMLfile(htmlFile)
	on error
		closeHTMLfile(htmlFile) of me
	end try
end main
main() of me
