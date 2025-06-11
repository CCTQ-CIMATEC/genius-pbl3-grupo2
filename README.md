# RISCV Processor
A simple RISC-V processor implementation with a structured verification environment.

## Source Organization
- **RTL Design**: Located in the `rtl/` directory.
- **Testbench Components**: Organized under `tb/` with subdirectories for agents, reference models, and top-level environment.
- **Source Lists**: Defined in `srclist/` for easy inclusion in simulation scripts.
- **doc**: Located in `doc/ `contains the conception and microarchitecture.

## Instructions
The following table lists the implemented instructions and their status.

| # | Instruction | Implemented | Tested | Working |
|---|-------------|:-----------:|:------:|:-------:|
| 1 | `LUI`       |     ✅     |   ✅   |   ✅   | 
| 2 | `AUIPC`     |     ✅     |   ✅   |   ✅   | 
| 3 | `JAL`       |     ✅     |   ✅   |   ✅   | 
| 4 | `JALR`      |     ✅     |   ✅   |   ✅   | 
| 5 | `BEQ`       |     ✅     |   ✅   |   ✅   | 
| 6 | `BNE`       |     ✅     |   ✅   |   ✅   | 
| 7 | `BLT`       |     ✅     |   ✅   |   ✅   | 
| 8 | `BGE`       |     ✅     |   ✅   |   ✅   | 
| 9 | `BLTU`      |     ✅     |   ✅   |   ✅   | 
| 10| `BGEU`      |     ✅     |   ✅   |   ✅   | 
| 11| `LB`        |     ✅     |   ✅   |   ✅   | 
| 12| `LH`        |     ✅     |   ✅   |   ✅   | 
| 13| `LW`        |     ✅     |   ✅   |   ✅   | 
| 14| `LBU`       |     ✅     |   ✅   |   ✅   | 
| 15| `LHU`       |     ✅     |   ✅   |   ✅   | 
| 16| `SB`        |     ✅     |   ✅   |   ✅   | 
| 17| `SH`        |     ✅     |   ✅   |   ✅   | 
| 18| `SW`        |     ✅     |   ✅   |   ✅   | 
| 19| `ADDI`      |     ✅     |   ✅   |   ✅   | 
| 20| `SLTI`      |     ✅     |   ✅   |   ✅   | 
| 21| `SLTIU`     |     ✅     |   ✅   |   ✅   | 
| 22| `XORI`      |     ✅     |   ✅   |   ✅   | 
| 23| `ORI`       |     ✅     |   ✅   |   ✅   | 
| 24| `ANDI`      |     ✅     |   ✅   |   ✅   | 
| 25| `SLLI`      |     ✅     |   ✅   |   ✅   | 
| 26| `SRLI`      |     ✅     |   ✅   |   ✅   | 
| 27| `SRAI`      |     ✅     |   ✅   |   ✅   | 
| 28| `ADD`       |     ✅     |   ✅   |   ✅   | 
| 29| `SUB`       |     ✅     |   ✅   |   ✅   | 
| 30| `SLL`       |     ✅     |   ✅   |   ✅   | 
| 31| `SLT`       |     ✅     |   ✅   |   ✅   | 
| 32| `SLTU`      |     ✅     |   ✅   |   ✅   | 
| 33| `XOR`       |     ✅     |   ✅   |   ✅   | 
| 34| `SRL`       |     ✅     |   ✅   |   ✅   | 
| 35| `SRA`       |     ✅     |   ✅   |   ✅   | 
| 36| `OR`        |     ✅     |   ✅   |   ✅   | 
| 37| `AND`       |     ✅     |   ✅   |   ✅   | 
| 38| `FENCE`     |     ❌     |   ❌   |   ❌   | 
| 39| `ECALL`     |     ❌     |   ❌   |   ❌   | 
| 40| `EBREAK`    |     ❌     |   ❌   |   ❌   | 

## Implementation Status

- [x] Conception
- [x] Microarchitecture
- [x] RTL Design
- [ ] TB environment
- [ ] Testcases
- [ ] Functional Verification
- [ ] RTL signoff 

## Verification Template Overview

The verification template in this repository is designed to provide a modular and reusable environment for verifying RTL designs using the Universal Verification Methodology (UVM). It includes the following components:

### Key Components
1. **Testbench Environment**:
   - The testbench is structured around UVM principles and includes agents, monitors, drivers, and sequencers.
   - The environment is defined in `tb/env/top/RISCV_env.sv` and instantiated in the top-level testbench `tb/RISCV_tb_top.sv`.

2. **Agents**:
   - The agent encapsulates the driver, monitor, and sequencer for the RISCV DUT.
   - Defined in `tb/env/agents/RISCV_agent/RISCV_agent.sv`.

3. **Reference Model**:
   - A behavioral model of the RISCV is implemented in `tb/env/ref_model/RISCV_ref_model.sv` to generate expected outputs for comparison.

4. **Scoreboard**:
   - The scoreboard compares the DUT's output with the reference model's output to verify correctness.
   - Implemented in `tb/env/top/RISCV_scoreboard.sv`.

5. **Coverage**:
   - Functional coverage is collected using `tb/env/top/RISCV_coverage.sv` to ensure all scenarios are tested.

6. **Sequences and Tests**:
   - Sequences generate randomized transactions for the DUT, defined in `tb/tests/sequence_lib/RISCV_store_seq.sv`.
   - Tests are defined in `tb/tests/RISCV_store_test.sv` and aggregated in `tb/tests/RISCV_test_list.sv`.

7. **Top-Level Testbench**:
   - The top-level testbench `tb/RISCV_tb_top.sv` instantiates the DUT, connects it to the UVM environment, and starts the simulation.

8. **Automation Scripts**:
   - The `bin/xrun.sh` script automates the build, simulation, and cleanup processes.

This template is designed to streamline the verification process, promote reusability, and ensure thorough testing of the RISCV design.

## How to run

### Step 1: Set up the environment
Before running the simulation, ensure that the required tools (Vivado or Vitis) are sourced. This sets up the necessary environment variables for the tools to function correctly.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

### Step 2: Run the simulation script
The `xrun.sh` script automates the process of compiling, elaborating, and simulating the design. Below are the common usage scenarios:

#### Run all tests
To run all tests in batch mode:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top -vivado "--R"
```
- `-top RISCV_tb_top`: Specifies the top-level testbench module.
- `--vivado "--R"`: Runs the simulation in batch mode.

#### Open the GUI
To open the Vivado GUI for debugging:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top --c -vivado "--g"
```
- `--c`: Cleans the build directory before running.
- `--vivado "--g"`: Opens the simulation in GUI mode.

#### Load a waveform structure
To load a specific waveform structure for analysis:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top --c -vivado "--g -view RISCV_tb_top_sim.wcfg"
```
- `--vivado "--g -view RISCV_tb_top_sim.wcfg"`: Opens the GUI and loads the specified waveform configuration file.

#### Run a specific test
To run a specific test case:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top --name_of_test RISCV_store_test --c -vivado "--g -view RISCV_tb_top_sim.wcfg"
```
- `--name_of_test RISCV_store_test`: Specifies the test case to run (default is `RISCV_store_test`).

### Step 3: Analyze results
- For batch mode, check the console output for pass/fail status and logs.
- For GUI mode, use the waveform viewer to debug and analyze signal activity.

### Notes
- The `--clean` option ensures a fresh build by removing intermediate files.
- The `--vivado` option allows passing additional parameters directly to Vivado for customization.

# Usage
```
xrun.sh [options]

Options:
  --t|-top <top_name>              Specify the top module name
  --N|-name_of_test <test_name>    Specify the test name (default: RISCV_store_test)
  --h|help                         Display this help message
  --c|-clean                       Clean build
  --v|-vivado <"--vivado_params">  Pass Vivado parameters

Use -v "--R" to run all, --v "--g" to gui, and --v "--g -view top_sim.wcfg" to load waveforms
```

## Important Information

1. **Tool Versions**:
   - Ensure you are using Vivado or Vitis version 2024.1 or later for compatibility with the scripts and UVM libraries.

2. **Directory Structure**:
   - Maintain the directory structure as provided in the repository to ensure the scripts and source lists function correctly.

3. **Debugging Tips**:
   - Use the `--vivado "--g"` option to open the GUI for debugging.
   - Check the `build/` directory for logs and intermediate files if issues arise during simulation.

4. **Extending the Template**:
   - To add new tests, create sequences in `tb/tests/sequence_lib/` and include them in `tb/tests/RISCV_test_list.sv`.
   - For additional coverage, extend the coverage model in `tb/env/top/RISCV_coverage.sv`.

5. **Support**:
   - For questions or issues, contact the maintainer at `nelsonafn@gmail.com`.

6. **License**:
   - This project is distributed under the BSD license. Refer to the `LICENSE` file for details.

This section provides essential details to ensure smooth usage and extension of the verification template.