;Fusion 360 CAM 2.0.4860
; Posts processor: MPCNC_Mill_Laser.cps
; Gcode generated: Sunday, December 2, 2018 1:56:26 PM GMT
; Document: cam_testpp v5
; Setup: Setup1
; 
; Ranges table:
; X: Min=2.588 Max=36 Size=33.412
; Y: Min=2.588 Max=36 Size=33.412
; Z: Min=-1 Max=15 Size=16
; 
; Tools table:
; T1 D=3.175 CR=0 - ZMIN=-1 - flat end mill
; T2 D=1.5 CR=0 - ZMIN=-1 - flat end mill

; *** START begin ***
G90
G21
M84 S0
G92 X0 Y0 Z0
; COMMAND_TOOL_MEASURE
; --- PROBE TOOL begin ---
M0 Attach ZProbe
G28 Z
G92 Z0.8
G0 Z50 F300
M0 Detach ZProbe
; --- PROBE TOOL end ---
; *** START end ***

; *** SECTION begin ***
;2D Contour1 - Milling - Tool: 1 - 1/8inch flat end mill
; X Min: 2.588 - X Max: 49.412
; Y Min: 2.588 - Y Max: 49.412
; Z Min: -1 - Z Max: 15
M400
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
; >>> Spindle Speed 21000
M3 S21000
; COMMAND_COOLANT_ON
M117 2D Contour1
G0 Z15
G0 X49.412 Y26 F2500
G0 Z5 F300
; MOVEMENT_PLUNGE
G1 Z1 F100
G1 Z-1
; 14
G1 Y49.412 F300
G1 X2.588
G1 Y2.588
G1 X49.412
G1 Y26
; MOVEMENT_RAPID
G0 Z15
; *** SECTION end ***

; *** SECTION begin ***
;2D Contour2 - Milling - Tool: 1 - 1/8inch flat end mill
; X Min: 9.587 - X Max: 42.412
; Y Min: 9.587 - Y Max: 42.412
; Z Min: -1 - Z Max: 15
M400
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
; >>> Spindle Speed 20000
M3 S20000
; COMMAND_COOLANT_ON
M117 2D Contour2
G0 Z15 F300
G0 X42.412 Y26 F2500
G0 Z5 F300
; MOVEMENT_PLUNGE
G1 Z1 F100
G1 Z-1
; 14
G1 Y42.412 F300
G1 X9.587
G1 Y9.587
G1 X42.412
G1 Y26
; MOVEMENT_RAPID
G0 Z15
; *** SECTION end ***

; *** SECTION begin ***
; --- CHANGE TOOL begin ---
; COMMAND_COOLANT_OFF
M400
M300 S400 P2000
G0 Z50 F300
G0 X0 Y0 F2500
; COMMAND_STOP_SPINDLE
M5
M0 Put tool 2 - 1.5mm
; COMMAND_TOOL_MEASURE
; --- PROBE TOOL begin ---
M0 Attach ZProbe
G28 Z
G92 Z0.8
G0 Z50 F300
M0 Detach ZProbe
; --- PROBE TOOL end ---
; --- CHANGE TOOL end ---
;Trace1 - Milling - Tool: 2 - 1.5mm flat end mill
; X Min: 16 - X Max: 36
; Y Min: 16 - Y Max: 36
; Z Min: -1 - Z Max: 15
M400
; COMMAND_START_SPINDLE
; COMMAND_SPINDLE_CLOCKWISE
; >>> Spindle Speed 21000
M3 S21000
; COMMAND_COOLANT_ON
M117 Trace1
G0 Z15
G0 X36 Y36 F2500
G0 Z4 F300
; MOVEMENT_LEAD_IN
G1 Z-1 F300
; MOVEMENT_CUTTING
G1 Y16
G1 X16
G1 Y36
G1 X36
; MOVEMENT_LEAD_OUT
G1 Z4
; MOVEMENT_RAPID
G0 Z15
; *** SECTION end ***

; *** STOP begin ***
M400
; COMMAND_COOLANT_OFF
; COMMAND_STOP_SPINDLE
M5
G0 X0 Y0 F2500
M117 Job end
; *** STOP end ***
