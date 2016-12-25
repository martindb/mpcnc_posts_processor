
CAM posts processor for use with Fusion 360 and MPCNC (www.vicious1.com) with RAMPS/Marlin

Some design points:
- Setup operation types: Milling, Water/Laser/Plasma
- Only support MM units (inches may work with custom start gcode - NOT TESTED)
- XY and Z independent travel speeds. Rapids are done with G1.
- Arcs support on XY plane
- Tested in Marlin 1.1.0RC8
- Tested with LCD display and SD card (built in tool change require printing from SD and LCD to restart)
- Support for 3 different laser power using "cutting modes" (through, etch, vaporize)
