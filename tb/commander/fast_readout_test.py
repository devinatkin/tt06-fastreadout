import time

from ttboard.cocotb.dut import DUT
from ttboard.demoboard import DemoBoard
print("Running Fast Readout Test - with microcotb")

dut = DUT()
tt = DemoBoard.get()

tt.shuttle.tt_um_devinatkin_fastreadout.enable()


print("Running Tests on Fast Readout TT Project")

tt.clock_project_stop()
auto_clocking = tt.is_auto_clocking
assert ~auto_clocking, "Auto clocking should be disabled for this test"

def measure_high_low_cycles(tt, dut, cycles=10, signal_index=0):
    """
    Measure HIGH time and LOW time for a digital output signal.

    Returns:
        A list of dictionaries like:
        [
            {"high": 1, "low": 2945},
            ...
        ]
    """
    results = []

    prev_state = dut.uio_out[signal_index]

    # First, synchronise to an edge so we start on a clean boundary.
    while True:
        tt.clock_project_once()
        curr_state = dut.uio_out[signal_index]
        if curr_state != prev_state:
            prev_state = curr_state
            break

    # After the first detected edge, prev_state is now the new level.
    # Measure alternating segments and combine them into full cycles.
    pending_high = None
    pending_low = None

    while len(results) < cycles:
        level_being_measured = prev_state
        count = 0

        while True:
            tt.clock_project_once()
            count += 1
            curr_state = dut.uio_out[signal_index]

            if curr_state != level_being_measured:
                prev_state = curr_state
                break

        if level_being_measured == 1:
            pending_high = count
        else:
            pending_low = count

        if pending_high is not None and pending_low is not None:
            results.append({
                "high": pending_high,
                "low": pending_low,
            })
            pending_high = None
            pending_low = None

    return results

def print_timing_analysis(timings):
    """Print timing analysis for measured cycles."""
    for i, t in enumerate(timings):
        total = t["high"] + t["low"]
        duty = t["high"] / total if total else 0
        print(f"Cycle {i}: HIGH={t['high']} LOW={t['low']} TOTAL={total} DUTY={duty:.6f}")


def shift_40bit_value(tt, dut, value):
    # Shift in 40 bits, LSB first
    print(f"Shifting in Binary Value: {value:040b}")
    for k in range(40):
        bit_value = (value >> k) & 1
        
        # Put data bit on ui_in[0]
        tt.ui_in[0] = bit_value
        time.sleep_ms(1)
        # shift clock low
        tt.ui_in[1] = 1
        time.sleep_ms(1)
        # shift clock high
        tt.ui_in[1] = 0
        time.sleep_ms(1)


    # load pulse on ui_in[2]
    tt.ui_in[2] = 1
    time.sleep_ms(1)

    tt.ui_in[1] = 1
    time.sleep_ms(1)

    tt.ui_in[1] = 0
    time.sleep_ms(1)

    tt.ui_in[2] = 0
    time.sleep_ms(1)

# Validate which bits correspond to which signals on the output and measure the timing for each input bit pattern. 

for bit in range(40):
    value = 1 << bit
    shift_40bit_value(tt,dut,value)

    for signal_index in range(8):
        timings = measure_high_low_cycles(tt, dut, cycles=1, signal_index=signal_index)
        print(f"Signal {signal_index} Timing Analysis:")
        print_timing_analysis(timings)

# Measure 0 to 31 (all combinations of 5 bits for each of the 8 signals) and measure timing for each signal for each input pattern.
for value in range(0,32):
    print(f"Testing value: {value:05b}")
    for signal_index in range(8):
        shift_40bit_value(tt, dut, value << ((7 - signal_index) * 5))
        timings = measure_high_low_cycles(tt, dut, cycles=1, signal_index=signal_index)
        print(f"Shifted value {value:05b} for signal {signal_index} - Timing Analysis:")
        print_timing_analysis(timings)



for signal_index in range(8):
    for value in range(0,32):
        print(f"Testing value: {value:05b}")
        shift_40bit_value(tt, dut, value << ((7 - signal_index) * 5))
        timings = measure_high_low_cycles(tt, dut, cycles=1, signal_index=signal_index)
        print(f"Shifted value {value:05b} for signal {signal_index} - Timing Analysis:")
        print_timing_analysis(timings)

