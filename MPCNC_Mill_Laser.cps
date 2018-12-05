/*

https://github.com/guffy1234/mpcnc_posts_processor

MPCNC posts processor for milling and laser/plasma cutting.

*/


// user-defined properties
properties = {
  jobTravelSpeedXY: 2500,              // High speed for travel movements X & Y (mm/min)
  jobTravelSpeedZ: 300,                // High speed for travel movements Z (mm/min)

  jobManualSpindlePowerControl: true,   // Spindle motor is controlled by manual switch 

  jobUseArcs: true,                    // Produce G2/G3 for arcs
  jobEnforceFeedrate: false,           // Add feedrate to each movement line

  jobSetOriginOnStart: true,           // Set origin when gcode start (G92)
  jobGoOriginOnFinish: true,           // Go X0 Y0 Z0 at gcode end

  toolChangeEnabled: true,          // Enable tool change code (bultin tool change requires LCD display)
  toolChangeX: 0,                   // X position for builtin tool change
  toolChangeY: 0,                   // Y position for builtin tool change
  toolChangeZ: 40,                  // Z position for builtin tool change
  toolChangeZProbe: true,           // Z probe after tool change
  toolChangeDisableZStepper: false, // disable Z stepper when change a tool

  probeOnStart: true,               // Execute probe gcode to align tool
  probeThickness: 0.8,              // plate thickness
  probeUseHomeZ: true,              // use G28 or G38 for probing 
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
  coolantBOff: "M42 P6 S0",          // Gcode command to turn off Coolant channel B

  commentWriteTools: true,
  commentActivities: true,
  commentSections: true,
  commentCommands: true,
  commentMovements: true,
};

propertyDefinitions = {
  jobTravelSpeedXY: {
    title: "Job: Travel speed X/Y", description: "High speed for travel movements X & Y (mm/min; in/min)", group: 1,
    type: "spatial", default_mm: 2500, default_in: 100
  },
  jobTravelSpeedZ: {
    title: "Job: Travel Speed Z", description: "High speed for travel movements z (mm/min; in/min)", group: 1,
    type: "spatial", default_mm: 300, default_in: 12
  },

  jobManualSpindlePowerControl: {
    title: "Job: Manual Spindle On/Off", description: "Set Yes when your spindle motor is controlled by manual switch", group: 1,
    type: "boolean", default_mm: true, default_in: true
  },
  jobUseArcs: {
    title: "Job: Use Arcs", description: "Use G2/G3 g-codes fo circular movements", group: 1,
    type: "boolean", default_mm: true, default_in: true
  },

  jobEnforceFeedrate: {
    title: "Job: Enforce Feedrate", description: "Add feedrate to each movement g-code", group: 1,
    type: "boolean", default_mm: false, default_in: false
  },

  jobSetOriginOnStart: {
    title: "Job: Reset on start (G92)", description: "Set origin when gcode start (G92)", group: 1,
    type: "boolean", default_mm: true, default_in: true
  },
  jobGoOriginOnFinish: {
    title: "Job: Goto 0 at end", description: "Go X0 Y0 at gcode end", group: 1,
    type: "boolean", default_mm: true, default_in: true
  },

  toolChangeEnabled: {
    title: "Change: Enabled", description: "Enable tool change code (bultin tool change requires LCD display)", group: 2,
    type: "boolean", default_mm: true, default_in: true
  },
  toolChangeX: {
    title: "Change: X", description: "X position for builtin tool change", group: 2,
    type: "spatial", default_mm: 0, default_in: 0
  },
  toolChangeY: {
    title: "Change: Y", description: "Y position for builtin tool change", group: 2,
    type: "spatial", default_mm: 0, default_in: 0
  },
  toolChangeZ: {
    title: "Change: Z ", description: "Z position for builtin tool change", group: 2,
    type: "spatial", default_mm: 40, default_in: 1.6
  },
  toolChangeZProbe: {
    title: "Change: Make Z Probe", description: "Z probe after tool change", group: 2,
    type: "boolean", default_mm: true, default_in: true
  },
  toolChangeDisableZStepper: {
    title: "Change: Disable Z stepper", description: "Disable Z stepper when change a tool", group: 2,
    type: "boolean", default_mm: false, default_in: false
  },

  probeOnStart: {
    title: "Probe: On job start", description: "Execute probe gcode on job start", group: 3,
    type: "boolean", default_mm: true, default_in: true
  },
  probeThickness: {
    title: "Probe: Plate thickness", description: "Plate thickness", group: 3,
    type: "spatial", default_mm: 0.8, default_in: 0.032
  },
  probeUseHomeZ: {
    title: "Probe: Use Home Z", description: "Use G28 or G38 for probing", group: 3,
    type: "boolean", default_mm: true, default_in: true
  },
  probeG38Target: {
    title: "Probe: G38 target", description: "Probing up to Z position", group: 3,
    type: "spatial", default_mm: -10, default_in: -0.5
  },
  probeG38Speed: {
    title: "Probe: G38 speed", description: "Probing with speed (mm/min; in/min)", group: 3,
    type: "spatial", default_mm: 30, default_in: 1.2
  },

  cutterOnVaporize: {
    title: "Laser: On - Vaporize", description: "GCode command to turn on the laser/plasma cutter in vaporize mode", group: 4,
    type: "string", default_mm: "M106 S255", default_in: "M106 S255"
  },
  cutterOnThrough: {
    title: "Laser: On - Through", description: "GCode command to turn on the laser/plasma cutter in through mode", group: 4,
    type: "string", default_mm: "M106 S200", default_in: "M106 S200"
  },
  cutterOnEtch: {
    title: "Laser: On - Etch", description: "GCode command to turn on the laser/plasma cutter in etch mode", group: 4,
    type: "string", default_mm: "M106 S100", default_in: "M106 S100"
  },
  cutterOff: {
    title: "Laser: Off", description: "Gcode command to turn off the laser/plasma cutter", group: 4,
    type: "string", default_mm: "M107", default_in: "M107"
  },

  gcodeStartFile: {
    title: "Extern: Start File", description: "File with custom Gcode for header/start (in nc folder)", group: 5,
    type: "file", default_mm: "", default_in: ""
  },
  gcodeStopFile: {
    title: "Extern: Stop File", description: "File with custom Gcode for footer/end (in nc folder)", group: 5,
    type: "file", default_mm: "", default_in: ""
  },
  gcodeToolFile: {
    title: "Extern: Tool File", description: "File with custom Gcode for tool change (in nc folder)", group: 5,
    type: "file", default_mm: "", default_in: ""
  },
  gcodeProbeFile: {
    title: "Extern: Probe File", description: "File with custom Gcode for tool probe (in nc folder)", group: 5,
    type: "file", default_mm: "", default_in: ""
  },

  coolantAMode: {
    title: "Coolant: A Mode", description: "Enable issuing g-codes for control Coolant channel A", group: 6, type: "integer",
    default_mm: 0, default_in: 0,
    values: [
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
  coolantAOff: {
    title: "Coolant: A Off command", description: "Gcode command to turn off Coolant A", group: 6, type: "string",
    default_mm: "M42 P11 S0", default_in: "M42 P11 S0"
  },
  coolantBMode: {
    title: "Coolant: B Mode", description: "Enable issuing g-codes for control Coolant channel B", group: 6, type: "integer",
    default_mm: 0, default_in: 0,
    values: [
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
  coolantBOn: {
    title: "Coolant: B On command", description: "GCode command to turn on Coolant channel B", group: 6, type: "string",
    default_mm: "M42 P6 S255", default_in: "M42 P6 S255"
  },
  coolantBOff: {
    title: "Coolant: B Off command", description: "Gcode command to turn off Coolant channel B", group: 6, type: "string",
    default_mm: "M42 P6 S0", default_in: "M42 P6 S0"
  },

  commentWriteTools: {
    title: "Comment: Write Tools", description: "Write table of used tools in job header", group: 7,
    type: "boolean", default_mm: true, default_in: true
  },
  commentActivities: {
    title: "Comment: Activities", description: "Write comments which somehow helps to understand current piece of g-code", group: 7,
    type: "boolean", default_mm: true, default_in: true
  },
  commentSections: {
    title: "Comment: Sections", description: "Write header of every section", group: 7,
    type: "boolean", default_mm: true, default_in: true
  },
  commentCommands: {
    title: "Comment: Trace Commands", description: "Write stringified commands called by CAM", group: 7,
    type: "boolean", default_mm: true, default_in: true
  },
  commentMovements: {
    title: "Comment: Trace Movements", description: "Write stringified movements called by CAM", group: 7,
    type: "boolean", default_mm: true, default_in: true
  },

};

// Internal properties
certificationLevel = 2;
extension = "gcode";
setCodePage("ascii");
capabilities = CAPABILITY_MILLING | CAPABILITY_JET;
description = "MPCNC Marlin 2.0 Milling/Laser";
// vendor of MPCNC
vendor = "v1engineering";
vendorUrl = "https://www.v1engineering.com";
// postprocessor origin https://github.com/guffy1234/mpcnc_posts_processor

// Formats
var xyzFormat = createFormat({ decimals: (unit == MM ? 3 : 4) });
var feedFormat = createFormat({ decimals: (unit == MM ? 0 : 2) });
var speedFormat = createFormat({ decimals: 0 });
var toolFormat = createFormat({ decimals: 0 });

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
  writeActivityComment(" *** STOP begin ***");
  writeln("M400");
  if (properties.gcodeStopFile == "") {
    onCommand(COMMAND_COOLANT_OFF);
    onCommand(COMMAND_STOP_SPINDLE);
    if (properties.jobGoOriginOnFinish) {
      rapidMovementsXY(0,0);
    }
    writeln("M117 Job end");
    writeActivityComment(" *** STOP end ***");
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
    writeFirstSection();
  }
  writeActivityComment(" *** SECTION begin ***");

  // Tool change
  if (properties.toolChangeEnabled && !isFirstSection() && tool.number != getPreviousSection().getTool().number) {
    toolChange();
  }

  if (properties.commentSections) {
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
  }

  writeln("M400");
  onCommand(COMMAND_START_SPINDLE);
  onCommand(COMMAND_COOLANT_ON);
  // Display section name in LCD
  writeln("M117 " + sectionComment);
  return;
}

// Called in every section end
function onSectionEnd() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
  fOutput.reset();
  writeActivityComment(" *** SECTION end ***");
  writeln("");
  return;
}

function onComment(message) {
  writeComment(message);
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
  if (properties.jobUseArcs) {
    circularMovements(clockwise, cx, cy, cz, x, y, z, feed);
  } else {
    linearize(tolerance);
  }
  return;
}

// Called on waterjet/plasma/laser cuts
var powerState = false;

function onPower(power) {
  if (power != powerState) {
    if (power) {
      writeActivityComment(" >>> LASER Power ON");
      writeln(cutterOnGCodeOfCurrentMode);
    } else {
      writeActivityComment(" >>> LASER Power OFF");
      writeln(properties.cutterOff);
    }
    powerState = power;
  }
  return;
}

// Called on Dwell Manual NC invocation
function onDwell(seconds) {
  writeActivityComment(" >>> Dwell");
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

function onMovement(movement) {
  if (properties.commentMovements) {
    var jet = tool.isJetTool && tool.isJetTool();
    var id;
    switch (movement) {
      case MOVEMENT_RAPID:
        id = "MOVEMENT_RAPID";
        break;
      case MOVEMENT_LEAD_IN:
        id = "MOVEMENT_LEAD_IN";
        break;
      case MOVEMENT_CUTTING:
        id = "MOVEMENT_CUTTING";
        break;
      case MOVEMENT_LEAD_OUT:
        id = "MOVEMENT_LEAD_OUT";
        break;
      case MOVEMENT_LINK_TRANSITION:
        id = jet ? "MOVEMENT_BRIDGING" : "MOVEMENT_LINK_TRANSITION";
        break;
      case MOVEMENT_LINK_DIRECT:
        id = "MOVEMENT_LINK_DIRECT";
        break;
      case MOVEMENT_RAMP_HELIX:
        id = jet ? "MOVEMENT_PIERCE_CIRCULAR" : "MOVEMENT_RAMP_HELIX";
        break;
      case MOVEMENT_RAMP_PROFILE:
        id = jet ? "MOVEMENT_PIERCE_PROFILE" : "MOVEMENT_RAMP_PROFILE";
        break;
      case MOVEMENT_RAMP_ZIG_ZAG:
        id = jet ? "MOVEMENT_PIERCE_LINEAR" : "MOVEMENT_RAMP_ZIG_ZAG";
        break;
      case MOVEMENT_RAMP:
        id = "MOVEMENT_RAMP";
        break;
      case MOVEMENT_PLUNGE:
        id = jet ? "MOVEMENT_PIERCE" : "MOVEMENT_PLUNGE";
        break;
      case MOVEMENT_PREDRILL:
        id = "MOVEMENT_PREDRILL";
        break;
      case MOVEMENT_EXTENDED:
        id = "MOVEMENT_EXTENDED";
        break;
      case MOVEMENT_REDUCED:
        id = "MOVEMENT_REDUCED";
        break;
      case MOVEMENT_HIGH_FEED:
        id = "MOVEMENT_HIGH_FEED";
        break;
    }
    if (id == undefined) {
      id = String(movement);
    }
    writeComment(" " + id);
  }
}

var currentSpindleSpeed = 0;

function setSpindeSpeed(_spindleSpeed, _clockwise) {
  var _rpm=_spindleSpeed;
  if (properties.jobManualSpindlePowerControl && _spindleSpeed > 0) {
    _spindleSpeed = 1; // for manula any positive input speed assumed as enabled. so it's just a flag
  }

  if (currentSpindleSpeed != _spindleSpeed) {
    if (_spindleSpeed > 0) {
      if (properties.jobManualSpindlePowerControl) {
        writeln("M0 Turn ON " + speedFormat.format(_rpm)+"RPM");
      } else {
        var s = sOutput.format(spindleSpeed);
        writeActivityComment(" >>> Spindle Speed " + speedFormat.format(_spindleSpeed));
        if (_clockwise) {
          writeln("M3" + s);
        } else {
          writeln("M4" + s);
        }
      }
    } else {
      if (properties.jobManualSpindlePowerControl) {
        writeln("M0 Turn OFF spindle");
      } else {
        writeln("M5");
      }
    }
    currentSpindleSpeed = _spindleSpeed;
  }
}

function onSpindleSpeed(spindleSpeed) {
  setSpindeSpeed(spindleSpeed, tool.clockwise);
}

function onCommand(command) {
  if (properties.commentActivities) {
    var stringId = getCommandStringId(command);
    writeComment(" " + stringId);
  }
  switch (command) {
    case COMMAND_START_SPINDLE:
      onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
      return;
    case COMMAND_SPINDLE_CLOCKWISE:
      if (tool.jetTool)
        return;
      setSpindeSpeed(spindleSpeed, true);
      return;
    case COMMAND_SPINDLE_COUNTERCLOCKWISE:
      if (tool.jetTool)
        return;
      setSpindeSpeed(spindleSpeed, false);
      return;
    case COMMAND_STOP_SPINDLE:
      if (tool.jetTool)
        return;
      setSpindeSpeed(0, true);
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

function handleMinMax(pair, range) {
  var rmin = range.getMinimum();
  var rmax = range.getMaximum();
  if (pair.min == undefined || pair.min > rmin) {
    pair.min = rmin;
  }
  if (pair.max == undefined || pair.min < rmin) {
    pair.max = rmax;
  }
}

function writeFirstSection() {
  if(properties.jobEnforceFeedrate)
  {
    fOutput = createVariable({ prefix: " F", force: true }, feedFormat);
  }

  // dump tool information
  var toolZRanges = {};
  var vectorX = new Vector(1, 0, 0);
  var vectorY = new Vector(0, 1, 0);
  var ranges = {
    x: { min: undefined, max: undefined },
    y: { min: undefined, max: undefined },
    z: { min: undefined, max: undefined },
  };
  var numberOfSections = getNumberOfSections();
  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    var tool = section.getTool();
    var zRange = section.getGlobalZRange();
    var xRange = section.getGlobalRange(vectorX);
    var yRange = section.getGlobalRange(vectorY);
    handleMinMax(ranges.x, xRange);
    handleMinMax(ranges.y, yRange);
    handleMinMax(ranges.z, zRange);
    if (is3D() && properties.commentWriteTools) {
      if (toolZRanges[tool.number]) {
        toolZRanges[tool.number].expandToRange(zRange);
      } else {
        toolZRanges[tool.number] = zRange;
      }
    }
  }

  writeComment(" ");
  writeComment(" Ranges table:");
  writeComment(" X: Min=" + xyzFormat.format(ranges.x.min) + " Max=" + xyzFormat.format(ranges.x.max) + " Size=" + xyzFormat.format(ranges.x.max - ranges.x.min));
  writeComment(" Y: Min=" + xyzFormat.format(ranges.y.min) + " Max=" + xyzFormat.format(ranges.y.max) + " Size=" + xyzFormat.format(ranges.y.max - ranges.y.min));
  writeComment(" Z: Min=" + xyzFormat.format(ranges.z.min) + " Max=" + xyzFormat.format(ranges.z.max) + " Size=" + xyzFormat.format(ranges.z.max - ranges.z.min));

  if (properties.commentWriteTools) {
    writeComment(" ");
    writeComment(" Tools table:");
    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = " T" + toolFormat.format(tool.number) + " D=" + xyzFormat.format(tool.diameter) + " CR=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " TAPER=" + taperFormat.format(tool.taperAngle) + "deg";
        }
        if (toolZRanges[tool.number]) {
          comment += " - ZMIN=" + xyzFormat.format(toolZRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type) + " " + tool.comment;
        writeComment(comment);
      }
    }
  }
  writeln("");
  writeActivityComment(" *** START begin ***");

  if (properties.gcodeStartFile == "") {
    writeln("G90"); // Set to Absolute Positioning
    switch (unit) {
      case IN:
        writeln("G20"); // Set Units to Inches
        break;
      case MM:
        writeln("G21"); // Set Units to Millimeters
        break;
    }
    writeln("M84 S0"); // Disable steppers timeout
    if (properties.jobSetOriginOnStart) {
      writeln("G92 X0 Y0 Z0"); // Set origin to initial position
    }
  } else {
    loadFile(properties.gcodeStartFile);
  }
  if (properties.probeOnStart && tool.number != 0) {
    onCommand(COMMAND_TOOL_MEASURE);
  }
  writeActivityComment(" *** START end ***");
  writeln("");
}

// Output a comment
function writeComment(text) {
  writeln(";" + String(text).replace(/[\(\)]/g, ""));
  return;
}

// Rapid movements with G1 and differentiated travel speeds for XY and Z
function rapidMovementsXY(_x, _y) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  if (x || y) {
    f = fOutput.format(propertyMmToUnit(properties.jobTravelSpeedXY));
    fOutput.reset();
    writeln("G0" + x + y + f);
  }
}
function rapidMovementsZ(_z) {
  var z = zOutput.format(_z);
  if (z) {
    f = fOutput.format(propertyMmToUnit(properties.jobTravelSpeedZ));
    fOutput.reset();
    writeln("G0" + z + f);
  }
}

function rapidMovements(_x, _y, _z) {
  rapidMovementsZ(_z);
  rapidMovementsXY(_x, _y);
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
    writeActivityComment(" --- CHANGE TOOL begin ---");

    writeln("M400"); // Wait movement buffer it's empty
    // Go to tool change position
    onRapid(propertyMmToUnit(properties.toolChangeX), propertyMmToUnit(properties.toolChangeY), propertyMmToUnit(properties.toolChangeZ));
    // turn off spindle and coolant
    onCommand(COMMAND_COOLANT_OFF);
    onCommand(COMMAND_STOP_SPINDLE);
    // Beep
    writeln("M300 S400 P2000");

    // Disable Z stepper
    if (properties.toolChangeDisableZStepper) {
      writeln("M0 Z Stepper will disabled. Wait for STOP!!");
      writeln("M18 Z");
    }

    // Ask tool change and wait user to touch lcd button
    writeln("M0 Tool " + tool.number + " " + tool.comment);

    // Run Z probe gcode
    if (properties.toolChangeZProbe && tool.number != 0) {
      onCommand(COMMAND_TOOL_MEASURE);
    }
    writeActivityComment(" --- CHANGE TOOL end ---");
  } else {
    // Custom tool change gcode
    loadFile(properties.gcodeToolFile);
  }
}

// Probe tool
function probeTool() {
  if (properties.gcodeProbeFile == "") {
    writeActivityComment(" --- PROBE TOOL begin ---");
    writeln("M0 Attach ZProbe");
    // refer http://marlinfw.org/docs/gcode/G038.html
    if (properties.probeUseHomeZ) {
      writeln("G28 Z");
    } else {
      writeln("G38.3" + fOutput.format(propertyMmToUnit(properties.probeG38Speed)) + zOutput.format(propertyMmToUnit(properties.probeG38Target)));
    }
    writeln("G92" + zOutput.format(propertyMmToUnit(properties.probeThickness)));
    if (properties.toolChangeZ != "") { // move up tool to safe height again after probing
      rapidMovementsZ(propertyMmToUnit(properties.toolChangeZ));
    }
    writeln("M0 Detach ZProbe");
    writeActivityComment(" --- PROBE TOOL end ---");
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
      writeActivityComment(" --- Start custom gcode " + folder + _file);
      write(txt);
      writeActivityComment(" --- End custom gcode " + folder + _file);
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
      writeActivityComment(" >>> Coolant A OFF");
      writeln(properties.coolantAOff);
    } else if (coolant == properties.coolantAMode) {
      writeActivityComment(" >>> Coolant A ON");
      writeln(properties.coolantAOn);
    }
  }
  if (properties.coolantBMode != 0 && properties.coolantBOn != "" && properties.coolantBOff != "") {
    if (currentCoolantMode == properties.coolantBMode) {
      writeActivityComment(" >>> Coolant B OFF");
      writeln(properties.coolantBOff);
    } else if (coolant == properties.coolantBMode) {
      writeActivityComment(" >>> Coolant B ON");
      writeln(properties.coolantBOn);
    }
  }
  currentCoolantMode = coolant;
}

function propertyMmToUnit(_v) {
  return (_v / (unit == IN ? 25.4 : 1));
}

function writeActivityComment(_comment) {
  if (properties.commentActivities) {
    writeComment(_comment);
  }
}