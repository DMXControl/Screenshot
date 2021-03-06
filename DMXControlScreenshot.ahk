#include include\lib_JSON.ahk
#EscapeChar `
#CommentFlag ;
#include include\lib_GuiButtonIcon.ahk
#include include\lib_Gdip.ahk
#include include\lib_DMXControl_screenshotfunctions.ahk
#singleinstance force 

PROGRAMNAME = DMXControl Screenshot
debug_internet := false
skip_intensive_windows_stuff := false
use_running_dmxcontrol := false

Menu, Tray, Icon, include\DMXControlScreenshot.dll, 1

RunAsAdmin() ; because we need admin rights for some actions we will make

configuration_get()

if(!software_list_get())
{
	MsgBox, 16, %PROGRAMNAME%, Couldn't get software info list from Wiki. `nAre you sure that your computer is connected to the internet and DMXControl Wiki is up and running?
	
	goto Exit
}

environment_prepare(true)

Restart:
selectedCategory := Object()
pictures_list_get()

goto SelectCategory

Exit:
gui, Destroy
environment_prepare(false)
ExitApp

SelectCategory:
	if(StrLen(A_GuiControl) > 0 && A_GuiControl != "Restart")
		selectedCategory.Insert(A_GuiControl)
	
	gui, Destroy

	categories := pictures_list_headers(Join("\n", selectedCategory*))

	gui, new, , % PROGRAMNAME
	if(categories.MaxIndex() > 0)
	{
		gui, add, text, W500, Select category for images
		gui, add, text, yp+20, % Join(" -> ", selectedCategory*)

		for key, category in categories
			gui, add, button, Left gSelectCategory, %category%
	}
	else
	{
		gui, add, text, W500, Select image to update
		gui, add, text, yp+20, % Join(" -> ", selectedCategory*)

		for key, image in pictures_list_images()
		{
			timestamp := picture_get_timestamp(image)
			days := timestamp
			EnvSub, days, %A_Now%, days
			days *= -1
			if(days < 8)
				FormatTime, description, % timestamp, HH:mm:ss
			else
				FormatTime, description, % timestamp, yyyy-MM-dd
			
			gui, add, button, X10 W300 Left gUpdateImage, %image%
			gui, add, button, xp+310 W24 gOpenWikiFile v%key% hwndIcon
			GuiButtonIcon(Icon, "include\DMXControlScreenshot.dll", 2)
			gui, add, text, xp+34 yp+4 W150, %description%, %days% days ago
			
			software := StrSplit(selectedCategory[1], " ")
			version := software_version_assume(software[1], software[2], timestamp)
			gui, add, text, xp+160 W150, %version%
			
		}
	}
	gui, add, button, X460 W100 gRestart, Restart
	gui, add, button, X570 yp W100 gExit, Exit
	gui, show, ; for other 'generic' system

return

UpdateImage:
	selected_image := A_GuiControl
	gui, Destroy
	
	if(!DMXControl_generate_image(selected_image))
		MsgBox % "Logic missing for auto generate image " . selected_image . " or other error hapened" ; TODO be more specific
	
	Goto SelectCategory
return

OpenWikiFile:
	images := pictures_list_images()
	file := images[A_GuiControl]
	Run http://www.dmxcontrol.de/wiki/File:%file%
return


Join(sep, params*) {
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}

configuration_get()
{	
	global ; all created wariables are global per default
	local inifile 
	inifile = configuration_%A_ComputerName%.ini ; the name of the file for config info
	
	local configuration_values := []
	configuration_values.Insert(["dmxcontrol_path", "Path to your DMXControl 3 installation, e.g. �C:\Programme\DMXControl3.0� without trailing backslash."])
	configuration_values.Insert(["wiki_username", "Your DMXControl Active Directory username"])
	
	local key, params, config, description
	for key, params in configuration_values
	{
		config := params[1]
		description := params[2]
		
		IniRead, config_%config% , %inifile%, DMXControlScreenshot, % config
		
		if(config_%config% == "ERROR" || config_%config% == "")
		{
			InputBox, config_%config%, % PROGRAMNAME, Please enter following value:`n%description%
			IniWrite, % config_%config% , %inifile%, DMXControlScreenshot, % config
		}
	}
	
	return true
}

pictures_list_get()
{
	global pictures_list, pictures_date
	global debug_internet

	if(debug_internet)
	{
		pictures_json = {"query":{"pages":{"3375":{"pageid":3375,"ns":0,"title":"Liste DMXControl 3 Handbuch Bilder","revisions":[{"*":"Diese Seite stellt eine �bersicht <!-- aller --> der im DMXControl 3 Dokumentation verwendeten Bilder dar.\n\n= DMXControl 3.0 Lumos =\n== Tutorial ==\n=== Lektion 1 ===\n<gallery mode=packed-hover>\nDatei:DMXC3_Overview.jpg\nDatei:DMXC3L01_kernel.JPG\nDatei:DMXC3L01_konsole.JPG\nDatei:DMXC3L01_connect.JPG\nDatei:DMXC3_Tutorial_Lektion1_Firewall.png\n<\/gallery>\n=== Lektion 2 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L02_PanelAssignment.jpg\nDatei:DMXC30_WindowsManager3.JPG\n<\/gallery>\n=== Lektion 3 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L03_projectExplorer.JPG\nDatei:DMXC3L03_createDevice.JPG\nDatei:DMXC3L03_createDeviceGroup.JPG\n<\/gallery>\n=== Lektion 4 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L04_liveView.JPG\nDatei:DMXC3L04_liveView_groups.jpg\n<\/gallery>\n=== Lektion 5 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L05_propertyPanels.JPG\nDatei:DMXC3L05_propertyTS.JPG\nDatei:DMXC3L05_propertyRGBParColor.jpg\nDatei:DMXC3L05_propertyMix.JPG\nDatei:DMXC3L05_PropertyGroupHandling.jpg\n<\/gallery>\n=== Lektion 6 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L06_AddInterface.JPG\nDatei:DMXC3L06_DE_IF_plugin_settings.JPG\n<\/gallery>\n=== Lektion 7 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L07_AffinityView.JPG\nDatei:DMXC3L07_ProjectExplorerMenues.JPG\nDatei:DMXC3L07_channelOverview.JPG\n<\/gallery>\n\n== Handbuch ==\n"}],"touched":"2014-09-08T12:25:34Z","lastrevid":11974,"counter":7,"length":290}}}}
	}
	else
	{
	
		http_path = http://www.dmxcontrol.de/mediawiki/api.php?format=json&action=query&titles=Liste DMXControl 3 Handbuch Bilder&prop=revisions|info&rvprop=content
		
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("GET", http_path)
		WebRequest.Send()
	}

	if(WebRequest.Status == 200 || debug_internet)
	{
		if(!debug_internet)
		{
			pictures_json := WebRequest.ResponseText
			WebRequest = ""
		}


		j := JSON_from(pictures_json)
		
		for key, value in j["query"]["pages"]
		{
			first := value
			break
		}
		
		pictures_date := RegExReplace(first["touched"], "[^\d]")
		
		pictures_list := first["revisions"][1]["*"]

		return true
	}
	else
	{
		; TODO
		WebRequest = ""
		return false
	}
}

pictures_list_headers(child_of = "", level = 0) 
{
	global pictures_list, pictures_list_start, pictures_list_end
	
	if(level == 0)
	{
		pictures_list_start := 1
		pictures_list_end := StrLen(pictures_list)
	}
	child_of := StrSplit(child_of, "\n")
	;if(child_of = "")
	;	child_of := []
	
	if(child_of.MaxIndex() == "")
	{
		level++
		headers := Object()
		
		P := pictures_list_start

		While P := RegExMatch( pictures_list, "O)\\n={" . level . "}\s?([^=]+?)\s*={" . level . "}",match,StrLen(match.Len)+P)
		{
			if(match.Pos < pictures_list_end)
			{
				headers.Insert(match[1])
				;MsgBox % match[1]
			}
			else
			{
				break
			}
		}
		
		return headers		
	}
	else
	{
		level++
		
		pictures_list_start := InStr(pictures_list, child_of[1], false, pictures_list_start) + StrLen(child_of[1])
		pictures_list_end_save := pictures_list_end
		pictures_list_end := RegExMatch(pictures_list, "\\n={" . level . "}\s?([^=]+?)\s*={" . level . "}", match, pictures_list_start)
		pictures_list_end := (pictures_list_end > 0 && pictures_list_end < pictures_list_end_save) ? pictures_list_end : pictures_list_end_save
		
		child_of.Remove(1)
		
		return pictures_list_headers(Join("\n", child_of*), level)
	}	
}

pictures_list_images()
{
	global pictures_list, pictures_list_start, pictures_list_end 
	images := Object()
	
	if(RegExMatch(Substr(pictures_list, pictures_list_start, pictures_list_end - pictures_list_start), "<gallery[^>]*>\\n(?<match>.*?)\\n<\\/gallery>", _))
	{
		StringReplace, _match, _match, Datei:, File:, 1
		StringReplace, _match, _match, File:, , 1
		
		images := StrSplit(_match, "\n")
	
		;for key, image in images
		;	MsgBox % image
	}
	
	return images
}

picture_get_timestamp(filename)
{
	global debug_internet
	
	http_path = http://www.dmxcontrol.de/mediawiki/api.php?format=json&action=query&titles=File:%filename%&prop=revisions|info&rvprop=timestamp
	
	if(!debug_internet)
	{
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("GET", http_path)
		WebRequest.Send()
	}
	else
	{
		return 2014-01-01
	}


	if(WebRequest.Status == 200 || debug_internet)
	{
		if(!debug_internet)
		{
			picture_json := WebRequest.ResponseText
			WebRequest = ""
		}


		j := JSON_from(picture_json)
		
		for key, value in j["query"]["pages"]
		{
			first := value
			break
		}
				
		time_string := RegExReplace(first["revisions"][1]["timestamp"], "[^\d]")
		
		EnvAdd, time, time_string
		
		return time

	}
	else
	{
		; TODO
		WebRequest = ""
		return false
	}
}

software_list_get()
{
	global software_list, software_date, debug_internet
	
	http_path = http://www.dmxcontrol.de/mediawiki/api.php?format=json&action=query&titles=Liste DMXControl Versionen&prop=revisions|info&rvprop=content
	
	if(!debug_internet)
	{
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("GET", http_path)
		WebRequest.Send()
	}

	if(WebRequest.Status == 200 || debug_internet)
	{
		if(!debug_internet)
		{
			json := WebRequest.ResponseText
			WebRequest = ""
		}
		else
		{
			json = {"query":{"pages":{"3377":{"pageid":3377,"ns":0,"title":"Liste DMXControl Versionen","revisions":[{"*":"{\n  \"DMXControl\": {\n    \"3.0\": {\n      \"latest\": \"DMXControl 3.0 BETA 6\",\n      \"versions\" : {\n          \"DMXControl 3.0 BETA 1\": \"20121231\"\n        , \"DMXControl 3.0 BETA 2\": \"20130320\"\n        , \"DMXControl 3.0 BETA 3\": \"20130331\"\n        , \"DMXControl 3.0 BETA 4\": \"20130718\"\n        , \"DMXControl 3.0 BETA 5\": \"20131118\"\n        , \"DMXControl 3.0 BETA 6\": \"20140105\"\n      }\n    }\n  }\n}"}],"touched":"2014-09-09T14:58:04Z","lastrevid":11978,"counter":11,"length":402}}}}
		}


		j := JSON_from(json)
		
		for key, value in j["query"]["pages"]
		{
			first := value
			break
		}
		
		software_date := RegExReplace(first["touched"], "[^\d]")
		
		software_list_string := first["revisions"][1]["*"]
		StringReplace, software_list_string, software_list_string, \n, , , 1
		
		software_list := JSON_from(software_list_string)
		
		return true
	}
	else
	{
		; TODO
		WebRequest = ""
		return false
	}		
}

software_version_assume(software, version, filedate)
{
	global software_list
	
	if(true) ;TODO: Check if we fetched software list
	{
		ret =
		
		for name, date in software_list[software][version]["versions"]
		{
			days := filedate
			StringReplace, date, date, -, , 1
			EnvSub, days, date, Days
			if(days >= 0)
				ret := name
		}
		
		return ret
	}
	else
	{
		return
	}
}

environment_prepare(startup)
{
	global PROGRAMNAME, GdipToken, use_running_dmxcontrol
	
	if(startup)
	{
		If !GdipToken := Gdip_Startup()
		{
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		}
		
		while(DMXControl_running() && !use_running_dmxcontrol)
		{
			MsgBox, 6, %PROGRAMNAME%, You have an instance of DMXControl 3 running.`nIt has to be closed before we can continue!, 10
			IfMsgBox Cancel
				ExitApp ; intentionally no goto exit, because this would "restore" some things that weren't done
			IfMsgBox Continue
				break
		}
		If(DMXControl_running() && !use_running_dmxcontrol)
		{
			DMXControl_close()
		}
		
		if(!use_running_dmxcontrol)
			FileMoveDir, %A_AppData%\DMXControl Projects e.V\DMXControl\, %A_AppData%\DMXControl Projects e.V\DMXControl_Screenshot_saved\, R

		SendInput, {LWin Down}d{LWin Up} ; show desktop, so we don't have so many cluttered windows
	}
	else
	{
		if(!use_running_dmxcontrol)
		{
			DMXControl_close()
			
			FileRemoveDir, %A_AppData%\DMXControl Projects e.V\DMXControl\, 1
			FileMoveDir, %A_AppData%\DMXControl Projects e.V\DMXControl_Screenshot_saved\, %A_AppData%\DMXControl Projects e.V\DMXControl\, R 
		}
		Gdip_Shutdown(pToken)

	}
		
	Windows_prepare_style(startup)
}
DMXControl_running()
{
	Process, Exist, LumosGUI.exe
	if(!ErrorLevel)
		Process, Exist, Lumos.exe
	return ErrorLevel
}

DMXControl_close()
{
	Process, Exist, LumosGUI.exe
	if(ErrorLevel)
	{
		WinActivate, DMXControl 3
		WinClose, DMXControl 3, , 30
		Process, WaitClose, LumosGUI.exe, 15 ; to give LumosGUI.exe a chance, to show the kernel window
		Process, Close, LumosGUI.exe
		Process, WaitClose, LumosGUI.exe, 15
	}
	
	Process, Exist, Lumos.exe
	if(ErrorLevel)
	{
		WinClose, DMXControl Kernel, , 30
		Process, Close, Lumos.exe ; should only be used, if window can't be closed - but it might be that kernel doesn't have a window
		Process, WaitClose, Lumos.exe, 15
	}
}
DMXControl_start_kernel(skip_question_window = false)
{
	global PROGRAMNAME, config_dmxcontrol_path
	
	Process, Exist, Lumos.exe
	if(ErrorLevel)
	{ ; Kernel already running
		return true
	}
	
	Run, %config_dmxcontrol_path%\Kernel\Lumos.exe
	WinWait, DMXControl Kernel, , 60
	WinActivate, DMXControl Kernel
	WinMove, , , 20, 20
	
	if(!skip_question_window)
	{
		MsgBox, 33, %PROGRAMNAME%, Please press OK if kernel is fully started up.`n (GoboAfinity-Thread finished message usually is last one) ; sadly can't do that automatically
		IfMsgBox OK
			return true
		else
			return false
	}
}

DMXControl_start_gui(connect_screen = false)
{
	global PROGRAMNAME, config_dmxcontrol_path
	
	Process, Exist, LumosGUI.exe
	if(ErrorLevel)
	{ ; GUI already running
		return true
	}
	
	if(connect_screen)
		Run, %config_dmxcontrol_path%\GUI\LumosGUI.exe
	else
		Run, %config_dmxcontrol_path%\GUI\LumosGUI.exe -nonetwork
	
	WinWait, LumosSplashScreen, , 15
	
	WinWaitClose, LumosSplashScreen, , 180
	
	if(connect_screen)
	{
		WinWait, Connect to DMXControl Server, , 60
	}
	else
	{
		WinWait, DMXControl 3, , 60
	}
	
	return true
}

Check_OS(required_os, force) ; allowed values: WIN_7, WIN_8, WIN_8.1, WIN_VISTA, WIN_2003, WIN_XP, WIN_2000
{
	if(A_OSVersion == required_os)
	{
		return true
	}
	else
	{
		if(force)
		{
			return false
		}
		else
		{
			MsgBox, 4, prog, Required OS is %required_os%`, but you have %A_OSVersion% running. Screenshot might not fit design guide. Continue anyways?
			IfMsgBox Yes
				return true
			IfMsgBox No
				return false
		}
	}
}

Windows_Firewall_RemoveDMXControl()
{
	Run, netsh advfirewall firewall delete rule name="DMXControl 3 Kernel"
	WinWaitActive, ahk_class ConsoleWindowClass, , 10
	WinWaitClose, , 15
	
	;Run, netsh advfirewall firewall delete rule name="DMXControl 3 GUI"
	;WinWaitActive, ahk_class ConsoleWindowClass, , 10
	;WinWaitClose, , 15
}

RunAsAdmin() {
	global skip_intensive_windows_stuff
	
	if(skip_intensive_windows_stuff)
		return
	
	Loop, %0%  ; For each parameter:
	{
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		params .= A_Space . param
	}
	ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"

	if not A_IsAdmin
	{
		If A_IsCompiled
			DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
		Else
			DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
		ExitApp
	}
}

Gdip_Take_Screenshot(pos_x, pos_y, pos_width, pos_height, filename) ; filename without extension
{	
	global GdipToken

	pBitmap := Gdip_BitmapFromScreen(pos_x . "|" . pos_y . "|" . pos_width . "|" . pos_height, "")
	
	FileCreateDir, screenshots
	FileDelete, screenshots\%filename%.png
	Gdip_SaveBitmapToFile(pBitmap, "screenshots\" . filename . ".png")

	Gdip_DisposeImage(pBitmap)
}

Take_Screenshot_Window(windowname, filename)
{	; moves window to foreground to capture it
	global PROGRAMNAME
	
	WinMove, %windowname%, , 20, 20
	WinGetPos, pos_x, pos_y, pos_width, pos_height, %windowname%
	
	if(pos_x = "")
	{
		MsgBox, 16, %PROGRAMNAME%, Couldn't find window %windowname%, so couldn't take screenshot
		return false
	}
	
	SendInput, {LWin Down}d{LWin Up} ; show desktop
	
	WinWaitActive, ahk_class WorkerW, , 10 ; wait for the desktop to show
		
	WinActivate, %windowname%
	WinWaitActive, %windowname%, , 10
	
	Click pos_x - 1, pos_y - 1 ; deactivate window
	
	screenshot_taken := Gdip_Take_Screenshot(pos_x - 7, pos_y - 7, pos_width + 7 + 9, pos_height + 7 + 9, filename)
	
	WinActivate, %PROGRAMNAME%
	
	return screenshot_taken	
}

Take_Screenshot_Windowpart(windowname, rel_pos_x, rel_pos_y, rel_width, rel_height, filename)
{	; window already has to be in foreground!
	global PROGRAMNAME
	
	WinGetPos, pos_x, pos_y, pos_width, pos_height, %windowname%
	
	if(pos_x = "")
	{
		MsgBox, 16, %PROGRAMNAME%, Couldn't find window %windowname%, so couldn't take screenshot
		return false
	}
	
	if(rel_pos_x < 0)
		rel_pos_x := pos_width + rel_pos_x
	if(rel_pos_y < 0)
		rel_pos_y := pos_height + rel_pos_y
	
	return Gdip_Take_Screenshot(pos_x + rel_pos_x, pos_y + rel_pos_y, rel_width, rel_height, filename)
	
}

Windows_HideDesktopIcons(hide_them)
{
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	If HWND =
		ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
	If hide_them
		WinHide, ahk_id %HWND%
	Else
		WinShow, ahk_id %HWND%
}

Windows_prepare_style(startup)
{
	global skip_intensive_windows_stuff
	
	if(skip_intensive_windows_stuff)
		return
	
	if(startup)
	{
		Run, include\DMXC2_Manual_Manual_WindowsDesign.themepack
	}
	else
	{
		Run, include\Windows 7 default.themepack
	}

	WinWaitActive, ahk_class CabinetWClass, , 30 ; waiting for style manager to show
	Sleep, 5000 ; give him five seconds to do his job
	WinClose ; and close him

	Windows_HideDesktopIcons(startup)
}