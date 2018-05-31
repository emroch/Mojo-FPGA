module counter_up_down #(
    parameter SIZE = 8,       // width of counter, in bits
    parameter DIV = 16,       // divisor, number of bits to count before incrementing
    parameter TOP = 0,        // maximum value
    parameter UP = 1          // up or down
  )(
    input               clk,  // clock input
    input               rst,  // reset to 0
    output [SIZE-1 : 0] value // output value
  );

  localparam WIDTH = SIZE + DIV;
  localparam MAX_VALUE = { TOP, {DIV{1'b1}} };

  reg [WIDTH-1 : 0] ctr;

  assign value = ctr[WIDTH-1 -: SIZE];

  always @(posedge clk) begin
    if (rst) begin
      ctr <= {WIDTH{1'b0}};
    end else begin
      if (UP) begin
        ctr <= ctr + 1'b1;
        if (TOP != 0 && ctr == MAX_VALUE) begin
          ctr <= 0;
        end
      end else begin
        ctr <= ctr - 1'b1;
        if (TOP != 0 && ctr == 0) begin
          ctr <= MAX_VALUE;
        end
      end
    end
  end

endmodule // counter_up_down
