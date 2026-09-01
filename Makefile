PROJECT ?= TimeOnTask.xcodeproj
SCHEME ?= TimeOnTask
CONFIGURATION ?= Debug
SWIFTLINT ?= swiftlint
SWIFTFORMAT ?= swiftformat

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

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration "$(CONFIGURATION)" build

test-unit:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" test -only-testing:TimeOnTaskTests

test-ui:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" test -only-testing:TimeOnTaskUITests

test:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" test

lint:
	$(SWIFTLINT) lint --config .swiftlint.yml --no-cache

format:
	$(SWIFTFORMAT) . --config .swiftformat --cache ignore

style:
	$(MAKE) format
	$(MAKE) lint
