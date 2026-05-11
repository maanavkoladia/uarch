REPORT_HTML := REPORT.html
CORE := design/EverythingEverywhereAllAtOnce/rtl/core

ALL_INPUTS := \
  report_front.md \
  $(CORE)/Fetch/REPORT_FETCH.md \
  chapters/decode.md \
  chapters/rr.md \
  $(CORE)/DC/REPORT_DC.md \
  $(CORE)/MEM/REPORT_MEM.md \
  $(CORE)/EXE/REPORT_EXE.md \
  $(CORE)/WB/REPORT_WB.md \
  chapters/icache.md \
  chapters/dcache.md \
  chapters/bus_arb.md \
  chapters/main_mem.md \
  chapters/ddr5.md \
  chapters/dma.md \
  report_back.md

report: $(REPORT_HTML)

$(REPORT_HTML): $(ALL_INPUTS)
	pandoc \
	  --toc --number-sections \
	  --shift-heading-level-by=1 \
	  --standalone \
	  --self-contained \
	  --metadata title="EverythingEverywhereAllAtOnce — CPU Final Design Report" \
	  --resource-path=.:figures \
	  -o $@ \
	  $(ALL_INPUTS)

clean:
	rm -f $(REPORT_HTML)

.PHONY: report clean
