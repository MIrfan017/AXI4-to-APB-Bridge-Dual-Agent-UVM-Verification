// Functional coverage (kept small - directed test).
class axi_coverage extends uvm_subscriber #(axi_seq_item);

  `uvm_component_utils(axi_coverage)

  protected axi_seq_item item;

  covergroup axi_cg;
    option.per_instance = 1;
    cp_dir  : coverpoint item.write {
      bins read  = {1'b0};
      bins write = {1'b1};
    }
    cp_addr : coverpoint item.addr {
      bins low  = {[32'h0000_0000 : 32'h0000_00FF]};
      bins mid  = {[32'h0000_0100 : 32'h0000_FFFF]};
      bins high = {[32'h0001_0000 : 32'hFFFF_FFFF]};
    }
    cp_data : coverpoint item.data {
      bins zero  = {32'h0000_0000};
      bins ones  = {32'hFFFF_FFFF};
      bins other = default;
    }
    cp_resp : coverpoint item.resp {
      bins okay   = {2'b00};
      bins others = {[2'b01 : 2'b11]};
    }
    x_dir_addr : cross cp_dir, cp_addr;
    x_dir_data : cross cp_dir, cp_data;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    axi_cg = new();
  endfunction

  function void write(axi_seq_item t);
    item = t;
    axi_cg.sample();
  endfunction

endclass


class apb_coverage extends uvm_subscriber #(apb_item);

  `uvm_component_utils(apb_coverage)

  protected apb_item item;

  covergroup apb_cg;
    option.per_instance = 1;
    cp_dir   : coverpoint item.write {
      bins read  = {1'b0};
      bins write = {1'b1};
    }
    cp_waits : coverpoint item.wait_cycles {
      bins none  = {0};
      bins one   = {1};
      bins few   = {[2:3]};
      bins many  = {[4:$]};
    }
    x_dir_waits : cross cp_dir, cp_waits;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_cg = new();
  endfunction

  function void write(apb_item t);
    item = t;
    apb_cg.sample();
  endfunction

endclass
