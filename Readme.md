# MatGemini - Base Gemini Matlab Scripts

[![MATLAB on GitHub-Hosted Runner](https://github.com/gemini3d/mat_gemini/actions/workflows/ci.yml/badge.svg)](https://github.com/gemini3d/mat_gemini/actions/workflows/ci.yml)
[![DOI](https://zenodo.org/badge/246748210.svg)](https://zenodo.org/badge/latestdoi/246748210)
[![View MatGemini on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/78676-matgemini)

These scripts form the basic core needed to work with Gemini3D ionospheric model to:

* generate a new simulation from scratch
* run a simulation
* read simulation output
* plot simulation output

The latter two functions are independent of the core GEMINI fortran/C model and as such can be used without first downloading and building.  I.e. to load and plot output data one does not need the main GEMINI fortran/C code, but creating input and running the GEMINI model from matlab require the core fortran/C code.

## Quick Start:  loading and plotting data only

Get MatGemini code:

```sh
git clone --recurse-submodules https://github.com/gemini3d/mat_gemini
```

If Gemini3D has previously been setup, from Matlab configure/check MatGemini paths:

```matlab
setup
```

Then run desired MatGemini commands.

---

If Gemini3D needs to be built, install Gemini3D
[gemini3d/external](https://github.com/gemini3d/external)
and then
[Gemini3D](https://github.com/gemini3d/gemini3d).

MatGemini finds Gemini3D by environment variable [GEMINI_ROOT](./docs/env.md).

If the system used is an offline (no Internet) system (some HPC are offline for security), see [doc](./docs/package.md).

For general usage and applications see [usage doc](./docs/usage.md) or
[troubleshooting doc](./docs/troubleshoot.md).
