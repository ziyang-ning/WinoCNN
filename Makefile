VCS = SW_VCS=2020.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 -kdb -lca -debug_access+all+reverse
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

all:	simv
	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = testbench/top_test1.sv
SIMFILES = $(wildcard \
	verilog/data_mem_top.sv \
	verilog/data_controller.sv \
	verilog/data_mem_controller_top.sv \
	verilog/main_controller.sv \
	verilog/newPE.sv \
	verilog/SRAM.v \
	verilog/weight_controller.sv \
	verilog/weight_mem_controller_top.sv \
	verilog/top.sv \
	verilog/CIM.sv \
	verilog/CIM_mem_top.sv \
	verilog/output_mem_top.sv \
)
SYNFILES = top.vg

#####
# Should be no need to modify after here
#####
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES) -o simv | tee simv.log

verdi:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(TESTBENCH) $(SIMFILES) -o verdi -R -gui | tee dve.log

.PHONY: verdi

diff2:
	cd test2 && \
	diff Y_HEX_modified.txt output_mem1_scan_out.txt 


diff1:
	cd test1 && \
	diff output_odd_modified.txt output_mem1_scan_out.txt && \
	diff output_even_modified.txt output_mem2_scan_out.txt

top.vg: verilog/top.sv syn/top.tcl
	dc_shell-t -f syn/top.tcl | tee syn/top.out

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv | tee syn_simv.log

syn:	syn_simv
	./syn_simv | tee syn_program.out | tee syn.log

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out sim verdi \
	syn_simv syn_simv.daidir syn_program.out \
	dve *.vpd *.vcd *.dump ucli.key \
        inter.fsdb novas* verdiLog	

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out *.ddc *.svf DVEfiles/

