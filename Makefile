
# Use this as a sanity check before committing your code.
# Just run `make` and you're all good.

all: flutter_app


flutter_app:
	flutter pub get
	flutter pub outdated
	dart run build_runner build -d
	dart fix --apply
	flutter analyze .
	flutter test
