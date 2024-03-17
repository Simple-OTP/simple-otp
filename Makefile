
all: rust_app flutter_app

rust_app:
	cd rust && cargo test

flutter_app:
	cd flutter && flutter pub get
	cd flutter && flutter pub outdated
	cd flutter && dart fix --apply
	cd flutter && flutter analyze .
	cd flutter && flutter test
