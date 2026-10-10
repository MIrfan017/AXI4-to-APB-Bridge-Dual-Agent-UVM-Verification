class apb_slave_driver extends uvm_component;

  `uvm_component_utils(apb_slave_driver)

  apb_agent_config cfg;
  apb_vif_t        vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (cfg == null) `uvm_fatal("NOCFG", "apb_slave_driver: cfg not set by agent")
  endfunction

  // number of wait cycles for the next transfer (config may change at run time)
  function int unsigned pick_wait();
    if (cfg.max_wait <= cfg.min_wait) return cfg.min_wait;
    return $urandom_range(cfg.max_wait, cfg.min_wait);
  endfunction

  task run_phase(uvm_phase phase);
    bit          in_txn;
    int unsigned wcnt;
    int unsigned target;

    vif    = cfg.vif;
    in_txn = 1'b0;
    wcnt   = 0;
    target = 0;

    vif.pready  = 1'b0;
    vif.prdata  = '0;
    vif.pslverr = 1'b0;
    wait (vif.rst_n === 1'b1);

    forever begin
      @(negedge vif.clk);
      if (vif.psel === 1'b1 && vif.penable === 1'b1) begin
        if (!in_txn) begin           // first cycle of a new transfer
          in_txn = 1'b1;
          wcnt   = 0;
          target = pick_wait();
        end
        if (wcnt >= target) begin    // complete the transfer at the next posedge
          vif.pready = 1'b1;
          if (vif.pwrite === 1'b1) begin
            cfg.mem[vif.paddr] = vif.pwdata;
          end else begin
            if (cfg.mem.exists(vif.paddr)) vif.prdata = cfg.mem[vif.paddr];
            else                           vif.prdata = cfg.default_rdata;
          end
          in_txn = 1'b0;
        end else begin
          vif.pready = 1'b0;
          wcnt++;
        end
      end else begin
        vif.pready = 1'b0;
        in_txn     = 1'b0;
        wcnt       = 0;
      end
    end
  endtask

endclass
