# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random

def set_load(dut, value):
  dut.ui_in.value[2] = value

def clock_in(dut, bit):
  # Set the data input to the bit
  dut.ui_in.value[0] = bit

  # Toggle the clock to clock in the bit
  dut.ui_in.value[1] = not dut.ui_in.value[1]

  # Toggle the clock back to its original state
  dut.ui_in.value[1] = not dut.ui_in.value[1]

@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 10)
  dut.rst_n.value = 1

  # Set the input values, wait one clock cycle, and check the output
  dut._log.info("Initial values - Shift in some data")
  
  set_load(dut, 0)


  shift_register_bits = 8 * 5; # 8 Pixels, 5 Bits Per Pixel
  random_data = random.getrandbits(shift_register_bits)  

  for i in range(shift_register_bits):
    clock_in(dut, (random_data >> i) & 1)
    await ClockCycles(dut.clk, 1)

  # Wait for the output uo_out to change a certain number of times

  for i in range(1000):
    await ClockCycles(dut.clk, 1)
    print(f"uo_out: {dut.uo_out.value}")
