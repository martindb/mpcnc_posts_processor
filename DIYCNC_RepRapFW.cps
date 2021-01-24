/*

https://github.com/guffy1234/mpcnc_posts_processor

MPCNC posts processor for milling and laser/plasma cutting.

*/
include("DIYCNC_Common.js");

description = "DIYCNC Milling/Laser - RepRapFirmware";

// user-defined properties
mergeProperties(properties, properties3dPrinter);
mergeProperties(propertyDefinitions, propertyDefinitions3dPrinter);

mergeProperties(properties, {
    jobDuetMillingMode: "M453 P2 I0 R30000 F200",  // GCode command to setup Duet3d milling mode
    jobDuetLaserMode: "M452 P2 I0 R255 F200",  // GCode command to setup Duet3d laser mode
});
mergeProperties(propertyDefinitions, {
    jobDuetMillingMode: {
        title: "Job: Duet Milling mode", description: "GCode command to setup Duet3d milling mode", group: 1, type: "string",
        default_mm: "M453 P2 I0 R30000 F200", default_in: "M453 P2 I0 R30000 F200"
    },
    jobDuetLaserMode: {
        title: "Job: Duet Laser mode", description: "GCode command to setup Duet3d laser mode", group: 1, type: "string",
        default_mm: "M452 P2 I0 R255 F200", default_in: "M452 P2 I0 R255 F200"
    },
});


function FirmwareRepRap() {
    Firmware3dPrinterLike.apply(this, arguments);
}
FirmwareRepRap.prototype = Object.create(Firmware3dPrinterLike.prototype);
FirmwareRepRap.prototype.constructor = FirmwareRepRap;
FirmwareRepRap.prototype.askUser = function (text, title, allowJog) {
    var v1 = " P\"" + text + "\" R\"" + title + "\" S3";
    var v2 = allowJog ? " X1 Y1 Z1" : "";
    writeBlock(mFormat.format(291), (properties.jobSeparateWordsWithSpace ? "" : " ") + v1 + v2);
}
FirmwareRepRap.prototype.section = function () {
    if (this.machineMode != currentSection.type) {
        switch (currentSection.type) {
            case TYPE_MILLING:
                writeBlock(properties.jobDuetMillingMode);
                break;
            case TYPE_JET:
                writeBlock(properties.jobDuetLaserMode);
                break;
        }
    }
    this.machineMode = currentSection.type;
}
FirmwareRepRap.prototype.laserOn = function (power) {
    switch (properties.cutterMarlinMode) {
        case 3:
            var laser_pwm = power / 100 * 255;
            writeBlock(mFormat.format(3), sFormat.format(laser_pwm));
            return;
    }
    Firmware3dPrinterLike.prototype.laserOn.apply(this, arguments);
}

currentFirmware = new FirmwareRepRap();