<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/ISC-HEI/isc-logos/main/white/ISC%20Logo%20inline%20white%20v3%20-%20large.webp">
  <img align="right" src="https://raw.githubusercontent.com/ISC-HEI/isc-logos/main/black/ISC%20Logo%20inline%20black%20v3%20-%20large.webp" alt="ISC Logo" height="50"/>
</picture>

![GitHub Repo stars](https://img.shields.io/github/stars/ISC-HEI/isc-hei-report)
![GitHub Release](https://img.shields.io/github/v/release/ISC-HEI/isc-hei-report?include_prereleases)
![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)

# Document templates for the ISC curricula

These are the official templates for reports, bachelor theses, project executive summaries, and posters for the [ISC degree programme](https://isc.hevs.ch/) at the School of Engineering in Sion. They are designed to help students focus on content by using `Typst` as the typesetting software.

<p align="center">
  <a href="examples/bachelor_thesis.pdf?raw=true"><img src="bachelor_thesis_thumb.png" alt="Bachelor Thesis" height="300"></a>
  <a href="examples/exec_summary.pdf?raw=true"><img src="exec_summary.png" alt="Executive Summary" height="300"></a>
  <a href="examples/report.pdf?raw=true"><img src="report_thumb.png" alt="Report" height="300"></a>
  <a href="examples/document.pdf?raw=true"><img src="document_thumb.png" alt="Report" height="300"></a>
  <a href="examples/poster.pdf?raw=true"><img src="poster_thumb.png" alt="Poster" height="300"></a>
  <a href="examples/tb_assignment.pdf?raw=true"><img src="tb_assignment_thumb.png" alt="Report" height="300"></a>
</p>

## Using the template, on the Web

In the `Typst` web application, start with the `isc-hei-*` document and voilà ! 

## Using one of templates in your shell

The package provides the following templates : 

```text
@preview/isc-hei-document
@preview/isc-hei-report
@preview/isc-hei-bthesis
@preview/isc-hei-exec-summary
@preview/isc-hei-tb-assignment
@preview/isc-hei-poster
```

First start by installing `Typst` on your machine. You can then initialize the project with the command :

```bash
typst init @preview/isc-hei-report
```

This template will initialize an sample report with sensible default values.

For the latest template for a bachelor thesis, use: 

```bash
typst init @preview/isc-hei-bthesis
```

or if you need a specific version, use:

```bash
typst init @preview/isc-hei-bthesis:0.5.0
```

For the latest template of the executive summary, use: 

```bash
typst init @preview/isc-hei-exec-summary
```

## Installing fonts locally

If you are running `typst` locally, you might miss some of the required fonts. For your convenience, a font download script is included in this repos. As all the fonts are released under the [SIL Open Font License](https://openfontlicense.org/), there are no file inclusion issues here.

To the install the fonts locally in a Linux environment, simply type

```bash
source install_fonts.sh
```

from within the `fonts` directory.

# Usage

When used locally, creating a PDF is straightforward with the command

```bash
typst compile report.typ
```

Even nicer, the following command compiles the report every time the file is modified.

```bash
typst watch report.typ
```

Another nice possibility is of course to use VScod(e | ium) via the `Typst LSP` plugin which enables direct compilation.

# Questions and help

If you need any help for installing or running those tools, do not hesitate to get in touch with its maintainer [pmudry](https://github.com/pmudry).

You can of course also propose changes using PR or raise issues if something is not clear. Have fun writing reports!
