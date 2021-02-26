
class BMHomeBloc extends Bloc<BMHomeEvent, BMHomeState> {
  ScaleService _scaleService;
  WatchService _watchService;
  GoalsDataService _goalsDataService;
  MeasurementUnitsService _measurementUnitsService;
  PersonalDetailsService _personalDetailsService;
  MeasurementsStatisticalDataService _measurementsStatisticalDataService;
  bool _isTempSupported = false;
  bool _isBloodSupported = false;
  TemperatureService _temperatureService;

  StreamSubscription _watchConnectionSubscription;

  Stream<StateData> get stateStream => _scaleService.stateController.stream;

  Stream<StatusData> get statusStream => _scaleService.statusController.stream;

  Stream<WeightData> get weightStream => _scaleService.weightController.stream;

  Stream<FatData> get fatStream => _scaleService.fatController.stream;

  Stream<FatData> get latestFatDataStream =>
      _measurementsStatisticalDataService.latestFatDataStream();

  Stream<ConnectionStateData> get connectionStateStream =>
      _scaleService.connectionController.stream;

  bool get isScaleConnected => ScaleService.isConnected;

  bool isWatchConnected = false;

  bool get isTempSupported => _isTempSupported;

  bool get isBloodSupported => _isBloodSupported;

  List<FatData> savedData = List<FatData>();

  ScaleDeviceData device;

  FatData latestFatData;

  MeasurementUnits unitsCache;

  Map<String, LineChartDataSet> dataSet = HashMap();
  Map<String, LineChartDataSet> weekSet = HashMap();
  Map<String, LineChartDataSet> monthSet = HashMap();
  Map<String, LineChartDataSet> yearSet = HashMap();

  BMHomeBloc({
    ScaleService scaleService,
    WatchService watchService,
    GoalsDataService goalsDataService,
    MeasurementUnitsService measurementUnitsService,
    PersonalDetailsService personalDetailsService,
    MeasurementsStatisticalDataService measurementsStatisticalDataService,
    TemperatureService temperatureService,
  }) : super(BMHomeInitialState()) {
    _scaleService = scaleService ?? locator<ScaleService>();
    _watchService = watchService ?? locator<WatchService>();
    _goalsDataService = goalsDataService ?? locator<GoalsDataService>();
    _measurementUnitsService =
        measurementUnitsService ?? locator<MeasurementUnitsService>();
    _personalDetailsService =
        personalDetailsService ?? locator<PersonalDetailsService>();
    _measurementsStatisticalDataService = measurementsStatisticalDataService ??
        locator<MeasurementsStatisticalDataService>();

    fatStream.listen((fatData) {
      this.latestFatData = fatData;
    });

    _initWatchPropertiesWith(_watchService.lastWatchDeviceData);
    _observeWatchConnectionState();
  }

  @override
  Stream<BMHomeState> mapEventToState(BMHomeEvent event) async* {
    PersonalDetails personalDetails;
    GoalsData goalsData;

    StreamGroup streamGroup = StreamGroup();

    if (event is BMHomeFetchDataEvent) {
      device = await _scaleService.getData();

      latestFatData =
          await _measurementsStatisticalDataService.fetchLastFatData();

      if (latestFatData == null) {
        await _measurementsStatisticalDataService.pull();
        latestFatData =
        await _measurementsStatisticalDataService.fetchLastFatData();
      }

      WatchDeviceData watch = await _initWatchProperties();

      yield BMHomeWatchPropertiesInitializedState(watch);

      if (device != null) {
        if (!ScaleService.isConnected) {
          await _scaleService.connectToDevice(
            ScaleConnectionData(
              device.macAddress,
              device.name,
              device.brandName,
            ),
          );
        }
      }

      streamGroup.add(_personalDetailsService.fetchData());
      streamGroup.add(_measurementUnitsService.fetchData());
      streamGroup.add(_goalsDataService.fetchData());
    } else if (event is BMHomeFetchWatchDataEvent) {
      WatchDeviceData watch = await _initWatchProperties();
      yield BMHomeWatchPropertiesInitializedState(watch);
    }

    streamGroup.close();

    if (unitsCache != null && personalDetails != null && goalsData != null) {
      yield BMHomeDataState(
          fatData: latestFatData,
          personalDetails: personalDetails,
          measurementUnits: unitsCache,
          goalsData: goalsData);
    }

    await for (final data in streamGroup.stream) {
      if (data is MeasurementUnits) {
        unitsCache = data;
      } else if (data is PersonalDetails) {
        personalDetails = data;
      } else if (data is GoalsData) {
        goalsData = data;
      }

      if (unitsCache != null && personalDetails != null && goalsData != null) {
        yield BMHomeDataState(
            fatData: latestFatData,
            personalDetails: personalDetails,
            measurementUnits: unitsCache,
            goalsData: goalsData);
      }
    }
  }

  _getWatchDeviceData() async {
    final device = await _watchService.getCurrentWatchDeviceData();
    if (device == null) return;
    _isBloodSupported = device.isBloodSupported;
    _isTempSupported = device.isTempSupported;
  }

  void _initWatchPropertiesWith(WatchDeviceData device) {
    isWatchConnected = device != null;
    _isTempSupported = device?.isTempSupported ?? false;
    _isBloodSupported = device?.isBloodSupported ?? false;
  }

  Future<WatchDeviceData> _initWatchProperties() async {
    WatchDeviceData device = await _watchService.getCurrentWatchDeviceData();
    _initWatchPropertiesWith(device);
    return device;
  }

  Future<void> _observeWatchConnectionState() async {
    await _watchConnectionSubscription?.cancel();
    _watchConnectionSubscription =
        _watchService.connectionObservable.listen((state) {
      if (state.state == WatchConnectionState.STATE_CONNECTED) {
        add(BMHomeFetchWatchDataEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _watchConnectionSubscription?.cancel();
    return super.close();
  }
}
