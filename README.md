# AD9361 SDR on MicroBlaze and Virtex UltraScale+

Final AD9361 hardware and bare-metal firmware sources from the Mahan SDK
workspace, organized for **Vivado / SDK 2018.3_AR71948** and
**`xcvu9p-flga2104-2-i`**. Existing Git history is preserved.

| Directory | Contents | Guide |
| --- | --- | --- |
| `vivado/` | RF RTL, MicroBlaze BD, IP configurations, constraints, local packaged IP and simulation | [Hardware README](vivado/README.md) |
| `sdk/` | Final MicroBlaze application, BSP configuration and original SDK hardware handoff | [Software README](sdk/README.md) |

## Hardware

From the repository root, with Vivado 2018.3 on `PATH`:

```text
vivado -mode batch -nojournal -nolog -source vivado/scripts/create_project.tcl
```

Open `vivado/build/ad9361_microblaze/ad9361_microblaze.xpr`.
The separate `vivado/IP_Repo_2018_3` package is provided for integration into a
parent design. The recreation script uses local RTL and does not require that
package. Generated projects and outputs remain ignored by Git.

## Firmware

1. Open SDK 2018.3 with a fresh workspace outside the checkout.
2. Import the three existing projects under `sdk`: `adaloop_top_hw_platform_0`,
   `Mahan3_App_bsp` and `Mahan3_App`.
3. Regenerate and build the BSP for `microblaze_0`, then build the application.

After generating the BSP, the supplied command-line build is also available:

```text
python sdk/Mahan3_App/build_verified_firmware.py
```

## Verified command interface

The hardware now latches each request, holds it while firmware executes, and
accepts completion only with the matching sequence token. Interrupt
acknowledgement is separate from command completion. Internal AXI word indices
57-63 implement the result/token/error mailbox, identified by `CAL2`.

TX LO write command 2 reprograms even an unchanged requested frequency, reads
back the PLL registers, checks the calculated frequency within 100 Hz, and
requires four consecutive lock reads before reporting success. The DAC enable
crossing has a two-stage synchronizer. Ramin comments retain previous code in
the modified command paths.

The Mahan parent calibration retry controller and Ethernet transfer logic are
outside this AD9361 repository. Legacy GPS/version registers remain unsupported
by this local register decoder; see the guides before using those commands.

## Validation and release scope

The final application compiles and links with SDK 2018.3 against the existing
generated BSP. Native Vivado 2018.3 mailbox simulation passes. Project
recreation, BD generation and local-package synthesis have also been checked;
existing integration warnings are documented in the hardware guide.

The tracked `sdk/adaloop_top_hw_platform_0/system.hdf` is retained unchanged.
This source update does not provide a newly exported, fully implemented 2018.3
board release. Export matching hardware and regenerate the BSP when changing
the processor subsystem. FPGA images, ELF files, generated BSP files, build
caches and workspace state remain excluded under the repository's existing
ignore policy.

Original Analog Devices, Xilinx and board-code notices remain in their files.
Refer to those notices for their applicable license terms.
