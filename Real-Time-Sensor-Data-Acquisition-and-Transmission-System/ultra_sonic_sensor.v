//===================================================================
// 1) HC-SR04 Ultrasonic Sensor Module (No external 'rst' input)
//===================================================================
module hc_sr04 #(
  parameter ten_us = 10'd120  // ~120 cycles for ~10µs at 12MHz
)(
  input             clk,         // ~12 MHz clock
  input             measure,     // start a measurement when in IDLE
  output reg [1:0]  state,       // optional debug: current state
  output            ready,       // high in IDLE (between measurements)
  input             echo,        // ECHO pin from HC-SR04
  output            trig,        // TRIG pin to HC-SR04
  output reg [23:0] distanceRAW, // raw cycle count while echo=1
  output reg [15:0] distance_cm  // computed distance in cm
);

  // -----------------------------------------
  // State definitions
  // -----------------------------------------
  localparam IDLE      = 2'b00,
             TRIGGER   = 2'b01,
             WAIT      = 2'b11,
             COUNTECHO = 2'b10;

  // 'ready' is high in IDLE
  assign ready = (state == IDLE);

  // 10-bit counter for ~10µs TRIGGER
  reg [9:0] counter;
  wire trigcountDONE = (counter == ten_us);

  // Initialize registers (for simulation & synthesis without reset)
  initial begin
    state       = IDLE;
    distanceRAW = 24'd0;
    distance_cm = 16'd0;
    counter     = 10'd0;
  end

  // -----------------------------------------
  // 1) State Machine
  // -----------------------------------------
  always @(posedge clk) begin
    case (state)
      IDLE: begin
        // Wait for measure pulse
        if (measure && ready)
          state <= TRIGGER;
      end

      TRIGGER: begin
        // ~10µs pulse, then WAIT
        if (trigcountDONE)
          state <= WAIT;
      end

      WAIT: begin
        // Wait for echo rising edge
        if (echo)
          state <= COUNTECHO;
      end

      COUNTECHO: begin
        // Once echo goes low => measurement done
        if (!echo)
          state <= IDLE;
      end

      default: state <= IDLE;
    endcase
  end

  // -----------------------------------------
  // 2) TRIG output is high in TRIGGER
  // -----------------------------------------
  assign trig = (state == TRIGGER);

  // -----------------------------------------
  // 3) Generate ~10µs trigger pulse
  // -----------------------------------------
  always @(posedge clk) begin
    if (state == IDLE) begin
      counter <= 10'd0;
    end
    else if (state == TRIGGER) begin
      counter <= counter + 1'b1;
    end
    // No else needed; once we exit TRIGGER, we stop incrementing.
  end

  // -----------------------------------------
  // 4) distanceRAW increments while ECHO=1
  // -----------------------------------------
  always @(posedge clk) begin
    if (state == WAIT) begin
      // Reset before new measurement
      distanceRAW <= 24'd0;
    end
    else if (state == COUNTECHO) begin
      // Add 1 each clock cycle while echo=1
      distanceRAW <= distanceRAW + 1'b1;
    end
  end

  // -----------------------------------------
  // 5) Convert distanceRAW to centimeters
  // -----------------------------------------
  // distance_cm = (distanceRAW * 34300) / (2 * 12000000)
  always @(posedge clk) begin
    distance_cm <= (distanceRAW * 34300) / (2 * 12000000);
  end

endmodule

//===================================================================
// 2) Refresher for ~50ms or ~250ms pulses
//===================================================================
module refresher250ms(
  input  clk,  // 12MHz
  input  en,
  output measure
);
  // For ~50ms at 12MHz: 12,000,000 * 0.05 = 600,000
  // For ~250ms at 12MHz: 12,000,000 * 0.25 = 3,000,000
  reg [18:0] counter;

  // measure = 1 if counter == 1 => single‐cycle pulse
  assign measure = (counter == 22'd1);

  initial begin
    counter = 22'd0;
  end

  always @(posedge clk) begin
    if (~en || (counter == 22'd600000))  
      // change to 3_000_000 if you want 250ms
      counter <= 22'd0;
    else
      counter <= counter + 1;
  end
endmodule

