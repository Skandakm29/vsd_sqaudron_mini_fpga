`include "uart_trx.v"
`include "ultra_sonic_sensor.v"

//----------------------------------------------------------------------------
//                         Module Declaration
//----------------------------------------------------------------------------
module top (
  // outputs
  output wire led_red,    // Red
  output wire led_blue,   // Blue
  output wire led_green,  // Green
  output wire uarttx,     // UART Transmission pin
  input  wire uartrx,     // UART Reception pin
  input  wire hw_clk,
  input  wire echo,       // External echo signal from sensor
  output wire trig        // Trigger output for sensor
);

  //----------------------------------------------------------------------------
  // 1) Internal Oscillator ~12 MHz
  //----------------------------------------------------------------------------
  wire int_osc;
  SB_HFOSC #(.CLKHF_DIV("0b10")) u_SB_HFOSC (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(int_osc)
  );

  //----------------------------------------------------------------------------
  // 2) Generate 9600 baud clock (from ~12 MHz)
  //----------------------------------------------------------------------------
  reg  clk_9600 = 0;
  reg  [31:0] cntr_9600 = 32'b0;
  parameter period_9600 = 625; // half‐period for 12 MHz -> 9600 baud

  always @(posedge int_osc) begin
    cntr_9600 <= cntr_9600 + 1'b1;
    if (cntr_9600 == period_9600) begin
      clk_9600  <= ~clk_9600;
      cntr_9600 <= 32'b0;
    end
  end

  //----------------------------------------------------------------------------
  // 3) RGB LED driver (just tying them to uartrx for demonstration)
  //----------------------------------------------------------------------------
  SB_RGBA_DRV #(
    .RGB0_CURRENT("0b000001"),
    .RGB1_CURRENT("0b000001"),
    .RGB2_CURRENT("0b000001")
  ) RGB_DRIVER (
    .RGBLEDEN(1'b1),
    .RGB0PWM(uartrx),
    .RGB1PWM(uartrx),
    .RGB2PWM(uartrx),
    .CURREN(1'b1),
    .RGB0(led_green),
    .RGB1(led_blue),
    .RGB2(led_red)
  );

  //----------------------------------------------------------------------------
  // 4) Ultrasonic Sensor signals
  //    We'll assume ultra_sonic_sensor.v (hc_sr04) has output distance_cm [15:0]
  //----------------------------------------------------------------------------
  wire [23:0] distanceRAW;       // If the sensor module also provides raw
  wire [15:0] distance_cm;       // MUST exist in hc_sr04, or define it
  wire        sensor_ready;
  wire        measure;

  hc_sr04 u_sensor (
    .clk        (int_osc),
    .trig       (trig),
    .echo       (echo),
    .ready      (sensor_ready),
    .distanceRAW(distanceRAW),
    .distance_cm(distance_cm),  // must exist in your sensor module
    .measure    (measure)
  );

  //----------------------------------------------------------------------------
  // 5) Trigger the sensor every ~250 ms or 50 ms
  //----------------------------------------------------------------------------
  refresher250ms trigger_timer (
    .clk (int_osc),
    .en  (1'b1),  // always enabled
    .measure (measure)
  );

  //----------------------------------------------------------------------------
  // 6) Finite‐State Machine to Print distance_cm as ASCII
  //----------------------------------------------------------------------------
  reg [3:0] state;
  localparam IDLE    = 4'd0,
             DIGIT_4 = 4'd1,
             DIGIT_3 = 4'd2,
             DIGIT_2 = 4'd3,
             DIGIT_1 = 4'd4,
             DIGIT_0 = 4'd5,
             SEND_CR = 4'd6,
             SEND_LF = 4'd7,
             DONE    = 4'd8;

  reg [31:0] distance_reg; // latch distance_cm for division
  reg [7:0]  tx_data;
  reg        send_data;

  // We run this state machine at clk_9600 so we only load
  // one character per 1-bit time. (Simplistic approach.)
  always @(posedge clk_9600) begin
    // By default, don't load a new character
    send_data <= 1'b0;

    case (state)
      //-------------------------------------------------
      // IDLE: wait for sensor_ready
      //-------------------------------------------------
      IDLE: begin
        if (sensor_ready) begin
          distance_reg <= distance_cm; // store the 16-bit measurement
          state <= DIGIT_4;           // go print all digits
        end
      end

      //-------------------------------------------------
      // Print the top decimal digit (5 digits total => "00057")
      //-------------------------------------------------
      DIGIT_4: begin
        tx_data  <= ((distance_reg / 10000) % 10) + 8'h30;
        send_data <= 1'b1;
        state    <= DIGIT_3;
      end
      DIGIT_3: begin
        tx_data  <= ((distance_reg / 1000) % 10) + 8'h30;
        send_data <= 1'b1;
        state    <= DIGIT_2;
      end
      DIGIT_2: begin
        tx_data  <= ((distance_reg / 100) % 10) + 8'h30;
        send_data <= 1'b1;
        state    <= DIGIT_1;
      end
      DIGIT_1: begin
        tx_data  <= ((distance_reg / 10) % 10) + 8'h30;
        send_data <= 1'b1;
        state    <= DIGIT_0;
      end
      DIGIT_0: begin
        tx_data  <= (distance_reg % 10) + 8'h30;
        send_data <= 1'b1;
        state    <= SEND_CR;
      end

      //-------------------------------------------------
      // Carriage Return + Line Feed
      //-------------------------------------------------
      SEND_CR: begin
        tx_data   <= 8'h0D; // '\r'
        send_data <= 1'b1;
        state     <= SEND_LF;
      end
      SEND_LF: begin
        tx_data   <= 8'h0A; // '\n'
        send_data <= 1'b1;
        state     <= DONE;
      end

      //-------------------------------------------------
      // Go back to IDLE
      //-------------------------------------------------
      DONE: begin
        state <= IDLE;
      end

      default: state <= IDLE;
    endcase
  end

  //----------------------------------------------------------------------------
  // 7) UART Transmitter
  //----------------------------------------------------------------------------
  uart_tx_8n1 sensor_uart (
    .clk      (clk_9600),
    .txbyte   (tx_data),
    .senddata (send_data),
    .tx       (uarttx)
  );

endmodule
