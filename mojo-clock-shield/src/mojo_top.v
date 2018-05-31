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
  );

wire rst = ~rst_n; // make reset active high

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

assign led = 8'b0;

endmodule
