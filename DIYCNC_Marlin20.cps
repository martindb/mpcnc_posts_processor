/*

https://github.com/guffy1234/mpcnc_posts_processor

MPCNC posts processor for milling and laser/plasma cutting.

*/
include("DIYCNC_Common.js");

description = "DIYCNC Milling/Laser - Marlin 2.0";

mergeProperties(properties, properties3dPrinter);
mergeProperties(propertyDefinitions, propertyDefinitions3dPrinter);

function FirmwareMarlin20() {
    Firmware3dPrinterLike.apply(this, arguments);
}
FirmwareMarlin20.prototype = Object.create(Firmware3dPrinterLike.prototype);
FirmwareMarlin20.prototype.constructor = FirmwareMarlin20;

currentFirmware = new FirmwareMarlin20();
