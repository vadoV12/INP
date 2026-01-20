INP Projects 2025/26
Two hardware design and low-level programming projects exploring processor architecture and assembly language implementation.📋 OverviewCourse: INP – Design of Computer Systems
Institution: FIT VUT Brno
Academic Year: 2025/26This repository contains solutions to two fundamental projects in computer architecture: implementing a BrainF*ck processor in VHDL and creating a vowel encryption cipher in MIPS64 assembly.Project 1: Simple Instruction Set Processor

Input: BrainF*ck source code via standard input
Output: Program execution with I/O through memory-mapped peripherals
Implementation: VHDL (synthesizable)
Target: FPGA (PYNQ-Z2 development kit)
Project 2: Consonant-Modulated Vowel Cipher

Input: Alphabetic string (name and surname)
Output: Encrypted text using dynamic key cipher
Implementation: MIPS64 assembly language
Environment: EduMIPS64 simulator
🎯 Project 1: BrainF*ck ProcessorFeatures

Complete BrainF*ck instruction set implementation (8 core instructions + extensions)
8kB unified memory for program and data (circular buffer)
Synchronous memory interface with read/write operations
Input/output peripheral interfaces
Loop constructs with bracket matching ([] and ())
Immediate value loading (0-9, A-F for hexadecimal values)
Program halt detection (@ separator)
Instruction Set
InstructionOpcodeDescription>0x3EIncrement pointer<0x3CDecrement pointer+0x2BIncrement current cell-0x2DDecrement current cell[0x5BWhile loop start]0x5DWhile loop end(0x28Do-while loop start)0x29Do-while loop end.0x2EOutput current cell,0x2CInput to current cell0-F0x30-0x46Load hex value@0x40Halt executionArchitecture Components

Datapath: PC (program counter), PTR (data pointer), CNT (bracket counter)
Control Unit: FSM managing instruction fetch, decode, and execution
Memory Interface: 13-bit addressing, 8-bit data width
I/O Interfaces: Input request/valid handshake, output busy/write enable
Bonus Extension
Optional implementation of display inversion instruction (~ opcode 0x7E) for 8×8 LED matrix display on PYNQ-Z2 hardware.🎯 Project 2: MIPS64 Vowel CipherEncryption Algorithm

Vowels only: Encrypts a, e, i, o, u, y – consonants remain unchanged
Dynamic key: Each vowel shifts by the position of the preceding consonant in alphabet
Special cases:

First vowel or vowel after vowel uses 'z' (position 26)
Wraps cyclically within a-z range

Input limited to lowercase a-z characters (max 30 characters)
Hardcoded vowel ASCII values for efficient comparison
Memory allocation for encrypted output
String termination with null character (0)
Output via syscall 5 (print string)
MIPS64 Implementation Details

Register management for character processing
Conditional branching for vowel/consonant detection
Arithmetic operations for cyclic shifting
Memory addressing for string manipulation
System calls for I/O operations
🛠️ Technical StackProject 1

Language: VHDL
Simulation: GHDL, Mentor Questa, GTKWave/Surfer
Synthesis: Vivado (for FPGA deployment)
Testing: Python-based test framework
Hardware: PYNQ-Z2 FPGA board (optional)
Project 2

Language: MIPS64 Assembly
Simulator: EduMIPS64 1.3.0+
Architecture: Pipelined MIPS64
Documentation: Integrated manual with instruction reference
