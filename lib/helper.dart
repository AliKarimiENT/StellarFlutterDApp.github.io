import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stl;

DateTime getLocalDateTime(String time) {
    var dateTime = time;
    var indexOfT = dateTime.indexOf('T');
    var indexOfZ = dateTime.indexOf('Z');
    var date = dateTime.substring(0, indexOfT);
    var UTCTime = dateTime.substring(indexOfT + 1, indexOfZ);
    var dateItems = date.split('-');
    var timeItems = UTCTime.split(':');
    int year = int.tryParse(dateItems[0])!;
    int month = int.tryParse(dateItems[1])!;
    int day = int.tryParse(dateItems[2])!;
    int hour = int.tryParse(timeItems[0])!;
    int minute = int.tryParse(timeItems[1])!;
    int second = int.tryParse(timeItems[2])!;
    final _utcTime = DateTime.utc(year, month, day, hour, minute, second);
    final _localTime = _utcTime.toLocal();
    return _localTime;
  }