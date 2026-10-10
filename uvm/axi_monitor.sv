class axi_monitor extends uvm_monitor;

  `uvm_component_utils(axi_monitor)

  axi_agent_config                   cfg;
  axi_vif_t                          vif;
  uvm_analysis_port #(axi_seq_item)  ap;

  protected axi_seq_item aw_q[$];
  protected axi_seq_item w_q[$];
  protected axi_seq_item ar_q[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (cfg == null) `uvm_fatal("NOCFG", "axi_monitor: cfg not set by agent")
  endfunction

  task run_phase(uvm_phase phase);
    axi_seq_item t;
    axi_seq_item aw_t;
    axi_seq_item w_t;
    axi_seq_item ar_t;
    vif = cfg.vif;
    forever begin
      @(posedge vif.clk);
      if (vif.rst_n !== 1'b1) begin
        aw_q.delete();
        w_q.delete();
        ar_q.delete();
      end else begin
        // ---- AW handshake
        if (vif.aw_valid === 1'b1 && vif.aw_ready === 1'b1) begin
          t = axi_seq_item::type_id::create("aw_t");
          t.write = 1'b1;
          t.addr  = vif.aw_addr;
          t.id    = vif.aw_id;
          t.len   = vif.aw_len;
          t.size  = vif.aw_size;
          t.burst = vif.aw_burst;
          aw_q.push_back(t);
        end
        // ---- W handshake
        if (vif.w_valid === 1'b1 && vif.w_ready === 1'b1) begin
          t = axi_seq_item::type_id::create("w_t");
          t.data = vif.w_data;
          t.strb = vif.w_strb;
          t.last = vif.w_last;
          w_q.push_back(t);
        end
        // ---- B handshake -> write transaction complete
        if (vif.b_valid === 1'b1 && vif.b_ready === 1'b1) begin
          if (aw_q.size() == 0 || w_q.size() == 0) begin
            `uvm_error("AXI_MON", "B handshake without matching AW/W")
          end else begin
            aw_t = aw_q.pop_front();
            w_t  = w_q.pop_front();
            aw_t.data    = w_t.data;
            aw_t.strb    = w_t.strb;
            aw_t.resp    = vif.b_resp;
            aw_t.resp_id = vif.b_id;
            `uvm_info("AXI_MON", {"complete: ", aw_t.convert2string()}, UVM_HIGH)
            ap.write(aw_t);
          end
        end
        // ---- AR handshake
        if (vif.ar_valid === 1'b1 && vif.ar_ready === 1'b1) begin
          t = axi_seq_item::type_id::create("ar_t");
          t.write = 1'b0;
          t.addr  = vif.ar_addr;
          t.id    = vif.ar_id;
          t.len   = vif.ar_len;
          t.size  = vif.ar_size;
          t.burst = vif.ar_burst;
          ar_q.push_back(t);
        end
        // ---- R handshake -> read transaction complete
        if (vif.r_valid === 1'b1 && vif.r_ready === 1'b1) begin
          if (ar_q.size() == 0) begin
            `uvm_error("AXI_MON", "R handshake without matching AR")
          end else begin
            ar_t = ar_q.pop_front();
            ar_t.data    = vif.r_data;
            ar_t.resp    = vif.r_resp;
            ar_t.resp_id = vif.r_id;
            ar_t.last    = vif.r_last;
            `uvm_info("AXI_MON", {"complete: ", ar_t.convert2string()}, UVM_HIGH)
            ap.write(ar_t);
          end
        end
      end
    end
  endtask

endclass
