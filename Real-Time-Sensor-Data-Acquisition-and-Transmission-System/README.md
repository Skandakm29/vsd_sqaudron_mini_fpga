# **Real-Time Sensor Data Acquisition and Transmission System**
## **1. Introduction**

This document compiles the entire **Real-Time Sensor Data Acquisition and Transmission System** design, including a system overview, design schematics, annotated code, testing procedures, and a short demonstration video. The goal is to measure distance using an **HC-SR04 ultrasonic sensor** on an FPGA and transmit the results via **UART** to a serial terminal.

***


## **2. System Overview**

The system comprises:

- **FPGA Internal Oscillator** at \~12 MHz.

- A **clock divider** and **refresher module** to periodically trigger measurements (e.g., every 50 ms or 250 ms).

- An **HC-SR04 sensor module** (`hc_sr04.v`) that generates a 10 µs trigger pulse, counts the echo duration, and calculates distance in centimeters.

- A **UART transmitter** (`uart_tx_8n1.v`) that sends the distance reading as ASCII characters at 9600 baud.

- **RGB LED** outputs for optional visual feedback.

The top module integrates these components, latches the measured distance, converts it to ASCII, and transmits it. A **USB–Serial** adapter receives the data, which can be viewed on a PC terminal.

***



## **3. Design Schematics**

### **3.1 Circuit Diagram**

****![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXd5xkb5gMuHSNYgQoRD_OxamARd0IUQAOl_i-2pFqskH-MfCgkCqAVZKaCm80sUEvnDQ_Axs8DmgC6NjuH-mt7uROLzRKor-2gfPz6er826Y1mfdYylWvkcJsPxds0z4VHbxxf_?key=6kJc66JRu5WFCB9blkyq0Utk)****
### **3.2 Block Diagram**
****![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXd3YQhi8gReP9dqfYN2P_hZpTpQ9WX7hxpKOFruj6omfOeUERVTwFJeBkqbTCt8lMyhfK2SCRqvcpJ-2Wgt-5-TVefg79lQuKLOID1_rKjf52kwsxw2MFAcIijrl7OTnb030-xa2g?key=6kJc66JRu5WFCB9blkyq0Utk)****

***


## **4. Annotated Code Listings**

This section briefly explains the main modules in the design. See the **src/** folder for complete Verilog files.


### **4.1. UART Transmit Module**

**File:** `uart_tx_8n1.v
` **Key Points:**

- **Finite State Machine** with states:

  - **IDLE**: Wait for `senddata=1`.

  - **START**: Output start bit (0).

  - **DATA BITS**: Shift out 8 bits, LSB first.

  - **STOP**: Output stop bit (1). Return to IDLE.

- **Baud Rate**: The module expects a 9600 Hz clock to step the FSM.


### **4.2. Ultrasonic Sensor Module (**`hc_sr04`**)**

**File:** `ultra_sonic_sensor.v
` **Key Points:**

- **State Machine**: IDLE → TRIGGER → WAIT → COUNTECHO → IDLE.

- **TRIG** is held high for \~10 µs in the TRIGGER state.

- **ECHO** is counted (distanceRAW) in the COUNTECHO state.

- **distance\_cm** = `(distanceRAW * 34300) / (2 * 12000000)` ( 12 MHz Clock).

```verilog

    // Example snippet
    always @(posedge clk) begin
      case (state)
        IDLE: if (measure) state <= TRIGGER;
        TRIGGER: if (trigcountDONE) state <= WAIT;
        WAIT: if (echo) state <= COUNTECHO;
        COUNTECHO: if (!echo) state <= IDLE;
      endcase
    end
```

### **4.3. Refresher Module**

**File:** `refresher250ms.v
` **Key Points:**

- Counts clock cycles up to a preset (e.g., 3,000,000 for 250 ms at 12 MHz).

- Outputs a **1‐cycle pulse** (`measure`) each time it resets.

```verilog
    always @(posedge clk) begin
      if (counter == 3000000) begin
        measure <= 1;
        counter <= 0;
      end else begin
        measure <= 0;
        counter <= counter + 1;
      end
    end
```

### **4.4. Top Module**

**File:** `top.v
` **Key Points:**

- **Generates** the 9600 Hz clock from the 12 MHz oscillator.

- **Instantiates** the sensor module, refresher, and UART.

- **Latches** `distance_cm` and converts it to ASCII digits via a small state machine.

- **Transmits** the ASCII string over UART.

```verilog
    // Pseudocode snippet
    always @(posedge clk_9600) begin
      case (state)
        IDLE: if (sensor_ready) distance_reg <= distance_cm; ...
        DIGIT_4: tx_data <= ((distance_reg/10000)%10) + '0'; ...
        ...
      endcase
    end
```

***


## **5. Testing Procedures**

### **5.1. Simulation**

1. **Testbench** (`ultra_sonic_sensor_tb.v`):

   - Provides a simulated `measure` pulse and a dummy echo signal.

2. **Waveforms**:

   - Dump waveforms to `wave.vcd`.

   - Verify the correct time in COUNTECHO corresponds to the final `distance_cm` output.


### **5.2. Hardware Testing**

1. **Wiring**:

   - TRIG → HC-SR04 TRIG, ECHO → HC-SR04 ECHO.

   - 5 V to sensor VCC, common GND.

   - FPGA’s UARTTX → USB–Serial RX.

2. **Serial Terminal**:

   - 9600 baud, 8 data bits, no parity, 1 stop bit.

3. **Measuring Distance**:

   - Place an object \~10 cm away from the sensor.

   - Terminal should display a reading around “00010” .

   - Move the object closer or farther to see changing values.

***


## **6. Short Video Demonstration**

[![Demo Video](path/to/thumbnail.png)](https://github.com/user-attachments/assets/51817db1-c7d6-4cea-a7fe-6f03eacc206a)



***


## **7. Synthesis & Programming**

### **7.1. Cloning & Building**

```bash


    git clone https://github.com/Skandakm29/Real-Time-Sensor-Data-Acquisition-and-Transmission-System.git
    cd "Real-Time-Sensor-Data-Acquisition-and-Transmission-System"
```
clones a GitHub repository for a real-time sensor data system and then enters its directory
```bash
   make build
```
This runs Yosys, nextpnr, and icepack (or your FPGA toolchain) to produce the final bitstream (e.g., `top.bin`).


### **7.2. Flashing the FPGA**

```tcl

    sudo make flash
````
This uploads `top.bin` to the FPGA board using `iceprog` or a similar programmer.


### **7.3. Running the Terminal**

```bash


    sudo make terminal
```
Opens a screen or minicom session at 9600 baud. Watch the distance measurements stream in as ASCII text.

***


## **8. Conclusion**

We have demonstrated a complete **Real-Time Sensor Data Acquisition and Transmission System** on an FPGA:

- The **HC-SR04** ultrasonic sensor is triggered at regular intervals.

- The FPGA counts echo pulses and calculates distance in centimeters.

- The **UART transmitter** sends the measurements at 9600 baud to a PC.

- Optional RGB LEDs provide local visual feedback.

This design can be extended to other sensors or improved by adding more robust error handling, or by supporting different baud rates or clock speeds.

***


## **9. References & Acknowledgments**

- [VSDSquadron mini Fpga board(datasheet)](https://www.vlsisystemdesign.com/vsdsquadronfm/)

- [Yosys Open Synthesis Suite](https://yosyshq.net/yosys/)

- [nextpnr: Next Generation Place-and-Route Too](https://github.com/YosysHQ/nextpnr)l

- [Icestrom](https://github.com/YosysHQ/icestorm)
