class apb_agent_config extends uvm_object;

  apb_vif_t                vif;
  uvm_active_passive_enum  is_active = UVM_ACTIVE;

  int unsigned             min_wait = 0;
  int unsigned             max_wait = 0;

  // slave memory (shared with tests so they can preload data)
  bit [APB_DATA_W-1:0]     mem [bit [APB_ADDR_W-1:0]];
  bit [APB_DATA_W-1:0]     default_rdata = '0;   // returned for never-written addresses

  `uvm_object_utils(apb_agent_config)

  function new(string name = "apb_agent_config");
    super.new(name);
  endfunction

  function void preload(bit [APB_ADDR_W-1:0] addr, bit [APB_DATA_W-1:0] data);
    mem[addr] = data;
  endfunction

endclass
