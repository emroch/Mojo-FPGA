module display_controller (
    input        clk,
    input        rst,
    input  [3:0] x,         // x coordinate to draw
    input  [2:0] y,         // y coordinate to draw
    input        valid,     // color data is ready to be written to frame buffer
    input  [7:0] red,       // 8-bit red input value
    input  [7:0] green,     // 8-bit green input value
    input  [7:0] blue,      // 8-bit blue input value
    input        flip,      // flip VRAM frame buffers
    output       flipped,   // indicates which frame buffer is active
    output [7:0] d1_c,      // display output signals (active low)
    output [7:0] d1_r,      //    :
    output [7:0] d1_g,      //    :
    output [7:0] d1_b,      //    :
    output [7:0] d2_c,      //    :
    output [7:0] d2_r,      //    :
    output [7:0] d2_g,      //    :
    output [7:0] d2_b       //    :
  );

  localparam  STATE_SIZE = $clog2(2);   // number of bits required for the states
  localparam  LOAD_FRAME = 1'b0;
  localparam  WAIT_VSYNC = 1'b1;

  reg [STATE_SIZE-1:0] state_d, state_q;

  reg page_d, page_q;           // indicate active VRAM buffer frame
  reg wea_d, wea_q;             // VRAM write enable
  reg [6:0] addra_d, addra_q;   // 7-bit LED address (0-127)
  reg [23:0] dina_d, dina_q;    // 24-bit color data
  wire [2:0] addrb;             // 3-bit row address (0-7)
  wire [383:0] doutb;           // 384-bit row data
  wire vsync;

  reg flipped_d, flipped_q;
  assign flipped = flipped_q;

  led_driver led_driver (
    .clk(clk),
    .rst(rst),
    .row(row_addr),       // output - next address for VRAM lookup
    .values(row_data),    // input - data input from VRAM
    .vsync(vsync),        // output - signal to switch VRAM buffers
    .d1_c(d1_c),          // output - active low display signals
    .d1_r(d1_r),          //   :
    .d1_g(d1_g),          //   :
    .d1_b(d1_b),          //   :
    .d2_c(d2_c),          //   :
    .d2_r(d2_r),          //   :
    .d2_g(d2_g),          //   :
    .d2_b(d2_b)           //   :
  );

  vram vram (
    .clka(clk),                 // input clka
    .wea(wea_q),                // input [0 : 0] wea
    .addra({page_q, addra_q}),  // input [7 : 0] addra
    .dina(dina_q),              // input [23 : 0] dina
    .clkb(clk),                 // input clkb
    .addrb({~page_q, addrb}),   // input [3 : 0] addrb
    .doutb(doutb)               // output [383 : 0] doutb
  );

  always @(*) begin
    // defaults to prevent latches
    state_d = state_q;
    page_d = page_q;
    wea_d = 1'b0;
    addra_d = addra_q;
    dina_d = dina_q;
    flipped_d = flipped_q;

    case (state_q)
      LOAD_FRAME: begin
        if (valid) begin
          wea_d = 1'b1;
          addra_d = {y, x};
          dina_d = {red, green, blue};
        end
        if (flip) begin
          state_d = WAIT_VSYNC;   // wait for vsync to flip the buffers
        end
      end
      WAIT_VSYNC: begin
        if (vsync) begin
          state_d = LOAD_FRAME;
          page_d = ~page_q;
          flipped_d = 1'b1;
        end
      end
      default:
        state_d = LOAD_FRAME;
    endcase
  end

  always @(posedge clk) begin
    if (rst) begin
      state_q <= LOAD_FRAME;
      page_q <= 1'b0;
    end else begin
      state_q <= state_d;
      page_q <= page_d;
    end

    wea_q <= wea_d;
    addra_q <= addra_d;
    dina_q <= dina_d;
    flipped_q <= flipped_d;
  end

endmodule // display_controller
