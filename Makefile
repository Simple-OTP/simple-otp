
# Use this as a sanity check before committing your code.
# Just run `make` and you're all good.

all: deps autogen lint tests

deps:
	flutter pub get
	flutter pub outdated
	flutter pub upgrade --major-versions

autogen:
	dart run build_runner build -d

lint:
	dart fix --apply
	flutter analyze .

tests:
	flutter test

apps: build/linux/x64/release/bundle/simple_otp

build/linux/x64/release/bundle/simple_otp: 
	flutter build linux

clean:
	flutter clean