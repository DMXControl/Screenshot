DMXControl_generate_image(image)
{
	global PROGRAMNAME
	
	extension_pos := InStr(image, ".", false, -1)
	
	image := SubStr(image, 1, extension_pos - 1)
	
	if(image == "DMXC3L01_kernel")
	{
		if(Check_OS("WIN_7", false))
		{
			windowname = DMXControl Kernel
			
			DMXControl_start_kernel()
			Take_Screenshot_Window(windowname, image)
			
			return true
		}
		else
			return false
	}
	else if(image == "DMXC3L01_konsole")
	{
		windowname = DMXControl Kernel
		
		if(Check_OS("WIN_7", false))
		{
			DMXControl_start_kernel()
			
			WinGetPos, pos_x, pos_y, pos_width, pos_height, %windowname%
			WinActivate, %windowname%
			
			WinMove, %windowname%, , 20, 20, pos_width, 462
			
			SendInput, help{Enter}
			SendInput, status{Enter}
			SendInput, menu{Enter}
			
			Take_Screenshot_Window(windowname, image)
			
			return true
		}
		else
			return false
	}
	else if(image == "DMXC3_Tutorial_Lektion1_Firewall")
	{
		windowname = ahk_class #32770 ; Windows Firewall Popup
		
		if(Check_OS("WIN_7", true))
		{
			if(DMXControl_running())
				DMXControl_close()
			
			Windows_Firewall_RemoveDMXControl()
			
			DMXControl_start_kernel(true)
			
			WinWaitActive, %windowname%, , 180 ; we have to wait the time until kernel is started up
			
			Take_Screenshot_Window(windowname, image)
			
			return true
		}
		else
			return false
	}
	else if(image == "DMXC3L01_connect")
	{
		windowname = Connect to DMXControl Server
		
		DMXControl_start_kernel()
		DMXControl_start_gui(true)
		
		Sleep, 10000 ; hopefully wait for current running server to appear in found servers list
		
		Take_Screenshot_Window(windowname, image)
		
		WinActivate, %windowname%
		CoordMode, Mouse, Window
		Click, 330, 300 ; Connect
		;Click, 410, 300 ; Cancel
		CoordMode, Mouse, Screen
		
		image = DMXC3L01_connected
		windowname = DMXControl 3
		
		WinWaitActive, %windowname%, , 180
		Take_Screenshot_Windowpart(windowname, -70, -30, 70, 30, image)
		
		return true
	}
	else if(image == "DMXC3L01_connected")
	{
		MsgBox, 36, %PROGRAMNAME%, This picture is automatically generated`, when picture DMXC3L01_connect´is taken.`nGenerate these two pictures now?
		IfMsgBox, Yes
			return DMXControl_generate_image("DMXC3L01_connect")
		else
			return false
	}
	else
	{
		return false
	}
}