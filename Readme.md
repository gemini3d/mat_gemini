# Gemini Matlab scripts

![ci](https://github.com/gemini3d/mat_gemini/workflows/ci/badge.svg)
[![DOI](https://zenodo.org/badge/246748210.svg)](https://zenodo.org/badge/latestdoi/246748210)
[![View MatGemini on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/78676-matgemini)
[![Build Status](https://travis-ci.com/gemini3d/mat_gemini.svg?branch=master)](https://travis-ci.com/gemini3d/mat_gemini)

These scripts form the basic core needed to work with Gemini3D ionospheric model to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

Matlab R2020a Update 5 and newer have better plot quality due to new Matlab graphics backend.

## Quick Start

We assume you already have a Fortran compiler and MPI library installed.

```sh
git clone https://github.com/gemini3d/mat_gemini
```

To enable mat_gemini functions, from the "mat_gemini/" directory in Matlab:

```matlab
setup
```

### Self-check (optional, but recommended)

Run the self-tests from Matlab in the mat_gemini/ directory:

```matlab
runtests('gemini3d.tests')
```

If the "runtests" dryrun fails with SSL certificate errors, you may need to tell Git the locatiion of your system SSL certificates. This can be an issue in general on HPC.
If this is an issue, and assuming your SSL certificates are at "/etc/ssl/certs/ca-bundle.crt", do these two steps from Terminal (not Matlab), one time.

1. edit ~/.bashrc to have

    ```sh
    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
    ```
2. issue Terminal command:

    ```sh
    git config --global http.sslCAInfo /etc/ssl/certs/ca-bundle.crt
    ```

## Usage

Assume you would like to run the [GDI Periodic Lowres example](https://github.com/gemini3d/gemini-examples/tree/master/init/GDI_periodic_lowres):

1. get the examples

    ```sh
    git clone https://github.com/gemini3d/gemini-examples
    ```
2. Ensure that MatGemini is on your Matlab path from Matlab run any one of {gemini3d,mat_gemini,gemini-example}/setup.m
3. run the example from Matlab:

    ```matlab
    ini = '~/gemini-examples/init/GDI_periodic_lowres'
    out_dir = '~/sims/gdi_lowres'
    gemini3d.gemini_run(out_dir, 'config', ini)
    ```

That will take about 1 hour on an 8-core 9th generation Intel i7 laptop CPU.

### Plot all simulation outputs

```matlab
gemini3d.gemini_plot(out_dir, "png")
```

generates plots under `out_dir + "/plots"`
Will save all plots under the `mysim/plots/` directory. Omitting `'png'` just displays the plots without saving.

### Plot simulation grid

Plots of the simulation grid can be made:

```matlab
gemini3d.plot_grid(sim_path)
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
[GDI_periodic_lowres](https://github.com/gemini3d/gemini-examples/tree/master/init/GDI_periodic_lowres) and
[KHI_periodic_lowres](https://github.com/gemini3d/gemini-examples/tree/master/init/KHI_periodic_lowres).

### Regenerate self-test reference datasets

This is intended for use by developers working with the internals of Gemini3D, the average user doesn't need this.
When a significant change is made to internal Gemini3D code, this may change the reference data and cause the self-tests to fail.
If determined that new reference datasets are needed:

```matlab
gemini3d.setup.generate_reference_data('../gemini-examples/initialize', '~/sim', 'test2d')
```

That makes all tests with subdirectory names containing "test2d".
A cell array or string array of names can also be specified.
