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

Note the name of the "default" distro--let's assume it's Ubuntu-22.04.
Then in Windows PowerShell set GEMINI_ROOT environment variable like:

```
$env:GEMINI_ROOT="\\wsl$\Ubuntu-22.04\home\username\libgem_gnu"
```

Note: use the full WSL path you installed Gemini3D to, not the literal text above.
You can see the path from Windows Explorer using the filepath syntax above.
You can set the environment variable in Matlab like:

```matlab
setenv("GEMINI_ROOT", "\\wsl$\Ubuntu-22.04\home\username\libgem_gnu")
```
