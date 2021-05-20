SHELL:=bash
WIDTH:=32

.PHONY: default synth pnr vcd parallel_synth parallel_pnr clean

default: compile synth pnr results

compile:
	@./pl2hdl $(WIDTH)

synth:
	@cd ../flow && for i in ./designs/sky130hs/*_$(WIDTH); \
	do make synth DESIGN_CONFIG=$$i/config.mk; done

parallel_synth:
	@cd ../flow && for i in ./designs/sky130hs/*_$(WIDTH); do make synth DESIGN_CONFIG=$$i/config.mk & done;
vcd:
	@cd tb && for i in ../AdderHDL/$(WIDTH)/*_*.v; do make default WIDTH=$(WIDTH) DESIGN=$$(basename $$i .v); done

pnr:
	@cd ../flow && for i in ./designs/sky130hs/*_$(WIDTH); do make finish DESIGN_CONFIG=$$i/config.mk; done

parallel_pnr:
	@cd ../flow && for i in ./designs/sky130hs/*_$(WIDTH); do make finish DESIGN_CONFIG=$$i/config.mk & done

results:
	@cd ../flow && ./util/genMetrics.py -p "sky130hs"
	@mkdir -p ./outputs/$(WIDTH)/objects
	@mkdir -p ./outputs/$(WIDTH)/logs
	@mkdir -p ./outputs/$(WIDTH)/reports
	@mkdir -p ./outputs/$(WIDTH)/results
	@cp ../flow/metrics.* ./outputs/$(WIDTH)/
	@rm ../flow/metrics.*
	@cp -r ../flow/objects/sky130hs/*_$(WIDTH) ./outputs/$(WIDTH)/objects/
	@cp -r ../flow/logs/sky130hs/*_$(WIDTH) ./outputs/$(WIDTH)/logs/
	@cp -r ../flow/reports/sky130hs/*_$(WIDTH) ./outputs/$(WIDTH)/reports/
	@cp -r ../flow/results/sky130hs/*_$(WIDTH) ./outputs/$(WIDTH)/results/
#	@./parse_results --width $(WIDTH) --tex_names "Designware" "Brent-Kung" "Han-Carlson" "Kogge-Stone" "Knowles" "Sklansky" "Ladner-Fischer" "Harris" "Ripple-carry" --eda_names "design_ware" "pparch_brentkung" "pparch_hancarlson" "pparch_koggestone" "pparch_knowles" "pparch_sklansky" "pparch_ladnerficsher" "pparch_harris" "ripple_carry"
#	@./parse_results --width $(WIDTH) --tex_names "Designware" "Ling\_BK" "Ling\_HC" "Ling\_KS" "Ling\_Kn" "Ling\_SK" "Ling\_LF" "Ling\_DH" "Ripple-carry" --eda_names "design_ware" "ling_brentkung" "ling_hancarlson" "ling_koggestone" "ling_knowles" "ling_sklansky" "ling_ladnerficsher" "ling_harris" "ripple_carry"

clean:
	@rm -rf AdderHDL
	@rm -rf ../flow/objects/sky130hs/*_$(WIDTH)
	@rm -rf ../flow/results/sky130hs/*_$(WIDTH)
	@rm -rf ../flow/reports/sky130hs/*_$(WIDTH)
	@rm -rf ../flow/designs/sky130hs/*_$(WIDTH)
	@rm -rf ../flow/logs/sky130hs/*_$(WIDTH)
	@rm -rf ../flow/designs/src/*_$(WIDTH)
	@rm -rf ../flow/metadata.json
	@rm -rf ../flow/metrics.*
	@rm -r ./outputs/$(WIDTH)
#	@rm -rf flow/synth_*
#	@rm -rf flow/pnr_*
