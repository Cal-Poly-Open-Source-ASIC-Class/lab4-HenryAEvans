module grey_cntr #(
  parameter int WIDTH=32
  ) (
    input   logic             arst_ni,
    input   logic             clk_a_i,
    input   logic             clk_b_i,

    input   logic             incr_i,
    output  logic [WIDTH-1:0] data_a_o,
    /* verilator lint_off UNOPTFLAT */
    output  logic [WIDTH-1:0] data_b_o
    /* verilator lint_on UNOPTFLAT */

    );
    /* verilator lint_off UNOPTFLAT */
    logic [WIDTH-1:0] cntr_a;
    logic [WIDTH-1:0] cntr_a_next;
    logic [WIDTH-1:0] cntr_a_grey;
    logic [WIDTH-1:0] cntr_a_grey_next;
    /* verilator lint_on UNOPTFLAT */

    assign cntr_a_grey_next = cntr_a_next ^ (cntr_a_next >> 1);
    assign cntr_a_next = unsigned'(cntr_a + 1);
    assign data_a_o = cntr_a;

    assign cntr_a[WIDTH-1] = cntr_a_grey[WIDTH-1];
    genvar i;
    generate
    for (i = WIDTH-2; i >= 0; i--) begin: gen_grey_cntr_a
      assign cntr_a[i] = cntr_a[i+1] ^ cntr_a_grey[i];
    end
    endgenerate

    always_ff @(posedge clk_a_i, negedge arst_ni) begin
      if (!arst_ni) begin
        cntr_a_grey <= 0;
      end else if (incr_i) begin
        cntr_a_grey <= cntr_a_grey_next;
      end
    end

    logic [WIDTH-1:0] cntr_b, inter_reg;
    always_ff @(posedge clk_b_i, negedge arst_ni) begin
      if (!arst_ni) begin
        cntr_b <= 0;
        inter_reg <= 0;
      end else begin
        inter_reg <= cntr_a_grey;
        cntr_b <= inter_reg;
      end
    end

    //assign data_b_o = (data_b_o >> 1) ^ cntr_b;

    assign data_b_o[WIDTH-1] = cntr_b[WIDTH-1];
    generate
    for (i = WIDTH-2; i >= 0; i--) begin: gen_grey_cntr_b
      assign data_b_o[i] = cntr_b[i] ^ data_b_o[i+1];
    end
    endgenerate


endmodule
