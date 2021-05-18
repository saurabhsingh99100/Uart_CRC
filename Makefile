#####################################################################

#	USER CUNFIGURATIONS
verilog_source = CRC_Rx_Engine.v
topmodule = CRC_Rx_Engine
cpp_driver = Sim.cpp
executable_name = Sim


#	ADVANCED CONFIGURATIONS
verilator_includes = -I obj_dir -I /usr/share/verilator/include -I /usr/share/verilator/include/vltstd
linking = -lncurses
verilated_path = /usr/share/verilator/include/verilated.cpp
gpp_flags =
#-pthread
verilator_flags = -Wall --relative-includes
########################################################################


default: clean build run

.PHONY: help
help:
	@echo "make clean	: to clean compiler generated files"
	@echo "make build	: to build the design"
	@echo "make run	: to run simulation"
	@echo "make		: to do all of the above (sequentially)"


.PHONY: build
build:
	@echo ">> Compiling verilog into cpp..."
	verilator $(verilator_flags) -cc $(verilog_source)

	@echo ">> Generating shared object..."
	cd obj_dir && make -f V$(topmodule).mk	

	@echo ">> Compiling driver cpp file with shared object..."
	g++ $(gpp_flags) $(cpp_driver) $(verilator_includes) $(verilated_path) obj_dir/V$(topmodule)__ALL.a $(linking) -o $(executable_name)


.PHONY: run
run: 
	@echo "================= SIMULATING ================="
	./$(executable_name)
	@echo "==============================================="


.PHONY: clean
clean:
	rm -f $(executable_name)
	rm -rf obj_dir
