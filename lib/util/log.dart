import 'package:logger/logger.dart';

Logger get logger => Log.instance;

class Log extends Logger {
  Log._()
      : super(
            printer: PrettyPrinter(
                dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart));
  static final instance = Log._();
}
