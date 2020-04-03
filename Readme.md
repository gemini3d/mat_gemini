# Gemini Matlab scripts

![ci](https://github.com/gemini3d/gemini-matlab/workflows/ci/badge.svg)

These scripts form the basic core needed to work with Gemini to:

* generate a new simulation from scratch
* read simulation output
* plot simulation

However, since the transition to Python, it was decided to move the Matlab scripts out to reduce maintenance effort.
They remain as a canonical known-working reference.

## Usage

To enable these scripts, each time you startup Matlab to work with Gemini, run from this directory in Matlab:

```matlab
setup
```

That just adds paths to Matlab.
If you prefer, you can add this to your Matlab
[startup.m](https://www.mathworks.com/help/matlab/ref/startup.html)
to always enable Gemini.
