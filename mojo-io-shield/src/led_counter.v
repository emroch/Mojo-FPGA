module led_counter (
    input        clk,
    input        rst,
    input  [2:0] btn_count, // 3 buttons for the counter (up, down, and clear)
    input  [2:0] btn_dim,   // 3 buttons for the dimmer (brighter, dimmer, and reset)
    output [7:0] leds       // output LED vector
  );

  wire [7:0] count_value;        // 8-bit value to be displayed on LEDs

  up_down_counter count (
    .clk(clk),
    .enable(|btn_count[2:1]),   // enable counting when either + or - (buttons 2 or 1) are pressed
    .up_down(btn_count[2]),     // count up if button 2 is pressed, otherwise count down
    .load(btn_count[0]),        // load the reset value when button 0 is pressed
    .data(8'h00),               // reset to 0
    .out(count_value)
  );

  led_dimmer dimmer (
    .clk(clk),
    .rst(btn_dim[0]),           // reset when button 0 is pressed
    .up(btn_dim[2]),            // increase brightness on button 2
    .down(btn_dim[1]),          // decrease brightness on button 1
    .value(count_value),        // the value to display on the dimmed LEDs
    .out(leds)                  // dimmed output
  );

endmodule // led_counter
