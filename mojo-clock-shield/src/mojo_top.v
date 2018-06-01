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
    input        avr_rx_busy    // AVR Rx buffer full
    // Clock Shield connections
    output       speaker,       // Buzzer output
    input        mic_data,      // Microphone data
    output       mic_clk,       // Microphone clock

    output       rtc_sclk,      // RTC clock
    output       rtc_cs,        // RTC chip select
    output       rtc_mosi,      // RTC MOSI
    input        rtc_miso,      // RTC MISO
    input        rtc_32khz,     // RTC 32 kHz output
    input        rtc_int,       // RTC interrupt

    input        up_button,     // Input from Up button (active high)
    input        down_button,   // Input from Down button (active high)
    input        select_button, // Input from Select button (active high)

    output [7:0] d1_c,          // Display 1 common anodes (active low)
    output [7:0] d1_r,          // Display 1 red cathodes (active low)
    output [7:0] d1_g,          // Display 1 green cathodes (active low)
    output [7:0] d1_b,          // Display 1 blue cathodes (active low)
    output [7:0] d2_c,          // Display 2 common anodes (active low)
    output [7:0] d2_r,          // Display 2 red cathodes (active low)
    output [7:0] d2_g,          // Display 2 green cathodes (active low)
    output [7:0] d2_b           // Display 2 blue cathodes (active low)
  );

  //////////////////////////////////////////////////
  //  Local Net and Variable Declarations
  //////////////////////////////////////////////////

  wire rst_s;             // synchronous reset
  wire [2:0] btn_up;      // debounced and synchronized button inputs
  wire [2:0] btn_down;    //   3 bits represent synchronous output <2>,
  wire [2:0] btn_sel;     //   pressed pulse <1>, and released pulse <0>

  wire x_coord, y_coord;
  wire flip;
  wire flipped;
  wire valid;
  wire [7:0] red, green, blue;

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
  assign speaker = 1'b0;              // don't use the speaker


  //////////////////////////////////////////////////
  // Module Instantiations
  //////////////////////////////////////////////////

  dipslay_controller display (
    .clk(clk),
    .rst(rst),
    .x(x_coord),
    .y(y_coord),
    .valid(valid),
    .red(red),
    .green(green),
    .blue(blue),
    .flip(flip),
    .flipped(flipped),
    .d1_c(d1_c),
    .d1_r(d1_r),
    .d1_g(d1_g),
    .d1_b(d1_b),
    .d2_c(d2_c),
    .d2_r(d2_r),
    .d2_g(d2_g),
    .d2_b(d2_b)
  );

  graphics_generator graphics (
    clk(clk),
    rst(rst),
    flipped(flipped),
    x(x_coord),
    y(y_coord),
    red(red),
    green(green),
    blue(blue),
    valid(valid),
    flip(flip)
  );

  debouncer up_dbnc (
    .clk(clk),
    .in(up_button),
    .out(btn_up[2]),
    .down(btn_up[1]),
    .up(btn_up[0])
  );

  debouncer down_dbnc (
    .clk(clk),
    .in(up_button),
    .out(btn_down[2]),
    .down(btn_down[1]),
    .up(btn_down[0])
  );

  debouncer sel_dbnc (
    .clk(clk),
    .in(up_button),
    .out(btn_sel[2]),
    .down(btn_sel[1]),
    .up(btn_sel[0])
  );

  d_ff rst_sync (clk, ~rst_n, rst_s);   // rst is synchronized, but not debounced

endmodule
