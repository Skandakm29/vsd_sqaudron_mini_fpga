`include "ultra_sonic_sensor.v"
`timescale 1ns/1ps

module tb_hc_sr04;
  reg clk = 0;
  reg rst = 1;
  wire measure;
  reg echo = 0;  // We'll manually toggle this to simulate sensor pulses
  wire trig;
  wire [1:0] state;
  wire [23:0] distanceRAW;
  wire [15:0] distance_cm;
  wire ready;

  // Generate a 12 MHz clock
  // 12 MHz => period ~83.333 ns, so half‐period ~41.666 ns
  always #41.666 clk = ~clk;

  // Instantiate the refresh module
  refresher250ms refresher (
    .clk(clk),
    .en(1'b1),
    .measure(measure)
  );

  // Instantiate hc_sr04
  hc_sr04 #(.ten_us(120)) dut (
    .clk(clk),
    .rst(rst),
    .measure(measure),
    .state(state),
    .ready(ready),
    .echo(echo),
    .trig(trig),
    .distanceRAW(distanceRAW),
    .distance_cm(distance_cm)
  );

  initial begin
    // Release reset after a short delay
    #200 rst = 0;

    // Monitor key signals
    $monitor(
      "time=%0t state=%b measure=%b echo=%b trig=%b RAW=%d cm=%d ready=%b",
      $time, state, measure, echo, trig, distanceRAW, distance_cm, ready
    );

    // Run for a while
    #10_000_000; // 10 us * 1,000? or 10 ms? depends on timescale, your choice
    $finish;
  end

  // Simulate echo response
  initial begin
    // Wait a bit after reset
    #2000;
    forever begin
      // Wait until 'trig' rises
      @(posedge trig);
      // Then wait 1 µs
      #1000 echo = 1'b1;
      // Keep echo high for 5 µs
      #5000 echo = 1'b0;
    end
  end
  initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0, tb_hc_sr04);
end

endmodule

