puts "\[INFO\]: Creating Clocks"
create_clock [get_ports rd_clk_i] -name clk_r -period 7
set_propagated_clock clk_r
create_clock [get_ports wr_clk_i] -name clk_w -period 14
set_propagated_clock clk_w

set_clock_groups -asynchronous -group [get_clocks {clk_r clk_w}]

puts "\[INFO\]: Setting Max Delay"

set read_period     [get_property -object_type clock [get_clocks {clk_r}] period]
set write_period    [get_property -object_type clock [get_clocks {clk_w}] period]
set min_period      [expr {min(${read_period}, ${write_period})}]

set_max_delay -from [get_pins rd_ptr.cntr_a_grey*df*/CLK] -to [get_pins rd_ptr.inter_reg*df*/D] $min_period
set_max_delay -from [get_pins wr_ptr.cntr_a_grey*df*/CLK] -to [get_pins wr_ptr.inter_reg*df*/D] $min_period
