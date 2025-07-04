# Find GEMINI3D: environment variable GEMINI_ROOT

Ensure environment variable GEMINI_ROOT is set to the top-level directory where Gemini3D is installed.
On Linux and MacOS, environment variables are set in ~/.profile (Linux) or ~/.zprofile (macOS) like:

```sh
export GEMINI_ROOT=/home/username/libgem_gnu
```

Use the correct path on your system, not the literal text above.

Alternatively, an environment file like `~/gemini3d.env` can be created with the same content.
Load this file in Matlab like:

```matlab
buildtool setup('~/gemini3d.env')
```

## Windows Subsystem for Linux (WSL)

Windows users can use Intel oneAPI to build Gemini3D and associated libraries natively from Windows.
Another choice is to generate the simulation files on Windows Matlab, then access those files from WSL to run the simulation.
That is, the Gemini3D code is compiled in Linux under WSL and run there.
