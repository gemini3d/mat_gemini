# Offline package

To make an offline mat_gemini package suitable for computers without Internet, package mat_gemini.tar.bz2 like:

```sh
cmake -P scripts/package.cmake
```

Then the end user copies that mat_gemini.tar.bz2 to the offline computer and extracts:

```sh
tar xf mat_gemini.tar.bz2
```
