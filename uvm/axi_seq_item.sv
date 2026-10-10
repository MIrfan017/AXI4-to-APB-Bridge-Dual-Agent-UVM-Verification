// AXI transaction (one single-beat read or write)
class axi_seq_item extends uvm_sequence_item;

  rand bit                         write;       // 1 = write, 0 = read
  rand bit [AXI_ADDR_W-1:0]        addr;
  rand bit [AXI_DATA_W-1:0]        data;        // write: data to send / read: data received
  rand bit [AXI_DATA_W/8-1:0]      strb;
  rand bit [AXI_ID_W-1:0]          id;
  rand int unsigned                resp_delay;  // cycles to wait before BREADY / RREADY

  // fixed for this bridge (single beat, 32-bit, INCR)
  bit [7:0]                        len   = 8'd0;
  bit [2:0]                        size  = 3'd2;
  bit [1:0]                        burst = 2'b01;

  // filled in by driver / monitor
  bit [1:0]                        resp;
  bit [AXI_ID_W-1:0]               resp_id;
  bit                              last;

  constraint c_defaults {
    strb       == '1;
    resp_delay inside {[0:8]};
  }

  `uvm_object_utils(axi_seq_item)

  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("%s addr=0x%08h data=0x%08h id=0x%0h resp=%0b resp_id=0x%0h last=%0b",
                     write ? "WR" : "RD", addr, data, id, resp, resp_id, last);
  endfunction

endclass
