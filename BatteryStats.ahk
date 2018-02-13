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

;END

IniRead, OnBatteryTime, config.ini, Variables, OnBatteryTime, -1
IniRead, LastBatteryPercent, config.ini, Variables, LastBatteryPercent, -1
IniRead, HighestBatteryPercent, config.ini, Variables, HighestBatteryPercent, -1
IniRead, LowestBatteryPercent, config.ini, Variables, LowestBatteryPercent, -1
IniRead, SessionDischargePercent, config.ini, Variables, SessionDischargePercent, 0

GetSystemPowerStatus()

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

if (batteryLifePercent >= BatteryPercentResetThreshold)
{
	gosub LogCharge
	gosub ResetAll
}

Menu, Tray, NoStandard
Menu, Tray, Add, Show Log, OpenLog
Menu, Tray, Add, Show Statistics, TrayTip 
Menu, Tray, Default, Show Statistics
Menu, Tray, Click, 1

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
			SessionDischargePercent := SessionDischargePercent - (batteryLifePercent-LastBatteryPercent)
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
	return
}

AddOnBatteryTime:
{
	OnBatteryTime := OnBatteryTime + RunPeriod
	IniWrite,%OnBatteryTime%,config.ini,Variables,OnBatteryTime
}

LogCharge:
{
	FileAppend, Charge %LowestBatteryPercent%`% to %HighestBatteryPercent%`%`n, Log.txt
	return
}

LogDischarge:
{
	t := GetFormattedTime(OnBatteryTime)
	FileAppend, Discharge %HighestBatteryPercent%`% to %LastBatteryPercent%`% in %t%`n, Log.txt
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
	HighestBatteryPercent = batteryLifePercent
	IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
	return
}

ResetLowest:
{
	LowestBatteryPercent = batteryLifePercent
	IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
	return
}

ResetAll:
{
	HighestBatteryPercent = batteryLifePercent
	LowestBatteryPercent = batteryLifePercent
	LastBatteryPercent = batteryLifePercent
	IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
	IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
	IniWrite,%LastBatteryPercent%,config.ini,Variables,LastBatteryPercent
	OnBatteryTime := 0
	SessionDischargePercent := 0
	return
}

TrayTip:
GetSystemPowerStatus()
Text = Current Battery : %batteryLifePercent%`%
if (acLineStatus = 0)
{
	Text = %Text%`nDischarge Amount : %SessionDischargePercent%`%
	t := GetFormattedTime(OnBatteryTime)
	Text = %Text%`nDischarge Time : %t%	
	if OnBatteryTime > 600000
	{
		t := FloorDecimal((SessionDischargePercent)/(OnBatteryTime/3600000))
		Text = %Text%`nAverage Discharge Rate : %t% (`%/h) 
	}
	else
	{
		Text = %Text%`nAverage Discharge Rate : -.-- (`%/h)
	}
	t := GetFormattedTime(batteryLifeTime*1000)
	Text = %Text%`nEstimated Time Remaining : %t%
}
else	
{
	Text = %Text% (AC)
}
TrayTip, Battery Stats, %Text%,,16
return

OpenLog:
	Run Edit %A_ScriptDir%\Log.txt
	return

#Include %A_ScriptDir%/Functions/SystemPowerStatus.ahk
#Include %A_ScriptDir%/Functions/FormattedTime.ahk
#Include %A_ScriptDir%/Functions/GetInteger.ahk
#Include %A_ScriptDir%/Functions/FloorDecimal.ahk