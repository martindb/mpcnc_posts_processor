
MPCNC Fusion 360 CAM posts processor
====

This is modified fork of https://github.com/martindb/mpcnc_posts_processor

CAM posts processor for use with Fusion 360 and MPCNC (www.vicious1.com) with RAMPS/Marlin

Some design points:
- Setup operation types: Milling, Water/Laser/Plasma
- Only support MM units (inches may work with custom start gcode - NOT TESTED)
- XY and Z independent travel speeds. Rapids are done with G0.
- Arcs support on XY plane
- Tested with LCD display and SD card (built in tool change require printing from SD and LCD to restart)
- Support for 3 different laser power using "cutting modes" (through, etch, vaporize)


# User Properties


## Group 1: Job propertyes

|Title|Description|Default|
|---|---|---|
Job: Travel Speed XY|High speed for travel movements X & Y (mm/min).|**2500 mm/min**|
Job: Travel Speed Z|High speed for travel movements Z (mm/min).|**300 mm/min**|
Job: Manual Spindle On/Off|Set it to true when the motor of your spindle is controlled by manual switch. So the preprocessor will issue additional pauses for TURN ON/TURN OFF the motor.|**true**|
Job: Reset on start (G92)|Set origin when gcode start (G92 X0 Y0 Z0). Only apply if not using gcodeStartFile.|**true**|
Job: Goto 0 at end|Go X0 Y0 at gcode end. Useful to find if your machine loss steeps or have any other mechanic issue (like loose pulleys). Also useful for repetitive jobs. Only apply if not using gcodeStopFile.|**true**|

  
## Group 2: Tool change

|Title|Description|Default|
|---|---|---|
Change: Enabled|Enable tool change code (bultin tool change requires LCD display)|**true**|
Change: X|X position for builtin tool change|**0**|
Change: Y|Y position for builtin tool change|**0**|
Change: Z|Z position for builtin tool change|**40**|
Change: Make Z Probe|Z probe after tool change|**true**|
Change: Disable Z stepper|Disable Z stepper when change a tool|**false**|

  
## Group 3: Z Probe

|Title|Description|Default|
|---|---|---|
Probe: On job start|Execute probe gcode on job start|**true**|
Probe: Plate thickness|Plate thickness|**0.8**|
Probe: Use Home Z|Use G28 or G38 for probing|**true**|
Probe: G38 target|Probing up to Z position|**-10**|
Probe: G38 speed|Probing with speed|**30**|

## Group 4: Laser/Plasma related

|Title|Description|Default|
|---|---|---|
Laser: On - Vaporize|GCode command to turn on the laser/plasma cutter in vaporize mode|**M106 S255**|
Laser: On - Through|GCode command to turn on the laser/plasma cutter in through mode|**M106 S200**|
Laser: On - Etch|GCode command to turn on the laser/plasma cutter in etch mode|**M106 S100**|
Laser: Off|Gcode command to turn off the laser/plasma cutter|**M107**|

## Group 5: Override behaviour by external files

|Title|Description|Default|
|---|---|---|
Extern: Start File|File with custom Gcode for header/start (in nc folder)||
Extern: Stop File|File with custom Gcode for footer/end (in nc folder)||
Extern: Tool File|File with custom Gcode for tool change (in nc folder)||
Extern: Probe File|File with custom Gcode for tool probe (in nc folder)||

# Sample of issued code blocks

## Gcode of milling with manually control spindel

```G-code
;Fusion 360 CAM 2.0.4860
; Posts processor: MPCNC_Mill_Laser.cps
; Gcode generated: Thursday, November 29, 2018 4:28:11 PM GMT
; Document: cam_testpp v1
; Setup: Setup1
; *======== START begin ==========* 
G90
G21
M84 S0
G92 X0 Y0 Z0
; COMMAND_TOOL_MEASURE
; +------- Probe tool -------+ 
M0 Attach ZProbe
G28 Z
G92 Z0.8
G1 Z40 F300
M0 Detach ZProbe
; +------- Tool probed -------+ 
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
M0 Turn ON CLOCKWISE
; *======== START end ==========* 
;2D Contour1 - Milling - Tool: 1 - 1/8inchflat end mill
; X Min: 2.588 - X Max: 49.412
; Y Min: 2.588 - Y Max: 49.412
; Z Min: -1 - Z Max: 15
M400
M117 2D Contour1
G0 Z15
G0 X49.412 Y26 F2500
G0 Z5 F300
G1 Z1 F100
G1 Z-1
G1 Y49.412 F300
G1 X2.588
G1 Y2.588
G1 X49.412
G1 Y26
G0 Z15

; *======== CHANGE TOOL begin ==========* 
M400
M300 S400 P2000
G0 Z40 F300
G0 X0 Y0 F2500
; COMMAND_STOP_SPINDLE
M0 Turn OFF spindle
M0 Put tool 2 - 1.5mm
; COMMAND_TOOL_MEASURE
; +------- Probe tool -------+ 
M0 Attach ZProbe
G28 Z
G92 Z0.8
G1  Z40 F300
M0 Detach ZProbe
; +------- Tool probed -------+ 
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
M0 Turn ON CLOCKWISE
; *======== CHANGE TOOL end ==========* 
;Trace1 - Milling - Tool: 2 - 1.5mmflat end mill
; X Min: 16 - X Max: 36
; Y Min: 16 - Y Max: 36
; Z Min: -1 - Z Max: 15
M400
M117 Trace1
G0 Z15
G0 X36 Y36 F2500
G0 Z4 F300
G1 Z-1 F300
G1 Y16
G1 X16
G1 Y36
G1 X36
G1 Z4
G0 Z15

; *======== STOP begin ==========* 
M400
; COMMAND_STOP_SPINDLE
M0 Turn OFF spindle
G0 X0 Y0 F2500
M117 Job end
; *======== STOP end ==========* 
```

## Gcode of milling with spindel controlled by M3/M4/M5

```G-code
;Fusion 360 CAM 2.0.4860
; Posts processor: MPCNC_Mill_Laser.cps
; Gcode generated: Thursday, November 29, 2018 4:31:32 PM GMT
; Document: cam_testpp v1
; Setup: Setup1
; *======== START begin ==========* 
G90
G21
M84 S0
G92 X0 Y0 Z0
; COMMAND_TOOL_MEASURE
; +------- Probe tool -------+ 
M0 Attach ZProbe
G28 Z
G92 Z0.8
G1 Z40 F300
M0 Detach ZProbe
; +------- Tool probed -------+ 
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
M3 S21000
; *======== START end ==========* 
;2D Contour1 - Milling - Tool: 1 - 1/8inchflat end mill
; X Min: 2.588 - X Max: 49.412
; Y Min: 2.588 - Y Max: 49.412
; Z Min: -1 - Z Max: 15
M400
M117 2D Contour1
G0 Z15
G0 X49.412 Y26 F2500
G0 Z5 F300
G1 Z1 F100
G1 Z-1
G1 Y49.412 F300
G1 X2.588
G1 Y2.588
G1 X49.412
G1 Y26
G0 Z15

; *======== CHANGE TOOL begin ==========* 
M400
M300 S400 P2000
G0 Z40 F300
G0 X0 Y0 F2500
; COMMAND_STOP_SPINDLE
M5
M0 Put tool 2 - 1.5mm
; COMMAND_TOOL_MEASURE
; +------- Probe tool -------+ 
M0 Attach ZProbe
G28 Z
G92 Z0.8
G1  Z40 F300
M0 Detach ZProbe
; +------- Tool probed -------+ 
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
M3 S21000
; *======== CHANGE TOOL end ==========* 
;Trace1 - Milling - Tool: 2 - 1.5mmflat end mill
; X Min: 16 - X Max: 36
; Y Min: 16 - Y Max: 36
; Z Min: -1 - Z Max: 15
M400
M117 Trace1
G0 Z15
G0 X36 Y36 F2500
G0 Z4 F300
G1 Z-1 F300
G1 Y16
G1 X16
G1 Y36
G1 X36
G1 Z4
G0 Z15

; *======== STOP begin ==========* 
M400
; COMMAND_STOP_SPINDLE
M5
G0 X0 Y0 F2500
M117 Job end
; *======== STOP end ==========* 
```

## Gcode of laser cutting

```G-code
;Fusion 360 CAM 2.0.4860
; Posts processor: MPCNC_Mill_Laser.cps
; Gcode generated: Thursday, November 29, 2018 4:32:05 PM GMT
; Document: cam_testpp v1
; Setup: Setup2
; *======== START begin ==========* 
G90
G21
M84 S0
G92 X0 Y0 Z0
; COMMAND_TOOL_MEASURE
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_COUNTERCLOCKWISE
; *======== START end ==========* 
;2D Profile1 - Laser/Plasma - Cutting mode: auto
; X Min: -25 - X Max: 25
; Y Min: -25.5 - Y Max: 25
; Z Min: 0 - Z Max: 15
M400
M117 2D Profile1
G0 Z15 F300
G0 X-9.94 Y-10.5 F2500
G0 Z0 F300
; LASER Power ON
M106 S200
; COMMAND_POWER_ON
G1 Y-10 F1000
G1 X-9.95
G1 X-10
G1 Y10
G1 X10
G1 Y-10
G1 X-9.95
G1 X-9.96
G1 Y-10.5
; LASER Power OFF
M107
; COMMAND_POWER_OFF
G0 Z5 F300
G0 X-9.99 Y-25.5 F2500
G0 Z0 F300
; LASER Power ON
M106 S200
; COMMAND_POWER_ON
G1 Y-25 F1000
G1 X-10
G1 X-25
G1 Y25
G1 X25
G1 Y-25
G1 X-10
G1 X-10.01
G1 Y-25.5
; LASER Power OFF
M107
; COMMAND_POWER_OFF
G0 Z15 F300

; *======== STOP begin ==========* 
M400
; COMMAND_STOP_SPINDLE
G0 X0 Y0 F2500
M117 Job end
; *======== STOP end ==========* 

```

# Resorces

[Marlin G-codes](http://marlinfw.org/meta/gcode/)
[Post Processor Training Guide](https://cam.autodesk.com/posts/posts/guides/Post%20Processor%20Training%20Guide.pdf)
[Enhancements to the post processor property definitions](https://forums.autodesk.com/t5/hsm-post-processor-forum/enhancements-to-the-post-processor-property-definitions/td-p/7325350)
[Dumper PostProcessor](https://cam.autodesk.com/hsmposts?p=dump)
[Library of exist post processors](https://cam.autodesk.com/hsmposts)
[Post processors forum](https://forums.autodesk.com/t5/hsm-post-processor-forum/bd-p/218)