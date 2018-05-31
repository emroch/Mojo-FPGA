module mojo_top (
    input        clk,           // 50MHz clock input
    input        rst_n,         // Input from reset button (active low)
    input        cclk,          // cclk input from AVR, high when AVR is ready
    output [7:0] led,           // Outputs to the 8 onboard LEDs
    // AVR SPI connections
    output       spi_miso,      // AVR SPI MISO
    input        spi_ss,        // AVR SPI Slave Select
    input        spi_mosi,      // AVR SPI MOSI
    input        spi_sck,       // AVR SPI Clock
    output [3:0] spi_channel,   // AVR general purpose pins (used by default to select ADC channel)
    // Serial connections
    input        avr_tx,        // AVR Tx => FPGA Rx
    output       avr_rx,        // AVR Rx => FPGA Tx
    input        avr_rx_busy,   // AVR Rx buffer full
    // IO Shield connections
    output [23:0] io_led,       // 24 LEDs (organized in 3 groups of 8)
    output [7:0]  io_seg,       // 7-segment LEDs
    output [3:0]  io_sel,       // Digit select for 7-segment displays
    input  [4:0]  io_button,    // 5 D-pad buttons
    input  [23:0] io_dip        // DIP switches (organized in 3 groups of 8)
  );

  //////////////////////////////////////////////////
  //  Local Net and Variable Declarations
  //////////////////////////////////////////////////

  wire rst_s;                 // synchronous reset
  wire [4:0] btn_s;           // debounced and synchronized button input
  wire [4:0] btn_pressed;     // single clock pulse when button is pressed
  wire [23:0] dip_s;          // debounced and synchronized switch input


  //////////////////////////////////////////////////
  // Output Port Assignments
  //////////////////////////////////////////////////

  /**
   * Configure the communication channel inputs.
   * These signals should be high-z when not used.
   */
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;

  assign led = 8'b0;                  // on-board LEDs
  assign io_led[23:8] = dip_s[23:8];  // show the DIP Switches on the IO-LEDs
  assign io_seg[7] = 1'b1;            // keep the decimal point off


  //////////////////////////////////////////////////
  // Module Instantiations
  //////////////////////////////////////////////////

  hex_driver hex (
    .clk(clk),
    .rst(1'b0),
    .values(dip_s[23:8]),   // use the left two DIP switch sections
    .seg(io_seg[6:0]),      // output to LED segments, active low
    .sel(io_sel)            // LED digit select, one-cold
  );

  led_counter led_count (
    .clk(clk),
    .rst(rst_s),
    .btn_count( {btn_pressed[0], btn_pressed[2], btn_s[1]} ),   // up, down, clear
    .btn_dim( {btn_pressed[4], btn_pressed[3], rst_s} ),        // brighter, dimmer, reset
    .leds(io_led[7:0])
  );

  debouncer btn_dbnc[4:0] (
    .clk(clk),
    .in(io_button),       // d-pad button array
    .out(btn_s),          // synchonized output
    .down(btn_pressed),   // single clock pulse when pressed
    .up()                 // -- unused
  );

  debouncer dip_dbnc[23:0] (
    .clk(clk),
    .in(io_dip),        // DIP switches
    .out(dip_s),        // synchonized output
    .down(),            // -- unused
    .up()               // -- unused
  );

  d_ff rst_sync (clk, ~rst_n, rst_s);   // rst does not need debouncing, so just use a FF

endmodule
