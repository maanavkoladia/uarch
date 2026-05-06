check:
	design_vision -no_gui -f run_fanout.tcl | tee check.log

parse: check.log
	python3 scripts/parse_violations.py check.log | tee parse.log

clean:
	rm -f *.log
