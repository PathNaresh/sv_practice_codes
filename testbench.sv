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
