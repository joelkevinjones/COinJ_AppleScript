-- commpile the text file of the COinJcalHandler applescript and modify 
-- the generated Info.plist file to set the URL scheme "coijcal" that
-- it handles
-- TODO
-- * use location to find file, not hard coded
-- * check for existence of file
on createApp()
	tell application "Script Editor"
		set theScript to open "/Volumes/User/Users/jones/gitRepos/githubSnippets/AppleScript/URLhandlers/COinJcalHandler.applescript"
		set applicationAlias to "/Volumes/User/Users/jones/gitRepos/githubSnippets/AppleScript/URLhandlers/COinJcalHandler.app"
		save theScript as "application" in applicationAlias with stay open
		close theScript
	end tell
end createApp

createApp() of me

(* add the following to generated Info.plist file
   "CFBundleURLTypes" => [
    0 => {
      "CFBundleURLName" => "COinJ Calendar Helper"
      "CFBundleURLSchemes" => [
        0 => "coijcal"
      ]
    }
  ]
*)

tell application "System Events"
	-- open Info.plist as property list file
	set infoPL to property list file "/Volumes/User/Users/jones/gitRepos/githubSnippets/AppleScript/URLhandlers/COinJcalHandler.app/Contents/Info.plist"
	tell property list items of infoPL
		set urltype to make new property list item at end with properties {kind:list, name:"CFBundleURLTypes", value:[]}
		tell property list items of urltype
			set typeRecord to make new property list item at end with properties {kind:record}
		end tell
		tell property list items of typeRecord
			make new property list item at end with properties {kind:string, name:"CFBundleURLName", value:"COinJ Calendar Helper"}
			set urlSchemes to make new property list item at end with properties {kind:list, name:"CFBundleURLSchemes", value:[]}
		end tell
		tell property list items of urlSchemes
			make new property list item at end with properties {kind:string, value:"coijcal"}
		end tell
	end tell
end tell