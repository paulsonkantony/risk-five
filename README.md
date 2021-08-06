<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/paulsonkantony/risk-five/">
    <img src="images/logo.png" alt="Logo" width="256" height="80">
  </a>
  <h1 align="center">RISK-FIVE</h1>
</p>
<br/>



<!-- ABOUT THE PROJECT -->
## About The Project
A Verilog based implementation of the RV32I Unprivileged RISC-V Instruction Set Architecture.
A subset of the RV32I Base Module has been implemented. The functions that have not been included are CSR functions, fence, ecall and ebreak.

## Current Design
- Entirely written in Verilog.
- Requires 1 clock cycle to complete any instruction (except LOAD - Requires two cycles).
- Single RISC-V Hart only.
- The privileged ISA is **not** implemented.
- FENCE, FENCE.I and CSR instructions are not implemented.
- K Extension - Zkn and Zks - Implemented
  - The Bit-Manipulation and Cryptography Instruction Set that we are using is still in the experimental phase.
  - The extension has not been ratified by the RISC-V Foundation yet.

## Future Scope
- Implement a classic 5-stage RISC pipeline.
- Evaluate the implementation of the privileged ISA.
- GPIO, LED, UART Support.

## Final Year Thesis 
**Paulson K Antony** - 17BEC1147\
**Nikshith Narayan Ramesh** - 17BEC1097\
**Pranav Suryadevara** - 17BEC1073\
**Prof. Prathiba A** - Project Guide

**Vellore Institute of Technology, Chennai Campus,\
Vandalur-Kelambakkam Road,\
Chennai - 600127**
