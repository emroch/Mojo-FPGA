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

  /**
   * Local wire and reg declarations
   */
  wire rst_s;         // synchronous reset
  wire [23:0] dip_s;  // synchronous switch input
  // wire rst = ~rst_n; // make reset active high

  /**
   * Configure the communication channel inputs.
   * These signals should be high-z when not used.
   */
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;

  /**
   * On-board LEDs
   */
  assign led = 8'b0;

  // show the DIP Switches on the LEDs
  assign io_led = dip_s;

  // assign io_seg = 8'hff;
  // assign io_sel = 4'hf;
  assign io_seg[7] = 1'b1;  // keep the decimal point off

  hex_driver hex (
    .clk(clk),
    .rst(rst_s),
    .values(dip_s[15:0]),
    .seg(io_seg[6:0]),
    .sel(io_sel)
  );

  /**
   * Apply synchronization to inputs
   */
  d_ff rst_sync (clk, ~rst_n, rst_s);
  d_ff dip_sync[23:0] (clk, io_dip, dip_s);


endmodule
