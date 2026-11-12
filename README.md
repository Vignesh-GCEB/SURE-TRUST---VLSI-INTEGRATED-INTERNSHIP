# Smart Home Alarm Controller – UVM Verification

A SystemVerilog/UVM verification environment for a Smart Home Alarm Controller. The testbench exercises the controller through its AHB-Lite programming interface and models external sensor and keypad activity, while monitoring alarm and interrupt outputs.

## Project Overview

The verification environment is organized around a virtual-sequencer-based UVM environment. It contains active agents for AHB, sensor, and keypad stimulus, and passive agents for alarm and interrupt observation. A reference model and scoreboard are used to predict expected behavior and compare it against observed DUT activity.

The top-level testbench instantiates the DUT, interfaces, clocks, resets, and UVM environment.

## Verification Architecture

| Component | Responsibility |
|---|---|
| AHB agent | Drives register read/write transactions and monitors bus activity |
| Sensor agent | Drives sensor-zone activity and monitors input transactions |
| Keypad agent | Drives PIN entry activity and monitors keypad transactions |
| Alarm agent | Passively observes siren, strobe, and alarm-active outputs |
| IRQ agent | Passively observes interrupt activity |
| Virtual sequencer | Coordinates AHB, sensor, and keypad sequences |
| Reference model | Predicts alarm-controller state and expected behavior |
| Scoreboard | Receives monitor transactions and checks observed behavior against the reference model |

## Repository Structure

```text
.
├── environment/
│   ├── ahb_agent.sv
│   ├── ahb_driver.sv
│   ├── ahb_monitor.sv
│   ├── ahb_seq_item.sv
│   ├── ahb_sequencer.sv
│   ├── alarm_agent.sv
│   ├── alarm_env.sv
│   ├── alarm_monitor.sv
│   ├── alarm_reference_model.sv
│   ├── alarm_scoreboard.sv
│   ├── alarm_seq_item.sv
│   ├── irq_agent.sv
│   ├── irq_monitor.sv
│   ├── irq_seq_item.sv
│   ├── keypad_agent.sv
│   ├── keypad_driver.sv
│   ├── keypad_monitor.sv
│   ├── keypad_seq_item.sv
│   ├── keypad_sequencer.sv
│   ├── sensor_agent.sv
│   ├── sensor_driver.sv
│   ├── sensor_monitor.sv
│   ├── sensor_seq_item.sv
│   ├── sensor_sequencer.sv
│   └── virtual_sequencer.sv
├── intf/
│   ├── ahb_if.sv
│   ├── alarm_if.sv
│   ├── irq_if.sv
│   ├── keypad_if.sv
│   └── sensor_if.sv
├── log/
├── sequences/
│   ├── AHB sequences
│   ├── sensor sequences
│   └── keypad sequences
├── tb_top/
│   └── tb_top.sv
├── test/
│   ├── alarm_base_test.sv
│   ├── alarm_smoke_test.sv
│   ├── motion_alarm_test.sv
│   ├── perimeter_alarm_test.sv
│   └── pin_failure_test.sv
└── virtual_seq/
    ├── smoke_virtual_sequence.sv
    ├── motion_alarm_vseq.sv
    ├── perimeter_alarm_vseq.sv
    ├── pin_failure_vseq.sv
    └── contr_write_status_read_vseq.sv
```

> The tree above highlights the main checked-in components. Refer to each directory for the complete set of source files.

## Verification Scenarios

The repository includes tests and sequences for scenarios such as:

- **Smoke test:** basic testbench/DUT operation.
- **Perimeter alarm:** perimeter sensor stimulus and alarm behavior.
- **Motion alarm:** motion sensor stimulus and alarm behavior.
- **PIN failure:** keypad PIN entry and failed-attempt handling.
- **Control/status access:** controller configuration and status readback flows.

The reference model includes modeled alarm states, arming modes, PIN authentication, timer values, zone configuration, alarm reasons, interrupt status, and event FIFO status. Exact expected results are determined by the design specification and the checks implemented in the scoreboard.

## Technology Stack

- **SystemVerilog** – RTL/testbench language
- **UVM** – constrained-random and reusable verification methodology
- **AHB-Lite** – memory-mapped register access interface
- **Synopsys VCS** – simulator (used where configured in the local environment)

The repository does not currently include a portable, self-contained simulator run script or a complete DUT source package. Simulation commands therefore depend on the local DUT RTL, UVM installation, simulator setup, and file-list/include configuration.

## Running the Testbench

1. Clone the repository:

   ```bash
   git clone https://github.com/Vignesh-GCEB/SURE-TRUST---VLSI-INTEGRATED-INTERNSHIP.git
   cd SURE-TRUST---VLSI-INTEGRATED-INTERNSHIP
   ```

2. Open the project in a SystemVerilog simulator with UVM support.
3. Add the project source files, DUT RTL, and required include directories to the simulator file list.
4. Ensure that the UVM library and simulator environment are configured.
5. Compile and run the selected test (for example, `alarm_smoke_test`, `motion_alarm_test`, or `perimeter_alarm_test`) using the simulator's project-specific command line.

A generic VCS invocation, once a correct file list and include paths have been prepared, has this form:

```bash
vcs -sverilog -ntb_opts uvm -f <filelist.f> -top tb_top \
    +UVM_TESTNAME=<test_name> -o simv
./simv
```

This is a template, not a verified command for the current repository: update the file list, include paths, top module, and test name to match the actual local setup.

## Notes

- The testbench top currently configures parameters including the number of zones, PIN width, timer width, event width, event FIFO depth, synchronization stages, debounce cycles, and PIN-attempt limit.
- Keep the reference model independent from DUT implementation details; it should represent expected specification behavior rather than reproduce DUT logic.
- Add new directed or constrained-random scenarios as reusable sequences and tests where practical.

## Author

**Vignesh**  
GitHub: [Vignesh-GCEB](https://github.com/Vignesh-GCEB)

---

This repository is part of a VLSI verification internship project focused on reusable UVM testbench development and functional verification.
