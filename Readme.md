# Gemini Matlab scripts

![ci](https://github.com/gemini3d/gemini-matlab/workflows/ci/badge.svg)

These scripts form the basic core needed to work with Gemini to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

## Usage

To add paths to all the gemini-matlab functions, from the "gemini-matlab/" directory in Matlab:

```matlab
setup
```

### Plot all simulation outputs

```matlab
plot_all('~/data/mysim', 'png')
```

Will save all plots under the `mysim/plots/` directory. Omitting `'png'` just displays the plots without saving.

### Run Gemini

To run a Gemini simulation based on a directory's config.nml, from Matlab or GNU Octave:

```matlab
run_gemini('/path/to/config.nml', '/path/to/output')
```

## Notes

### GNU Octave

GNU Octave currently can do NetCDF4, but not HDF5.
Octave's `save('-hdf5','out.h5',...)` saves the variables in a fixed layout that's not usable for Gemini.
