# Labelocity
**Labelocity:** Multimission PDS4 Labels is a flexible, customizable, multimission automated system for PDS4 label production at NASA Jet Propulsion Laboratory (JPL).

The **Labelocity** toolset is a [standalone application](https://github.com/NASA-AMMOS/labelocity) and is also included with the [VICAR general purpose image processing system](https://github.com/NASA-AMMOS/VICAR).

[Labelocity is being presented at the Universities Space Research Association (USRA) 6th Planetary Data Workshop in Flagstaff, AZ on Monday, June 26, 2023](https://www.hou.usra.edu/meetings/planetdata2023/technical_program/?session_no=302) and is also discussed in the [6th Planetary Data Workshop (2023), abstract #7071](https://www.hou.usra.edu/meetings/planetdata2023/pdf/7071.pdf).

# What's New in Release 1
This initial release provides the following features:
- Flexible, customizable, automated multi-mission system for label production
    - Reusable Velocity macros 
    - Driver scripts with a wrapper around the [PDS tool mi-label](https://github.com/NASA-PDS/mi-label/)
- Create labels from a variety of data sources, including ODL (PDS3) products, VICAR images and JSON metadata

**Labelocity** has been used to create most of the image, browse, mesh, calibration and documentation labels for several key missions, including the InSight and Mars 2020 missions. 

# Obtaining Labelocity
**Labelocity** can be obtained in two ways: pre-built binaries via tarball/ZIP download (which includes executable scripts), or source code via github.com.

### Requirements
To fully utilize **Labelicity** workstations must have the following software components pre-installed and available:
- The `tcsh` ([Tenex C Shell](https://www.tcsh.org/)), a `csh`-compatible shell installed and available to run most scripts. (This is usually pre-installed in Unix-based systems, including Macs, that provide shell prompts.)
    - (Planned future versions may provide feature-identical [BASH shell](https://www.gnu.org/software/bash/)-based scripts.)
- A `python3` installation, preferebly [Python 3.9.13](https://www.python.org/downloads/release/python-3913/) or newer, as provided by [Python.org](https://www.python.org/downloads/), to run certain scripts.
- A [Java 8-compatible JRE or JDK](https://adoptium.net/temurin/releases/?version=8), such as [OpenJDK](https://adoptopenjdk.net/releases.html), to launch `java` to execute compiled bytecode at the heart of Labelocity.

### Source Code 
- GitHub: https://github.com/NASA-AMMOS/labelocity
- Main Labelocity toolset source: [Click to download](https://github.com/NASA-AMMOS/labelocity/tarball/master) or [visit Releases for additional downloadable formats](https://github.com/NASA-AMMOS/labelocity/releases)

### Software Components
The Labelocity toolset consists of three complementary components separated by directory:
- `bin`: The `bin` directory consists largely of executable scripts in `tcsh` or `python 3` that wrap operations with command calls accepting various topical arguments.
- `jars`: Core image labeling functionality is pre-compiled into Java `JAR`s that are invoked by scripts in `bin`.
- `templates`: Velocity macro templates invoked by the scripts and used by the JARs to produce requested labeling outputs.  

_Executing **Labelocity** always begins by `cd`-ing to its directory and launching `./init.sh` which sets up the environment and launches the correct interpreter._

# Getting Started and Documentation
Running **Labelocity** is as quick as cloning this repository (or unpacking one of the above archives) and launching a script:
- Executing `./init.sh` launches a `tcsh` shell with properly sourced environment variables

Usage of the **Labelocity** toolset is described more fully in the Labelocity User Guide:
- [Labelocity User Guide](docs/LabelocityUserGuide_v1.0.pdf)

For more information on VICAR Open Source, the progenitor of **Labelocity**, documentation is available by [clicking here](https://github.com/NASA-AMMOS/VICAR#getting-started-and-documentation).

# Modifying Labelocity
One of the prime purposes of Open Source is to solicit contributions from the community, and we welcome such contributions. However, at the current time, this git repo is read-only. At some point in the future, we hope to make this easier, but for now, send any changes to [vicar_help@jpl.nasa.gov](mailto:vicar_help@jpl.nasa.gov) for further discussion. As this software is part of the [VICAR Suite](https://github.com/NASA-AMMOS/VICAR) used in mission surface operations, changes are vetted carefully. Getting more contributions from the community will help make the case for improved governance in the public sphere.
