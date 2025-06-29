MODULE_NAME := experiments/memory_footprint
LAYOUTS := layout4kb
EXPERIMENT_DIR := $(MODULE_NAME)
EXPERIMENTS := $(EXPERIMENT_DIR)/$(LAYOUTS)
MEASUREMENTS := $(EXPERIMENTS)/repeat0/perf.out
LAYOUT_FILES := $(ROOT_DIR)/$(EXPERIMENT_DIR)/layouts/$(LAYOUTS).csv

EXTRA_ARGS_FOR_MOSALLOC := --analyze
NUM_OF_REPEATS := 1

$(EXPERIMENT_DIR): $(EXPERIMENTS)
	
$(EXPERIMENTS): $(MEASUREMENTS)

$(MEASUREMENTS): $(ROOT_DIR)/$(EXPERIMENT_DIR)/layouts/layout4kb.csv | experiments-prerequisites
	echo ========== [INFO] start producing: $@ ==========
	experiment_dir=$$(realpath -m $@/../..)
	$(bind_first_sibling) $(run_benchmark) --directory "$$experiment_dir" \
		--submit_command "$(measure_perf_events) $(RUN_MOSALLOC_TOOL) --library $(MOSALLOC_TOOL) -cpf $< $(EXTRA_ARGS_FOR_MOSALLOC)" -- \
		$(BENCHMARK1)

CREATE_MEMORY_FOOTPRINT_LAYOUTS := $(MODULE_NAME)/createLayouts.py
$(LAYOUT_FILES):
	ram_size_kb=$(shell grep MemTotal /proc/meminfo | cut -d ':' -f 2 | sed 's, ,,g' | sed 's,kB,,g')
	$(CREATE_MEMORY_FOOTPRINT_LAYOUTS) --mem_max_size_kb=$$ram_size_kb \
		--output=$(dir $@)/..

# undefine LAYOUTS to allow next makefiles to use the defaults LAYOUTS
undefine EXTRA_ARGS_FOR_MOSALLOC
undefine LAYOUTS
