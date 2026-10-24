# AD9361 SDR on MicroBlaze and Virtex UltraScale+

Hardware and bare-metal software sources for an AD9361 SDR system targeting a
Xilinx Virtex UltraScale+ **`xcvu9p-flga2104-2-i`**, using **Vivado / SDK 2018.3**
(the original tools and handoff report **2018.3_AR71948**).

The repository has two sibling directories:

| Directory | Contents | Guide |
| --- | --- | --- |
| `vivado/` | FPGA hardware: MicroBlaze block design, RF datapath RTL, IP configurations, and board constraints | [Hardware README](vivado/README.md) |
| `sdk/` | Software running on MicroBlaze: application C sources, standalone BSP configuration, and SDK hardware handoff | [Software README](sdk/README.md) |

MicroBlaze itself is a soft processor instantiated in the Vivado hardware block
design. SDK builds the firmware that runs on that processor; the BSP describes
the hardware peripherals available to the software.

## Repository layout

```text
.
|-- README.md
|-- vivado/
|   |-- README.md
|   |-- rtl/
|   |-- bd/system.bd
|   |-- ip/
|   |-- constraints/
|   `-- scripts/create_project.tcl
`-- sdk/
    |-- README.md
    |-- Mahan3_App/                 MicroBlaze application
    |-- Mahan3_App_bsp/             Standalone BSP configuration
    `-- adaloop_top_hw_platform_0/  SDK hardware project and system.hdf
```

## Hardware workflow

From the repository root, with Vivado 2018.3 on `PATH`:

```text
vivado -mode batch -nojournal -nolog -source vivado/scripts/create_project.tcl
```

Open the generated project at
`vivado/build/ad9361_microblaze/ad9361_microblaze.xpr`. Generated projects and
outputs remain outside version control. See the [hardware guide](vivado/README.md)
for the FMC2 pin map, address map, registers, and validation results.

## Software workflow

1. Open SDK 2018.3 with a fresh workspace outside the checkout.
2. Import existing projects from **`<repository>/sdk`**:
   `adaloop_top_hw_platform_0`, `Mahan3_App_bsp`, and `Mahan3_App`.
3. Regenerate BSP sources for `microblaze_0`, then build the BSP and application.
4. Use a matching FPGA bitstream and hardware export when downloading the ELF.

The [software guide](sdk/README.md) covers build settings, board initialization,
RF defaults, and the firmware command interface. SDK project names and sibling
relationships are preserved by the directory split.

## Hardware/software integration status

The supplied hardware snapshot and SDK firmware have known register-interface
differences. For example, firmware uses completion/result words 57-59 and
firmware/GPS words 100-110, which the supplied `axi_lite_drv.v` does not implement.
See the [hardware integration notes](vivado/README.md#integration-issues-retained-from-the-supplied-sources).

The existing SDK handoff at `sdk/adaloop_top_hw_platform_0/system.hdf` is retained
unchanged. Neither this directory reorganization nor the earlier source cleanup
establishes a matched hardware/software board release. Full implementation,
timing closure, and on-board RF validation remain to be performed.

Original Analog Devices, Xilinx, and board-code notices remain in their files;
refer to those notices for the applicable license terms.
