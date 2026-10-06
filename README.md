# Tiny RV32I RISC-V Processor Using Verilog HDL

A complete RTL implementation and verification of a **single-cycle Tiny RISC-V (RV32I) processor** designed using **Verilog HDL**. The processor was simulated using **Icarus Verilog** and verified through **GTKWave waveform analysis**.

---

## Project Overview

This project implements a simple RISC-V processor datapath based on the RV32I instruction set architecture. The design demonstrates the complete instruction execution flow:

- Instruction Fetch
- Instruction Decode
- Register Read
- Immediate Generation
- ALU Execution
- Memory Access
- Write Back

The processor was developed from scratch in Verilog HDL to understand the fundamental concepts of:

- Computer Architecture
- CPU Datapath Design
- Control Unit Design
- RTL Hardware Design
- Digital System Verification

---

## Processor Architecture

The processor consists of the following major components:

- Program Counter (PC)
- Instruction Memory
- Register File
- Immediate Generator
- Control Unit
- ALU Control
- Arithmetic Logic Unit (ALU)
- Data Memory
- Multiplexers
- Write-back Unit

### Architecture Flow

```
          +----------------+
          | Program Counter |
          +----------------+
                  |
                  v
        +-------------------+
        | Instruction Memory |
        +-------------------+
                  |
                  v
        +-------------------+
        |   Control Unit    |
        +-------------------+
                  |
                  v
        +-------------------+
        |   Register File   |
        +-------------------+
                  |
                  v
        +-------------------+
        | Immediate Generator|
        +-------------------+
                  |
                  v
        +-------------------+
        |        ALU        |
        +-------------------+
                  |
                  v
        +-------------------+
        |   Data Memory     |
        +-------------------+
                  |
                  v
        +-------------------+
        |   Write Back      |
        +-------------------+
```

---

## Supported Instructions

| Instruction Type | Supported Instructions |
|-----------------|------------------------|
| R-Type | ADD, SUB, AND, OR |
| I-Type | ADDI, ORI |
| Load | LW |
| Store | SW |
| Branch | BEQ |

---

## Simulation Environment

### Tools Used

| Tool | Purpose |
|------|---------|
| Verilog HDL | RTL implementation |
| Icarus Verilog | Compilation and simulation |
| GTKWave | Waveform visualization and verification |
| Visual Studio Code | Development environment |

---

## Simulation Commands

Compile the design:

```bash
iverilog -g2012 -o sim.out tinyriscv.v
```

Run simulation:

```bash
vvp sim.out
```

Open waveform:

```bash
gtkwave wave.vcd
```

---

## Verification Results

The processor was verified using a custom simulation testbench.

### Register Verification

```
x13 = 30
x5  = 32
x1  = 8
x4  = 40
x22 = 10
x8  = 77
x9  = 88
```

### Memory Verification

```
Mem[11] = 55
Mem[6]  = 99
```

The simulation confirms successful execution of:

- Arithmetic operations
- Immediate operations
- Load instructions
- Store instructions
- Register write-back operations
- Memory read/write operations

---

## GTKWave Simulation

The waveform verification demonstrates:

- Program Counter progression
- Instruction execution
- Register read/write operations
- ALU calculation
- Control signal behavior
- Memory access
- Write-back stage



## Project Files

```
Tiny-RISC-V-Processor-Verilog/

│
├── tinyriscv.v
│       RTL implementation of Tiny RISC-V processor
│
├── wave.vcd
│       GTKWave simulation waveform file
│
├── images/
│       Architecture and simulation figures
│
└── results/
        Simulation verification results
```

---

## Future Improvements

Possible future extensions:

- Add more RV32I instructions
- Implement pipelined architecture
- Add hazard detection and forwarding
- FPGA implementation
- Hardware testing on development boards

---

## Author

**Afnan Avi**

**Project Title:**  
Tiny RV32I RISC-V Processor Design and Verification Using Verilog HDL

---

## References

- David A. Patterson and John L. Hennessy  
  *Computer Organization and Design: The Hardware/Software Interface — RISC-V Edition*

- RISC-V Instruction Set Architecture Documentation
