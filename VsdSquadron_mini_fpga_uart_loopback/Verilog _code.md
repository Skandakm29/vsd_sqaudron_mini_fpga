# **Step 1: Understanding the Verilog Code**
The Verilog code can be accessed [here](https://github.com/Skandakm29/VsdSquadron_mini_fpga_uart_loopback).  
It is designed for an **FPGA (Field Programmable Gate Array)** and implements a **UART Loopback (8N1 format)** along with **RGB LED control** using an **internal oscillator and counter**.

This module enables **serial communication via UART** and **controls RGB LEDs based on UART signals**.

---

## **Port Analysis**
The first section of the code specifies the **ports** of the FPGA board.

| **Port Name**   | **Type**  | **Width** | **Description** |
|---------------|---------|---------|----------------|
| `led_red`    | Output  | 1-bit   | Controls **Red LED** (Active High). |
| `led_blue`   | Output  | 1-bit   | Controls **Blue LED** (Active High). |
| `led_green`  | Output  | 1-bit   | Controls **Green LED** (Active High). |
| `uarttx`     | Output  | 1-bit   | **UART TX Line** (Transmits serial data). |
| `uartrx`     | Input   | 1-bit   | **UART RX Line** (Receives serial data). |
| `hw_clk`     | Input   | 1-bit   | **FPGA system clock input**. |

---

## **Internal Component Analysis**
The module consists of **three main internal components**:

---

### **Internal Oscillator (`SB_HFOSC`)**
```verilog
SB_HFOSC #(.CLKHF_DIV ("0b10")) u_SB_HFOSC (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(int_osc)
);
```
- **Purpose**: Generates a stable internal clock signal.
- **Configuration**: Uses `CLKHF_DIV = "0b10"` (binary 2) for clock division.
- **Control Signals**:
  - `CLKHFPU = 1'b1`: Enables **power-up**.
  - `CLKHFEN = 1'b1`: Enables **oscillator**.
  - `CLKHF`: Output connected to the **`int_osc`** signal.

---

### **Frequency Counter Logic**
```verilog
reg [27:0] frequency_counter_i;

always @(posedge int_osc) begin
    frequency_counter_i <= frequency_counter_i + 1'b1;
end
```
| **Component** | **Functionality** |
|-------------|----------------|
| `frequency_counter_i` (28-bit) | **Counter for timing operations**. |
| Increments on `posedge int_osc` | Used for **time-based events** in FPGA. |
| `uartrx` signal used as input | Affects LED behavior. |

- This **counter** is driven by the **internal oscillator (`int_osc`)**.
- The counter value can be used for **timing adjustments** in the design.

---

### **UART TX 8N1 (Transmitter)**
```verilog
module uart_tx_8n1 (
    input wire clk,        // System clock
    input wire [7:0] txbyte, // 8-bit data input
    input wire senddata,   // Transmission trigger
    output reg txdone,     // Transmission completion flag
    output wire tx         // UART TX output
);
```
| **Component** | **Functionality** |
|-------------|----------------|
| `txbit` | Stores the **current bit being transmitted**. |
| `buf_tx` | **Shift register** that holds UART data. |
| `bits_sent` | **Tracks how many bits have been transmitted**. |

#### **FSM State Definitions**
```verilog
parameter STATE_IDLE    = 8'd0;  // Wait for `senddata`
parameter STATE_STARTTX = 8'd1;  // Send Start Bit (0)
parameter STATE_TXING   = 8'd2;  // Send 8-bit Data
parameter STATE_TXDONE  = 8'd3;  // Send Stop Bit (1)
```

#### **UART Transmission Logic**
```verilog
always @(posedge clk) begin
    if (senddata == 1 && state == STATE_IDLE) begin
        state <= STATE_STARTTX;
        buf_tx <= txbyte;
        txdone <= 1'b0;
    end else if (state == STATE_IDLE) begin
        txbit <= 1'b1;
        txdone <= 1'b0;
    end

    if (state == STATE_STARTTX) begin
        txbit <= 1'b0; // Start bit
        state <= STATE_TXING;
    end

    if (state == STATE_TXING && bits_sent < 8'd8) begin
        txbit <= buf_tx[0]; // Send LSB first
        buf_tx <= buf_tx >> 1;
        bits_sent <= bits_sent + 1;
    end else if (state == STATE_TXING) begin
        txbit <= 1'b1; // Stop bit
        bits_sent <= 8'b0;
        state <= STATE_TXDONE;
    end

    if (state == STATE_TXDONE) begin
        txdone <= 1'b1;
        state <= STATE_IDLE;
    end
end
```

---

### **What This Does**
- **`STATE_IDLE`** → Waits for `senddata`.  
- **`STATE_STARTTX`** → Sends start bit (`0`).  
- **`STATE_TXING`** → Sends 8-bit data (`LSB first`).  
- **`STATE_TXDONE`** → Sends stop bit (`1`), marks completion.  

---

### **UART Loopback Implementation**
#### **How It Works**
- Instead of using a **separate UART receiver (`uart_rx_8n1`)**, the design **directly loops back the received signal (`uartrx`) to `uarttx`**.
- This acts as a **wire-based echo loopback**, useful for **testing UART communication**.

#### **Loopback Code in Verilog**
```verilog
assign uarttx = uartrx;
```



## **RGB LED Driver (`SB_RGBA_DRV`)**
```verilog
SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1),
    .RGB0PWM (uartrx),
    .RGB1PWM (uartrx),
    .RGB2PWM (uartrx),
    .CURREN  (1'b1),
    .RGB0    (led_green),
    .RGB1    (led_blue),
    .RGB2    (led_red)
);
```
- **Controls RGB LEDs using UART signals**.
- **Fixed brightness configuration**:
  - `RGB0_CURRENT = "0b000001"`
  - `RGB1_CURRENT = "0b000001"`
  - `RGB2_CURRENT = "0b000001"`

---

## **Module Documentation (Summary)**

### **Purpose**
This module **implements a UART transmitter** and **RGB LED controller** using:
1. **Internal Oscillator (`SB_HFOSC`)** for clocking.
2. **Finite State Machine (FSM)** for UART TX control.
3. **Shift Register (`buf_tx`)** for serial transmission.
4. **Counter Logic (`frequency_counter_i`)** for timing.

### **UART TX Working**
- Transmits **8-bit data (LSB first)**.
- Uses **start (0) and stop (1) bits**.
- Sends **serial data on `uarttx` pin**.

### **RGB LED Control**
- **Uses UART RX (`uartrx`) to drive LEDs**.
- **Changes LED color based on UART activity**.

---
