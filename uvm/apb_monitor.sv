// APB monitor: one item per completed transfer (PSEL & PENABLE & PREADY at posedge)
class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  apb_agent_config                  cfg;
  apb_vif_t                         vif;
  uvm_analysis_port #(apb_item)     ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (cfg == null) `uvm_fatal("NOCFG", "apb_monitor: cfg not set by agent")
  endfunction

  task run_phase(uvm_phase phase);
    apb_item     t;
    int unsigned wcnt;
    vif  = cfg.vif;
    wcnt = 0;
    forever begin
      @(posedge vif.clk);
      if (vif.rst_n !== 1'b1) begin
        wcnt = 0;
      end else if (vif.psel === 1'b1 && vif.penable === 1'b1) begin
        if (vif.pready === 1'b1) begin
          t = apb_item::type_id::create("apb_t");
          t.write       = vif.pwrite;
          t.addr        = vif.paddr;
          t.data        = (vif.pwrite === 1'b1) ? vif.pwdata : vif.prdata;
          t.slverr      = vif.pslverr;
          t.wait_cycles = wcnt;
          `uvm_info("APB_MON", {"transfer: ", t.convert2string()}, UVM_HIGH)
          ap.write(t);
          wcnt = 0;
        end else begin
          wcnt++;
        end
      end else begin
        wcnt = 0;
      end
    end
  endtask

endclass
