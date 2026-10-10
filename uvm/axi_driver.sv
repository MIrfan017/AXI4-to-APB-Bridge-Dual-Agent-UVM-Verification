class axi_driver extends uvm_driver #(axi_seq_item);

  `uvm_component_utils(axi_driver)

  axi_agent_config cfg;
  axi_vif_t        vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (cfg == null) `uvm_fatal("NOCFG", "axi_driver: cfg not set by agent")
  endfunction

  task run_phase(uvm_phase phase);
    vif = cfg.vif;
    init_signals();
    wait (vif.rst_n === 1'b1);
    forever begin
      seq_item_port.get_next_item(req);
      if (req.write) drive_write(req);
      else           drive_read(req);
      seq_item_port.item_done();
    end
  endtask

  task init_signals();
    vif.aw_id = '0;  vif.aw_addr = '0;  vif.aw_len = '0;   vif.aw_size = '0;
    vif.aw_burst = '0; vif.aw_lock = 1'b0; vif.aw_cache = '0; vif.aw_prot = '0;
    vif.aw_qos = '0; vif.aw_region = '0; vif.aw_user = '0; vif.aw_valid = 1'b0;
    vif.w_data = '0; vif.w_strb = '0; vif.w_last = 1'b0; vif.w_user = '0; vif.w_valid = 1'b0;
    vif.b_ready = 1'b0;
    vif.ar_id = '0;  vif.ar_addr = '0;  vif.ar_len = '0;   vif.ar_size = '0;
    vif.ar_burst = '0; vif.ar_lock = 1'b0; vif.ar_cache = '0; vif.ar_prot = '0;
    vif.ar_qos = '0; vif.ar_region = '0; vif.ar_user = '0; vif.ar_valid = 1'b0;
    vif.r_ready = 1'b0;
  endtask

  // ---------------------------------------------------------------- write ----
  task drive_write(axi_seq_item t);
    fork
      begin : aw_channel
        @(negedge vif.clk);
        vif.aw_id    = t.id;
        vif.aw_addr  = t.addr;
        vif.aw_len   = t.len;
        vif.aw_size  = t.size;
        vif.aw_burst = t.burst;
        vif.aw_valid = 1'b1;
        while (vif.aw_ready !== 1'b1) @(negedge vif.clk);
        @(negedge vif.clk);
        vif.aw_valid = 1'b0;
      end
      begin : w_channel
        @(negedge vif.clk);
        vif.w_data   = t.data;
        vif.w_strb   = t.strb;
        vif.w_last   = 1'b1;
        vif.w_valid  = 1'b1;
        while (vif.w_ready !== 1'b1) @(negedge vif.clk);
        @(negedge vif.clk);
        vif.w_valid  = 1'b0;
      end
    join
    repeat (t.resp_delay) @(negedge vif.clk);
    vif.b_ready = 1'b1;
    while (vif.b_valid !== 1'b1) @(negedge vif.clk);
    t.resp    = vif.b_resp;      // captured before the handshake edge
    t.resp_id = vif.b_id;
    @(negedge vif.clk);
    vif.b_ready = 1'b0;
  endtask

  // ----------------------------------------------------------------- read ----
  task drive_read(axi_seq_item t);
    @(negedge vif.clk);
    vif.ar_id    = t.id;
    vif.ar_addr  = t.addr;
    vif.ar_len   = t.len;
    vif.ar_size  = t.size;
    vif.ar_burst = t.burst;
    vif.ar_valid = 1'b1;
    while (vif.ar_ready !== 1'b1) @(negedge vif.clk);
    @(negedge vif.clk);
    vif.ar_valid = 1'b0;
    repeat (t.resp_delay) @(negedge vif.clk);
    vif.r_ready = 1'b1;
    while (vif.r_valid !== 1'b1) @(negedge vif.clk);
    t.data    = vif.r_data;
    t.resp    = vif.r_resp;
    t.last    = vif.r_last;
    t.resp_id = vif.r_id;
    @(negedge vif.clk);
    vif.r_ready = 1'b0;
  endtask

endclass
