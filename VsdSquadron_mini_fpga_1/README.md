
# VSD Squadron Mini FPGA Project

## Overview
This project demonstrates FPGA implementation on the VSDSquadron Mini FPGA board using Verilog and open-source tools (Yosys, NextPNR, and IceStorm). It includes an internal oscillator, a frequency counter, and RGB LED control.

## Tools Required
- **Yosys** - Logic synthesis
- **NextPNR** - Placement & routing
- **IceStorm** - Bitstream generation
- **Git** - Version control


## 1.Port Analysis:
```verilog
module top (
    // Outputs
    output wire led_red,   // Red
    output wire led_blue,  // Blue
    output wire led_green, // Green
    input wire hw_clk,     // Hardware Oscillator, not the internal oscillator
    output wire testwire
);
```

The first section of the code specifies the **ports** of the board, which are in the form of:
1. *led_red, led_blue, led_green* : These **three output wires** control the **RGB LED colors**. Each wire carries a **single-bit signal** that determines whether its corresponding color is **active** (1) or **inactive** (0).
2. *hw_clk* : A **single-bit input wire** that connects to the **hardware oscillator**, providing the system **clock signal** that drives the module's timing.
3. *testwire* : A **single-bit output** that provides a **test/debug signal**, specifically connected to **bit 5** of the frequency counter.

### Internal Component Analysis:
The module specifies three main internal components:

**1. Internal Oscilliator (*SB_HFOSC*)**
- Purpose: This generates a stable internal clock signal
- Configuration: Uses CLKHF_DIV = "0b10" (binary 2) for clock division
- Control Signals:
    1. *CLKHFPU = 1'b1* : Enables power-up
    2. *CLKHFEN = 1'b1* : Enables oscillator
    3. *CLKHF* : Output connected to internal *int_osc* signal

**2. Frequency Counter Logic**
- Implementation: 28-bit register (*frequency_counter_i*)
- Operation: Increments on every positive edge of *int_osc*
- Test functionality: Bit 5 is routed to *testwire* for monitoring
- Purpose: Provides a way to verify oscillator operation and timing


**3. RGB LED Driver (*SB_RGBA_DRV*)**

- Configuration:
    1. *RGBLEDEN = 1'b1* : Enables LED operation
    2. *RGB0PWM = 1'b0* : Red LED minimum brightness
    3. *RGB1PWM = 1'b0* : Green LED minimum brightness
    4. *RGB2PWM = 1'b1* : Blue LED maximum brightness
    5. *CURREN = 1'b1* : Enables current control
- Current settings: All LEDs set to "0b000001" (minimum current)
- Output connections:
    1. *RGB0* → *led_red*
    2. *RGB1* → *led_green*
    3. *RGB2* → *led_blue*
  
## 2.Pin Mappings
| Signal    | FPGA Pin | Description          |
|-----------|---------|----------------------|
| led_red   | 39      | Red LED Output       |
| led_blue  | 40      | Blue LED Output      |
| led_green | 41      | Green LED Output     |
| hw_clk    | 20      | External Clock Input |
| testwire  | 17      | Debugging Signal     |

## 3.Build & Flash Instructions
### Clone the Repository
```sh
git clone https://github.com/Skandakm29/VsdSquadron_mini_fpga-.git
cd VsdSquadron_mini_fpga-
```
## Compile and Flash the FPGA
```sh
make build
make flash
```
## Expected Behavior
Blue LED remains ON (controlled by SB_RGBA_DRV).

## 4.Demo video 

[![Watch the Demo](https://github.com/user-attachments/assets/9e443ef9-fec5-4688-9051-d291137a4921)](https://github.com/user-attachments/assets/9e443ef9-fec5-4688-9051-d291137a4921)

## License
This project is open-source under the MIT License.

## Contact
Email: kmskanda29@gmail.com

