# Mojo-FPGA
Sketchbook repository for various projects for the Mojo FPGA.

## Projects
#### Base Project
`mojo-base` - This is the base project for the Mojo FPGA.  It contains pin assignments and an interface module for the onboard Atmel microcontroller.  All new projects should be copied from this one.  (From [Embedded Micro](https://embeddedmicro.com) ([github](https://github.com/embmicro/mojo-base-project)))

#### IO Shield
`mojo-io-shield` - This is a demonstration of the capabilities of the IO Shield. Includes several reusable IO Shield components, such as a driver for the multiplexed 7-segment displays, a variable length PWM for the LEDs, and an adjustable dimmer for the LEDs.  This design displays the value on the upper 16 DIP switches on the corresponding LEDs and as hexadecimal on the 7-segment displays.  It also uses the 5 buttons and the on-board reset button to control a counter on the lower 8 LEDs that can be incremented, decremented, reset to 0, and dimmed.

## License
This repository as a whole is licensed under the [MIT License](https://opensource.org/licenses/mit-license.php), but may also include software components from other projects with their own licenses.  Individual components are licensed by the LICENSE file in deepest containing folder.
