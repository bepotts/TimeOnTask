PROJECT ?= TimeOnTask.xcodeproj
SCHEME ?= TimeOnTask
CONFIGURATION ?= Debug
SWIFTLINT ?= swiftlint
SWIFTFORMAT ?= swiftformat
TEST_OUTPUT_DIR ?= TestReports
TEST_OUTPUT_FILE ?= $(TEST_OUTPUT_DIR)/$@.log

SHELL := /bin/bash

define RUN_AND_LOG
@mkdir -p "$(TEST_OUTPUT_DIR)"
@set -o pipefail; \
	$(1) 2>&1 | tee "$(TEST_OUTPUT_FILE)"
@echo "Test output saved to $(TEST_OUTPUT_FILE)"
endef

.PHONY: help build test test-unit test-ui lint format style

help:
	@echo "Available targets:"
	@echo "  make build      Build $(SCHEME) in $(CONFIGURATION)"
	@echo "  make test-unit  Run all unit tests"
	@echo "  make test-ui    Run all UI tests"
	@echo "  make test       Run all unit and UI tests"
	@echo "  make lint       Run SwiftLint"
	@echo "  make format     Run SwiftFormat"
	@echo "  make style      Run SwiftFormat, then SwiftLint"
	@echo ""
	@echo "Test output:"
	@echo "  Defaults to $(TEST_OUTPUT_DIR)/<target>.log"
	@echo "  Override with TEST_OUTPUT_FILE=path/to/output.log"

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration "$(CONFIGURATION)" build

test-unit:
	$(call RUN_AND_LOG,xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" test -only-testing:TimeOnTaskTests)

test-ui:
	$(call RUN_AND_LOG,xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" test -only-testing:TimeOnTaskUITests)

test:
	$(call RUN_AND_LOG,xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" test)

lint:
	$(SWIFTLINT) lint --config .swiftlint.yml --no-cache

format:
	$(SWIFTFORMAT) . --config .swiftformat --cache ignore

style:
	$(MAKE) format
	$(MAKE) lint
