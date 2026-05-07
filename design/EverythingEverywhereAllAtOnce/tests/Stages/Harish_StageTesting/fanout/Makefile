CHECK_LOG_FILE=check.log


.PHONY: check checkRaw clean

check:
	design_vision -no_gui -f run_fanout.tcl | tee $(CHECK_LOG_FILE)
	python3 ./scripts/parse_check_log.py $(CHECK_LOG_FILE) > $(CHECK_LOG_FILE).parsed

checkRaw:
	design_vision -no_gui -f run_fanout.tcl | tee $(CHECK_LOG_FILE)

parse: check.log
	python3 scripts/parse_violations.py check.log | tee parse.log

clean:
	rm -f *.log