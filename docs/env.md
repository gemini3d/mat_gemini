# Find GEMINI3D: environment variable GEMINI_ROOT

Ensure environment variable GEMINI_ROOT is set to the top-level directory where Gemini3D is installed.
On Linux and MacOS, environment variables are set in ~/.profile (Linux) or ~/.zprofile (macOS) like:

```sh
export GEMINI_ROOT=/home/username/libgem_gnu
```

Use the correct path on your system, not the literal text above.

## Windows Subsystem for Linux (WSL)

Windows users are generally recommended to use WSL for ease of building Gemini3D and associated libraries.
Users that have Gemini3D compiled in WSL and using native Windows Matlab need to refer to the WSL Gemini3D location in GEMINI_ROOT using the WSL Windows path syntax prefixed with `\\wsl$`.
Determine this location by from Windows Terminal:

```sh
wsl --list
```

the typical result is like:

```
Windows Subsystem for Linux Distributions:
Ubuntu (Default)
```

Note the name of the "default" distro.

Check in Windows Explorer for the path to the Gemini3D install in WSL. 
It might be like (for username "me"):

```
\\wsl$\Ubuntu\home\me\libgem_gnu
```

Set the environment variable in Matlab like:

```matlab
setenv("GEMINI_ROOT", "\\wsl$\Ubuntu\home\me\libgem_gnu")
```
