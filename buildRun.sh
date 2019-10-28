#!/bin/sh
export LD_LIBRARY_PATH=.
fpc -g rexxsample.pas
rexx test.rex