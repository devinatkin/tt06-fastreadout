![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)
[![Run Testbenches](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_testbenches.yml/badge.svg)](https://github.com/devinatkin/tt06-fastreadout/actions/workflows/run_testbenches.yml)

# What is this Project?
Thanks to the licensing and software issues associated the year of 2023 I got essentially zero work completed towards my thesis, work was completed but it went to waste due to issues outside my control. This project contains an attempt to recover some of that work by recreating it in a fully digital format. The original design is for an image sensor and therefore is inherently mixed signal. There will be two submissions to tiny tapeout, a fully digital version which simulates the analog functionaltiy and a small analog design which aims to match as close as possible to the digital design. 

Hopefully the final submission to this Repository will be an update with an associated paper... For now I need to complete this design. 

## Primary Design Components
- Input Registers (512 bit + Shift Registers which represent the image data)
- Pixel Array (64 + 64) Frequency Modulation Output modules setup to pretend to be a full 64x64 array of pixels.
- Output Organizer Measures the Frequency Outputs from the 'Pixels' and outputs them from the chip acting as a basic router


# Tiny Tapeout Verilog Project Template

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.
To learn more and get started, visit https://tinytapeout.com.

## Verilog Projects

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Optionally, add a testbench to the `test` folder. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/).

## Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://docs.google.com/document/d/1aUUZ1jthRpg4QURIIyzlOaPWlmQzr-jBn3wZipVUPt4)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@matthewvenn](https://twitter.com/matthewvenn)
