# Gemini Matlab scripts

![ci](https://github.com/gemini3d/mat_gemini/workflows/ci/badge.svg)
[![DOI](https://zenodo.org/badge/246748210.svg)](https://zenodo.org/badge/latestdoi/246748210)
[![View MatGemini on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/78676-matgemini)


These scripts form the basic core needed to work with Gemini to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

## Usage

To add paths to all the mat_gemini functions, from the "mat_gemini/" directory in Matlab:

```matlab
setup
```

We suggest that if you already have the
[Gemini3D](https://github.com/gemini3d/gemini3d.git)
code to set operating system environment variable `GEMINI_ROOT` with value of that path to ensure you use that code directory.
Otherwise, MatGemini will automatically Git clone and build Gemini3D.

### Self-tests

To run the self-tests from Matlab in the mat_gemini/ directory:

```matlab
runtests('tests', 'UseParallel',true)
```

If you have the Parallel Computing Toolbox, the tests will run in parallel.

### Plot all simulation outputs

```matlab
plot_all('~/data/mysim', 'png')
```

Will save all plots under the `mysim/plots/` directory. Omitting `'png'` just displays the plots without saving.

### Run Gemini

To run a Gemini simulation based on a directory's config.nml, from Matlab or GNU Octave:

```matlab
gemini_run('/path/to/config.nml', '/path/to/output')
```

### Regenerate self-test reference datasets

This is intended for use by developers working with the internals of Gemini3D, the average user doesn't need this.
When a significant change is made to internal Gemini3D code, this may change the refernece data and cause the self-tests to fail.
If determined that new reference datasets are needed:

```matlab
generate_reference_data('../gemini-examples/initialize', '~/sim', 'test2d')
```

That makes all tests with subdirectory names containing "test2d".
A cell array or string array of names can also be specified.

## Notes

### GNU Octave

Currently, bugs and feature limitations in Octave prevent the full use of Octave with Gemini.

#### HDF5: feature missing from Octave

GNU Octave currently cannot use HDF5.
Octave's `save('-hdf5','out.h5',...)` saves the variables in a fixed layout that's not usable for Gemini.

#### NetCDF4: buggy file writing

Unfortunately, there is also a bug in Octave NetCDF interface that causes only the first value to be written to a vector (1D) variable, leaving the other values at fill value.
This happens on Windows and Linux.
