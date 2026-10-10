class axi_apb_env_config extends uvm_object;

  axi_agent_config  axi_cfg;
  apb_agent_config  apb_cfg;

  bit has_scoreboard = 1;
  bit has_coverage   = 1;

  `uvm_object_utils(axi_apb_env_config)

  function new(string name = "axi_apb_env_config");
    super.new(name);
  endfunction

endclass
