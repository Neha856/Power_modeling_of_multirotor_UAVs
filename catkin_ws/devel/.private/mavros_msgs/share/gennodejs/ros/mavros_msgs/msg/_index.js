
"use strict";

let RCOut = require('./RCOut.js');
let RCIn = require('./RCIn.js');
let HilSensor = require('./HilSensor.js');
let WheelOdomStamped = require('./WheelOdomStamped.js');
let Thrust = require('./Thrust.js');
let RTKBaseline = require('./RTKBaseline.js');
let CamIMUStamp = require('./CamIMUStamp.js');
let GlobalPositionTarget = require('./GlobalPositionTarget.js');
let ActuatorControl = require('./ActuatorControl.js');
let GPSRTK = require('./GPSRTK.js');
let LogData = require('./LogData.js');
let AttitudeTarget = require('./AttitudeTarget.js');
let VehicleInfo = require('./VehicleInfo.js');
let Mavlink = require('./Mavlink.js');
let PlayTuneV2 = require('./PlayTuneV2.js');
let CommandCode = require('./CommandCode.js');
let ParamValue = require('./ParamValue.js');
let CompanionProcessStatus = require('./CompanionProcessStatus.js');
let LogEntry = require('./LogEntry.js');
let HomePosition = require('./HomePosition.js');
let OverrideRCIn = require('./OverrideRCIn.js');
let PositionTarget = require('./PositionTarget.js');
let HilGPS = require('./HilGPS.js');
let StatusText = require('./StatusText.js');
let ESCInfoItem = require('./ESCInfoItem.js');
let CameraImageCaptured = require('./CameraImageCaptured.js');
let ManualControl = require('./ManualControl.js');
let WaypointList = require('./WaypointList.js');
let MagnetometerReporter = require('./MagnetometerReporter.js');
let Waypoint = require('./Waypoint.js');
let TerrainReport = require('./TerrainReport.js');
let ESCStatus = require('./ESCStatus.js');
let ESCInfo = require('./ESCInfo.js');
let Vibration = require('./Vibration.js');
let FileEntry = require('./FileEntry.js');
let CellularStatus = require('./CellularStatus.js');
let VFR_HUD = require('./VFR_HUD.js');
let BatteryStatus = require('./BatteryStatus.js');
let ADSBVehicle = require('./ADSBVehicle.js');
let GPSINPUT = require('./GPSINPUT.js');
let EstimatorStatus = require('./EstimatorStatus.js');
let OpticalFlowRad = require('./OpticalFlowRad.js');
let Tunnel = require('./Tunnel.js');
let ESCTelemetry = require('./ESCTelemetry.js');
let ESCStatusItem = require('./ESCStatusItem.js');
let RTCM = require('./RTCM.js');
let NavControllerOutput = require('./NavControllerOutput.js');
let ExtendedState = require('./ExtendedState.js');
let DebugValue = require('./DebugValue.js');
let WaypointReached = require('./WaypointReached.js');
let HilControls = require('./HilControls.js');
let Param = require('./Param.js');
let SysStatus = require('./SysStatus.js');
let State = require('./State.js');
let Altitude = require('./Altitude.js');
let GPSRAW = require('./GPSRAW.js');
let OnboardComputerStatus = require('./OnboardComputerStatus.js');
let ESCTelemetryItem = require('./ESCTelemetryItem.js');
let TimesyncStatus = require('./TimesyncStatus.js');
let HilStateQuaternion = require('./HilStateQuaternion.js');
let LandingTarget = require('./LandingTarget.js');
let MountControl = require('./MountControl.js');
let RadioStatus = require('./RadioStatus.js');
let HilActuatorControls = require('./HilActuatorControls.js');
let Trajectory = require('./Trajectory.js');

module.exports = {
  RCOut: RCOut,
  RCIn: RCIn,
  HilSensor: HilSensor,
  WheelOdomStamped: WheelOdomStamped,
  Thrust: Thrust,
  RTKBaseline: RTKBaseline,
  CamIMUStamp: CamIMUStamp,
  GlobalPositionTarget: GlobalPositionTarget,
  ActuatorControl: ActuatorControl,
  GPSRTK: GPSRTK,
  LogData: LogData,
  AttitudeTarget: AttitudeTarget,
  VehicleInfo: VehicleInfo,
  Mavlink: Mavlink,
  PlayTuneV2: PlayTuneV2,
  CommandCode: CommandCode,
  ParamValue: ParamValue,
  CompanionProcessStatus: CompanionProcessStatus,
  LogEntry: LogEntry,
  HomePosition: HomePosition,
  OverrideRCIn: OverrideRCIn,
  PositionTarget: PositionTarget,
  HilGPS: HilGPS,
  StatusText: StatusText,
  ESCInfoItem: ESCInfoItem,
  CameraImageCaptured: CameraImageCaptured,
  ManualControl: ManualControl,
  WaypointList: WaypointList,
  MagnetometerReporter: MagnetometerReporter,
  Waypoint: Waypoint,
  TerrainReport: TerrainReport,
  ESCStatus: ESCStatus,
  ESCInfo: ESCInfo,
  Vibration: Vibration,
  FileEntry: FileEntry,
  CellularStatus: CellularStatus,
  VFR_HUD: VFR_HUD,
  BatteryStatus: BatteryStatus,
  ADSBVehicle: ADSBVehicle,
  GPSINPUT: GPSINPUT,
  EstimatorStatus: EstimatorStatus,
  OpticalFlowRad: OpticalFlowRad,
  Tunnel: Tunnel,
  ESCTelemetry: ESCTelemetry,
  ESCStatusItem: ESCStatusItem,
  RTCM: RTCM,
  NavControllerOutput: NavControllerOutput,
  ExtendedState: ExtendedState,
  DebugValue: DebugValue,
  WaypointReached: WaypointReached,
  HilControls: HilControls,
  Param: Param,
  SysStatus: SysStatus,
  State: State,
  Altitude: Altitude,
  GPSRAW: GPSRAW,
  OnboardComputerStatus: OnboardComputerStatus,
  ESCTelemetryItem: ESCTelemetryItem,
  TimesyncStatus: TimesyncStatus,
  HilStateQuaternion: HilStateQuaternion,
  LandingTarget: LandingTarget,
  MountControl: MountControl,
  RadioStatus: RadioStatus,
  HilActuatorControls: HilActuatorControls,
  Trajectory: Trajectory,
};
