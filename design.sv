// Simple synchronous FIFO.
// It stores data on writes and gives data back on reads using the same clock.
module sync_fifo # (
  parameter FIFO_DEPTH = 8,
  parameter DATA_WIDTH = 8
) (
  input clk,
  input rst_n,
  input cs,
  input wr_en,
  input rd_en,
  input [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output full,
  output empty
);
  // Number of address bits needed to point inside the FIFO.
  localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);
  // Memory array (2D) that holds all FIFO values.
  logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

  // Write and read pointers - 1 bit wider than FIFO_DEPTH to tell full/empty conditions
  logic [FIFO_DEPTH_LOG:0] wr_ptr;
  logic [FIFO_DEPTH_LOG:0] rd_ptr;

  // Pointers FF - Reset clears both pointers so the FIFO starts empty.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
    end else begin
      // Move the write pointer only when write is allowed.
      if (cs && wr_en && !full) begin
        wr_ptr <= wr_ptr + 1'b1;
      end
      // Move the read pointer only when read is allowed.
      if (cs && rd_en && !empty) begin
        rd_ptr <= rd_ptr + 1'b1;
      end
    end
  end

  // Memory FF - Write data into memory and place read data on the output.
  always_ff @(posedge clk) begin
    if (cs && wr_en && !full) begin
      fifo_mem[wr_ptr[FIFO_DEPTH_LOG-1:0]] <= data_in;
    end
    if (cs && rd_en && !empty) begin
      data_out <= fifo_mem[rd_ptr[FIFO_DEPTH_LOG-1:0]];
    end
  end

  // Full means the pointers match in the lower bits, but not in the top bit.
  assign full = (wr_ptr[FIFO_DEPTH_LOG] != rd_ptr[FIFO_DEPTH_LOG]) 
                && 
                (wr_ptr[FIFO_DEPTH_LOG-1:0] == rd_ptr[FIFO_DEPTH_LOG-1:0]);
  // Empty means both pointers are exactly the same.
  assign empty = (wr_ptr == rd_ptr);
endmodule