// Base virtual sequence: helpers shared by all virtual sequences.
class axi_apb_base_vseq extends uvm_sequence;

  `uvm_object_utils(axi_apb_base_vseq)
  `uvm_declare_p_sequencer(axi_apb_vsqr)

  int unsigned checks_done = 0;
  int unsigned checks_failed = 0;

  function new(string name = "axi_apb_base_vseq");
    super.new(name);
  endfunction

  // configure APB slave wait states (applies from the next APB transfer)
  function void set_apb_waits(int unsigned min_w, int unsigned max_w);
    p_sequencer.apb_cfg.min_wait = min_w;
    p_sequencer.apb_cfg.max_wait = max_w;
  endfunction

  task do_write(input bit [AXI_ADDR_W-1:0] addr,
                input bit [AXI_DATA_W-1:0] data,
                input bit [AXI_ID_W-1:0]   id    = '0,
                input int unsigned         delay = 0);
    axi_single_write_seq seq;
    seq = axi_single_write_seq::type_id::create("wr_seq");
    seq.addr       = addr;
    seq.data       = data;
    seq.id         = id;
    seq.resp_delay = delay;
    seq.start(p_sequencer.axi_sqr);
  endtask

  // read and compare against an explicit expected value (directed check)
  task do_read_check(input bit [AXI_ADDR_W-1:0] addr,
                     input bit [AXI_DATA_W-1:0] exp,
                     input bit [AXI_ID_W-1:0]   id    = '0,
                     input int unsigned         delay = 0);
    axi_single_read_seq seq;
    seq = axi_single_read_seq::type_id::create("rd_seq");
    seq.addr       = addr;
    seq.id         = id;
    seq.resp_delay = delay;
    seq.start(p_sequencer.axi_sqr);
    checks_done++;
    if (seq.rdata !== exp) begin
      checks_failed++;
      `uvm_error("VSEQ", $sformatf("read @0x%08h returned 0x%08h, expected 0x%08h", addr, seq.rdata, exp))
    end
    if (seq.resp !== 2'b00) begin
      checks_failed++;
      `uvm_error("VSEQ", $sformatf("read @0x%08h RRESP=%0b, expected OKAY", addr, seq.resp))
    end
  endtask

endclass
