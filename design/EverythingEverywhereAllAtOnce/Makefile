PYTHON = python
LOG_FILE = gen.log

.PHONY: clean all gen_dry gen

all:
	echo "cd into be dirs to comiplie"

gen_dry:
	$(PYTHON) ./scripts/generateStructural.py --dry-run ./config/gen.conf.json | tee $(LOG_FILE)

gen:
	$(PYTHON) ./scripts/generateStructural.py ./config/gen.conf.json | tee $(LOG_FILE)

clean:
	@echo "Not yet written"
