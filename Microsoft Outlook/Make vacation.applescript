tell application "Microsoft Outlook"
	set theVacation to make new calendar event with properties {free busy status:free, subject:"<name> Vacation", all day flag:true, has reminder:false, start time:(current date), end time:(current date) + 3600}
	open theVacation
end tell