# Implementing a UART Transmitter that Sends Data Based on Sensor Inputs

## Objective:
Design and implement a **UART transmitter** that sends real-time **sensor data** over a serial interface. This ensures the FPGA can **communicate sensor values** reliably to an external device.

---


# 1.Study the Existing Code

## Module Analysis

### **Architecture Overview**
The `sense_uart_tx` module enables **sensor-driven UART transmission**, ensuring efficient and structured data transfer. The architecture includes:

1. **Sensor Data Handling**
2. **Baud Rate Generation**
3. **UART Transmission Logic**
4. **State Machine for Data Control**

---

### **Operation Flow**
1. **Data Sampling**
   - Sensor values are **sampled** at defined intervals.
   - A **data_valid** signal triggers the transmission process.
   - The **32-bit sensor data buffer** holds the values before transmission.

2. **Baud Rate Control**
   - The **baud rate generator** creates a stable **9600 baud clock**.
   - A counter-based approach ensures correct bit timing.

3. **UART Transmission Sequence**
   - **START**: Outputs a **low start bit**.
   - **DATA BITS**: Transmits **8-bit chunks** sequentially.
   - **STOP**: Outputs a **high stop bit** to mark the end.
   - **State transitions** synchronize the process.

4. **Status Indication**
   - The **tx_done** signal indicates completion.
   - The **ready** signal ensures no data loss during continuous sensor readings.

---

### **Port Analysis**
1. **Clock and Reset**
   - **clk**: Drives synchronous operations.
   - **reset_n**: Resets all internal states.

2. **Sensor Interface**
   - **sensor_data [31:0]**: Input from the sensor module.
   - **data_valid**: Indicates new sensor data availability.

3. **UART Output**
   - **tx_out**: UART serial output for external communication.

4. **Control Signals**
   - **tx_start**: Initiates UART transmission.
   - **tx_done**: Signals when data transmission is complete.
   - **ready**: Indicates module is ready for new data.

---

### **Internal Logic**
1. **Finite State Machine (FSM)**
   - **IDLE**: Waits for a **data_valid** trigger.
   - **START**: Sends the **start bit (0)**.
   - **DATA**: Sequentially shifts out **8-bit portions** of sensor data.
   - **STOP**: Outputs the **stop bit (1)**.
   - **DONE**: Raises `tx_done` and returns to IDLE.

2. **Baud Rate Generator**
   - Uses **clock division** to produce an accurate **9600 Hz baud clock**.

3. **Shift Register**
   - Holds **32-bit sensor data**.
   - Sequentially shifts **8 bits per transmission cycle**.


# 2.System Architecture

## Block diagram
<details>
   <summary>Block diagram</summary>

   ![Block diagram](https://github.com/user-attachments/assets/15f9116a-ffa7-4ca3-90fa-f3e1a19eab03)
   This block diagram illustrates an **FPGA-based UART transmission system** for sensor data.

### **Sensor Section**
- **Sensor Interface** → Captures raw data.
- **Data Processing** → Filters/formats the data.
- **Data Buffer** → Stores processed data before transmission.

### **FPGA Section**
- **Baud Rate Generator** → Generates clock for UART.
- **Data Buffer** → Stores sensor data for transmission.
- **TX Shift Register** → Shifts data bit by bit.
- **UART TX Logic** → Handles start, data, and stop bits.
- **State Machine** → Controls the transmission sequence.

### **Data Flow**
1. Sensor collects and processes data.
2. FPGA buffers and prepares it for UART.
3. TX Shift Register formats the data.
4. UART TX Logic transmits it serially.
5. State Machine ensures correct timing.

</details>

## Circuit Diagram

<details>
   <summary>Circuit diagram</summary>

   ![Circuit diagram](https://github.com/user-attachments/assets/de674840-445b-4f92-8f14-888fd27434d0)

</details>


#  3.Synthesis & Programming

## Testing and Output

## **Clone & Setup Repository**
```bash
git clone https://github.com/Skandakm29/vsd_squadron_minifpga_4.git
cd "Vsd_squadron_mini_Fpga_4"
```

###  Build the Bitstream
```bash
make build
```
 Generates top.bin for the FPGA.

###  **Flash to FPGA**
```bash
sudo make flash
```
Uploads the bitstream to the FPGA.
### **UART Testing**
```bash
sudo make terminal
```


# 4.UART Transmission Showcase

## Demo Video

   ![Watch the Demo](https://github.com/user-attachments/assets/4ce16e78-e394-4b0d-826d-901246b7e372)




