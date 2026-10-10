class axi_apb_vsqr extends uvm_sequencer;

  `uvm_component_utils(axi_apb_vsqr)

  axi_sequencer     axi_sqr;
  apb_agent_config  apb_cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
