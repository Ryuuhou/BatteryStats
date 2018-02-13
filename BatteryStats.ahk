#Persistent
#SingleInstance

;CONFIG SETTINGS

global RunPeriod = 5000
global BatteryPercentResetThreshold = 95

;END


;INTERNAL VARIABLES, DO NOT MODIFY

global OnBatteryTime
global LastBatteryPercent
global LastACStatus
global HighestBatteryPercent
global LowestBatteryPercent
global SessionDischargePercent
global IconPath
global IconPercentage
global CurrentIcon
global Text

IconPercentage := Array(item)
IconPercentage[0] := 15
IconPercentage[1] := 30
IconPercentage[2] := 60
IconPercentage[3] := 90
CurrentIcon := -1

;END

IniRead, OnBatteryTime, config.ini, Variables, OnBatteryTime, 0
IniRead, LastBatteryPercent, config.ini, Variables, LastBatteryPercent, -1
IniRead, HighestBatteryPercent, config.ini, Variables, HighestBatteryPercent, -1
IniRead, LowestBatteryPercent, config.ini, Variables, LowestBatteryPercent, -1
IniRead, SessionDischargePercent, config.ini, Variables, SessionDischargePercent, 1

GetSystemPowerStatus()

gosub SetTrayIcon
LastACStatus := acLineStatus
IniWrite,%LastACStatus%,config.ini,Variables,LastACStatus

if (LowestBatteryPercent = -1)
{
	gosub ResetLowest
}

if (HighestBatteryPercent = -1)
{
	gosub ResetHighest
}

if (LastBatteryPercent = -1)
{
	gosub ResetLast
}

if (SessionDischargePercent = 1)
{
	gosub ResetSessionDischarge
}

if (batteryLifePercent >= BatteryPercentResetThreshold and batteryLifePercent > LastBatteryPercent)
{
	gosub LogCharge
	gosub ResetAll
}

Menu, Tray, NoStandard
Menu, Tray, Add, Show Log, OpenLog
Menu, Tray, Add, Show Statistics, TrayTip 
Menu, Tray, Default, Show Statistics
Menu, Tray, Click, 1
Menu, Tray, Add, Exit, Exit

;acLineStatus
;batteryLifePercent
;batteryLifeTime
;batteryFullLifeTime

SetTimer, Run, %RunPeriod%

return


Run:
{
	GetSystemPowerStatus()
	if (LastBatteryPercent != batteryLifePercent)
	{
		if (LastBatteryPercent > batteryLifePercent)
		{
			SessionDischargePercent := SessionDischargePercent - (LastBatteryPercent-batteryLifePercent)
			IniWrite,%SessionDischargePercent%,config.ini,Variables,SessionDischargePercent
			gosub ResetLowest
		}
		else if (batteryLifePercent > BatteryPercentResetThreshold)
		{
			gosub ResetAll		
		}
		else if (HighestBatteryPercent < batteryLifePercent and acLineStatus = 1)
		{
			gosub ResetHighest
		}
		gosub ResetLast
	}
	if (acLineStatus = 0)
	{
		gosub AddOnBatteryTime
		if (LastACStatus = 1)
		{
			LastACStatus := 0
			IniWrite,%LastACStatus%,config.ini,Variables,LastACStatus
			gosub LogCharge
		}
	}
	else if (acLineStatus = 1)
	{
		if (LastACStatus = 0)
		{
			LastACStatus := 1
			IniWrite,%LastACStatus%,config.ini,Variables,LastACStatus
			gosub LogDischarge
		}
	}
	gosub TrayToolTip
	gosub SetTrayIcon
	return
}

AddOnBatteryTime:
{
	OnBatteryTime := OnBatteryTime + RunPeriod
	IniWrite,%OnBatteryTime%,config.ini,Variables,OnBatteryTime
	return
}

LogCharge:
{
	FileAppend, Charge %LowestBatteryPercent%`% to %batteryLifePercent%`%`n, Log.txt
	return
}

LogDischarge:
{
	t := GetFormattedTime(OnBatteryTime)
	FileAppend, Discharge %HighestBatteryPercent%`% to %batteryLifePercent%`% in %t%`n, Log.txt
	return
}

ResetLast:
{
	LastBatteryPercent := batteryLifePercent
	IniWrite,%LastBatteryPercent%,config.ini,Variables,LastBatteryPercent
	return
}

ResetHighest:
{
	HighestBatteryPercent := batteryLifePercent
	IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
	return
}

ResetLowest:
{
	LowestBatteryPercent := batteryLifePercent
	IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
	return
}

ResetSessionDischarge:
{
	SessionDischargePercent := 0
	IniWrite,%SessionDischargePercent%,config.ini,Variables,SessionDischargePercent
	return
}

ResetAll:
{
	HighestBatteryPercent := batteryLifePercent
	LowestBatteryPercent := batteryLifePercent
	LastBatteryPercent := batteryLifePercent
	OnBatteryTime := 0
	SessionDischargePercent := 0
	IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
	IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
	IniWrite,%LastBatteryPercent%,config.ini,Variables,LastBatteryPercent
	IniWrite,%OnBatteryTime%,config.ini,Variables,OnBatteryTime
	IniWrite,%SessionDischargePercentt%,config.ini,Variables,SessionDischargePercent
	return
}

TrayTip:
{
	TrayTip, Battery Stats, %Text%,,16
	return
}

TrayToolTip:
{
	Text = Current Battery : %batteryLifePercent%`%
	if (acLineStatus = 0)
	{
		Text = %Text% (%SessionDischargePercent%`%)
		t := GetFormattedTime(OnBatteryTime)
		Text = %Text%`nDischarge Time : %t%	
		if OnBatteryTime > 600000
		{
			t := FloorDecimal((SessionDischargePercent)/(OnBatteryTime/3600000))
			Text = %Text%`nAverage Discharge : %t% (`%/h) 
		}
		else
		{
			Text = %Text%`nAverage Discharge : -.-- (`%/h)
		}
		t := GetFormattedTime(batteryLifePercent/(SessionDischargePercent*-1/OnBatteryTime))
		Text = %Text%`nEstimated Time Remaining : %t%
	}
	else	
	{
		Text = %Text% (AC)
	}
	Menu, Tray, Tip, %Text%
	return
}

SetTrayIcon:
{
	if (acLineStatus = 1)
	{
		Menu, Tray, Icon, %A_ScriptDir%/Icons/charging.ico,,1
		CurrentIcon := 5
	}
	else if (batteryLifePercent <= IconPercentage[0] and CurrentIcon != 0) ;LESS THAN 15
	{
		Menu, Tray, Icon, %A_ScriptDir%/Icons/empty.ico,,1
		CurrentIcon := 0
	}
	else if (batteryLifePercent > IconPercentage[0] and batteryLifePercent <= IconPercentage[1] and CurrentIcon != 1) ;LESS THAN 30
	{
		Menu, Tray, Icon, %A_ScriptDir%/Icons/low.ico,,1
		CurrentIcon := 1
	}
	else if (batteryLifePercent > IconPercentage[1] and batteryLifePercent <= IconPercentage[2] and CurrentIcon != 2) ;LESS THAN 60
	{
		Menu, Tray, Icon, %A_ScriptDir%/Icons/half.ico,,1
		CurrentIcon := 2
	}
	else if (batteryLifePercent > IconPercentage[2] and batteryLifePercent < IconPercentage[3] and CurrentIcon != 3) ;LESS THAN 90
	{
		Menu, Tray, Icon, %A_ScriptDir%/Icons/almost_full.ico,,1
		CurrentIcon := 3
	}
	else if (batteryLifePercent >= IconPercentage[3] and CurrentIcon != 4) ;GREATER THAN 90
	{
		Menu, Tray, Icon, %A_ScriptDir%/Icons/full.ico,,1
		CurrentIcon := 4
	}	
	return
}

OpenLog:
{
	Run Edit %A_ScriptDir%\Log.txt
	return
}

Exit:
{
	ExitApp
	return	
}
	
#Include %A_ScriptDir%/Functions/SystemPowerStatus.ahk
#Include %A_ScriptDir%/Functions/FormattedTime.ahk
#Include %A_ScriptDir%/Functions/GetInteger.ahk
#Include %A_ScriptDir%/Functions/FloorDecimal.ahk