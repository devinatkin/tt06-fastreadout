# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random
async def shift_in_value(dut, value):
  # Convert value into a 40-bit binary representation
  # DATA_IN1 = ui_in[0];
  # RCLK_1 = ui_in[1];
  # LOAD_1 = ui_in[2];
  binary_value = bin(value)[2:].zfill(40)

  for i in range(0, 40, 1):
    # Set the value of the data input ui_in [0] to the current bit of the binary value
    if binary_value[i] == "1":
      dut.ui_in.value = (dut.ui_in.value | 0b00000001) | 0b00000010 # DIN = 1 RCLK = 1
    else:
      dut.ui_in.value = (dut.ui_in.value & 0b11111110) | 0b00000010 # DIN = 0 RCLK = 1
    await ClockCycles(dut.clk, 1)
    
    dut.ui_in.value = dut.ui_in.value & 0b11111101 # RCLK = 0
    await ClockCycles(dut.clk, 1)
    
  # assert dut.user_project.Row_Register_input.shift_reg.value == value, f"Expected {value}, got {dut.user_project.Row_Register_input.shift_reg.value}"

  # Load the data into the shift register
  dut.ui_in.value = dut.ui_in.value | 0b00000110 # LOAD = 1 RCLK = 1

  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = dut.ui_in.value & 0b11111001 # LOAD = 0 RCLK = 0
  await ClockCycles(dut.clk, 1)
  # assert dut.user_project.ROW_DATA.value == value, f"Expected {value}, got {dut.user_project.Row_Register_input.shift_reg.value}"

@cocotb.test()
async def test_input_shift(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0b00000000
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = dut.ui_in.value | 0b00000010 # RCLK = 1
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = dut.ui_in.value & 0b11111101 # RCLK = 0
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 10)
  
  # Set the input values, wait one clock cycle, and check the output
  dut._log.info("Start Shifting in a handful of values from 0 to 2 ** 40 - 1")
  
  for i in range(255):
    ran = random.randint(0, 2**40 - 1)
    await shift_in_value(dut, ran)
  
  dut._log.info("Shift in the Largest Value")
  await shift_in_value(dut, 2**40 - 1)

  dut._log.info("Shift in the Smallest Value")
  await shift_in_value(dut, 0)

  dut._log.info("Shift in the Middle Value")
  await shift_in_value(dut, 2**20)

  dut._log.info("Done")


@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0b00000000
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = dut.ui_in.value | 0b00000010 # RCLK = 1
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = dut.ui_in.value & 0b11111101 # RCLK = 0
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 10)
  
  # Set the input values, wait one clock cycle, and check the output
  dut._log.info("Create a pattern of values to shift in")

  pixels = 8
  bits_per_pixel = 5
  shift_register_bits = pixels * bits_per_pixel
  register_target_values = [0, 0, 0, 0, 0, 0, 0, 0]

  # Count up from 0 to 31
  for i in range(32):
    register_target_values.append(i)
  # Count down from 31 to 0
  for i in range(31, -1, -1):
    register_target_values.append(i)

  register_target_values.append(0)
  register_target_values.append(0)
  register_target_values.append(0)
  register_target_values.append(0)
  register_target_values.append(0)
  register_target_values.append(0)
  register_target_values.append(0)
  register_target_values.append(0)


  dut._log.info("Shift in the values")
  for i in range(0, len(register_target_values)-(pixels-1), 1):
    # Take Pixel Values from the register_target_values and express them as a single 40-bit value
    pixel_values = 0
    for j in range(pixels):
      pixel_value = register_target_values[i + j]
      pixel_values = pixel_values | (pixel_value << (j * bits_per_pixel))
    
    # Shift in the pixel values
    await shift_in_value(dut, pixel_values)

    # Wait for the output to be ready
    await ClockCycles(dut.clk, 256)

    pulse_watch = 0
    pulse_times = [0, 0, 0, 0, 0, 0, 0, 0]
    while (pulse_watch != 0b11111111):
      pulse_watch = pulse_watch | dut.uio_out.value
      if (dut.uio_out.value != 0):
        current_time = cocotb.utils.get_sim_time('ns')
        
        for j in range(8):
          if (dut.uio_out.value & (1 << j)):
            pulse_times[j] = current_time
      await ClockCycles(dut.clk, 1)


    pulse_watch = 0
    pulse_period = [0, 0, 0, 0, 0, 0, 0, 0]
    while (pulse_watch != 0b11111111):
      pulse_watch = pulse_watch | dut.uio_out.value
      if (dut.uio_out.value != 0):
        current_time = cocotb.utils.get_sim_time('ns')
        for j in range(8):
          if (dut.uio_out.value & (1 << j)):
            if pulse_period[j] == 0:
              period = current_time - pulse_times[j]
              pulse_period[j] = period
      await ClockCycles(dut.clk, 1)


  