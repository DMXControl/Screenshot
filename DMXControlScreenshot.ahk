#include lib_JSON.ahk
#EscapeChar `
#CommentFlag ;
#singleinstance force 

PROGRAMNAME = DMXControl Screenshot
debug := false

selectedCategory := Object()

if(pictures_list_get())
{
	goto SelectCategory
}
else
{
	MsgBox, 16, %PROGRAMNAME%, Couldn't get picture list from Wiki. `nAre you sure that your computer is connected to the internet and DMXControl Wiki is up and running?
}

Exit:
ExitApp

SelectCategory:
	if(StrLen(A_GuiControl) > 0)
	{
		selectedCategory.Insert(A_GuiControl)
		gui, Destroy
	}

	categories := pictures_list_headers(Join("\n", selectedCategory*))

	if(categories.MaxIndex() > 0)
	{
		gui, add, text,, Select category for images
		gui, add, text,, % Join(" -> ", selectedCategory*)

		for key, category in categories
			gui, add, button, gSelectCategory, %category%
	}
	else
	{
		gui, add, text,, Select image to update
		gui, add, text,, % Join(" -> ", selectedCategory*)

		for key, image in pictures_list_images()
			gui, add, button, gUpdateImage, %image%
	}
	gui, add, button, gExit, Cancel
	gui, show, ; for other 'generic' system

return

UpdateImage:
	selected_image := A_GuiControl
	gui, Destroy
	
	MsgBox % "Logic missing for auto generate image " . selected_image
	
	Goto Exit
return


Join(sep, params*) {
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}

get_configuration()
{	
	return false
}

pictures_date = ""
pictures_list = ""

pictures_list_get()
{
	global pictures_list, pictures_date
	global debug

	if(debug)
	{
		pictures_json = {"query":{"pages":{"3375":{"pageid":3375,"ns":0,"title":"Liste DMXControl 3 Handbuch Bilder","revisions":[{"*":"Diese Seite stellt eine \u00dcbersicht <!-- aller --> der im DMXControl 3 Dokumentation verwendeten Bilder dar.\n\n= DMXControl 3.0 Lumos =\n== Tutorial ==\n=== Lektion 3 ===\n<gallery mode=packed-hover>\nDatei:DMXC3L02_PanelAssignment.jpg\nDatei:DMXC30_WindowsManager3.JPG\n<\/gallery>\n\n\n== Handbuch ==\n=== Wrong entry ==="}],"touched":"2014-09-08T12:25:34Z","lastrevid":11974,"counter":7,"length":290}}}}
	}
	else
	{
	
		http_path = http://www.dmxcontrol.de/mediawiki/api.php?format=json&action=query&titles=Liste DMXControl 3 Handbuch Bilder&prop=revisions|info&rvprop=content
		
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("GET", http_path)
		WebRequest.Send()
	}

	if(WebRequest.Status == 200 || debug)
	{
		if(!debug)
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
		
		pictures_date := first["touched"] ; TODO: better format
		
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

pictures_list_start = 0
pictures_list_end = 0

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