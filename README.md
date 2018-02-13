
BatteryStats
--

by Ryuuhou

README 02/12/18

## Requirements: 

Running from source
* AHK (http://ahkscript.org/ or https://autohotkey.com/)

Running from .zip releases (zip includes .exe and required icon files)
* None

THIS SCRIPT IS ONLY TESTED AND MAINTAINED ON WIN10. I may be unable to help you on any other version.

## Features:

* Display battery statistics by clicking icon tray
* Discharge amount since full charge
* Discharge time since full charge
* Battery life estimate
* Logging charge and discharge history
* Customizable percent that determines full charge


## Installation:

Extract the files to a directory of your choice. Create a shortcut to BatteryStats.exe or BatteryStats.ahk and place it in your startup folder. This will allow it to start whenever the computer boots up.

## Usage:

Click the tray icon to display battery stats as a notification. Right click the tray icon and click Show Logs to see previous charging and discharging history.

## Customization:

You may edit BatteryStats.ahk and edit the variables within the CONFIG SETTINGS. 

* RunPeriod determines how often the script polls for battery stats (in milliseconds). Default is 5000ms
* BatteryPercentResetThreshold determines the percentage which is considered a full charge. All statistics will be reset for the next discharge. Default is 95 (%)