// APB agent: monitor always, reactive slave BFM when active
class apb_agent extends uvm_agent;

  `uvm_component_utils(apb_agent)

  apb_agent_config   cfg;      // set by env right after creation
  apb_slave_driver   drv;
  apb_monitor        mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (cfg == null) `uvm_fatal("NOCFG", "apb_agent: cfg not set by env")
    mon     = apb_monitor::type_id::create("mon", this);
    mon.cfg = cfg;
    if (cfg.is_active == UVM_ACTIVE) begin
      drv     = apb_slave_driver::type_id::create("drv", this);
      drv.cfg = cfg;
    end
  endfunction

endclass
