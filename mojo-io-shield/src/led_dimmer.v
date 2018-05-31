module led_dimmer #(
    parameter OUT_LEN = 8,
    parameter PWM_LEN = 4
  )(
    input clk,
    input rst,
    input up,
    input down,
    input [OUT_LEN-1:0] value,
    output [OUT_LEN-1:0] out
  );

  wire pwm_active;
  reg [PWM_LEN-1:0] level_d, level_q;

  assign out = value & {OUT_LEN{pwm_active}};

  pwm #(PWM_LEN) pwm_ctrl (clk, rst, level_q, pwm_active);

  always @(*) begin
    level_d = level_q;              // default to prevent latches

    if (up) begin
      if (~&level_q)                // increase the level if it is not
        level_d = level_q + 1'b1;   // already maxed out (i.e. all ones)
    end else if (down) begin
      if (level_q > 1)              // decrease the level, only if
        level_d = level_q - 1'b1;   // the LEDs will stay on
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      level_q <= {PWM_LEN{1'b1}};
    end else begin
      level_q <= level_d;
    end
  end

endmodule // led_dimmer
