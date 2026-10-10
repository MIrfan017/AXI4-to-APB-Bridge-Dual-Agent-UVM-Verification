class axi_agent extends uvm_agent;

  `uvm_component_utils(axi_agent)

  axi_agent_config cfg;      // set by env right after creation
  axi_sequencer    sqr;
  axi_driver       drv;
  axi_monitor      mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (cfg == null) `uvm_fatal("NOCFG", "axi_agent: cfg not set by env")
    mon     = axi_monitor::type_id::create("mon", this);
    mon.cfg = cfg;
    if (cfg.is_active == UVM_ACTIVE) begin
      sqr     = axi_sequencer::type_id::create("sqr", this);
      drv     = axi_driver::type_id::create("drv", this);
      drv.cfg = cfg;
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass
