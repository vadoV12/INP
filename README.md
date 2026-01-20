# INP Projects 2025/26

Two hardware design and low-level programming projects exploring **processor architecture** and **assembly language implementation**.

---

## 📋 Overview

- **Course:** INP – Design of Computer Systems  
- **Institution:** Faculty of Information Technology, Brno University of Technology (FIT VUT)  
- **Academic Year:** 2025/26  

This repository contains solutions to two fundamental computer architecture projects:
- A **BrainF*ck processor** implemented in **VHDL**
- A **vowel encryption cipher** implemented in **MIPS64 assembly**

---

## 📁 Projects

### 🧠 Project 1 – Simple Instruction Set Processor (BrainF*ck)

**Input**
- BrainF*ck source code via standard input

**Output**
- Program execution with I/O through memory-mapped peripherals

**Implementation**
- Language: **VHDL (synthesizable)**
- Target: **FPGA (PYNQ-Z2 development kit)**

---

### 🔐 Project 2 – Consonant-Modulated Vowel Cipher

**Input**
- Alphabetic string (name and surname)

**Output**
- Encrypted text using a dynamic key cipher

**Implementation**
- Language: **MIPS64 assembly**
- Environment: **EduMIPS64 simulator**

---

## 🎯 Project 1 – BrainF*ck Processor

### Features

- Complete BrainF*ck instruction set  
  (8 core instructions + extensions)
- 8 kB unified memory for program and data (circular buffer)
- Synchronous memory interface (read/write)
- Input/output peripheral interfaces
- Loop constructs with bracket matching (`[]`, `()`)
- Immediate value loading (`0–9`, `A–F` for hexadecimal)
- Program halt detection using `@` separator

---

### Instruction Set

| Instruction | Opcode | Description |
|------------|--------|-------------|
| `>` | `0x3E` | Increment pointer |
| `<` | `0x3C` | Decrement pointer |
| `+` | `0x2B` | Increment current cell |
| `-` | `0x2D` | Decrement current cell |
| `[` | `0x5B` | While loop start |
| `]` | `0x5D` | While loop end |
| `(` | `0x28` | Do-while loop start |
| `)` | `0x29` | Do-while loop end |
| `.` | `0x2E` | Output current cell |
| `,` | `0x2C` | Input to current cell |
| `0–F` | `0x30–0x46` | Load hexadecimal value |
| `@` | `0x40` | Halt execution |

---

### Architecture Components

- **Datapath**
  - PC (program counter)
  - PTR (data pointer)
  - CNT (bracket counter)
- **Control Unit**
  - FSM controlling fetch, decode, and execute stages
- **Memory Interface**
  - 13-bit addressing
  - 8-bit data width
- **I/O Interfaces**
  - Input request/valid handshake
  - Output busy/write-enable signaling

---

### Bonus Extension

- Optional implementation of display inversion instruction  
  `~` (opcode `0x7E`) for an **8×8 LED matrix** on PYNQ-Z2 hardware

---

## 🎯 Project 2 – MIPS64 Vowel Cipher

### Encryption Algorithm

- Encrypts **vowels only**: `a, e, i, o, u, y`
- Consonants remain unchanged
- **Dynamic key**:
  - Vowel shift equals the alphabetical position of the preceding consonant
- **Special cases**:
  - First vowel or vowel after vowel uses `'z'` (position 26)
  - Cyclic wrapping within `a–z`
- Input limited to lowercase letters (`a–z`), max 30 characters

---

### Implementation Details

- Hardcoded ASCII values for vowels
- Register-based character processing
- Conditional branching for vowel/consonant detection
- Arithmetic for cyclic shifting
- Dedicated memory space for encrypted output
- Null-terminated string (`0`)
- Output via syscall `5` (print string)

---

## 🛠️ Technical Stack

### Project 1

- **Language:** VHDL  
- **Simulation:** GHDL, Mentor Questa, GTKWave / Surfer  
- **Synthesis:** Vivado (FPGA deployment)  
- **Testing:** Python-based test framework  
- **Hardware:** PYNQ-Z2 FPGA board (optional)

### Project 2

- **Language:** MIPS64 Assembly  
- **Simulator:** EduMIPS64 (v1.3.0+)  
- **Architecture:** Pipelined MIPS64  
- **Documentation:** Integrated instruction reference

---
