![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)
[![Run Normal Length Testbenches](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_testbenches.yml/badge.svg)](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_testbenches.yml)
[![Run Long Running Testbenches](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_long_testbenches.yml/badge.svg)](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_long_testbenches.yml)

# What is this Project?
This project is a image sensor "Simulation" intended to validate a readout scheme for larger scale usage. I have my doubts that anyone will be able to make good use of it outside of myself; however, I wish anyone who chooses to try the best of luck. It is intended to be a fix for the readout chain of the image sensor shown originally in [this publication](https://publications.waset.org/10013512/current-starved-ring-oscillator-image-sensor). The design consists of an image read-in shift register, a set of frequency modules, and a set of frequency counters to measure the frequency of the output. Overall this should be a validation of the readout method for any light controlled oscillator based pixel design.

## Primary Design Components
- Input Registers (shift_register.v), these had to be shrunk dramatically to git into the available space. These bits simply represent the light levels on the pixels that are simulated. 
- Pixel Array (frequency_module.v), instead of simulating an array of pixels with both rows and columns I have chosen to simulate a single short column of pixel. This is because the design is intended to be a validation of the readout chain and not the pixel design. This is also due to the limited space available on the chip.
- Frequency Counter (frequency_counter.v), this is a simple counter that counts the number of clock cycles between the rising edges of the input clock. This is used to measure the frequency of the output of the pixel array.

# Tiny Tapeout Verilog Project Template

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.
To learn more and get started, visit https://tinytapeout.com.
