# **UART Loopback Circuit Diagram**
![Circuit Diagram](https://github.com/Skandakm29/VsdSquadron_mini_fpga_uart_loopback/blob/main/circuit_diagram.png)

## **🔹 Key Components**
- **FPGA (VSD Squadron Mini):** Handles UART communication & LED control.
- **FTDI Cable:** Provides USB-to-UART communication.
- **RGB LED Driver (`SB_RGBA_DRV`):** Controls LEDs based on UART input.
- **High-Frequency Oscillator (`SB_HFOSC`):** Generates clock signals.
- **Frequency Counter:** Derives a **9600 Hz baud rate clock**.

## **🔹 Circuit Connections**
| **Component**  | **FPGA Pin** | **Function** |
|--------------|------------|----------------|
| **UART TX**  | Pin 14     | Sends data (Connected to RX) |
| **UART RX**  | Pin 15     | Receives data (Loopback from TX) |
| **FTDI TX**  | -          | Sends data to FPGA RX |
| **FTDI RX**  | -          | Receives data from FPGA TX |
| **RGB LEDs** | PWM Output | Controlled via UART signals |

