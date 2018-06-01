module graphics_generator (
    input clk,
    input rst,
    input flipped,          // trigger signal from display controller that buffers have flipped
    output [3:0] x,         // x coordinate to write to VRAM
    output [2:0] y,         // y coordinate to write to VRAM
    output [7:0] red,       // red color data to write to VRAM
    output [7:0] green,     // green color data    "     "
    output [7:0] blue,      // blue color data     "     "
    output valid,           // indicates valid data
    output flip             // goes high when frame is done being written
  );

  localparam  STATE_SIZE = $clog2(2);
  localparam  CREATE_FRAME = 1'b0;
  localparam  WAIT_FLIP = 1'b1;

  reg [STATE_SIZE-1:0] state_d, state_q;

  reg [3:0] x_d, x_q;
  reg [2:0] y_d, y_q;
  reg [7:0] red_d, red_q;
  reg [7:0] green_d, green_q;
  reg [7:0] blue_d, blue_q;
  reg valid_d, valid_q;
  reg flip_d, flip_q;

  assign x = x_q;
  assign y = y_q;
  assign red = red_q;
  assign green = green_q;
  assign blue = blue_q;
  assign valid = valid_q;
  assign flip = flip_q;

  always @(*) begin
    state_d = state_q;
    red_d = 8'h00;
    green_d = 8'h00;
    blue_d = 8'h00;
    valid_d = 1'b0;
    flip_d = 1'b0;
    x_d = x_q;
    y_d = y_q;

    case (state_q)
      CREATE_FRAME: begin
        // step through x values
        x_d = x_q + 1'b1;
        if (x_q == 4'b1111) begin
          // increase y when x is maxed out
          y_d = y_q + 1'b1;
          if (y_q == 3'b111) begin
            // when both x and y are maxed out, flip the buffer
            valid_d = 1'b0;
            flip_d = 1'b1;
            state_d = WAIT_FLIP;
          end
        end
      end
      WAIT_FLIP: begin
        if (flipped) begin
          state_d = CREATE_FRAME;
        end
      end
    endcase

  end

endmodule // graphics_generator
