`timescale 1ns/1ps
module tb_sync_fifo;
  localparam FIFO_DEPTH = 8;
  localparam DATA_WIDTH = 8;
  logic clk = 1'b0; // otherwise the clock will be X at time 0 and clk will never toggle (remain X)
  logic rst_n;
  logic cs;
  logic wr_en;
  logic rd_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full;
  logic empty;

  sync_fifo #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .cs(cs),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  always #5 clk = ~clk;

  initial begin
    // GTKWave dump
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_sync_fifo);
    
    rst_n = 1'b0;
    cs = 1'b0;
    wr_en = 1'b0;
    rd_en = 1'b0;
    data_in = 8'h00;

    repeat(5) @(posedge clk); // holding the above values for 5 clock cycles

    rst_n = 1'b1;
    cs = 1'b1;
    
    for (int i = 0; i < FIFO_DEPTH; i++) begin
      wr_en <= 1'b1;
      data_in <= 8'hA0 + i;
      @(posedge clk);
    end
    wr_en <= 1'b0;

    repeat(2) @(posedge clk);

    for (int i = 0; i < FIFO_DEPTH; i++) begin
      rd_en <= 1'b1;
      @(posedge clk);
    end
    rd_en <= 1'b0;

    repeat(2) @(posedge clk);

    #100; $finish;
  end
endmodule