
// fifo - Design : design.sv file
module fifo #(parameter WIDTH = 8, DEPTH = 16)(

  input             clk,
  input             reset,
  input             write_en,
  input             read_en,
  input [WIDTH-1:0] data_in,

  output reg [WIDTH-1:0] data_out,
  output reg             empty,
  output reg             full

  );

  reg [WIDTH-1:0] mem [0:DEPTH-1];
  reg [$clog2(DEPTH):0] write_ptr, read_ptr, count;

  always @(posedge clk or posedge reset) begin

    if(reset) begin
      write_ptr <= 0;
      read_ptr  <= 0;
      count     <= 0;
      empty     <= 1;
      full      <= 0;
    end

    else begin
      if (write_en && !full) begin
        mem[write_ptr] <= data_in;
	write_ptr      <= write_ptr + 1;
	count          <= count + 1;
      end

      if (read_en && !empty) begin
        data_out <= mem[read_ptr];
	read_ptr <= read_ptr + 1;
	count    <= count - 1;
      end

      empty <= (count == 0);
      full  <= (count == DEPTH);
    end

  end
  
endmodule

// Testbench 
`include "design.sv"
`timescale 1ns/1ps

module fifo_tb;

  // parameters
  localparam WIDTH = 8;
  localparam DEPTH = 16;

  // signals
  reg clk;
  reg reset;
  reg write_en;
  reg read_en;
  reg [WIDTH-1:0] data_in;

  wire [WIDTH-1:0] data_out;
  wire empty;
  wire full;

  // DUT Instantiation
  fifo dut(.clk(clk),
           .reset(reset),
	   .write_en(write_en),
	   .read_en(read_en),
	   .data_in(data_in),
	   .data_out(data_out),
	   .empty(empty),
	   .full(full)
	   );

  // clock generation
  always #1 clk = ~clk;

  // Test logic

  initial begin

    //Initialize signals
    clk = 0;
    reset = 1;
    data_in = 0;
    write_en = 0;
    read_en = 0;

    //remove reset
    #2;
    reset = 0;

    // Write operation
    repeat(DEPTH) begin
      @(posedge clk);
      write_en = 1;
      data_in = $random % 256;
    end
    @(posedge clk);
    write_en = 0;

    #10;

    // Read operation
    repeat(DEPTH) begin
      @(posedge clk);
      read_en = 1;
    end
    @(posedge clk);
    read_en = 0;

    #10;

    $finish;

  end

  initial begin
    $monitor("Time : %0t, write_en : %b, read_en : %b, data_in : %d, data_out : %d, empty : %b, full : %b", $time, write_en, read_en, data_in, data_out, empty, full);
  end

  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars;
  end

endmodule
