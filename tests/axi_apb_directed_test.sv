// Directed test: runs the directed virtual sequence once.
class axi_apb_directed_test extends axi_apb_base_test;

  `uvm_component_utils(axi_apb_directed_test)

  function new(string name = "axi_apb_directed_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_apb_directed_vseq vseq;
    phase.raise_objection(this, "directed test running");
    vseq = axi_apb_directed_vseq::type_id::create("vseq");
    vseq.start(env.vsqr);
    #200ns;                                   // let the last items reach the scoreboard
    phase.drop_objection(this, "directed test done");
  endtask

endclass
