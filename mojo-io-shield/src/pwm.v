module pwm #(
    parameter LENGTH = 8
  )(
    input clk,
    input rst,
    input [LENGTH-1 : 0] duty,
    output pwm
  );

  reg pwm_d, pwm_q;
  reg [LENGTH-1 : 0] ctr_d, ctr_q;

  assign pwm = pwm_q;

  always @(*) begin
    ctr_d = ctr_q + 1'b1;

    // special case for zero duty cycle
    if (duty == 0) begin
      pwm_d = 1'b0;
    end
    // otherwise, turn the output on while the counter
    // is less than or equal to the duty cycle and turn
    // it off when it exceeds the duty cycle
    else if (duty >= ctr_q) begin
      pwm_d = 1'b1;
    end else begin
      pwm_d = 1'b0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
    end

    pwm_q <= pwm_d;
  end

endmodule // pwm
