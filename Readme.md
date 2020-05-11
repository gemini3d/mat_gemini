# Gemini Matlab scripts

![ci](https://github.com/gemini3d/gemini-matlab/workflows/ci/badge.svg)

These scripts form the basic core needed to work with Gemini to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

## Usage

To enable these scripts, each time you startup Matlab to work with Gemini, run from the "gemini-matlab/" directory in Matlab:

```matlab
setup
```

## Notes

### GNU Octave

GNU Octave currently can do NetCDF4, but not HDF5.
Octave's `save('-hdf5','out.h5',...)` saves the variables in a fixed layout that's not usable for Gemini.