/*

https://github.com/guffy1234/mpcnc_posts_processor

MPCNC posts processor for milling and laser/plasma cutting.

*/
include("DIYCNC_Common.js");

description = "DIYCNC Milling/Laser - Grbl 1.1";

// user-defined properties
mergeProperties(properties, {
    cutterGrblMode: 4,                // GRBL mode laser/plasma cutter
    coolantAGrbl: 7,                        // GCode command to turn on Coolant channel A
    coolantBGrbl: 8,                        // GCode command to turn on Coolant channel A
});

mergeProperties(propertyDefinitions, {
    cutterGrblMode: {
        title: "Laser: GRBL mode", description: "GRBL mode of the laser/plasma cutter", group: 4,
        type: "integer", default_mm: 4, default_in: 4,
        values: [
            { title: "M4 S{PWM}/M5 dynamic power", id: 4 },
            { title: "M3 S{PWM}/M5 static power", id: 3 },
        ]
    },
    coolantAGrbl: {
        title: "Coolant: A code", description: "GRBL g-codes for control Coolant channel A", group: 6, type: "integer",
        default_mm: 7, default_in: 7,
        values: [
            { title: "M7 flood", id: 7 },
            { title: "M8 mist", id: 8 },
        ]
    },
    coolantBGrbl: {
        title: "Coolant: B code", description: "GRBL g-codes for control Coolant channel B", group: 6, type: "integer",
        default_mm: 8, default_in: 8,
        values: [
            { title: "M7 flood", id: 7 },
            { title: "M8 mist", id: 8 },
        ]
    },
});

function FirmwareGrbl() {
    FirmwareBase.apply(this, arguments);
}

FirmwareGrbl.prototype = Object.create(FirmwareBase.prototype);
FirmwareGrbl.prototype.constructor = FirmwareGrbl;
FirmwareGrbl.prototype.init = function () {
    gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
    writeln("%");
}
FirmwareGrbl.prototype.start = function () {
    writeBlock(gAbsIncModal.format(90)); // Set to Absolute Positioning
    writeBlock(gFeedModeModal.format(94));
    writeBlock(gPlaneModal.format(17));
    writeBlock(gUnitModal.format(unit == IN ? 20 : 21));
}
FirmwareGrbl.prototype.end = function () {
    writeBlock(mFormat.format(30));
}
FirmwareGrbl.prototype.close = function () {
    writeln("%");
}
FirmwareGrbl.prototype.comment = function (text) {
    writeln("(" + String(text).replace(/[\(\)]/g, "") + ")");
}
FirmwareGrbl.prototype.flushMotions = function () {
},
    FirmwareGrbl.prototype.spindleOn = function (_spindleSpeed, _clockwise) {
        writeActivityComment(" >>> Spindle Speed " + speedFormat.format(_spindleSpeed));
        writeBlock(mFormat.format(_clockwise ? 3 : 4), sOutput.format(spindleSpeed));
    }
FirmwareGrbl.prototype.spindleOff = function () {
    writeBlock(mFormat.format(5));
}
FirmwareGrbl.prototype.laserOn = function (power) {
    var laser_pwm = power / 100 * 255;
    writeBlock(mFormat.format(properties.cutterGrblMode), sFormat.format(laser_pwm));
}
FirmwareGrbl.prototype.laserOff = function () {
    writeBlock(mFormat.format(5));
}
FirmwareGrbl.prototype.coolantA = function (on) {
    writeBlock(mFormat.format(on ? properties.coolantAGrbl : 9));
}
FirmwareGrbl.prototype.coolantB = function (on) {
    writeBlock(mFormat.format(on ? properties.coolantBGrbl : 9));
}
FirmwareGrbl.prototype.dwell = function (seconds) {
    seconds = clamp(0.001, seconds, 99999.999);
    writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
}
FirmwareGrbl.prototype.display_text = function (txt) {
}
FirmwareGrbl.prototype.circular = function (clockwise, cx, cy, cz, x, y, z, feed) {
    if (!properties.jobUseArcs) {
        linearize(tolerance);
        return;
    }
    var start = getCurrentPosition();

    if (isFullCircle()) {
        if (isHelical()) {
            linearize(tolerance);
            return;
        }
        switch (getCircularPlane()) {
            case PLANE_XY:
                writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), fOutput.format(feed));
                break;
            case PLANE_ZX:
                writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), fOutput.format(feed));
                break;
            case PLANE_YZ:
                writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), fOutput.format(feed));
                break;
            default:
                linearize(tolerance);
        }
    } else {
        switch (getCircularPlane()) {
            case PLANE_XY:
                writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), fOutput.format(feed));
                break;
            case PLANE_ZX:
                writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), fOutput.format(feed));
                break;
            case PLANE_YZ:
                writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), fOutput.format(feed));
                break;
            default:
                linearize(tolerance);
        }
    }
}
FirmwareGrbl.prototype.toolChange = function () {
    writeBlock(mFormat.format(6), tFormat.format(tool.number));
    writeBlock(gFormat.format(54));
}
FirmwareGrbl.prototype.probeTool = function () {
}

currentFirmware = new FirmwareGrbl();