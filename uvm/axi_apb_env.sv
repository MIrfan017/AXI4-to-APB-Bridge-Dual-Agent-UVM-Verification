class axi_apb_env extends uvm_env;

  `uvm_component_utils(axi_apb_env)

  axi_apb_env_config   cfg;

  axi_agent            axi_agt;
  apb_agent            apb_agt;
  axi_apb_scoreboard   sb;
  axi_coverage         axi_cov;
  apb_coverage         apb_cov;
  axi_apb_vsqr         vsqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi_apb_env_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("NOCFG", "axi_apb_env_config not found in config_db")

    axi_agt     = axi_agent::type_id::create("axi_agt", this);
    axi_agt.cfg = cfg.axi_cfg;
    apb_agt     = apb_agent::type_id::create("apb_agt", this);
    apb_agt.cfg = cfg.apb_cfg;

    if (cfg.has_scoreboard)
      sb = axi_apb_scoreboard::type_id::create("sb", this);
    if (cfg.has_coverage) begin
      axi_cov = axi_coverage::type_id::create("axi_cov", this);
      apb_cov = apb_coverage::type_id::create("apb_cov", this);
    end
    vsqr = axi_apb_vsqr::type_id::create("vsqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.has_scoreboard) begin
      axi_agt.mon.ap.connect(sb.axi_export);
      apb_agt.mon.ap.connect(sb.apb_export);
    end
    if (cfg.has_coverage) begin
      axi_agt.mon.ap.connect(axi_cov.analysis_export);
      apb_agt.mon.ap.connect(apb_cov.analysis_export);
    end
    vsqr.axi_sqr = axi_agt.sqr;
    vsqr.apb_cfg = cfg.apb_cfg;
  endfunction

endclass
