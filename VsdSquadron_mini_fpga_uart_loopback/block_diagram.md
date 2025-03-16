# **UART Loopback Block Diagram**

## **1. What is UART?**
**UART (Universal Asynchronous Receiver-Transmitter)** is a serial communication protocol used for **asynchronous data transfer** between devices. It does not require a separate clock signal; instead, it uses a **baud rate** to synchronize communication.

## **2. What is UART Loopback Mode?**
**UART loopback** is a special mode where the **transmitted (`TX`) data is directly routed to the receiver (`RX`)**, allowing self-testing without external connections.

### **Why Use Loopback Mode?**
 **Debugging UART Transmission** → Ensures data is sent and received correctly.  
 **No External Hardware Required** → TX is internally connected to RX.  
 **Self-Testing** → Helps verify UART functionality in an FPGA or microcontroller.

## **3. UART Loopback Block Diagram**
![UART Loopback](https://github.com/Skandakm29/VsdSquadron_mini_fpga_uart_loopback/blob/main/uartloopback.png)

## **Explanation of Each Block**

### **1. UART Transmitter**
- This block is responsible for **sending serial data**.
- It converts **parallel 8-bit data** into a **serial bitstream**.
- Generates **Start Bit (`0`), Data Bits (LSB First), and Stop Bit (`1`)**.

### **2. Direct Connection (Loopback)**
- Instead of sending data to an external device, **TX (`uarttx`) is directly connected to RX (`uartrx`)**.
- Implements a **hardware loopback**, allowing data sent from TX to be immediately received by RX.

### **3. UART Receiver**
- Reads the **serial data from TX** via the direct connection.
- Reconstructs the original **8-bit parallel data**.
- This allows **testing UART transmission without an external receiver**.

---

## **Loopback Implementation in Verilog**
### **Direct Connection Logic**
```verilog
assign uarttx = uartrx;
```

- Any data sent on uarttx is instantly received on uartrx.
 - This eliminates the need for external connections during testing.
 - Helps debug UART transmission in an FPGA-based system.
