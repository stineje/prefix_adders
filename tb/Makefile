.PHONY: compile gen_vectors test

WIDTH:=32
DESIGN:=ripple_carry
NUM_VECTORS:=100

default: clean compile gen_vectors test move

compile:
	@sed -i '1d' tb.v
	@sed -i '1 i\`define WIDTH $(WIDTH)' tb.v 
	@cp ../AdderHDL/$(WIDTH)/$(DESIGN).v .

gen_vectors:
	@./gen_vectors.py -width $(WIDTH) -num_vectors $(NUM_VECTORS) > vectors.dat

test:
	export DESIGN=$(DESIGN); vsim -do tb.do -c

move:
	cp design.vcd ../outputs/$(WIDTH)/$(DESIGN)/

clean:
	git clean -xdf .
