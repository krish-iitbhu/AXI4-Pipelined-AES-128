#AXI4-Lite Based Pipelined AES-128 Hardware Accelerator
Overview

This project implements a 128-bit AES (Advanced Encryption Standard) encryption accelerator in Verilog HDL with an AXI4-Lite slave interface. The design is intended for FPGA-based hardware acceleration and demonstrates the complete flow  through AXI to a pipelined AES encryption engine.

The accelerator accepts a 128-bit plaintext and a 128-bit encryption key, performs AES-128 encryption using a 10-round pipelined architecture, and stores the resulting ciphertext back into memory-mapped output registers accessible through the AXI interface.

#Features

AXI4-Lite Slave Interface
Memory-Mapped Control and Status Registers
128-bit Plaintext Input
128-bit Encryption Key Input
128-bit Ciphertext Output
Pipelined AES Datapath
Combinational Key Expansion Module

<img width="400" height="500" alt="{4724D5E0-8974-4258-930D-10D7B22E3D11}" src="https://github.com/user-attachments/assets/9734f116-d71f-43e8-812a-d9993af08a92" />


AES Pipeline
The datapath consists of:

Initial AddRoundKey
9 Standard AES Rounds
SubBytes
ShiftRows
MixColumns
AddRoundKey

Final Round
SubBytes
ShiftRows
AddRoundKey



for verification I have use a standard example
# Verification
Test Vector

Plaintext:
00112233445566778899aabbccddeeff

Key:
000102030405060708090a0b0c0d0e0f

Expected Ciphertext:
69c4e0d86a7b0430d8cdb78070b4c55a
