VCS = SW_VCS=2020.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 -kdb -lca -debug_access+all+reverse

all:	simv
	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = testbench/CIM_mem_top_test.sv
SIMFILES = $(wildcard \
	verilog/output_memory.sv \
	verilog/SRAM.v \
	verilog/output_mem_top.sv \
	verilog/CIM.sv \
	verilog/CIM_mem_top.sv \
)


#####
# Should be no need to modify after here
#####
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES) -o simv | tee simv.log

verdi:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(TESTBENCH) $(SIMFILES) -o verdi -R -gui | tee dve.log

.PHONY: verdi

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out sim verdi \
	syn_simv syn_simv.daidir syn_program.out \
	dve *.vpd *.vcd *.dump ucli.key \
        inter.fsdb novas* verdiLog	

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out *.ddc *.svf DVEfiles/

