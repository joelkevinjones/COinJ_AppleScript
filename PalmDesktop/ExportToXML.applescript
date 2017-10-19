-- Copyright 2010-2013 Joel Jones joelkevinjones@gmail.com

-- Export Palm Desktop user data as an xml file.  There is
-- currently no consumer of this information.

-- TODO: Use xml links to specify categories and attachments
-- http://www.w3.org/TR/xlink/
-- write out each subclass of entry with a single function taking
-- subclass tag string and the entry.  This will write out the tag with
-- an attribute of xml:id="id".
-- categories aren't a subclass of entry, but of item---double check their ids

-- TODO: use user event scripting to handle checking if a
-- dialog box is open in Palm Desktop and close it before trying to do export,
-- otherwise an error message is produced about apple event timing out
-- and the output file is corrupted slightly.

global outFD

global indent
set indent to 1

global blanks
set blanks to "                                                         "

global indentAmount
set indentAmount to 2

global enableProgressBar
set enableProgressBar to false

on getItemCount()
	tell application "Palm Desktop"
		set categoriesCount to count of categories
		set addressCount to count of addresses
		set memoCount to count of memos
		set todoCount to count of to dos
		set eventCount to get count of events
		return categoriesCount + addressCount + memoCount + todoCount + eventCount
	end tell
end getItemCount

on startProgressBar(itemCount)
	if enableProgressBar then
		tell application "SKProgressBar"
			activate
			set floating to false
			set position to {100, 100}
			set width to 600
			set title to "Palm Desktop XML Export"
			set header to "Exporting to XML"
			tell progress bar
				set minimum value to 0
				set maximum value to itemCount
				set current value to 0
				set indeterminate to false
			end tell
			set show window to true
		end tell
	end if
end startProgressBar

on setFooter(msg)
	if enableProgressBar then
		tell application "SKProgressBar" to set footer to msg
	end if
end setFooter

on advanceProgressBar(amt)
	if enableProgressBar then
		tell application "SKProgressBar"
			tell progress bar
				start animation
				increment by amt
				stop animation
			end tell
		end tell
	end if
end advanceProgressBar

on nSpaces(n)
	if n is less than 0 then return ""
	return characters 1 through n of blanks as string
end nSpaces

on curIndent()
	return nSpaces(indent * indentAmount) of me
end curIndent

on doIndent()
	local indentStr
	set indentStr to curIndent() of me
	set indent to indent + 1
	return indentStr
end doIndent

on unIndent()
	set indent to indent - 1
end unIndent

on openOutFile()
	local outFile
	set outFile to choose file name default name "palmDesktop.xml" default location (path to home folder) with prompt "Choose a name and a location to export to."
	--set outFile to "Macintosh HD:Users:jones:palmDesktopTest.xml"
	set outFD to open for access outFile with write permission
	set eof outFD to 0
end openOutFile

on closeOutFile()
	close access outFD
end closeOutFile

on writeLine(str)
	local outBuf
	set outBuf to str & (character id 10) -- new line
	write outBuf to outFD
end writeLine

on writeXMLdecl()
	writeLine("<?xml version=\"1.0\" encoding=\"macintosh\" ?>") of me
end writeXMLdecl

on writeBeginTag(tagName)
	local tag
	set tag to doIndent() of me & "<" & tagName & ">"
	--display dialog "writeBeginTag" & tag
	writeLine(tag as string) of me
	return tag
end writeBeginTag

on writeEndTag(tagName)
	local tag
	set tag to curIndent() of me & "</" & tagName & ">"
	unIndent()
	--display dialog tag
	writeLine(tag as string) of me
	return tag
end writeEndTag
property searchList : {"<", ">", "&", "\"", "'"}
property replaceList : {"&lt;", "&gt;", "&amp;", "&quot;", "&#039;"}

to toXML(t)
	local escStr
	local escItem
	set escStr to ""
	set t to t's text items
	considering case
		repeat with i from 1 to count t
			set escItem to item i of t
			repeat with n from 1 to count searchList
				if escItem is equal to item n of searchList then
					set escItem to item n of replaceList
				end if
			end repeat
			set escStr to escStr & escItem
		end repeat
	end considering
	escStr
end toXML

-- todo: xml escape tagData, including ^M line endings
on writeTagged(tagName, tagData)
	local taggedData
	if tagData = missing value then return ""
	if tagData is equal to "" then return ""
	--display dialog "writeTagged, tagData before toXML " & tagData
	set tagData to tagData as string
	set tagData to toXML(tagData) of me
	set taggedData to curIndent() of me & "<" & tagName & ">" & tagData & "</" & tagName & ">"
	writeLine(taggedData) of me
	return taggedData
end writeTagged

on getIDForEntry(theEntry)
	local idString
	set idString to id of theEntry
	set idString to (class of theEntry as string) & idString
	-- replace spaces with ""
	return idString
end getIDForEntry

on writeLinkTo(tagName, theEntry)
	local tag
	local idString
	if theEntry = missing value then return
	tell application "Palm Desktop"
		set idString to getIDForEntry(theEntry) of me
		display dialog "idString: " & idString
		set tag to curIndent() of me & "<" & tagName & " xref=\"ID" & (get id of theEntry as string) & "\"/>"
		--display dialog "writeLinkTo " & tag
		writeLine(tag as string) of me
	end tell
end writeLinkTo

on writeCategoryLinkTo(tagName, theCategory)
	local tag
	local idString
	if theCategory = missing value then return
	tell application "Palm Desktop"
		set idString to getIDForEntry(theEntry) of me
		set tag to curIndent() of me & "<" & tagName & " xref=\"" & idString & "\"/>"
		--display dialog "writeCategoryLinkTo " & tag
		writeLine(tag as string) of me
	end tell
end writeCategoryLinkTo

on writeBeginEntry(tagName, theEntry)
	local tag
	local idString
	tell application "Palm Desktop"
		set idString to getIDForEntry(theEntry) of me
		set tag to doIndent() of me & "<" & tagName & " xml:id=\"" & idString & "\">"
		writeLine(tag) of me
		--display dialog "writeBeginEntry " & tag
		writePrimaryCategory(theEntry) of me
		writeSecondaryCategory(theEntry) of me
		writeTagged("private", get private of theEntry) of me
		writeAttachments(get attachments of theEntry) of me
	end tell
end writeBeginEntry

-- TODO should write categories once and then reference their ids where used
on writeCategory(categoryName, theCategory)
	tell application "Palm Desktop"
		advanceProgressBar(1) of me
		if theCategory is equal to missing value then return
		writeBeginTag(categoryName) of me
		set theName to name of theCategory
		if not (theName = missing value) then
			writeTagged("name", get name of theCategory) of me
		end if
		writeTagged("id", get id of theCategory) of me
		writeTagged("colorIndex", get color index of theCategory) of me
		writeEndTag(categoryName) of me
	end tell
end writeCategory

on writePrimaryCategory(theAddress)
	local theName
	tell application "Palm Desktop"
		try
			set theCategory to primary category of theAddress
		on error errMsg number errNum
			if errNum is equal to -1728 then
				return
			else
				error errMsg number errNum
			end if
		end try
		--writeCategory("primaryCategory", theCategory) of me
		writeCategoryLinkTo("primaryCategory", theCategory) of me
	end tell
end writePrimaryCategory

on writeSecondaryCategory(theAddress)
	local theName
	tell application "Palm Desktop"
		try
			set theCategory to secondary category of theAddress
		on error errMsg number errNum
			if errNum is equal to -1728 then
				return
			else
				error errMsg number errNum
			end if
		end try
		-- display dialog "writeSecondaryCategory" & theCategory
		--writeCategory("secondaryCategory", theCategory) of me
		writeCategoryLinkTo("secondaryCategory", theCategory) of me
	end tell
end writeSecondaryCategory

-- TODO: attachments to files that don't exist cause a problem
on writeAttachments(theAttachments)
	local attachclass, aliasName, writtenBeginTag
	set writtenBeginTag to false
	tell application "Palm Desktop"
		if (count of theAttachments) is equal to 0 then return
		repeat with theAttachment in theAttachments
			try
				-- This may not be quite right, as attachment are items, not just entries, so it may be a file (or window?)
				set attachclass to class of theAttachment
				--if attachclass is equal to Çclass CATFÈ then
				if attachclass is equal to alias then
					set aliasName to ((theAttachment as alias) as string)
					if not writtenBeginTag then
						writeBeginTag("attachments") of me
						set writtenBeginTag to true
					end if
					writeTagged("file", aliasName) of me
				else
					if not writtenBeginTag then
						writeBeginTag("attachments") of me
						set writtenBeginTag to true
					end if
					writeLinkTo("attachment", theAttachment) of me
				end if
			on error errText number errNum partial result partialResult
				if errNum is not -1700 then
					closeOutFile() of me
					display dialog "writeAttachments " & errText & errNum & attachclass as string
					tell application "Palm Desktop"
						partialResult
					end tell
				end if
			end try
		end repeat
		if writtenBeginTag then writeEndTag("attachments") of me
	end tell
end writeAttachments

on writePostalAddress(postalAddress)
	local theLabel, theStreetAddressOne, theStreetAddressOne, theCity, theState
	local theZip, theCountry
	tell application "Palm Desktop"
		set theStreetAddressOne to street address one of postalAddress
		set theStreetAddressTwo to street address two of postalAddress
		set theCity to city of postalAddress
		set theState to state of postalAddress
		set theZip to zip of postalAddress
		set theCountry to country of postalAddress
		if theStreetAddressOne & theStreetAddressTwo & theCity & theState & theZip & theCountry is equal to "" then return
		writeBeginTag("postalAddress") of me
		set theLabel to label of postalAddress
		if not (theLabel = missing value) then
			writeTagged("postalAddressLabel", name of theLabel) of me
		end if
		writeTagged("streetAddressOne", theStreetAddressOne) of me
		writeTagged("streetAddressTwo", theStreetAddressTwo) of me
		writeTagged("city", theCity) of me
		writeTagged("state", theState) of me
		writeTagged("zip", theZip) of me
		writeTagged("country", theCountry) of me
		writeEndTag("postalAddress") of me
	end tell
end writePostalAddress

on writePhoneNumber(theNumber)
	local theLabel
	tell application "Palm Desktop"
		if raw number of theNumber is equal to "" then return
		writeBeginTag("phone") of me
		set theLabel to label of theNumber
		if not (theLabel = missing value) then
			writeTagged("phoneLabel", name of theLabel) of me
		end if
		writeTagged("rawNumber", get raw number of theNumber) of me
		writeTagged("inMenu", get in menu of theNumber) of me
		writeEndTag("phone") of me
	end tell
end writePhoneNumber

-- todo: add which custom field number is being written and add
-- that to the tag
on writeCustomField(theCustomField)
	tell application "Palm Desktop"
		if field text of theCustomField is equal to "" then return
		writeBeginTag("customField") of me
		writeTagged("fieldTitle", field title of theCustomField) of me
		writeTagged("fieldText", field text of theCustomField) of me
		writeEndTag("customField") of me
	end tell
end writeCustomField

on writeBirthday(theBirthday)
	tell application "Palm Desktop"
		if class of theBirthday is text and theBirthday is not equal to "" then
			writeTagged("birthdayNoYear", theBirthday) of me
		else
			writeTagged("birthday", theBirthday as string) of me
		end if
	end tell
end writeBirthday

on writeAddress(theAddress)
	advanceProgressBar(1) of me
	tell application "Palm Desktop"
		writeBeginEntry("address", theAddress) of me
		writeTagged("firstName", get first name of theAddress) of me
		writeTagged("lastName", get last name of theAddress) of me
		writeTagged("prefix", get prefix of theAddress) of me
		writeTagged("suffix", get suffix of theAddress) of me
		writeTagged("title", get title of theAddress) of me
		writeTagged("company", get company of theAddress) of me
		writeTagged("division", get division of theAddress) of me
		writePostalAddress(get address one of theAddress) of me
		writePostalAddress(get address two of theAddress) of me
		writePhoneNumber(get phone one of theAddress) of me
		writePhoneNumber(get phone two of theAddress) of me
		writePhoneNumber(get phone three of theAddress) of me
		writePhoneNumber(get phone four of theAddress) of me
		writeCustomField(get custom one of theAddress) of me
		writeCustomField(get custom two of theAddress) of me
		writeCustomField(get custom three of theAddress) of me
		writeCustomField(get custom four of theAddress) of me
		writeCustomField(get custom five of theAddress) of me
		writeCustomField(get custom six of theAddress) of me
		writeCustomField(get custom seven of theAddress) of me
		writeCustomField(get custom eight of theAddress) of me
		writeCustomField(get custom nine of theAddress) of me
		writeCustomField(get custom ten of theAddress) of me
		writeCustomField(get custom eleven of theAddress) of me
		writeCustomField(get custom twelve of theAddress) of me
		writeBirthday(get birthday of theAddress) of me
		writeTagged("comments", get comments of theAddress) of me
		writeTagged("modificationDate", get modification date of theAddress) of me
		writeTagged("marked", get marked of theAddress) of me
		writeEndTag("address") of me
	end tell
end writeAddress

on writeAddresses()
	tell application "Palm Desktop"
		--set theAddress to address 1
		writeBeginTag("addresses") of me
		repeat with theAddress in addresses
			writeAddress(theAddress) of me
		end repeat
		writeEndTag("addresses") of me
	end tell
end writeAddresses

on writeMemo(theMemo)
	advanceProgressBar(1) of me
	tell application "Palm Desktop"
		writeBeginEntry("memo", theMemo) of me
		writeTagged("title", title of theMemo) of me
		writeTagged("contents", contents of contents of theMemo) of me
		writeTagged("creationDate", creation date of theMemo) of me
		writeTagged("modificationDate", modification date of theMemo) of me
		writeEndTag("memo") of me
	end tell
end writeMemo

on writeMemos()
	tell application "Palm Desktop"
		writeBeginTag("memos") of me
		repeat with theMemo in memos
			--set theMemo to memo 0
			writeMemo(theMemo) of me
		end repeat
		writeEndTag("memos") of me
	end tell
end writeMemos

on writeCategories()
	tell application "Palm Desktop"
		writeBeginTag("categories") of me
		repeat with theCategory in categories
			writeCategory("category", theCategory) of me
		end repeat
		writeEndTag("categories") of me
	end tell
end writeCategories

on writeEvent(theEvent)
	advanceProgressBar(1) of me
	tell application "Palm Desktop"
		writeBeginEntry("event", theEvent) of me
		writeTagged("title", title of theEvent) of me
		writeTagged("startTime", start time of theEvent) of me
		writeTagged("endTime", end time of theEvent) of me
		writeTagged("duration", duration of theEvent) of me
		writeTagged("allDayEvent", all day event of theEvent) of me
		if alarm of theEvent is not equal to missing value then writeTagged("alarm", alarm of theEvent) of me
		writeEndTag("event") of me
	end tell
end writeEvent

on writeEvents()
	tell application "Palm Desktop"
		writeBeginTag("events") of me
		-- TODO: check if the event is non-recurring, and if so, don't write it out
		--set theEvent to event 1
		repeat with theEvent in events
			writeEvent(theEvent) of me
		end repeat
		writeEndTag("events") of me
	end tell
end writeEvents

on writeToDo(theToDo)
	advanceProgressBar(1) of me
	tell application "Palm Desktop"
		writeBeginEntry("todo", theToDo) of me
		writeTagged("title", title of theToDo) of me
		writeTagged("dueDate", due date of theToDo) of me
		writeTagged("reminder", reminder of theToDo) of me
		if completion date of theToDo is not equal to missing value then writeTagged("completionDate", completion date of theToDo) of me
		writeTagged("priority", priority of theToDo) of me
		writeTagged("carryOver", carry over of theToDo) of me
		writeEndTag("todo") of me
	end tell
end writeToDo

on writeToDos()
	tell application "Palm Desktop"
		writeBeginTag("todos") of me
		--set theToDo to to do 1
		repeat with theToDo in to dos
			writeToDo(theToDo) of me
		end repeat
		writeEndTag("todos") of me
	end tell
end writeToDos

on main()
	try
		tell application "Palm Desktop"
			local itemCount
			set itemCount to getItemCount() of me
			startProgressBar(itemCount) of me
			openOutFile() of me
			writeXMLdecl() of me
			writeBeginTag("palmDesktop") of me
			setFooter("Categories") of me
			writeCategories() of me
			setFooter("Addresses") of me
			writeAddresses() of me
			--setFooter("Memos") of me
			--writeMemos() of me
			setFooter("Events") of me
			writeEvents() of me
			--writeEventOccurences() of me
			setFooter("To Dos") of me
			writeToDos() of me
			--writeToDoOccurences() of me
			writeEndTag("palmDesktop") of me
			closeOutFile() of me
			if enableProgressBar then tell application "SKProgressBar" to quit
		end tell
	on error errText number errNum partial result partialResult
		closeOutFile() of me
		if enableProgressBar then tell application "SKProgressBar" to quit
		display dialog "main " & errText & errNum as string
		tell application "Palm Desktop"
			partialResult
		end tell
	end try
	
	tell application "SKProgressBar" to quit
end main

main() of me
