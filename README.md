Grain growth model in APL
========================

Dyalog APL script to perform grain growth simulations.
The model is a slightly simplified version of:

- [Traka 2022](https://doi.org/10.4233/uuid:962f6655-a1b8-4c38-8467-0b2b651ab629)

Installation
------------

Download and extract into some directory.

Usage
-----

First, make sure [Dyalog](https://www.dyalog.com/download-zone.htm)
version 18.2 or higher is installed,
and set the simulation parameters editing the `gg.json` file
(the comments in the file explain the meaning of each parameter).
Then, run the `gg.apls` script on a command window
or double-click the corresponding icon.

Alternatively, from the Dyalog interpreter:

    2⎕FIX({(' '=⊃⍵)∨∨/':{}'∊⍵}¨⊢⍤/⊢)⊃⎕NGET'gg.apls' 1
    Sim'gg.json'

Plotting
--------

The script 'plotgg.m' can be used to plot the initial and final
microstructures with [MTEX](https://mtex-toolbox.github.io/). Eg:

    plotgg('./gg_')


jgl@dyalog.com 2023
