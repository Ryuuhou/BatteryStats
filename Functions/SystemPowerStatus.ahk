GetSystemPowerStatus()
{

VarSetCapacity(powerStatus, 1+1+1+1+4+4)

success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)

global acLineStatus, batteryLifePercent

If (ErrorLevel != 0 OR success = 0)

{

	MsgBox 16, Power Status, Can't get the power status...

	ExitApp

}

acLineStatus := GetInteger(powerStatus, 0, false, 1)

batteryLifePercent := GetInteger(powerStatus, 2, false, 1)


If batteryLifePercent = 255

	batteryLifePercent = Unknown

Else

	batteryLifePercent = %batteryLifePercent%

return
}