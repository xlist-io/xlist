.PHONY: build help

all: build

build:
	dart run build_runner build

build-watch:
	dart run build_runner watch

gen:
	fluttergen

json-models:
	dart run json_model src=json_files

splash:
	dart run flutter_native_splash:create

icons:
	dart run flutter_launcher_icons

release-apk:
	flutter build apk \
		-v --no-tree-shake-icons \
		--release \
		--obfuscate --split-debug-info=./symbols

release-aab:
	flutter build appbundle \
		-v --no-tree-shake-icons \
		--release \
		--obfuscate --split-debug-info=./symbols

release-ios:
	flutter build ios -v --release

help:
	@echo "make build: run build_runner build"
	@echo "make build-watch: run build_runner watch"
	@echo "make gen: generate fluttergen"
	@echo "make json-models: generate json models"
	@echo "make splash: generate splash screen"
	@echo "make icons: generate app icons"
	@echo "make release-apk: build release apk"
	@echo "make release-aab: build release aab"
	@echo "make release-ios: build release ios"
