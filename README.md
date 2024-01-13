# LC3SV

## Overview

This repository contains the SystemVerilog implementation of a 16-bit Little Computer 3 (LC-3) RISC processor. The project focuses on designing, testing, and verifying the processor, with future plans to enhance performance and use better verification techniques.

## Project Components
- **Location of Files:** Design and Verification files can be found in: lc3bsv.srcs/sources_1/new/

### 1. Microarchitecture

- **Memory:** Implementation of memory components for the processor.
- **Block Level Data-Path:** Design and integration of the block-level data path.
- **Data-Bus:** Definition and handling of the data bus for efficient data transfer.
- **Register File:** Implementation of the register file for storing and accessing data.
- **Controller and Microsequencer:** Design and integration of the controller and microsequencer for control flow.

### 2. Verification Architecture

- **UVM-Like Verification:** Learned and used transactions, generators, drivers, interfaes, and environment for the memory module that can be tested using EDA Playground

### 3. Future Enhancements

The project aims to incorporate the following features for improved performance:

- **Pipelining:** Multi-stage pipelining with data forwarding, Out-of-Order Execution, etc. to enhance instruction throughput.
- **Virtual Memory:** Integration of virtual memory with radix-tree page tables to extend addressable memory space.
- **LRU, L1, L2 Caches:** Incorporation of LRU caches and L1, L2 caches for efficient data caching.
- **Exception Handling:** Implementation of mechanisms for handling exceptions during program execution for page faults, unknown opcodes, etc.
- **Branch Prediction:** Integration of branch prediction techniques for optimizing control flow.
- **Verification:** Implementing testing environment for entire CPU and integrate scoreboards and monitors 