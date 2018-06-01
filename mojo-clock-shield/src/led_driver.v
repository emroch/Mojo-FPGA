module led_driver (
    input          clk,
    input          rst,
    output [2:0]   row,       // current row to output
    input  [383:0] values,    // color date for the entire row (16 LEDs * 3 colors/LED * 8 bits/color = 384 bits)
    output         vsync,     // single clock pulse at the end of the drawing period
    output [7:0]   d1_c,      // display output signals (active low)
    output [7:0]   d1_r,      //    :
    output [7:0]   d1_g,      //    :
    output [7:0]   d1_b,      //    :
    output [7:0]   d2_c,      //    :
    output [7:0]   d2_r,      //    :
    output [7:0]   d2_g,      //    :
    output [7:0]   d2_b       //    :
  );

  localparam  CTR_LEN = 18;   // 3 bits for row, 7 bits for delay, 8 bits for PWM

  wire [7:0] red   [15:0];    // 8-bit red values for each of 16 LEDs in the row
  wire [7:0] green [15:0];    // 8-bit green values
  wire [7:0] blue  [15:0];    // 8-bit blue values

  reg [15:0] led_r_d, led_r_q;
  reg [15:0] led_g_d, led_g_q;
  reg [15:0] led_b_d, led_b_q;
  reg [7:0] led_row_d, led_row_q;

  reg [CTR_LEN-1:0] ctr_d, ctr_q;

  // outputs are active low, so invert signals
  assign d1_c = ~led_row_q;
  assign d1_r = ~led_r_q[7 -: 8];
  assign d1_g = ~led_g_q[7 -: 8];
  assign d1_b = ~led_b_q[7 -: 8];
  assign d2_c = ~led_row_q;
  assign d2_r = ~led_r_q[15 -: 8];
  assign d2_g = ~led_g_q[15 -: 8];
  assign d2_b = ~led_b_q[15 -: 8];

  assign vsync = &ctr_q;

  assign row = ctr_d[CTR_LEN-1 -: 3];   // use the upcoming row value to pre-fetch values

  genvar col;
  generate
    for (col = 0; col < 16; col = col + 1) begin : color_sep
      assign red[col]   = values[23 + col*24 -: 8];
      assign green[col] = values[15 + col*24 -: 8];
      assign blue[col]  = values[ 7 + col*24 -: 8];
    end
  endgenerate


  always @(*) begin
    ctr_d = ctr_q + 1'b1;                         // advance the counter

    led_row_d = 1'b1 << ~ctr_q[CTR_LEN-1 -: 3];   // set active row based on MSB of counter

    // for each of the 16 LEDs, compare the value to
    // the 8 lowest bits of the counter to generate
    // a PWM signal
    integer i;
    for (i = 0; i < 16; i = i + 1) begin
      led_r_d = (red[i]   > ctr_q[7:0]) ? 1'b1 : 1'b0;
      led_g_d = (green[i] > ctr_q[7:0]) ? 1'b1 : 1'b0;
      led_b_d = (blue[i]  > ctr_q[7:0]) ? 1'b1 : 1'b0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 1'b0;
      led_r_q <= 16'b0;
      led_g_q <= 16'b0;
      led_b_q <= 16'b0;
      led_row_q <= 8'b0;
    end else begin
      ctr_q <= ctr_d;
      led_r_q <= led_r_d;
      led_g_q <= led_g_d;
      led_b_q <= led_b_d;
      led_row_q <= led_r_d;
    end
  end

endmodule // led_driver
