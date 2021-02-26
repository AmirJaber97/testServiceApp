
class SleepDataService implements SyncableDataService {
  SleepDao _localProvider;
  SyncableProvider _remoteProvider;
  
  SleepDataService({
    SleepDao localProvider,
    SyncableProvider remoteProvider,
  })  : _localProvider = localProvider ?? locator<AppDatabase>().sleepDao,
        _remoteProvider = remoteProvider ?? FirestoreSleepDataProvider();

  ///Saves a list of Sleep objects to the local data provider
  Future saveSleepList(List<Sleep> sleeps) async {
    for (Sleep sleep in sleeps) {
      await saveSleep(sleep);
    }
  }

  ///Saves a Sleep object to the local data provider
  Future saveSleep(Sleep sleep) async {
    locator<ConnectedAppsDataService>().onChangeSleep(sleep);
    return _localProvider.insertSleep(sleep);
  }

  ///Fetches all Sleep objects
  Future<List<Sleep>> fetchAllSleep() async {
    return _localProvider.fetchAllSleep();
  }

  ///Fetches Sleep objects with `time` property value which is equal or greater
  ///to the `today` subtracted by 7 days time.
  Future<List<Sleep>> fetchLast7DaysSleep() async {
    DateTime day7DaysAgo = DateTime.now().subtract(Duration(days: 7));
    DateTime startOfTheDay7DaysAgo =
        DateTime(day7DaysAgo.year, day7DaysAgo.month, day7DaysAgo.day, 0);

    return _localProvider.fetchSleepInTimeRange(
      start: startOfTheDay7DaysAgo,
      end: DateTime.now(),
    );
  }

  ///Fetches Sleep objects of the current month, starting from 1st day of the month, inclusive
  Future<List<Sleep>> fetchCurrentMonthSleep() {
    DateTime now = DateTime.now();
    DateTime currentMonth1stDay =
        DateTime(now.year, now.month, 1, 0, 0, 0, 0, 0);
    return _localProvider.fetchSleepInTimeRange(
        start: currentMonth1stDay, end: now);
  }

  ///Fetches Sleep for today
  ///
  ///Nullable
  Future<Sleep> fetchTodaySleep() async {
    DateTime now = DateTime.now();
    DateTime todayStartDay = DateTime(now.year, now.month, now.day);
    List<Sleep> sleeps = await _localProvider.fetchSleepInTimeRange(
      start: todayStartDay,
      end: now,
    );
    if (sleeps == null || sleeps.length == 0)
      return null;
    else
      return sleeps.last;
  }

  ///Fetches Last available Sleep data
  ///
  ///Nullable
  Future<Sleep> fetchLastSleep() {
    return _localProvider.fetchLastSleep();
  }

  ///Fetches Last available Sleep data stream
  ///
  ///Nullable
  Stream<Sleep> fetchLastSleepStream() {
    return _localProvider.fetchLastSleepStream();
  }

  ///Pulls the data from the remote provider into the local provider
  @override
  Future pull() async {
    final data = await _remoteProvider.exportAll();
    _localProvider.importAll(data);
  }

  ///Pushes the data from the local data provider into the remote data provider
  @override
  Future push() async {
    _remoteProvider.importAll(await _localProvider.exportAll());
  }

}
