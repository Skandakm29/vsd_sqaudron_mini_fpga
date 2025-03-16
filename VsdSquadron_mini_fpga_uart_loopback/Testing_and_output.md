# Testing and Output 

## Clone & Setup Repository
```bash
git clone https://github.com/Skandakm29/VsdSquadron_mini_fpga_uart_loopback.git
cd "VsdSquadron_mini_fpga_uart_loopback"
```
Build & Flash FPGA Bitstream
###  Build the Bitstream
```bash
make build
```
 Generates top.bin for the FPGA.

###  **Flash to FPGA**
```bash
sudo make flash
Uploads the bitstream to the FPGA.
```
### **UART Loopback Testing**
Open Serial Terminal
```bash
sudo picocom -b 9600 /dev/ttyUSB0 --echo
```
 Send Data & Verify Output

# Expected Output:

Sent Data (TX)   | Received Data (RX)
-----------------|------------------
A               | AA
hello           | hheelllloo

Exit Terminal
CTRL + A, then CTRL + X
# If no output appears:
1. Check FPGA pin connections.
2. Ensure baud rate is set to 9600.
3. Verify FTDI cable is properly connected.
