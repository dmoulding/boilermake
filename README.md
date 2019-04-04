Boilermake - A reusable, but flexible, boilerplate makefile.

Overview
--------
Boilermake is a reusable GNU Make compatible Makefile. It uses a non-recursive
strategy which avoids the many well-known pitfalls of recursive make.
Currently, boilermake only knows how to build C and C++ programs.

Boilermake requires GNU Make version 3.81 or later. Earlier versions of GNU Make
lack some required functionality.

Boilermake is free software. It is released under the GNU General Public
License.

Using Boilermake
----------------
To use the boilermake Makefile you need to create makefile fragments, called
"submakefiles" in boilermake parlance, which tell boilermake how to build your
program. A special submakefile named main.mk must be created. This is the first
submakefile that boilermake will look for and read.

A very minimal main.mk might look something like this:

  TARGET  := foo
  SOURCES := bar.c baz.c

This main.mk instructs boilermake to build a program named foo by compiling and
linking bar.c and baz.c. Again, this is just a *minimal* example. Additional
variables recognized by boilermake can allow for pretty powerful and flexible
builds. Even with this simple example, "#include" dependencies are
automatically generated, a "clean" rule is generated, and all intermediate (.o)
files are output under a directory named "build".

Boilermake Variables
--------------------
The previous example illustrated the use of a couple of boilermake's special
variables: TARGET and SOURCES. Boilermake has many other special variables
that can be used in your main.mk (or other submakefiles). All of the special
variables that boilermake uses are documented in the MANUAL file distributed
with boilermake. See that file for information about each variable's purpose.

Submakefiles
------------
In addition to main.mk, you can also create other "submakefiles" to modularize
or compartmentalize your build information. Submakefiles can be included using
the SUBMAKEFILES variable. Submakefiles can include other submakefiles,
allowing for a hierarchy of submakefiles. For instance, you might find it
convenient to create a submakefile for every subdirectory in your project.

Targets
-------
The final products of a build are referred to as "targets" in boilermake. Each
submakefile can define at most one target. However, a single boilermake
"project" containing multiple submakefiles can build many targets -- up to one
per submakefile. Targets are defined using the TARGET variable, and they may be
executables (including shared objects) or static libraries. If a target's name
ends with ".a", then boilermake will build that target as a static library,
otherwise the target will be built as an executable.

Submakefiles are Makefiles
--------------------------
Submakefiles are processed as normal GNU Makefiles, so all the GNU Make syntax
and processing rules apply. You can create variables of your own. You can use
conditional logic. Anything you can do in a normal GNU Makefile, you can do in
your submakefiles. You can get really advanced and define your own targets
without using the boilermake TARGET variable. The key thing is that boilermake
defines a number of special variables that you can use to automatically create
build rules that can otherwise be quite difficult to get right.

Example Test Application
------------------------
The test-app directory contains a simple example main.mk with several
submakefiles, illustrating how to build a small sample application.
