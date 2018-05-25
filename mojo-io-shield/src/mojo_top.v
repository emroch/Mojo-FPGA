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
  // wire [4:0] btn_s;   // synchronous button input

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
  assign io_led[23:8] = dip_s[23:8];

  // assign io_seg = 8'hff;
  // assign io_sel = 4'hf;
  assign io_seg[7] = 1'b1;  // keep the decimal point off

  hex_driver hex (
    .clk(clk),
    .rst(1'b0),
    .values(dip_s[23:8]), // use the left two DIP switch sections
    .seg(io_seg[6:0]),
    .sel(io_sel)
  );

  // generate a pulse when a button is pressed
  wire [4:0] btn_s;
  wire [4:0] btn_pressed;
  debouncer btn_dbnc[4:0] (
    .clk(clk), .in(io_button), .out(btn_s), .down(btn_pressed), .up()
  );

  reg [7:0] led_value;  // 8-bit value to be displayed on LEDs
  reg [3:0] pwm_value;  // 4-bit brightness level of LEDs (0-16)
  wire pwm_output;      // whether the LEDs should be on or off
  pwm #(.LENGTH(4)) led_pwm (clk, rst_s, pwm_value, pwm_output);
  // AND the value with the PWM control vector to dim LEDs that are
  // lit, but not affect the ones that are off
  assign io_led[7:0] = led_value & {8{pwm_output}};

  initial begin
    led_value = 8'h00;
    pwm_value = 4'hf;
  end

  always @(posedge clk) begin
    if (rst_s) begin
      pwm_value <= 4'hf;
    end

    if (btn_s[1]) begin     // use the center button as a clear
      led_value <= 8'h00;
    end

    // adjust the display value
    if (btn_pressed[0]) begin           // use up button to increment
      led_value <= led_value + 8'h01;
    end else if (btn_pressed[2]) begin  // use down button to decrement
      led_value <= led_value - 8'h01;
    end

    // adjust the display brightness
    if (btn_pressed[3]) begin           // use left button to decrease brightness
      if (pwm_value > 1)                // iff pwm level is at least 1
        pwm_value <= pwm_value - 4'h1;
    end else if (btn_pressed[4]) begin  // use right button to increase brightness
      if (~&pwm_value)                  // iff at least one bit is 0 (i.e. not 255)
        pwm_value <= pwm_value + 4'h1;
    end
  end

  /**
   * Apply synchronization to inputs
   */
  debouncer rst_dbnc (
    .clk(clk), .in(~rst_n), .out(rst_s), .down(), .up()
  );
  debouncer dip_dbnc[23:0] (
    .clk(clk), .in(io_dip), .out(dip_s), .down(), .up()
  );
  // d_ff rst_sync (clk, ~rst_n, rst_s);
  // d_ff dip_sync[23:0] (clk, io_dip, dip_s);
  // d_ff btn_sync[4:0] (clk, io_button, btn_s);

endmodule
