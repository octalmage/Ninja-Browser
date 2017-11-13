SDK = $(shell xcrun --show-sdk-path)

test: 
	swiftc -sdk $(SDK) test.swift
