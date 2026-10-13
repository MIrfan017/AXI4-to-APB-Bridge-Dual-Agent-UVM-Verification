// Base test: gets the virtual interfaces from config_db, builds the configs and the env
class axi_apb_base_test extends uvm_test;

  `uvm_component_utils(axi_apb_base_test)

  axi_apb_env         env;
  axi_apb_env_config  env_cfg;

  function new(string name = "axi_apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    axi_vif_t axi_vif;
    apb_vif_t apb_vif;
    super.build_phase(phase);

    if (!uvm_config_db#(axi_vif_t)::get(this, "", "axi_vif", axi_vif))
      `uvm_fatal("NOVIF", "axi_vif not found in config_db (set it in tb_top)")
    if (!uvm_config_db#(apb_vif_t)::get(this, "", "apb_vif", apb_vif))
      `uvm_fatal("NOVIF", "apb_vif not found in config_db (set it in tb_top)")

    env_cfg         = axi_apb_env_config::type_id::create("env_cfg");
    env_cfg.axi_cfg = axi_agent_config::type_id::create("axi_cfg");
    env_cfg.apb_cfg = apb_agent_config::type_id::create("apb_cfg");
    env_cfg.axi_cfg.vif = axi_vif;
    env_cfg.apb_cfg.vif = apb_vif;

    uvm_config_db#(axi_apb_env_config)::set(this, "env", "cfg", env_cfg);
    env = axi_apb_env::type_id::create("env", this);

  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_root::get().print_topology();
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) == 0)
      `uvm_info("RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction

endclass
