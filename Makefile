SDK = $(shell xcrun --show-sdk-path)

getElement:
	swiftc -sdk $(SDK) getElement.swift
