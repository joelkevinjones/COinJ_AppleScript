(* Scrape applications to get list of keyboard shortcuts *)

-- To Do
--	Add gathering of recognized menu item descriptions that have keyboard shortcuts
--	Fix problem with Keynote>Share>Collaborate With Others having a cmdChar added
-- Add recursion into menus
-- Fix issue with Winodws menu in Alpha

-- References
--Encoding hints in Apple's Private Use Area - HarJIT's Website https://harjit.moe/applehints.html
--keyboard - Where can I find the unicode symbols for Mac functional keys? (Command, Shift, etc.) - Ask Different https://apple.stackexchange.com/questions/55727/where-can-i-find-the-unicode-symbols-for-mac-functional-keys-command-shift-e
--Keyboard icons & terminology - Ask Different Meta https://apple.meta.stackexchange.com/questions/193/keyboard-icons-terminology?lq=1
--carbon-dev Mailing List https://web.archive.org/web/20140115092208/http://lists.apple.com/archives/carbon-dev/2006/Jul/index.html

on mkDebugAttributeRecord(menuItem)
	tell application "System Events"
		--tell menuItem
		set debugAttrRecord to {identifier:value of attribute "AXIdentifier", enabled:value of attribute "AXEnabled", frame:value of attribute "AXFrame", parent:value of attribute "AXParent", size:value of attribute "AXSize", menuItemCmdGlyph:value of attribute "AXMenuItemCmdGlyph", role:value of attribute "AXRole", menuItemPrimaryUIElement:value of attribute "AXMenuItemPrimaryUIElement", menuItemCmdModifiers:value of attribute "AXMenuItemCmdModifiers", position:value of attribute "AXPosition", theTitle:value of attribute "AXTitle", helpString:value of attribute "AXHelp", menuItemCmdChar:value of attribute "AXMenuItemCmdChar", roleDescription:value of attribute "AXRoleDescription", selected:value of attribute "AXSelected", menuItemCmdVirtualKey:value of attribute "AXMenuItemCmdVirtualKey", menuItemMarkChar:value of attribute "AXMenuItemMarkChar"}
		--end tell
	end tell
end mkDebugAttributeRecord

-- List of Mac/Apple keyboard symbols · GitHub https://gist.github.com/Zenexer/c5243c4216f1f8cd2251
global cmdChar
set cmdChar to "⌘" -- U+2318
global shiftChar
set shiftChar to "⇧" -- U+21E7
global optChar
set optChar to "⌥" -- U+2325
global ctrlChar
set ctrlChar to "⌃" -- U+2303
global tabChar
set tabChar to "⇥" -- U+21E5
global escChar
set escChar to "⎋" -- U+238B kMenuEscapeGlyph = 0x1B (27)

--/Library/Developer/CommandLineTools/SDKs/MacOSX11.3.sdk/System/Library/Frameworks/
--Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Menus.h
global menuControlChar
set menuControlChar to ctrlChar -- kMenuControlGlyph = 0x06 (6)
global menuSpaceChar
set menuSpaceChar to "Space" -- kMenuSpaceGlyph = 0x09 (9)
global deleteRightChar
set deleteRightChar to "⌦" -- U+2326 kMenuDeleteRightGlyph = 0x0A (10)
global menuReturnChar
set menuReturnChar to "↩" -- U+21A9 kMenuReturnGlyph = 0x0B (11)
global deleteLeftChar
set deleteLeftChar to "⌫" -- U+232B kMenuDeleteLeftGlyph = 0x17 (23)
global leftArrowChar
set leftArrowChar to "←" -- U+2190 kMenuLeftArrowGlyph 0x64 (100)
global rightArrowChar
set rightArrowChar to "→" -- U+2192 kMenuRightArrowGlyph = 0x65 (101)

-- /Library/Developer/CommandLineTools/SDKs/MacOSX11.3.sdk/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Headers/AXAttributeConstants.h
-- typedef CF_OPTIONS(UInt32, AXMenuItemModifiers) {
--    kAXMenuItemModifierNone         = 0,        /* Mask for no modifiers other than the -- command key (which is used by default) */
--    kAXMenuItemModifierShift        = (1 << 0), /* Mask for shift key modifier */
--    kAXMenuItemModifierOption       = (1 << 1), /* Mask for option key modifier */
--    kAXMenuItemModifierControl      = (1 << 2), /* Mask for control key modifier */
--    kAXMenuItemModifierNoCommand    = (1 << 3)  /* Mask for no modifiers at all, not even the command key */
--};
on mkModStr(cmdMod)
	set modStr to ""
	--if ((cmdMod mod 16) > 7) then return modStr -- no cmdChar
	if ((cmdMod mod 8) > 3) then set modStr to modStr & ctrlChar
	if ((cmdMod mod 4) > 1) then set modStr to modStr & optChar
	if ((cmdMod mod 2) > 0) then set modStr to modStr & shiftChar
	--set modStr to modStr & cmdChar
	return modStr
end mkModStr

on getCharForGlyph(theGlyph)
	if theGlyph is missing value then return ""
	if theGlyph is equal to 2 then return tabChar
	if theGlyph is equal to 6 then return menuControlChar
	if theGlyph is equal to 9 then return menuSpaceChar
	if theGlyph is equal to 10 then return deleteRightChar
	if theGlyph is equal to 11 then return menuReturnChar
	if theGlyph is equal to 23 then return deleteLeftChar
	if theGlyph is equal to 27 then return escChar
	if theGlyph is equal to 100 then return leftArrowChar
	if theGlyph is equal to 101 then return rightArrowChar
	display dialog "unrecog glyph " & theGlyph
	return "unrecog glyph"
end getCharForGlyph

on mkDesc(attrRec)
	set desc to ""
	set desc to desc & (theTitle of attrRec as string)
	local cmdMod
	set cmdMod to menuItemCmdModifiers of attrRec
	set desc to desc & " " & mkModStr(cmdMod) of me
	if ((cmdMod mod 16) ≤ 7) or (cmdMod is equal to 0) then set desc to desc & cmdChar
	if (menuItemCmdChar of attrRec is not missing value) then
		set desc to desc & (menuItemCmdChar of attrRec as string)
	else
		set desc to desc & getCharForGlyph(menuItemCmdGlyph of attrRec) of me
	end if
	--get theTitle of attrRec
	return desc
end mkDesc

on mkAttributeRecord(menuItem)
	tell application "System Events"
		tell menuItem
			get attributes
			get value of attribute "AXTitle"
			if value of attribute "AXMenuItemCmdGlyph" is missing value then
				display dialog "AXMenuItemCmdGlyph missing"
			end if
			display dialog "after AXMenuItemCmdGlyph fetch"
			set attributeRecord to {menuItemCmdGlyph:value of attribute "AXMenuItemCmdGlyph", menuItemCmdModifiers:value of attribute "AXMenuItemCmdModifiers", theTitle:value of attribute "AXTitle", menuItemCmdChar:value of attribute "AXMenuItemCmdChar", menuItemCmdVirtualKey:value of attribute "AXMenuItemCmdVirtualKey", menuItemMarkChar:value of attribute "AXMenuItemMarkChar"}
		end tell
	end tell
	return attributeRecord
end mkAttributeRecord

tell application "System Events"
	set theApp to application process "Alpha"
	set theMenuBar to menu bar 1 of theApp
	local shouldSkip
	repeat with mbItemIdx from 8 to 8 --count of menu bar items of theMenuBar
		set mbItem to menu 1 of menu bar item mbItemIdx of theMenuBar
		repeat with menuItemIdx from 16 to 16 --count of menu items of mbItem
			set menuItem to menu item menuItemIdx of mbItem
			get UI elements of mbItem
			try
				set shouldSkip to false
				set attrRec to mkAttributeRecord(menuItem) of me
			on error the error_message number the error_number
				if error_number is equal to -1728 then -- undefined attribute, e.g. from 1st Help Menu item
					set shouldSkip to true
				else
					set the error_text to "Error: " & the error_number & ". " & the error_message
					display dialog the error_text buttons {"OK"} default button 1
					return the error_text
				end if
			end try
			if not shouldSkip then
				--get attributes of menuItem
				--get value of attribute "AXRole" of menuItem
				--set dbgAttr to mkDebugAttributeRecord(menuItem) of me
				set desc to mkDesc(attrRec) of me
				--display dialog desc
			end if
		end repeat
	end repeat
end tell
(* See also: /Library/Developer/CommandLineTools/SDKs/MacOSX11.3.sdk/System/Library/Frameworks/AppKit.framework/Versions/C/Headers/NSMenu.h *)
