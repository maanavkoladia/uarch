RR_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/RR/

# RR packages (must be compiled before modules)
RR_PKGS = \
	$(RR_PATH_INTERNAL)/pkg/RegisterRead_pkg.sv \

# RR source files
RR_SRC_FILES = \
	$(RR_PATH_INTERNAL)/AddressGen_Logic.sv \
	$(RR_PATH_INTERNAL)/AddyX_NeuralNet.sv \
	$(RR_PATH_INTERNAL)/RegFile.sv \
	$(RR_PATH_INTERNAL)/RegSB.sv \
	$(RR_PATH_INTERNAL)/RR.sv \

