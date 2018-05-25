module debouncer #(
    parameter LENGTH = 16
  )(
    input      clk,
    input      in,
    output reg out,   // synchronized button output
    output     down,  // single clock pulse when button is pressed
    output     up     // single clock pulse when button is released
  );

  wire btn_sync;              // synchronized button input
  reg [LENGTH-1 : 0] count;   // counter to delay through potential glitches

  wire idle = (out == btn_sync);  // if synchronized input is the same as
                                  // the output, don't do anything

  wire max_count = &count;        // triggered when all bits of count are 1

  // assign the edge detection outputs
  assign down = ~idle & max_count &  out;
  assign up   = ~idle & max_count & ~out;

  d_ff sync (clk, in, btn_sync);

  always @(posedge clk) begin
    if (idle) begin
      count <= 0;                 // output matches input, reset the counter
    end else begin
      count <= count + 1'b1;         // input changed, increment the counter
      if (max_count)              // if the counter maxed out,
        out <= ~out;  // consider the button changed
    end
  end

endmodule // debouncer
