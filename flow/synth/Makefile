DESIGN:=ripple_carry
WIDTH:=32

synth:
	@echo "DC Synthesis"
	@mkdir -p reports
	@mkdir -p mapped
	@mkdir -p unmapped
	dc_shell-xg-t -64bit -f scripts/synth.tcl | tee synth.out
	@mkdir -p ../../outputs
	@mkdir -p ../../outputs/$(WIDTH)/$(DESIGN)/
	@cp mapped/*.sdc ../../outputs/$(WIDTH)/$(DESIGN)/
	@cp mapped/*.vh ../../outputs/$(WIDTH)/$(DESIGN)/
	@cp -r reports ../../outputs/$(WIDTH)/$(DESIGN)/

clean:
	rm -rf  alib-52 WORK mapped unmapped reports analyzed synth.out
	rm -f default.svf
	rm -f command.log
	rm -f filenames*.log
