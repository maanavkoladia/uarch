check:
	design_vision -no_gui -f run_fanout.tcl | tee check.log

clean:
	rm -f *.log*
	rm -rf WORK/
	rm -f *.svf

parse: check
	python3 scripts/parse_jacob.py check.log | tee parse.log
