//----------------------------------------------------------------------------
//                         Module Declaration                                
//----------------------------------------------------------------------------
// This module controls an RGB LED using an internal oscillator and a frequency counter.
module top (
  // Output Ports
  output wire led_red,   // Red LED control signal
  output wire led_blue,  // Blue LED control signal
  output wire led_green, // Green LED control signal
  output wire testwire,  // Debugging/test signal output

  // Input Ports
  input wire hw_clk // External hardware oscillator (not used in this design)
);

  // Internal Signals
  wire        int_osc;             // Internal oscillator clock signal
  reg  [27:0] frequency_counter_i; // 28-bit frequency counter for clock division

  // Assign testwire to the 5th bit of the counter (acts as a frequency divider)
  assign testwire = frequency_counter_i[5];

  /* 
   * Frequency Counter Logic
   * - This always block increments `frequency_counter_i` on each rising edge of `int_osc`
   * - Effectively creates a clock divider that generates slower clock pulses
   */
  always @(posedge int_osc) begin
    frequency_counter_i <= frequency_counter_i + 1'b1;
  end

//----------------------------------------------------------------------------
//                       Internal Oscillator                                
//----------------------------------------------------------------------------
// Generates an internal clock signal using the FPGA's built-in oscillator
// - `CLKHF_DIV("0b10")` configures the oscillator to a specific frequency
// - `CLKHFPU(1'b1)` ensures the oscillator is powered up
// - `CLKHFEN(1'b1)` enables the oscillator output
  SB_HFOSC #(.CLKHF_DIV ("0b10")) u_SB_HFOSC ( 
    .CLKHFPU(1'b1), 
    .CLKHFEN(1'b1), 
    .CLKHF(int_osc) // Connect oscillator output to `int_osc`
  );

//----------------------------------------------------------------------------
//                       RGB LED Driver                                     
//----------------------------------------------------------------------------
// Controls the RGB LED using `SB_RGBA_DRV` primitive
// - RGB0PWM, RGB1PWM, RGB2PWM determine the LED color (PWM signals)
// - CURREN enables current for the LED driver
// - RGBLEDEN enables LED output
// - LED color setup: Red (0), Green (0), Blue (1) -> Only Blue LED is ON
  SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1),  // Enable RGB LED
    .RGB0PWM (1'b0),  // Red LED PWM (OFF)
    .RGB1PWM (1'b0),  // Green LED PWM (OFF)
    .RGB2PWM (1'b1),  // Blue LED PWM (ON)
    .CURREN  (1'b1),  // Enable current flow
    .RGB0    (led_red),   // Connect to actual hardware pin for Red LED
    .RGB1    (led_green), // Connect to actual hardware pin for Green LED
    .RGB2    (led_blue)   // Connect to actual hardware pin for Blue LED
  );

//----------------------------------------------------------------------------
//                       LED Current Configuration                           
//----------------------------------------------------------------------------
// Set the drive strength for each LED (lower value -> lower brightness)
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001"; // Red current level
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001"; // Green current level
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001"; // Blue current level

endmodule
