# MatGemini usage

**MatGemini finds Gemini3D by environment variable GEMINI_ROOT**.
Ensure environment variable GEMINI_ROOT is set to the top-level directory where Gemini3D is installed.

## Simulation prep:  calling GEMINI core model components from MATLAB

Features requiring Gemini3D runs include "gemini3d.model.setup" and "gmeini3d.run".
If MacOS issues with CMake or Git not found, try running from Matlab:

```sh
gemini3d.sys.macos_path()
```

Optionally, run the self-tests from Matlab in the mat_gemini/ directory:

```matlab
buildtool
```

for Matlab older than R2022b, the tests can be run by:

```matlab
runtests('gemini3d.test')
```

## `mat_gemini` functionality

Generally, one sets up a simulation, runs, then plots the outputs of that simulation.
Once that works, one perhaps changes simulation parameters, perhaps by perturbing the plasma or inputs with custom functions.

### Creating new simulation data

`gemini3d.model.setup()` creates a neutral atmosphere using MSIS.
The default is to use MSISE00, but MSIS 2.x is also available.
This is user selectable in the simulation config.nml file as 10 times the MSIS version.
For example, for MSIS 2.1:

```
&neutral_BG
msis_version = 21
/
```

`0` is MSISE00 (default)

### Run Simulation

By default we assume that the user will run the GEMINI core model from the command line.

The Matlab Live Scripts example/ns_fang.mlx interactively demonstrates running a 2D simulation, or simply run from Matlab:

```matlab
gemini3d.run(out_dir, 'Examples/init/2dns_fang.nml')
```

### Load a simulation config.nml file

Information from a simulation config.nml can be loaded into a structure via:

```matlab
cfg = gemini3d.read.config(directory)
```

For a complete description of possible options to specify in a `config.nml` file please see
[Readme_input](https://github.com/gemini3d/gemini3d/blob/main/docs/Readme_input.md)

### Load a data frame

The data writes out to a file at a rate set by the `dtout` parameter in `config.nml`.
You can load these by filename, or by directory + time:

```matlab
dat = gemini3d.read.frame(filename);
```

```matlab
dat = gemini3d.read.frame(directory, time=datetime(2012,1,20,12,5,3));
```

The variables in the `dat` struct are listed and explained in the main GEMINI repository
[Readme_output](https://github.com/gemini3d/gemini3d/blob/main/docs/Readme_output.md)

### Load a grid file

To read the grid data from a simulation directory do:

```matlab
xg = gemini3d.read.grid(directory)
```

Elements of the output grid structure are listed and described in the
[Readme_input](https://github.com/gemini3d/gemini3d/blob/main/docs/Readme_input.md)

### Plot all simulation outputs

```matlab
gemini3d.plot(out_dir, "png")
```

generates plots under `out_dir + "/plots"`
Will save all plots under the `mysim/plots/` directory. Omitting `'png'` just displays the plots without saving.

### Plot simulation grid

Plots of the simulation grid can be made:

```matlab
gemini3d.plot.grid(sim_path)
```

This can help show if something unintended happened.

## Advanced usage

### Custom functions

Often users will desire to perturb the quiescent equilibrium data with custom Matlab functions.
Assuming these functions have an interface like

```matlab
myfunc(cfg, xg)
```

then they can be specified in the config.nml file under setup/setup_functions.
For examples see
[GDI_periodic_lowres](https://github.com/gemini3d/gemini-examples/tree/main/init/GDI_periodic_lowres) and
[KHI_periodic_lowres](https://github.com/gemini3d/gemini-examples/tree/main/init/KHI_periodic_lowres).

### compare data directories

It can be useful to compare a simulation output and/or input with a "known good" reference case.
We provide this facility within the Matlab unittest framework for robustness and clarity.

```matlab
gemini3d.compare(new_dir, reference_dir)
```

That compares simulation inputs and outputs.

---

To only compare simulation input:

```matlab
gemini3d.compare(new_dir, reference_dir, 'in')
```

---

To only compare simulation output:

```matlab
gemini3d.compare(new_dir, reference_dir, 'out')
```
