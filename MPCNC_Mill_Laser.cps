/*

  $Revision: 42049 24365c4692af9ba58117d1ab4b45705fca82c227 $
  $Date: 2018-07-30 11:44:37 $
  
MPCNC posts processor for milling and laser/plasma cutting.

Some design points:
- Setup operation types: Milling, Water/Laser/Plasma
- Only support MM units (inches may work with custom start gcode - NOT TESTED)
- XY and Z independent travel speeds. Rapids are done with G1.
- Arcs support on XY plane
- Tested with LCD display and SD card (built in tool change require printing from SD and LCD to restart)
- Support for 3 different laser power using "cutting modes" (through, etch, vaporize)

*/


// user-defined properties
properties = {
  travelSpeedXY: 2500,              // High speed for travel movements X & Y (mm/min)
  travelSpeedZ: 300,                // High speed for travel movements Z (mm/min)

  manualSpindlePowerControl: true,   // Spindle motor is controlled by manual switch 

  setOriginOnStart: true,           // Set origin when gcode start (G92)
  goOriginOnFinish: true,           // Go X0 Y0 Z0 at gcode end

  toolChangeEnabled: true,          // Enable tool change code (bultin tool change requires LCD display)
  toolChangeX: 0,                   // X position for builtin tool change
  toolChangeY: 0,                   // Y position for builtin tool change
  toolChangeZ: 40,                  // Z position for builtin tool change
  toolChangeZProbe: true,           // Z probe after tool change
  toolChangeDisableZStepper: false, // disable Z stepper when change a tool

  probeOnStart: true,               // Execute probe gcode to align tool
  probeThickness: 0.8,              // plate thickness
  probeUseHomeZ: true,               // use G28 or G38 for probing 
  probeG38Target: -10,              // probing up to pos 
  probeG38Speed: 30,                // probing with speed 

  gcodeStartFile: "",               // File with custom Gcode for header/start (in nc folder)
  gcodeStopFile: "",                // File with custom Gcode for footer/end (in nc folder)
  gcodeToolFile: "",                // File with custom Gcode for tool change (in nc folder)
  gcodeProbeFile: "",               // File with custom Gcode for tool probe (in nc folder)

  cutterOnVaporize: "M106 S255",    // GCode command to turn on the laser/plasma cutter in vaporize mode
  cutterOnThrough: "M106 S200",     // GCode command to turn on the laser/plasma cutter in through mode
  cutterOnEtch: "M106 S100",        // GCode command to turn on the laser/plasma cutter in etch mode
  cutterOff: "M107",                 // Gcode command to turn off the laser/plasma cutter

  coolantAMode: 0, // Enable issuing g-codes for control Coolant channel A 
  coolantAOn: "M42 P11 S255",        // GCode command to turn on Coolant channel A
  coolantAOff: "M42 P11 S0",         // Gcode command to turn off Coolant channel A
  coolantBMode: 0, // Use issuing g-codes for control Coolant channel B  
  coolantBOn: "M42 P6 S255",         // GCode command to turn on Coolant channel B
  coolantBOff: "M42 P6 S0"          // Gcode command to turn off Coolant channel B
};

propertyDefinitions = {
  travelSpeedXY: { title: "Job: Travel speed X/Y", description: "High speed for travel movements X & Y (mm/min)", group: 1, type: "integer", default_mm: 2500 },
  travelSpeedZ: { title: "Job: Travel Speed Z", description: "High speed for travel movements z (mm/min)", group: 1, type: "integer", default_mm: 300 },

  manualSpindlePowerControl: { title: "Job: Manual Spindle On/Off", description: "Set Yes when your spindle motor is controlled by manual switch", group: 1, type: "boolean", default_mm: true },
  setOriginOnStart: { title: "Job: Reset on start (G92)", description: "Set origin when gcode start (G92)", group: 1, type: "boolean", default_mm: true },
  goOriginOnFinish: { title: "Job: Goto 0 at end", description: "Go X0 Y0 at gcode end", group: 1, type: "boolean", default_mm: true },

  toolChangeEnabled: { title: "Change: Enabled", description: "Enable tool change code (bultin tool change requires LCD display)", group: 2, type: "boolean", default_mm: true },
  toolChangeX: { title: "Change: X", description: "X position for builtin tool change", group: 2, type: "integer", default_mm: 0 },
  toolChangeY: { title: "Change: Y", description: "Y position for builtin tool change", group: 2, type: "integer", default_mm: 0 },
  toolChangeZ: { title: "Change: Z ", description: "Z position for builtin tool change", group: 2, type: "integer", default_mm: 40 },
  toolChangeZProbe: { title: "Change: Make Z Probe", description: "Z probe after tool change", group: 2, type: "boolean", default_mm: true },
  toolChangeDisableZStepper: { title: "Change: Disable Z stepper", description: "Disable Z stepper when change a tool", group: 2, type: "boolean", default_mm: false },

  probeOnStart: { title: "Probe: On job start", description: "Execute probe gcode on job start", group: 3, type: "boolean", default_mm: true },
  probeThickness: { title: "Probe: Plate thickness", description: "Plate thickness", group: 3, type: "number", default_mm: 0.8 },
  probeUseHomeZ: { title: "Probe: Use Home Z", description: "Use G28 or G38 for probing", group: 3, type: "boolean", default_mm: true },
  probeG38Target: { title: "Probe: G38 target", description: "Probing up to Z position", group: 3, type: "integer", default_mm: -10 },
  probeG38Speed: { title: "Probe: G38 speed", description: "Probing with speed", group: 3, type: "integer", default_mm: 30 },

  cutterOnVaporize: { title: "Laser: On - Vaporize", description: "GCode command to turn on the laser/plasma cutter in vaporize mode", group: 4, type: "string", default_mm: "M106 S255" },
  cutterOnThrough: { title: "Laser: On - Through", description: "GCode command to turn on the laser/plasma cutter in through mode", group: 4, type: "string", default_mm: "M106 S200" },
  cutterOnEtch: { title: "Laser: On - Etch", description: "GCode command to turn on the laser/plasma cutter in etch mode", group: 4, type: "string", default_mm: "M106 S100" },
  cutterOff: { title: "Laser: Off", description: "Gcode command to turn off the laser/plasma cutter", group: 4, type: "string", default_mm: "M107" },

  gcodeStartFile: { title: "Extern: Start File", description: "File with custom Gcode for header/start (in nc folder)", group: 5, type: "file", default_mm: "" },
  gcodeStopFile: { title: "Extern: Stop File", description: "File with custom Gcode for footer/end (in nc folder)", group: 5, type: "file", default_mm: "" },
  gcodeToolFile: { title: "Extern: Tool File", description: "File with custom Gcode for tool change (in nc folder)", group: 5, type: "file", default_mm: "" },
  gcodeProbeFile: { title: "Extern: Probe File", description: "File with custom Gcode for tool probe (in nc folder)", group: 5, type: "file", default_mm: "" },

  coolantAMode: {
    title: "Coolant: A Mode", description: "Enable issuing g-codes for control Coolant channel A", group: 6, type: "integer", default_mm: 0, values: [
      { title: "off", id: 0 },
      { title: "flood", id: 1 },
      { title: "mist", id: 2 },
      { title: "throughTool", id: 3 },
      { title: "air", id: 4 },
      { title: "airThroughTool", id: 5 },
      { title: "suction", id: 6 },
      { title: "floodMist", id: 7 },
      { title: "floodThroughTool", id: 8 }
    ]
  },
  coolantAOn: { title: "Coolant: A On command", description: "GCode command to turn on Coolant channel A", group: 6, type: "string", default_mm: "M42 P11 S255" },
  coolantAOff: { title: "Coolant: A Off command", description: "Gcode command to turn off Coolant A", group: 6, type: "string", default_mm: "M42 P11 S0" },
  coolantBMode: {
    title: "Coolant: B Mode", description: "Enable issuing g-codes for control Coolant channel B", group: 6, type: "integer", default_mm: 0, values: [
      { title: "off", id: 0 },
      { title: "flood", id: 1 },
      { title: "mist", id: 2 },
      { title: "throughTool", id: 3 },
      { title: "air", id: 4 },
      { title: "airThroughTool", id: 5 },
      { title: "suction", id: 6 },
      { title: "floodMist", id: 7 },
      { title: "floodThroughTool", id: 8 }
    ]
  },
  coolantBOn: { title: "Coolant: B On command", description: "GCode command to turn on Coolant channel B", group: 6, type: "string", default_mm: "M42 P6 S255" },
  coolantBOff: { title: "Coolant: B Off command", description: "Gcode command to turn off Coolant channel B", group: 6, type: "string", default_mm: "M42 P6 S0" },
};


// Internal properties
certificationLevel = 2;
extension = "gcode";
setCodePage("ascii");
capabilities = CAPABILITY_MILLING | CAPABILITY_JET;
description = "MPCNC Marlin 2.0 Milling/Laser";

// Formats
var xyzFormat = createFormat({ decimals: 3 });
var feedFormat = createFormat({ decimals: 0 });
var speedFormat = createFormat({ decimals: 0 });

// Linear outputs
var xOutput = createVariable({ prefix: " X" }, xyzFormat);
var yOutput = createVariable({ prefix: " Y" }, xyzFormat);
var zOutput = createVariable({ prefix: " Z" }, xyzFormat);
var fOutput = createVariable({ prefix: " F" }, feedFormat);
var sOutput = createVariable({ prefix: " S", force: true }, speedFormat);

// Circular outputs
var iOutput = createReferenceVariable({ prefix: " I" }, xyzFormat);
var jOutput = createReferenceVariable({ prefix: " J" }, xyzFormat);
var kOutput = createReferenceVariable({ prefix: " K" }, xyzFormat);

// Arc support variables
minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = false;
allowedCircularPlanes = undefined;

// Called in every new gcode file
function onOpen() {
  // See onSection
  return;
}

// Called at end of gcode file
function onClose() {
  writeComment(" *======== STOP begin ==========* ");
  writeln("M400");
  if (properties.gcodeStopFile == "") {
    onCommand(COMMAND_COOLANT_OFF);
    onCommand(COMMAND_STOP_SPINDLE);
    if (properties.goOriginOnFinish) {
      writeln("G0 X0 Y0" + fOutput.format(properties.travelSpeedXY)); // Go to XY origin
      //onRapid(0,0,position.z);
    }
    writeln("M117 Job end");
    writeComment(" *======== STOP end ==========* ");
  } else {
    loadFile(properties.gcodeStopFile);
  }
  return;
}

// Misc variables
var cutterOnGCodeOfCurrentMode;

// Called in every section
function onSection() {

  // Write Start gcode of the documment (after the "onParameters" with the global info)
  if (isFirstSection()) {
    writeComment(" *======== START begin ==========* ");
    if (properties.gcodeStartFile == "") {
      writeln("G90"); // Set to Absolute Positioning
      writeln("G21"); // Set Units to Millimeters
      writeln("M84 S0"); // Disable steppers timeout
      if (properties.setOriginOnStart) {
        writeln("G92 X0 Y0 Z0"); // Set origin to initial position
      }
    } else {
      loadFile(properties.gcodeStartFile);
    }
    if (properties.probeOnStart && tool.number != 0) {
      onCommand(COMMAND_TOOL_MEASURE);
    }
    onCommand(COMMAND_START_SPINDLE);
    writeComment(" *======== START end ==========* ");
  }

  // Tool change
  if (properties.toolChangeEnabled && !isFirstSection() && tool.number != getPreviousSection().getTool().number) {
    toolChange();
  }

  // Machining type
  if (currentSection.type == TYPE_MILLING) {
    // Specific milling code
    writeComment(sectionComment + " - Milling - Tool: " + tool.number + " - " + tool.comment + " " + getToolTypeName(tool.type));
  }

  if (currentSection.type == TYPE_JET) {
    // Cutter mode used for different cutting power in PWM laser
    switch (currentSection.jetMode) {
      case JET_MODE_THROUGH:
        cutterOnGCodeOfCurrentMode = properties.cutterOnThrough;
        break;
      case JET_MODE_ETCHING:
        cutterOnGCodeOfCurrentMode = properties.cutterOnEtch;
        break;
      case JET_MODE_VAPORIZE:
        cutterOnGCodeOfCurrentMode = properties.cutterOnVaporize;
        break;
      default:
        error("Cutting mode is not supported.");
    }
    writeComment(sectionComment + " - Laser/Plasma - Cutting mode: " + getParameter("operation:cuttingMode"));
  }

  // Print min/max boundaries for each section
  vectorX = new Vector(1, 0, 0);
  vectorY = new Vector(0, 1, 0);
  writeComment(" X Min: " + xyzFormat.format(currentSection.getGlobalRange(vectorX).getMinimum()) + " - X Max: " + xyzFormat.format(currentSection.getGlobalRange(vectorX).getMaximum()));
  writeComment(" Y Min: " + xyzFormat.format(currentSection.getGlobalRange(vectorY).getMinimum()) + " - Y Max: " + xyzFormat.format(currentSection.getGlobalRange(vectorY).getMaximum()));
  writeComment(" Z Min: " + xyzFormat.format(currentSection.getGlobalZRange().getMinimum()) + " - Z Max: " + xyzFormat.format(currentSection.getGlobalZRange().getMaximum()));

  // Display section name in LCD
  writeln("M400");
  writeln("M117 " + sectionComment);

  // set coolant after we have positioned at Z
  onCommand(COMMAND_COOLANT_ON);
  return;
}

// Called in every section end
function onSectionEnd() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
  fOutput.reset();
  writeln("");
  return;
}

// Rapid movements
function onRapid(x, y, z) {
  rapidMovements(x, y, z);
  return;
}

// Feed movements
function onLinear(x, y, z, feed) {
  linearMovements(x, y, z, feed);
  return;
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  circularMovements(clockwise, cx, cy, cz, x, y, z, feed);
  return;
}

// Called on waterjet/plasma/laser cuts
var powerState = false;

function onPower(power) {
  if (power != powerState) {
    if (power) {
      writeComment(" LASER Power ON");
      writeln(cutterOnGCodeOfCurrentMode);
    } else {
      writeComment(" LASER Power OFF");
      writeln(properties.cutterOff);
    }
    powerState = power;
  }
  return;
}

// Called on Dwell Manual NC invocation
function onDwell(seconds) {
  writeComment(" Dwell");
  writeln("G4 S" + seconds);
  writeln("");
  return;
}

// Called with every parameter in the documment/section
function onParameter(name, value) {

  // Write gcode initial info
  // Product version
  if (name == "generated-by") {
    writeComment(value);
    writeComment(" Posts processor: " + FileSystem.getFilename(getConfigurationPath()));
  }
  // Date
  if (name == "generated-at") writeComment(" Gcode generated: " + value + " GMT");
  // Document
  if (name == "document-path") writeComment(" Document: " + value);
  // Setup
  if (name == "job-description") writeComment(" Setup: " + value);

  // Get section comment
  if (name == "operation-comment") sectionComment = value;

  return;
}

function onSpindleSpeed(spindleSpeed) {
  var s = sOutput.format(spindleSpeed);
  writeComment(" Spindle Speed " + s);
  writeln(s);
}

function onCommand(command) {
  var stringId = getCommandStringId(command);
  writeComment(" " + stringId);
  switch (command) {
    case COMMAND_START_SPINDLE:
      onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
      return;
    case COMMAND_SPINDLE_CLOCKWISE:
      if (tool.jetTool)
        return;
      if (properties.manualSpindlePowerControl) {
        writeln("M0 Turn ON CLOCKWISE");
      } else {
        writeln("M3" + sOutput.format(spindleSpeed));
      }
      return;
    case COMMAND_SPINDLE_COUNTERCLOCKWISE:
      if (tool.jetTool)
        return;
      if (properties.manualSpindlePowerControl) {
        writeln("M0 Turn ON COUNTERCLOCKWISE");
      } else {
        writeln("M4" + sOutput.format(spindleSpeed));
      }
      return;
    case COMMAND_STOP_SPINDLE:
      if (tool.jetTool)
        return;
      if (properties.manualSpindlePowerControl) {
        writeln("M0 Turn OFF spindle");
      } else {
        writeln("M5");
      }
      return;
    case COMMAND_COOLANT_ON:
      setCoolant(tool.coolant);
      return;
    case COMMAND_COOLANT_OFF:
      setCoolant(0);  //COOLANT_DISABLED
      return;
    case COMMAND_LOCK_MULTI_AXIS:
      return;
    case COMMAND_UNLOCK_MULTI_AXIS:
      return;
    case COMMAND_BREAK_CONTROL:
      return;
    case COMMAND_TOOL_MEASURE:
      if (tool.jetTool)
        return;
      probeTool();
      return;
  }
}

// Output a comment
function writeComment(text) {
  writeln(";" + String(text).replace(/[\(\)]/g, ""));
  return;
}

// Rapid movements with G1 and differentiated travel speeds for XY and Z
function rapidMovements(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);

  if (z) {
    f = fOutput.format(properties.travelSpeedZ);
    fOutput.reset();
    writeln("G0" + z + f);
  }
  if (x || y) {
    f = fOutput.format(properties.travelSpeedXY);
    fOutput.reset();
    writeln("G0" + x + y + f);
  }
  return;
}

// Linear movements
function linearMovements(_x, _y, _z, _feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = fOutput.format(_feed);
  if (x || y || z) {
    writeln("G1" + x + y + z + f);
  }
  return;
}

// Circular movements
function circularMovements(_clockwise, _cx, _cy, _cz, _x, _y, _z, _feed) {
  // Marlin supports arcs only on XY plane
  switch (getCircularPlane()) {
    case PLANE_XY:
      var x = xOutput.format(_x);
      var y = yOutput.format(_y);
      var f = fOutput.format(_feed);
      var start = getCurrentPosition();
      var i = iOutput.format(_cx - start.x, 0);
      var j = jOutput.format(_cy - start.y, 0);

      if (_clockwise) {
        writeln("G2" + x + y + i + j + f);
      } else {
        writeln("G3" + x + y + i + j + f);
      }
      break;
    default:
      linearize(tolerance);
  }
  return;
}

// Tool change
function toolChange() {
  if (properties.gcodeToolFile == "") {
    // Builtin tool change gcode
    writeComment(" *======== CHANGE TOOL begin ==========* ");

    onCommand(COMMAND_COOLANT_OFF);
    // Beep
    writeln("M400"); // Wait movement buffer it's empty
    writeln("M300 S400 P2000");

    // Go to tool change position
    onRapid(properties.toolChangeX, properties.toolChangeY, properties.toolChangeZ);

    onCommand(COMMAND_STOP_SPINDLE);

    // Disable Z stepper
    if (properties.toolChangeDisableZStepper) {
      writeln("M0 Z Stepper will disabled. Wait for STOP!!");
      writeln("M18 Z");
    }

    // Ask tool change and wait user to touch lcd button
    writeln("M0 Put tool " + tool.number + " - " + tool.comment);

    // Run Z probe gcode
    if (properties.toolChangeZProbe && tool.number != 0) {
      onCommand(COMMAND_TOOL_MEASURE);
    }
    onCommand(COMMAND_START_SPINDLE);
    writeComment(" *======== CHANGE TOOL end ==========* ");
  } else {
    // Custom tool change gcode
    loadFile(properties.gcodeToolFile);
  }
}

// Probe tool
function probeTool() {
  if (properties.gcodeProbeFile == "") {
    writeComment(" +------- Probe tool -------+ ");
    writeln("M0 Attach ZProbe");
    // refer http://marlinfw.org/docs/gcode/G038.html
    if (properties.probeUseHomeZ) {
      writeln("G28 Z");
    } else {
      writeln("G38.3" + fOutput.format(properties.probeG38Speed) + zOutput.format(properties.probeG38Target));
    }
    writeln("G92" + zOutput.format(properties.probeThickness));
    if (properties.toolChangeZ != "") { // move up tool to safe height again after probing
      writeln("G0" + zOutput.format(properties.toolChangeZ) + fOutput.format(properties.travelSpeedZ));
    }
    writeln("M0 Detach ZProbe");
    writeComment(" +------- Tool probed -------+ ");
  } else {
    loadFile(properties.gcodeProbeFile);
  }
}

// Test if file exist/can read and load it
function loadFile(_file) {
  var folder = FileSystem.getFolderPath(getOutputPath()) + PATH_SEPARATOR;
  if (FileSystem.isFile(folder + _file)) {
    var txt = loadText(folder + _file, "utf-8");
    if (txt.length > 0) {
      writeComment(" Start custom gcode " + folder + _file);
      write(txt);
      writeComment(" End custom gcode " + folder + _file);
      writeln("");
    }
  } else {
    writeComment(" Can't open file " + folder + _file);
    error("Can't open file " + folder + _file);
  }
}

var currentCoolantMode = 0;

// Manage coolant state 
function setCoolant(coolant) {
  if (currentCoolantMode == coolant) {
    return;
  }
  if (properties.coolantAMode != 0 && properties.coolantAOn != "" && properties.coolantAOff != "") {
    if (currentCoolantMode == properties.coolantAMode) {
      writeln(properties.coolantAOff);
    } else if (coolant == properties.coolantAMode) {
      writeln(properties.coolantAOn);
    }
  }
  if (properties.coolantBMode != 0 && properties.coolantBOn != "" && properties.coolantBOff != "") {
    if (currentCoolantMode == properties.coolantBMode) {
      writeln(properties.coolantBOff);
    } else if (coolant == properties.coolantBMode) {
      writeln(properties.coolantBOn);
    }
  }
  currentCoolantMode = coolant;
}

