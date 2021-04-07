SHELL:=bash
WIDTH:=32

.PHONY: default synth pnr vcd parallel_synth parallel_pnr clean

default: compile synth vcd pnr

compile:
	@./pl2hdl $(WIDTH)

synth:
	@cd flow && for i in ../AdderHDL/$(WIDTH)/*_*.v; do make synth WIDTH=$(WIDTH) DESIGN=$$(basename $$i .v); done

parallel_synth:
	@cd flow && for i in ../AdderHDL/$(WIDTH)/*_*.v; do make synth WIDTH=$(WIDTH) DESIGN=$$(basename $$i .v) & done

vcd:
	@cd tb && for i in ../AdderHDL/$(WIDTH)/*_*.v; do make default WIDTH=$(WIDTH) DESIGN=$$(basename $$i .v); done

pnr:
	@cd flow && for i in ../AdderHDL/$(WIDTH)/*_*.v; do make pnr WIDTH=$(WIDTH) DESIGN=$$(basename $$i .v); done

parallel_pnr:
	@cd flow && for i in ../AdderHDL/$(WIDTH)/*_*.v; do make pnr WIDTH=$(WIDTH) DESIGN=$$(basename $$i .v) & done

results:
	@./parse_results --width $(WIDTH) --tex_names "Designware" "Brent-Kung" "Han-Carlson" "Kogge-Stone" "Knowles" "Sklansky" "Ladner-Fischer" "Harris" "Ripple-carry" --eda_names "design_ware" "pparch_brentkung" "pparch_hancarlson" "pparch_koggestone" "pparch_knowles" "pparch_sklansky" "pparch_ladnerficsher" "pparch_harris" "ripple_carry"
	@./parse_results --width $(WIDTH) --tex_names "Designware" "Ling\_BK" "Ling\_HC" "Ling\_KS" "Ling\_Kn" "Ling\_SK" "Ling\_LF" "Ling\_DH" "Ripple-carry" --eda_names "design_ware" "ling_brentkung" "ling_hancarlson" "ling_koggestone" "ling_knowles" "ling_sklansky" "ling_ladnerficsher" "ling_harris" "ripple_carry"

clean:
	@rm -rf flow/synth_*
	@rm -rf flow/pnr_*
