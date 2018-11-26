
MPCNC Fusion 360 CAM posts processor
====

This is modified fork of https://github.com/martindb/mpcnc_posts_processor

CAM posts processor for use with Fusion 360 and MPCNC (www.vicious1.com) with RAMPS/Marlin

Some design points:
- Setup operation types: Milling, Water/Laser/Plasma
- Only support MM units (inches may work with custom start gcode - NOT TESTED)
- XY and Z independent travel speeds. Rapids are done with G1.
- Arcs support on XY plane
- Tested with LCD display and SD card (built in tool change require printing from SD and LCD to restart)
- Support for 3 different laser power using "cutting modes" (through, etch, vaporize)


# User Properties


## Travel speeds

**travelSpeedXY**:
  High speed for travel movements X & Y (mm/min).
  Defaults to **2500 mm/min**.

**travelSpeedZ**:
  High speed for travel movements Z (mm/min).
  Defaults to **300 mm/min**.

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
  Disable Z stepper when when change a tool.
  Defaults to **false**.
  
## Z Probe

**probeOnStart**: 
  Execute tool probe gcode to align tool prior to milling start. Tool number must be diffent than 0 (0 used for laser/plasma). If gcodeProbeFile is not set, use builtin tool probe gcode.
  Defaults to **true**.

**probeThickness**: 
  Thickness of the probe plate.
  Defaults to **0.8**.

**probeThickness**: 
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

## Job Start

```
;Fusion 360 CAM 2.0.4860
;Posts processor: MPCNC_Mill_Laser.cps
;Gcode generated: Monday, November 26, 2018 4:20:09 PM GMT
;Document: cam3 v1
;Setup: Setup3
; *======== START begin ==========* 
G90
G21
M84 S0
G92 X0 Y0 Z0
; +------- Probe tool -------+ 
M0 Attach ZProbe
G28 Z
G92 Z0.8
G1  Z40 F300
M0 Detach ZProbe
; +------- Tool probed -------+ 
M0 Turn ON spindle
; *======== START end ==========* 
;2D Make pocket - Milling - Tool: 1 - flat end mill
;X Min: -22.913 - X Max: 22.913
;Y Min: -17.913 - Y Max: 17.913
;Z Min: -3 - Z Max: 15
M400
M117 2D Make pocket
G0 Z15
.......
```

## Tool change

```
.......
G0 Z15

; *======== CHANGE TOOL begin ==========* 
M400
M300 S400 P2000
G1  Z40 F300
G1  X0 Y0 F2500
M0 Turn OFF spindle
M0 Put tool 2 - flat end mill
; +------- Probe tool -------+ 
M0 Attach ZProbe
G28 Z
G92 Z0.8
G1  Z40 F300
M0 Detach ZProbe
; +------- Tool probed -------+ 
M0 Turn ON spindle
; *======== CHANGE TOOL end ==========* 
;2D Small square - Milling - Tool: 2 - flat end mill
;X Min: -5.75 - X Max: 5.75
;Y Min: -6.2 - Y Max: 5.75
;Z Min: -1 - Z Max: 15
M400
M117 2D Small square
G0 Z15
.......
```

## Job End

```
.......
G0 Z15

; *======== STOP begin ==========* 
M400
M117 Job end
G0 X0 Y0 F2500
M0 Turn OFF spindle. COMPLETE!
; *======== STOP end ==========* 

```
