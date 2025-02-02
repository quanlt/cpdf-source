cpdf-source
===========

Free for non-commercial use. See LICENSE for details. Copyright Coherent
Graphics Ltd 2022.

This code builds two things:

a) The CPDF PDF Command Line Tools, which are a popular commercial command line
tool for editing PDF files.

b) cpdf as an OCaml library, for which presently-scanty documentation is here:

[https://coherentpdf.com/cpdf/](https://coherentpdf.com/cpdf/)


Prerequisites to build
----------------------

The OCaml compiler

[http://ocaml.org](http://ocaml.org)

The camlpdf library

[http://github.com/johnwhitington/camlpdf](http://www.github.com/johnwhitington/camlpdf)

The ocamlfind library manager

[http://projects.camlcity.org/projects/findlib.html](http://projects.camlcity.org/projects/findlib.html)

If you are using the OPAM package manager:

[http://opam.ocamlpro.com](http://opam.ocamlpro.com)

these can be installed by:

```
opam install camlpdf
```

To build
--------

If downloading from Github, obtain the correct source. This means choosing the
tag for a particular version, such as "v2.5". The head of the master branch is
unstable.

1. Type `make` to make the cpdf executable and the library

2. Type `make install` to install the OCaml cpdf library.

The `cpdf` executable should be manually placed somewhere suitable.

Alternatively, the library and command-line binary can be installed by

```
opam install cpdf
```

Documentation
-------------

The file `cpdfmanual.pdf` in this folder is the documentation for the command
line tools. The documentation for the cpdf OCaml library is in `doc/html/cpdf/`
in this folder once the library has been built.


C API
-----

A C interface to cpdf is available, in source and binary form:

[https://github.com/johnwhitington/cpdflib-source](https://github.com/johnwhitington/cpdflib-source)

[https://github.com/coherentgraphics/cpdflib-binary](https://github.com/coherentgraphics/cpdflib-binary)

Python API
----------

A Python interface to cpdf is available:

[https://pypi.org/project/pycpdflib/](https://pypi.org/project/pycpdflib/)

Contact
-------

[contact@coherentgraphics.co.uk](mailto:contact@coherentgraphics.co.uk)
