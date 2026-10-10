TEST      = axi_apb_directed_test
#axi_apb_base_test
SEED      = 1
VERBOSITY = UVM_MEDIUM
WAVE      = 1
# UVM global timeout (simulation time units)
TIME_OUT  = 100000000

SIM_ARGS  = +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) \
            +UVM_TIMEOUT=$(TIME_OUT) +ntb_random_seed=$(SEED)
ifeq ($(WAVE),1)
SIM_ARGS += +WAVE
endif

compile:
	mkdir -p ./out
	vcs -sverilog -f build.flist -timescale=1ns/1ps -ntb_opts uvm-1.2 -cm line+cond+tgl+assert -LDFLAGS -Wl,--no-as-needed -full64 -debug_all +vcs+lic+wait -l compile.log
	cd ./out && rm -rf build_$(TEST)
	cd ./out && mkdir build_$(TEST)
	mv csrc simv.daidir simv.vdb simv vc_hdrs.h compile.log ./out/build_$(TEST)

# for simulation
sim:
	cd ./out/build_$(TEST) && ./simv -cm line+cond+tgl+assert -cm_name $(TEST) $(SIM_ARGS) > log_build_$(TEST).log
	@echo "---------------- result ($(TEST)) ----------------"
	@grep -E "TEST PASSED|TEST FAILED|UVM_ERROR :|UVM_FATAL :" ./out/build_$(TEST)/log_build_$(TEST).log || true
	@echo "Log: ./out/build_$(TEST)/log_build_$(TEST).log"

# To view waveform, run `make gui` command in the terminal
gui:
	cd ./out/build_$(TEST) && dve -full64 -vpd waveform.vpd

# More advance make targets
cov:
	urg -report ./out/coverage_report -dir ./out/build_*/*.vdb

clean:
	rm -rf ./out/build_$(TEST)

allclean:
	rm -rf ./out/*

dve_cov:
	dve -covdir ./out/build_$(TEST)/simv.vdb

# ---------------------------------------------------------------------------
# Run a single test (compile + sim) :  make run TEST=axi_apb_directed_test
# ---------------------------------------------------------------------------
run: compile sim

# ---------------------------------------------------------------------------
# Separate target for each test
# ---------------------------------------------------------------------------
directed:
	$(MAKE) run TEST=axi_apb_directed_test

# ---------------------------------------------------------------------------
# Run all tests, then merge coverage of all of them
# ---------------------------------------------------------------------------
TESTS = axi_apb_directed_test

all_tests:
	for t in $(TESTS); do $(MAKE) run TEST=$$t || exit 1; done
	$(MAKE) cov

.PHONY: compile sim gui cov clean allclean dve_cov run directed all_tests
