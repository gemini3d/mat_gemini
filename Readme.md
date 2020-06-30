# Gemini Matlab scripts

![ci](https://github.com/gemini3d/mat_gemini/workflows/ci/badge.svg)

These scripts form the basic core needed to work with Gemini to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

## Usage

To add paths to all the mat_gemini functions, from the "mat_gemini/" directory in Matlab:

```matlab
setup
```

To run the self-tests, helping ensure you'll be able to correctly generate simulation inputs, from Matlab in the mat_gemini/ directory:

```matlab
runtests('tests')
```

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

## Notes

### GNU Octave

Currently, bugs and feature limitations in Octave prevent the full use of Octave with Gemini.

#### HDF5: feature missing from Octave

GNU Octave currently can not do HDF5.
Octave's `save('-hdf5','out.h5',...)` saves the variables in a fixed layout that's not usable for Gemini.

#### NetCDF4: buggy file writing

Unfortunately, there is also a bug in Octave NetCDF interface that causes only the first value to be written to a vector (1D) variable, leaving the other values at fill value.
This happens on Windows and Linux.
