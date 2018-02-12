GetSystemPowerStatus()
{

VarSetCapacity(powerStatus, 1+1+1+1+4+4)

success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)

global acLineStatus, batteryFlag, batteryLifePercent, batteryLifeTime, batteryFullLifeTime

If (ErrorLevel != 0 OR success = 0)

{

	MsgBox 16, Power Status, Can't get the power status...

	ExitApp

}

acLineStatus := GetInteger(powerStatus, 0, false, 1)

batteryFlag := GetInteger(powerStatus, 1, false, 1)

batteryLifePercent := GetInteger(powerStatus, 2, false, 1)

batteryLifeTime := GetInteger(powerStatus, 4, true)

batteryFullLifeTime := GetInteger(powerStatus, 8, true)



;If acLineStatus = 0
;	acLineStatus = Offline
;Else If acLineStatus = 1
;	acLineStatus = Online
;Else If acLineStatus = 255
;	acLineStatus = Unknown



If batteryFlag = 0

	batteryFlag = Not being charged - Between 33 and 66 percent

Else If batteryFlag = 1

	batteryFlag =  High - More than 66 percent

Else If batteryFlag = 2

	batteryFlag = Low - Less than 33 percent

Else If batteryFlag = 4

	batteryFlag = Critical - Less than 5 percent

Else If batteryFlag = 8

	batteryFlag = Charging

Else If batteryFlag = 128

	batteryFlag = No system battery

Else If batteryFlag = 255

	batteryFlag = Unknown



If batteryLifePercent = 255

	batteryLifePercent = Unknown

Else

	batteryLifePercent = %batteryLifePercent%



If batteryLifeTime = -1

	batteryLifeTime = Unknown



If batteryFullLifeTime = -1

	batteryFullLifeTime = Unknown

Else

	batteryFullLifeTime := GetFormattedTime(batteryFullLifeTime)
	
}