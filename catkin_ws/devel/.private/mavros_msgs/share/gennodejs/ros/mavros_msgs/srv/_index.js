
"use strict";

let FileChecksum = require('./FileChecksum.js')
let WaypointClear = require('./WaypointClear.js')
let FileRemoveDir = require('./FileRemoveDir.js')
let StreamRate = require('./StreamRate.js')
let LogRequestData = require('./LogRequestData.js')
let ParamPush = require('./ParamPush.js')
let CommandTriggerControl = require('./CommandTriggerControl.js')
let CommandHome = require('./CommandHome.js')
let CommandTriggerInterval = require('./CommandTriggerInterval.js')
let FileClose = require('./FileClose.js')
let ParamPull = require('./ParamPull.js')
let SetMode = require('./SetMode.js')
let FileTruncate = require('./FileTruncate.js')
let FileRename = require('./FileRename.js')
let FileList = require('./FileList.js')
let CommandLong = require('./CommandLong.js')
let FileWrite = require('./FileWrite.js')
let CommandAck = require('./CommandAck.js')
let WaypointSetCurrent = require('./WaypointSetCurrent.js')
let ParamGet = require('./ParamGet.js')
let CommandInt = require('./CommandInt.js')
let FileRead = require('./FileRead.js')
let FileRemove = require('./FileRemove.js')
let MessageInterval = require('./MessageInterval.js')
let FileOpen = require('./FileOpen.js')
let VehicleInfoGet = require('./VehicleInfoGet.js')
let FileMakeDir = require('./FileMakeDir.js')
let SetMavFrame = require('./SetMavFrame.js')
let CommandBool = require('./CommandBool.js')
let WaypointPush = require('./WaypointPush.js')
let CommandVtolTransition = require('./CommandVtolTransition.js')
let WaypointPull = require('./WaypointPull.js')
let ParamSet = require('./ParamSet.js')
let LogRequestEnd = require('./LogRequestEnd.js')
let CommandTOL = require('./CommandTOL.js')
let LogRequestList = require('./LogRequestList.js')
let MountConfigure = require('./MountConfigure.js')

module.exports = {
  FileChecksum: FileChecksum,
  WaypointClear: WaypointClear,
  FileRemoveDir: FileRemoveDir,
  StreamRate: StreamRate,
  LogRequestData: LogRequestData,
  ParamPush: ParamPush,
  CommandTriggerControl: CommandTriggerControl,
  CommandHome: CommandHome,
  CommandTriggerInterval: CommandTriggerInterval,
  FileClose: FileClose,
  ParamPull: ParamPull,
  SetMode: SetMode,
  FileTruncate: FileTruncate,
  FileRename: FileRename,
  FileList: FileList,
  CommandLong: CommandLong,
  FileWrite: FileWrite,
  CommandAck: CommandAck,
  WaypointSetCurrent: WaypointSetCurrent,
  ParamGet: ParamGet,
  CommandInt: CommandInt,
  FileRead: FileRead,
  FileRemove: FileRemove,
  MessageInterval: MessageInterval,
  FileOpen: FileOpen,
  VehicleInfoGet: VehicleInfoGet,
  FileMakeDir: FileMakeDir,
  SetMavFrame: SetMavFrame,
  CommandBool: CommandBool,
  WaypointPush: WaypointPush,
  CommandVtolTransition: CommandVtolTransition,
  WaypointPull: WaypointPull,
  ParamSet: ParamSet,
  LogRequestEnd: LogRequestEnd,
  CommandTOL: CommandTOL,
  LogRequestList: LogRequestList,
  MountConfigure: MountConfigure,
};
