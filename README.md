
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


## Travel speeds

|Title|Description|Default|
|---|---|---|
Job: Travel Speed XY|High speed for travel movements X & Y (mm/min).|**2500 mm/min**|
Job: Travel Speed Z|High speed for travel movements Z (mm/min).|**300 mm/min**|

## Origins

**setOriginOnStart**:
  Set origin when gcode start (G92 X0 Y0 Z0). Only apply if not using gcodeStartFile.
  Defaults to **true**.

**goOriginOnFinish**:
  Go X0 Y0 at gcode end. Useful to find if your machine loss steeps or have any other mechanic issue (like loose pulleys). Also useful for repetitive jobs. Only apply if not using gcodeStopFile.
  Defaults to **true**.

## Spindel

**manualSpindlePowerControl**:
  Set it to true when the motor of your spindle is controlled by manual switch. So the preprocessor will issue additional pauses for TURN ON/TURN OFF the motor.
  Defaults to **true**.
  
## Tool change

**toolChangeEnabled**:
  Enable tool change gcode. If gcodeToolFile is not set, use builtin tool change gcode.
  Bultin tool change requires LCD display as it uses M0.
  Defaults to **true**.

**toolChangeX**:
  Define X position for builtin tool change.
  Defaults to **0**.
  
**toolChangeY**:
  Define Y position for builtin tool change.
  Defaults to **0**.

**toolChangeZ**:
  Define Z position for builtin tool change.
  Defaults to **40**.

**toolChangeZProbe**: 
  Enable Z probe after builtin tool change.
  Defaults to **true**.
  
**toolChangeDisableZStepper**
  Disable Z stepper when change a tool.
  Defaults to **false**.
  
## Z Probe

**probeOnStart**: 
  Execute tool probe gcode to align tool prior to milling start. Tool number must be diffent than 0 (0 used for laser/plasma). If gcodeProbeFile is not set, use builtin tool probe gcode.
  Defaults to **true**.

**probeThickness**: 
  Thickness of the probe plate.
  Defaults to **0.8**.

**probeUseHomeZ**: 
  Use "G28 Z" or "G38.3". True means G28.
  Defaults to **true**.

**probeG38Target**: 
  Target of Z probing with G38.
  Defaults to **true**.

**probeG38Speed**: 
  Speed of Z probing with G38.
  Defaults to **30**.

## Override behaviour by external files

**gcodeStartFile**:
  File with custom gcode for header/start. The file must be in nc folder. If set, content in this file overrides builtin start gcode.
  No default.

**gcodeStopFile**:
  File with custom Gcode for footer/end. The file must be in nc folder. If set, content in this file overrides builtin stop gcode.
  No default.

**gcodeToolFile**:
  File with custom Gcode for tool change. The file must be in nc folder. If set, content in this file overrides builtin tool change gcode.
  No default.

**gcodeProbeFile**:
  File with custom Gcode for tool probe. The file must be in nc folder. If set, content in this file overrides builtin tool probe gcode.
  No default.

## Laser/Plasma related

**cutterOnThrough**:
  Define gcode command for turn on laser/plasma in trough (any quality) cutting mode.
  Defaults to **"M106 S200"**.
   
**cutterOnEtch**:
  Define gcode command to turn on laser/plasma in etch cutting mode.
  Defaults to **"M106 S100"**.
   
**cutterOnVaporize**:
  Define gcode command to turn on laser/plasma in vaporize cutting mode.
  Defaults to **"M106 S255"**.

**cutterOff**:
  Define gcode to turn off laser/plasma.
  Defaults to **"M107"**.


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
