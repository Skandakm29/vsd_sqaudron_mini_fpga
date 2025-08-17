# VSD_Squadron_FPGA_Projects
This repo contains four FPGA-based projects showcasing real-time UART communication, LED control, and sensor data acquisition. Designed using Verilog, Yosys, and NextPNR, running on the VSD Squadron Mini FPGA board
#  VSD Squadron Mini FPGA - Project Collection
## 
<img src="https://github.com/user-attachments/assets/a8bb3868-4454-48b9-9a43-8db6f9467c5c" alt="VSDSquadron mini fpga" width="400"/>


##  About the Board
The **VSD Squadron Mini FPGA** is a beginner-friendly **open-source FPGA board** designed for rapid prototyping and digital system implementation.

### **Board Specifications**
🔹 **FPGA Chip**: Lattice UltraPlus ICE40UP5K (5.3K LUTs)  
🔹 **Memory**: 1Mb SPRAM, 120Kb DPRAM, 4MB SPI Flash  
🔹 **General Purpose I/O (GPIO)**: 32 accessible pins  
🔹 **Connectivity**: FTDI FT232H USB-to-SPI for programming & debugging  
🔹 **Multipliers**: 8 DSP multipliers for arithmetic operations  
**[View the Datasheet](https://www.vlsisystemdesign.com/wp-content/uploads/2025/01/VSDSquadronFMDatasheet.pdf)** 
**For more details, visit the official website:** [VSD Official Page](https://www.vlsisystemdesign.com/vsdsquadronfm/)  

---

## 🔹 Projects Overview
## 🔹 FPGA Projects Overview

This repository contains **five FPGA-based projects**, each focusing on different aspects of **digital design, communication, and real-time processing** using the **VSD Squadron Mini FPGA**.

|  | Project Name                                         | Description |
|----|------------------------------------------------------|-------------|
| 1 | [Blink LED](https://github.com/Skandakm29/vsd_sqaudron_mini_fpga/tree/master/VsdSquadron_mini_fpga_1)                  | Basic FPGA LED blink test |
| 2| [UART Loopback](https://github.com/Skandakm29/vsd_sqaudron_mini_fpga/tree/master/VsdSquadron_mini_fpga_uart_loopback)          | Simple UART TX-RX loopback |
| 3 | [UART Transmitter](https://github.com/Skandakm29/vsd_sqaudron_mini_fpga/tree/master/Vsd_squadron_mini_Fpga_3)    | Sends serial data from FPGA to an external device |
| 4 | [UART Sensor-Based Transmitter](https://github.com/Skandakm29/vsd_sqaudron_mini_fpga/tree/master/Vsd_squadron_mini_Fpga_3) | Sends sensor data via UART |
| 5 | [Real-Time Sensor Data Acquisition](https://github.com/Skandakm29/vsd_sqaudron_mini_fpga/tree/master/Real-Time-Sensor-Data-Acquisition-and-Transmission-System) | Collects and processes sensor data for transmission |

 **Each project has a dedicated README with implementation details, Verilog source files, and simulation outputs.**  
Click on a project name to explore more details!


---

##  Setup & Installation
### **Install the required tool chain**
~~~
sudo apt update
~~~
### **Install synthesis, P&R, bitstream, and debugging tools**
~~~
sudo apt install -y \
  yosys \
  nextpnr-ice40 \
  icestorm \
  iverilog \
  gtkwave \
  picocom \
  make \
  git
~~~

### **Clone the Repository**

After installing the required tools, **clone this repository**:

    git clone https://github.com/Skandakm29/vsd_sqaudron_mini_fpga.git

Navigate into the repository:

    cd vsd_sqaudron_mini_fpga

***


### **Navigate to the Specific Project**

Each project has its own directory. Navigate to the project you want to work on:

Example:

    
    cd VsdSquadron_mini_fpga_uart_loopback

To view available files:

    
    ls
    

***


### **Clean Previous Builds**

Before starting a new build, clean old files using:

```sh
sudo make clean
```

This removes any previous bitstream files.

***


### **Build the FPGA Bitstream**

To **synthesize the design and generate the bitstream**, run:

    sudo make build

This will execute:

- **Synthesis (Yosys)**
- **Place & Route (NextPNR)**
- **Bitstream Generation (IceStorm)**

***


### **Flash the FPGA**

Once the bitstream is built, upload it to the FPGA using:

```sh
    sudo make flash
```
This command programs the **VSD Squadron Mini FPGA board**.

***

###
## Acknowledgment  

I would like to express my gratitude to:  

- **[Kunal Ghosh](https://www.linkedin.com/in/kunal-ghosh-vlsisystemdesign-com-28084836/)** for his valuable contributions to open-source VLSI education and FPGA learning resources.  
- **Open-Source Developers** who contributed to tools like **[Yosys](https://yosyshq.net/), [NextPNR](https://github.com/YosysHQ/nextpnr), [IceStorm](http://www.clifford.at/icestorm/), and [Icarus Verilog](http://iverilog.icarus.com/)**, making FPGA development accessible to everyone.  

This project is part of my journey in **FPGA & Digital Design**, and I deeply appreciate the knowledge and tools provided by the open-source community.  

##  Connect with Me  

**LinkedIn:** [K M Skanda](https://www.linkedin.com/in/k-m-skanda-541a02291/)  
**Email:** [kmskanda29@gmail.com](mailto:kmskanda29@gmail.com)  
