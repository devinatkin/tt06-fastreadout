![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)
[![Run Testbenches](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_testbenches.yml/badge.svg)](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_testbenches.yml)

# What is this Project?
Thanks to the licensing and software issues associated the year of 2023 I got essentially zero work completed towards my thesis, work was completed but it went to waste due to issues outside my control. This project contains an attempt to recover some of that work by recreating it in a fully digital format. The original design is for an image sensor and therefore is inherently mixed signal. There will be two submissions to tiny tapeout, a fully digital version which simulates the analog functionaltiy and a small analog design which aims to match as close as possible to the digital design. 

Hopefully the final submission to this Repository will be an update with an associated paper... For now I need to complete this design. 

## Primary Design Components
- Input Registers (512 bit which represent the image data)
- Pixel Array (64 + 64) Frequency Modulation Output modules setup to pretend to be a full 64x64 array of pixels.
- Output Organizer Measures the Frequency Outputs from the 'Pixels' and outputs them from the chip acting as a basic router

### Input Shift Registers
The input shift registers are a 512 bit shift register which is used to store the image data. The data is clocked in serially and then clocked out in parallel. The data is clocked out in parallel to the sudo pixel array. (Each pixel in a column is represented by 8-bits in the shift register).



# What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.
To learn more and get started, visit https://tinytapeout.com.
