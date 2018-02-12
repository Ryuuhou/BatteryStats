#Persistent
#SingleInstance

;CONFIG SETTINGS

global RunPeriod = 5000

;END


;INTERNAL VARIABLES, DO NOT MODIFY

global OnBatteryTime
global LastBatteryPercent
global LastACStatus
global HighestBatteryPercent
global LowestBatteryPercent

;END

IniRead, OnBatteryTime, config.ini, Variables, OnBatteryTime, 0	
IniRead, LastBatteryPercent, config.ini, Variables, LastBatteryPercent, 0	
IniRead, HighestBatteryPercent, config.ini, Variables, HighestBatteryPercent, 0	
IniRead, LowestBatteryPercent, config.ini, Variables, LowestBatteryPercent, 0

GetSystemPowerStatus()

LastACStatus := acLineStatus
IniWrite,%LastACStatus%,config.ini,Variables,LastACStatus

if (HighestBatteryPercent = 0)
{
	HighestBatteryPercent = batteryLifePercent
	IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
}
if (LowestBatteryPercent = 0)
{
	LowestBatteryPercent = batteryLifePercent
	IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
}
if batteryLifePercent > LastBatteryPercent
(
	HighestBatteryPercent := batteryLifePercent
	LastBatteryPercent := batteryLifePercent
	IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
	FileAppend, Charge %LowestBatteryPercent%`% to %HighestBatteryPercent%`%`n, Log.txt
	OnBatteryTime := 0
)


Menu, Tray, MainWindow
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
		if (LowestBatteryPercent > batteryLifePercent)
		{
			LowestBatteryPercent := batteryLifePercent
			IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
		}
		if (HighestBatteryPercent < batteryLifePercent)
		{
			HighestBatteryPercent := batteryLifePercent
			IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
		}
		LastBatteryPercent := batteryLifePercent
		IniWrite,%LastBatteryPercent%,config.ini,Variables,LastBatteryPercent
	}
	if (acLineStatus = 0)
	{
		if (LastACStatus = 1)
		{
			LastACStatus := 0
			FileAppend, Charge %LowestBatteryPercent%`% to %HighestBatteryPercent%`%`n, Log.txt
			IniWrite,%LastACStatus%,config.ini,Variables,LastACStatus
			HighestBatteryPercent := batteryLifePercent
			IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
			LowestBatteryPercent := LastBatteryPercent
			IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
		}
		OnBatteryTime := OnBatteryTime + RunPeriod
		IniWrite,%OnBatteryTime%,config.ini,Variables,OnBatteryTime
	}
	else if (acLineStatus = 1)
	{
		if (LastACStatus = 0)
		{
			LastACStatus := 1
			FileAppend, Discharge %HighestBatteryPercent%`% to %LastBatteryPercent%`% in %OnBatteryTime%`n, Log.txt
			IniWrite,%LastACStatus%,config.ini,Variables,LastACStatus
			HighestBatteryPercent := batteryLifePercent
			IniWrite,%HighestBatteryPercent%,config.ini,Variables,HighestBatteryPercent
			LowestBatteryPercent := LastBatteryPercent
			IniWrite,%LowestBatteryPercent%,config.ini,Variables,LowestBatteryPercent
			OnBatteryTime := 0
		}
	}
	return
}

TrayTip:
GetSystemPowerStatus()
t := GetFormattedTime(OnBatteryTime)
Text = Current Battery : %batteryLifePercent%`%
if (acLineStatus = 0)
{
	Text = %Text%`nDischarge Time : %t%
	
	if OnBatteryTime > 600000
	{
		t := FloorDecimal((LowestBatteryPercent-HighestBatteryPercent)/(OnBatteryTime/3600000))
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
	Text = %Text%(AC)
}
TrayTip, Battery Stats, %Text%,,16
return

#Include %A_ScriptDir%/Functions/SystemPowerStatus.ahk
#Include %A_ScriptDir%/Functions/FormattedTime.ahk
#Include %A_ScriptDir%/Functions/GetInteger.ahk
#Include %A_ScriptDir%/Functions/FloorDecimal.ahk