module async_fifo #(
  parameter int DEPTH=8,
  parameter int WIDTH=32
  ) (
    input   logic               areset_ni,

    // Write Port
    input   logic               wr_clk_i,
    input   logic               wr_en_i,
    input   logic [WIDTH-1:0]   wr_data_i,
    output  logic               wr_full_o,

    // Read Port
    input   logic               rd_clk_i,
    input   logic               rd_en_i,
    output  logic [WIDTH-1:0]   rd_data_o,
    output  logic               rd_empty_o
    );

    localparam int CntrWidth = $clog2(DEPTH) + 1;

    logic [WIDTH-1:0] fifo_mem [DEPTH];

    logic [CntrWidth-1:0] wr_ptr_wr, wr_ptr_rd;

    grey_cntr #(.WIDTH(CntrWidth)) wr_ptr (
      .arst_ni(areset_ni),
      .clk_a_i(wr_clk_i),
      .clk_b_i(rd_clk_i),
      .incr_i(wr_en_i && !wr_full_o),
      .data_a_o(wr_ptr_wr),
      .data_b_o(wr_ptr_rd)
      );

    logic [CntrWidth-1:0] rd_ptr_rd, rd_ptr_wr;

    grey_cntr #(.WIDTH(CntrWidth)) rd_ptr (
      .arst_ni(areset_ni),
      .clk_a_i(rd_clk_i),
      .clk_b_i(wr_clk_i),
      .incr_i(rd_en_i && !rd_empty_o),
      .data_a_o(rd_ptr_rd),
      .data_b_o(rd_ptr_wr)
      );

    assign rd_empty_o = wr_ptr_rd == rd_ptr_rd;
    assign wr_full_o = wr_ptr_wr == (rd_ptr_wr ^ (1 << CntrWidth-1));

    always_ff @(posedge wr_clk_i) begin
      if (wr_en_i && !wr_full_o) begin
        fifo_mem[wr_ptr_wr[CntrWidth-2:0]] <= wr_data_i;
      end
    end

    assign rd_data_o = fifo_mem[rd_ptr_rd[CntrWidth-2:0]];

endmodule
