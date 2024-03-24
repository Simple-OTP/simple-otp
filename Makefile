
# Use this as a sanity check before committing your code.
# Just run `make` and you're all good.

all: rust_app flutter_app

rust_app:
	cd rust && cargo test

flutter_app:
	cd flutter && flutter pub get
	cd flutter && flutter pub outdated
	cd flutter && dart run build_runner build
	cd flutter && dart fix --apply
	cd flutter && flutter analyze .
	cd flutter && flutter test
