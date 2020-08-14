# Gemini Matlab scripts

![ci](https://github.com/gemini3d/mat_gemini/workflows/ci/badge.svg)
[![DOI](https://zenodo.org/badge/246748210.svg)](https://zenodo.org/badge/latestdoi/246748210)
[![View MatGemini on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/78676-matgemini)

These scripts form the basic core needed to work with Gemini to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

## Quick Start

1. if you don't already have [Gemini3D](https://github.com/gemini3d/gemini3d.git) installed, change to the directory where you like to keep code projects, and:

    ```sh
    git clone https://github.com/gemini3d/gemini3d

    ctest -S gemini3d/setup.cmake -VV
    ```

    That assumes you already have a Fortran compiler and MPI library installed. That will build and test the Gemini3D Fortran code.
    We suggest setting operating system environment variable `GEMINI_ROOT` with value of that path (e.g. ~/gemini3d) to ensure you use that code directory.
2. If you haven't already got a copy of this repo:

    ```sh
    git clone https://github.com/gemini3d/mat_gemini
    ```
3. To enable mat_gemini functions, from the "mat_gemini/" directory in Matlab:

    ```matlab
    setup
    ```
4. To run the self-tests from Matlab in the mat_gemini/ directory:

    ```matlab
    test_gemini
    ```

## Usage

Assume you would like to run the [GDI Periodic Lowres example](https://github.com/gemini3d/gemini-examples/tree/master/init/GDI_periodic_lowres):

1. get the examples

    ```sh
    git clone https://github.com/gemini3d/gemini-examples
    ```
2. Ensure that MatGemini is on your Matlab path from Matlab run any one of {gemini3d,mat_gemini,gemini-example}/setup.m
3. run the example from Matlab:

    ```sh
    ini = 'gemini-examples/init/GDI_periodic_lowres'
    out_dir = '~/sims/gdi_lowres'
    gemini3d.gemini_run(ini, out_dir)
    ```

That will take about 1 hour on an 8-core 9th generation Intel i7 laptop CPU.

### Plot all simulation outputs

```sh
gemini3d.vis.gemini_plot(out_dir, 'png')
```
That generates plots under `[outdir, '/plots']`
Will save all plots under the `mysim/plots/` directory. Omitting `'png'` just displays the plots without saving.

## Advanced usage

### Custom functions

Often users will desire to perturb the quiescent equilibrium data with custom Matlab functions.
Assuming these functions have an interface like

```matlab
myfunc(cfg, xg)
```

then they can be specified in the config.nml file under setup/setup_functions.
For examples see
[GDI_periodic_lowres](https://github.com/gemini3d/gemini-examples/tree/master/init/GDI_periodic_lowres) and
[KHI_periodic_lowres](https://github.com/gemini3d/gemini-examples/tree/master/init/KHI_periodic_lowres).

### Regenerate self-test reference datasets

This is intended for use by developers working with the internals of Gemini3D, the average user doesn't need this.
When a significant change is made to internal Gemini3D code, this may change the reference data and cause the self-tests to fail.
If determined that new reference datasets are needed:

```matlab
gemini3d.generate_reference_data('../gemini-examples/initialize', '~/sim', 'test2d')
```

That makes all tests with subdirectory names containing "test2d".
A cell array or string array of names can also be specified.
