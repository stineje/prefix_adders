DESIGN:=ripple_carry
WIDTH:=32
WIDTH_minus:=$(shell expr $(WIDTH) - 1)

.PHONY: parallel_synth synth pnr default change clean all purge

default: clean synth pnr

all: default

synth:
	@mkdir -p synth/hdl
	@rm -rf synth_$(WIDTH)_$(DESIGN)
	@cp -r synth synth_$(WIDTH)_$(DESIGN)
	@cp ../AdderHDL/$(WIDTH)/$(DESIGN).v synth_$(WIDTH)_$(DESIGN)/hdl/

pnr:
	@rm -rf pnr_$(WIDTH)_$(DESIGN)
	@cp -r pnr pnr_$(WIDTH)_$(DESIGN)
	@cd pnr_$(WIDTH)_$(DESIGN) && make clean all DESIGN=$(DESIGN) WIDTH=$(WIDTH)

clean:
	@cd synth && make clean
	@cd pnr && make clean && ./clean_me.csh

purge: clean
	@rm -rf synth_*
	@rm -rf pnr_*
