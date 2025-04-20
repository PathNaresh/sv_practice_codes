// sequnece class - seqnce.sv file
class seqnce;
  randc logic [3:0] a;
  randc logic [3:0] b;
  
  logic [4:0] out;
  
  function void display(string name);
    $display("@time %0t [%0s] :: a : %0d b : %0d & out : %0d", $time, name, a, b, out);
  endfunction
endclass

// generator class - generator.sv file 
class generator;
  // sequence instance & creating memory for it
  seqnce seq = new();
  
  // mailbox instance
  mailbox mbx;
  
  // 'new' constructor - to get the mailbox from the top module
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction
  
  // 'run' task to randomize & put the generated sequence packet into the mailbox and print the packet
  task run();
    seq.randomize();
    mbx.put(seq);
    seq.display("GENERATOR");
  endtask
endclass

// driver class - driver.sv file
class driver;
  // sequnce instance
  seqnce seq;
  
  // mailbox instance
  mailbox mbx;
  
  // 'new' constructor - to get the mailbox from the top module
  function new(mailbox mbx);
    this.mbx  = mbx;
  endfunction
  
  // 'run' task to get the sequnce packet from the mailbox & perform the addition and print result
  task run();
    mbx.get(seq);
    seq.out = seq.a + seq.b;
    seq.display("DRIVER");
  endtask
endclass

// top module 
`include "seqnce.sv"
`include "generator.sv"
`include "driver.sv"

module top;
  
  // creating a mailbox
  mailbox mbx = new();
  
  // passing the mailbox to generator & driver using 'new' construct
  generator gen = new(mbx);
  driver    drv = new(mbx);
  
  // fork-join to run the generator & driver tasks parallely
  initial begin
    fork 
      gen.run();
      drv.run();
    join
  end
  
endmodule

// output - log
@time 0 [GENERATOR] :: a : 1 b : 5 & out : x
@time 0 [DRIVER] :: a : 1 b : 5 & out : 6
           V C S   S i m u l a t i o n   R e p o r t 
