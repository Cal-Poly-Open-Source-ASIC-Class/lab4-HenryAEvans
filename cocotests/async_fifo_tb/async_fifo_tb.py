import asyncio
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import (
    ClockCycles, RisingEdge, FallingEdge,
    Timer
)

async def write_fifo(dut):
    for curr_wr_val in range(20):
        dut.wr_data_i.value = curr_wr_val
        dut.wr_en_i.value = 1;
        await ClockCycles(dut.wr_clk_i, 1)
        if (dut.wr_full_o.value == 1):
            await FallingEdge(dut.wr_full_o)
            await ClockCycles(dut.wr_clk_i, 1)
    dut.wr_en_i.value = 0;

async def read_fifo(dut):
    for curr_rd_val in range(20):
        dut.rd_en_i.value = 1;
        if (dut.rd_empty_o.value == 1):
            await FallingEdge(dut.rd_empty_o)
        await ClockCycles(dut.rd_clk_i, 1)
        assert dut.rd_data_o.value == curr_rd_val
    dut.rd_en_i.value = 0;

@cocotb.test()
async def fifo_test(dut):
    
    cocotb.start_soon(Clock(dut.rd_clk_i, 13, units='ns').start())
    cocotb.start_soon(Clock(dut.wr_clk_i, 7, units='ns').start())

    # reset
    dut.areset_ni = 0
    await ClockCycles(dut.rd_clk_i, 5)
    dut.areset_ni = 1
    
    rd_coro = cocotb.start_soon(write_fifo(dut))
    wr_coro = cocotb.start_soon(read_fifo(dut))

    await rd_coro
    await wr_coro

