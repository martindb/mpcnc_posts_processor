/*

MPCNC posts processor for milling and laser/plasma cutting.

Some design points:
- Setup operation types: Milling, Water/Laser/Plasma
- Only support MM units (inches may work with custom start gcode - NOT TESTED)
- XY and Z independent travel speeds. Rapids are done with G1.
- Arcs support on XY plane
- Tested in Marlin 1.1.0RC8
- Tested with LCD display and SD card (built in tool change require printing from SD and LCD to restart)
- Support for 3 different laser power using "cutting modes" (through, etch, vaporize)

*/


// user-defined properties
properties = {
  cutterOnThrough: "M106 S200",     // GCode command to turn on the laser/plasma cutter in through mode
  cutterOnEtch: "M106 S100",        // GCode command to turn on the laser/plasma cutter in etch mode
  cutterOnVaporize: "M106 S255",    // GCode command to turn on the laser/plasma cutter in vaporize mode
  cutterOff: "M107",                // Gcode command to turn off the laser/plasma cutter
  travelSpeedXY: 2500,              // High speed for travel movements X & Y (mm/min)
  travelSpeedZ: 300,                // High speed for travel movements Z (mm/min)
  setOriginOnStart: true,           // Set origin when gcode start (G92)
  goOriginOnFinish: true,           // Go X0 Y0 Z0 at gcode end
  gcodeStartFile: "",               // File with custom Gcode for header/start (in nc folder)
  gcodeStopFile: "",                // File with custom Gcode for footer/end (in nc folder)
  gcodeToolFile: "",                // File with custom Gcode for tool change (in nc folder)
  gcodeProbeFile: "",               // File with custom Gcode for tool probe (in nc folder)
  toolChangeEnabled: true,          // Enable tool change code (bultin tool change requires LCD display)
  toolChangeXY: "X0 Y0",            // X&Y position for builtin tool change
  toolChangeZ: "Z30",               // Z position for builtin tool change
  toolChangeZProbe: true,           // Z probe after tool change
  probeOnStart: true                // Execute probe gcode to align tool
};

// Internal properties
extension = "gcode";
setCodePage("ascii");
capabilities = CAPABILITY_MILLING | CAPABILITY_JET;
description = "MPCNC Milling and Laser/Plasma cutter";

// Formats
var xyzFormat = createFormat({decimals:3});
var feedFormat = createFormat({decimals:0});

// Linear outputs
var xOutput = createVariable({prefix:" X"}, xyzFormat);
var yOutput = createVariable({prefix:" Y"}, xyzFormat);
var zOutput = createVariable({prefix:" Z"}, xyzFormat);
var fOutput = createVariable({prefix:" F"}, feedFormat);

// Circular outputs
var	iOutput	=	createReferenceVariable({prefix:" I"},	xyzFormat);
var	jOutput	=	createReferenceVariable({prefix:" J"},	xyzFormat);
var	kOutput	=	createReferenceVariable({prefix:" K"},	xyzFormat);

// Arc support variables
minimumChordLength	=	spatial(0.01,	MM);
minimumCircularRadius	=	spatial(0.01,	MM);
maximumCircularRadius	=	spatial(1000,	MM);
minimumCircularSweep	=	toRad(0.01);
maximumCircularSweep	=	toRad(180);
allowHelicalMoves	=	false;
allowedCircularPlanes	=	undefined;

// Misc variables
var powerState = false;
var cutterOn;

// Called in every new gcode file
function onOpen() {
  // See onSection
  return;
}

// Called at end of gcode file
function onClose() {

  // End message to LCD
  writeln("M400");
  writeln("M117 Job end");

  if(properties.gcodeStopFile == "") {
    if(properties.goOriginOnFinish) {
      writeln("G1 X0 Y0" + fOutput.format(properties.travelSpeedXY)); // Go to XY origin
      writeln("G1 Z0" + fOutput.format(properties.travelSpeedZ)); // Go to Z origin
    }
  } else {
    loadFile(properties.gcodeStopFile);
  }
  return;
}

// Called in every section
function onSection() {

  // Write Start gcode of the documment (after the "onParameters" with the global info)
  if(isFirstSection()) {
    writeln("");
    if(properties.gcodeStartFile == "") {
      writeln("G90"); // Set to Absolute Positioning
      writeln("G21"); // Set Units to Millimeters
      writeln("M84 S0"); // Disable steppers timeout
      if(properties.setOriginOnStart) {
        writeln("G92 X0 Y0 Z0"); // Set origin to initial position
      }
      writeln("");
    } else {
      loadFile(properties.gcodeStartFile);
    }

    if(properties.probeOnStart && tool.number != 0) {
      probeTool();
    }
  }

  // Tool change
  if(properties.toolChangeEnabled && !isFirstSection() && tool.number != getPreviousSection().getTool().number) {
    toolChange();
  }

  // Machining type
  if(currentSection.type == TYPE_MILLING) {
    // Specific milling code
    writeComment(sectionComment + " - Milling - Tool: " + tool.number + " - " + getToolTypeName(tool.type));
  }

  if(currentSection.type == TYPE_JET) {
    // Cutter mode used for different cutting power in PWM laser
      switch (currentSection.jetMode) {
      case JET_MODE_THROUGH:
        cutterOn = properties.cutterOnThrough;
        break;
      case JET_MODE_ETCHING:
        cutterOn = properties.cutterOnEtch;
        break;
      case JET_MODE_VAPORIZE:
        cutterOn = properties.cutterOnVaporize;
        break;
      default:
        error("Cutting mode is not supported.");
    }
    writeComment(sectionComment + " - Laser/Plasma - Cutting mode: " + getParameter("operation:cuttingMode"));
  }

  // Print min/max boundaries for each section
  vectorX = new Vector(1,0,0);
  vectorY = new Vector(0,1,0);
  writeComment("X Min: " + xyzFormat.format(currentSection.getGlobalRange(vectorX).getMinimum()) + " - X Max: " + xyzFormat.format(currentSection.getGlobalRange(vectorX).getMaximum()));
  writeComment("Y Min: " + xyzFormat.format(currentSection.getGlobalRange(vectorY).getMinimum()) + " - Y Max: " + xyzFormat.format(currentSection.getGlobalRange(vectorY).getMaximum()));
  writeComment("Z Min: " + xyzFormat.format(currentSection.getGlobalZRange().getMinimum()) + " - Z Max: " + xyzFormat.format(currentSection.getGlobalZRange().getMaximum()));

  // Display section name in LCD
  writeln("M400");
  writeln("M117 " + sectionComment);

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
function onRapid(x, y, z)	{
  rapidMovements(x, y, z);
  return;
}

// Feed movements
function onLinear(x, y, z, feed)	{
  linearMovements(x, y, z, feed);
  return;
}

function onCircular(clockwise, cx, cy, cz, x,	y, z, feed)	{
  circularMovements(clockwise, cx, cy, cz, x,	y, z, feed);
  return;
}

// Called on waterjet/plasma/laser cuts
function onPower(power) {
  if(power != powerState) {
    if(power) {
      writeln(cutterOn);
    } else {
      writeln(properties.cutterOff);
    }
    powerState = power;
  }
  return;
}

// Called on Dwell Manual NC invocation
function onDwell(seconds) {
  writeComment("Dwell");
  writeln("G4 S" + seconds);
  writeln("");
}

// Called with every parameter in the documment/section
function onParameter(name, value) {

  // Write gcode initial info
  // Product version
  if(name == "generated-by") {
    writeComment(value);
    writeComment("Posts processor: " + FileSystem.getFilename(getConfigurationPath()));
  }
  // Date
  if(name == "generated-at") writeComment("Gcode generated: " + value + " GMT");
  // Document
  if(name == "document-path") writeComment("Document: " + value);
  // Setup
  if(name == "job-description") writeComment("Setup: " + value);

  // Get section comment
  if(name == "operation-comment") sectionComment = value;

  return;
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

  if(z) {
    f = fOutput.format(properties.travelSpeedZ);
    fOutput.reset();
    writeln("G1" + z + f);
  }
  if(x || y) {
    f = fOutput.format(properties.travelSpeedXY);
    fOutput.reset();
    writeln("G1" + x + y + f);
  }
  return;
}

// Linear movements
function linearMovements(_x, _y, _z, _feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = fOutput.format(_feed);
  if(x || y || z) {
    writeln("G1" + x + y + z + f);
  }
  return;
}

// Circular movements
function circularMovements(_clockwise, _cx, _cy, _cz, _x,	_y, _z, _feed) {
  // Marlin supports arcs only on XY plane
  switch (getCircularPlane()) {
  case PLANE_XY:
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var f = fOutput.format(_feed);
    var start	=	getCurrentPosition();
    var i = iOutput.format(_cx - start.x, 0);
    var j = jOutput.format(_cy - start.y, 0);

    if(_clockwise) {
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
  if(properties.gcodeToolFile == "") {
    // Builtin tool change gcode
    writeComment("Tool Change");

    // Beep
    writeln("M400"); // Wait movement buffer it's empty
    writeln("M300 S400 P2000");

    // Go to tool change position
    if(properties.toolChangeZ != "") {
      writeln("G1 " + properties.toolChangeZ + fOutput.format(properties.travelSpeedZ));
    }
    if(properties.toolChangeXY != "") {
      writeln("G1 " + properties.toolChangeXY + fOutput.format(properties.travelSpeedXY));
    }

    // Ask tool change and wait user to touch lcd button
    writeln("M0 Put tool " + tool.number + " - " + getToolTypeName(tool.type));

    // Run Z probe gcode
    if(properties.toolChangeZProbe && tool.number != 0) {
      writeComment("Z Probe gcode goes here");
    }
    writeln("");
  } else {
    // Custom tool change gcode
    loadFile(properties.gcodeToolFile);
  }
}

// Probe tool
function probeTool() {
  if(properties.gcodeProbeFile == "") {
    writeComment("Probe tool - Not yet implemented");
    writeln("");
  } else {
    loadFile(properties.gcodeProbeFile);
  }
}

// Test if file exist/can read and load it
function loadFile(_file) {
  var folder = FileSystem.getFolderPath(getOutputPath()) + PATH_SEPARATOR;
  if(FileSystem.isFile( folder + _file)) {
    var txt = loadText( folder + _file, "utf-8");
    if ( txt.length > 0 ) {
      writeComment("Start custom gcode " + folder + _file);
      write(txt);
      writeComment("End custom gcode " + folder + _file);
      writeln("");
    }
  } else {
    writeComment("Can't open file " + folder + _file);
    error("Can't open file " + folder + _file);
  }
}
