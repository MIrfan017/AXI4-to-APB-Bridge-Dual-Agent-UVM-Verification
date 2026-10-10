class axi_agent_config extends uvm_object;

  axi_vif_t                vif;
  uvm_active_passive_enum  is_active = UVM_ACTIVE;

  `uvm_object_utils(axi_agent_config)

  function new(string name = "axi_agent_config");
    super.new(name);
  endfunction

endclass
