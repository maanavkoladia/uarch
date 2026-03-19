
PYTHON = python3.9

.PHONY: clean all gen_dry gen

all:
	echo "cd into be dirs to comiplie"

gen_dry:
	$(PYTHON) ./scripts/generateStructural.py --dry-run ./config/gen.conf.json

gen:
	$(PYTHON) ./scripts/generateStructural.py ./config/gen.conf.json

clean:
	@echo "Not yet written"
