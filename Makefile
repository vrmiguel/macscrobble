SWIFT_SOURCES = macscrobble.swift
SWIFT_OUTPUT = macscrobble

all: build

build:
	swiftc -framework Foundation -framework MediaPlayer $(SWIFT_SOURCES) -o $(SWIFT_OUTPUT)

auth:
	python3 auth.py

.PHONY: all build auth