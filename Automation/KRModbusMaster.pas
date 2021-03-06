(******************************************************************************)
(*                                                                            *)
(*  Kandiral Ruslan                                                           *)
(*  https://kandiral.ru                                                       *)
(*                                                                            *)
(*  KRModbusMaster                                                            *)
(*  Ver.: 17.03.2020                                                          *)
(*  https://kandiral.ru/delphi/krmodbusmaster.pas.html                        *)
(*                                                                            *)
(******************************************************************************)
unit KRModbusMaster;

interface

uses
  {$IF CompilerVersion >= 23}
    Winapi.Windows, System.Classes, System.SysUtils,
  {$ELSE}
    Windows, Classes, SysUtils,
  {$IFEND}
    KRConnector, KRModbus, KRTypes, KRThreadQueue, KRRuntimeErrors,
    KRThread, lgop, KRCRC, funcs;

type
  TMBMError = integer;

const
  MBM_ERRORS_COUNT = 12;

  mbmeOk = TMBMError(0);
  mbmeNotConnector = TMBMError(1);
  mbmeIncorrectID = TMBMError(2);
  mbmeIncorrectPackageLength = TMBMError(3);
  mbmeCRC = TMBMError(4);
  mbmeIncorrectFunction = TMBMError(5);
  mbmeIncorrectMBPackageLength = TMBMError(6);
  mbmeIncorrectDataLength = TMBMError(7);
  mbmeQueueOverflowed = TMBMError(8);
  mbmeTimeOut = TMBMError(9);
  mbmeRealTimeError = TMBMError(10);
  mbmeModbusNotActive = TMBMError(11);
  mbmeClientNotActive = TMBMError(12);

  MB_PARSER_ERRORS_MSG : array[0..MBM_ERRORS_COUNT] of String = (
    '��� ������.',
    '�� ��������� ������ �������� ������.',
    '�������� ������������� ������.',
    '�������� ������ ������.',
    '������ ����������� �����.',
    '�������� ����� �������.',
    '�������� ������ Modbus ������.',
    '�������� ������ ������.',
    '������� �����������.',
    '�������.',
    '������ ������� ����������.',
    '���������� ��������� Modbus ��������.',
    'Modbus ������ ��������.'
  );

  //------ Modbus Master Functions ---------------------------------------------
  function MBMReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  function MBMReadStatus(ADevAddr: byte; AFrom: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;

  function MBMUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; AFrom: byte; ABuffer: PKRBuffer): Byte;

  function MBMWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  //------ Modbus RTU Master Functions -----------------------------------------
  function MBMRTUReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMRTUReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMRTUReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMRTUReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  function MBMRTUReadStatus(ADevAddr: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;

  function MBMRTUUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; ABuffer: PKRBuffer): Byte;

  function MBMRTUWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMRTUWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMRTUWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMRTUWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  //------ Modbus TCP Master Functions -----------------------------------------
  function MBMTCPReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMTCPReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMTCPReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMTCPReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  function MBMTCPReadStatus(ADevAddr: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;

  function MBMTCPUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; ABuffer: PKRBuffer): Byte;

  function MBMTCPWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMTCPWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMTCPWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMTCPWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  //------ Modbus ASCII Master Functions ---------------------------------------
  function MBMASCIIReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMASCIIReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMASCIIReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMASCIIReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

  function MBMASCIIReadStatus(ADevAddr: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;

  function MBMASCIIUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; ABuffer: PKRBuffer): Byte;

  function MBMASCIIWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMASCIIWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMASCIIWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
  function MBMASCIIWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;

type
  TMBMCallBack = procedure(AError: integer; AData: Pointer) of Object;

  TMBPack = record
    Addres: Word;
    MBType: TMBType;
    MBFunc: TMBFunc;
    Start, Count: Word;
    Data: TKRRegisters;
    DataBt: TKRBytes;
    CallBack: TMBMCallBack;
    pBuf: PKRBuffer;
    bLen: Byte;
    bRLen: Byte;
    id: byte;
    uData: Pointer;
  end;
  PMBPack = ^TMBPack;

  TKRMBThread = class;

  TKRModbusMaster = class(TComponent)
  private
    FConnector: TKRConnector;
    FThread: TKRMBThread;
    FQueue: TKRThreadQueue;
    FRuntimeErrorEv: TKRRuntimeErrorEv;
    procedure SetConnector(const Value: TKRConnector);
    procedure SetActive(const Value: boolean);
    function GetActive: boolean;
    function GetQueueCount: integer;
    function GetRuntimeErrorEv: TKRRuntimeErrorEv;
    procedure SetRuntimeErrorEv(const Value: TKRRuntimeErrorEv);
    procedure DoRuntimeError(ADesc: String; E: Exception);
    function GetWaitPauseTime: Cardinal;
    function GetWaitTime: Cardinal;
    procedure SetWaitPauseTime(const Value: Cardinal);
    procedure SetWaitTime(const Value: Cardinal);
    function GetCheckID: boolean;
    procedure SetCheckID(const Value: boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    function ErrorMsg(AError: integer; var ALevel: String): String;


    procedure ReadReadCoils(AMBType: TMBType; AAddres: byte; AStartCoil, ACount: Word;
      ACallBack: TMBMCallBack);
    procedure ReadDiscretInputs(AMBType: TMBType; AAddres: byte; AStartInput, ACount: Word;
      ACallBack: TMBMCallBack);
    procedure ReadHoldingRegisters(AMBType: TMBType; AAddres: byte; AStartReg, ACount: Word;
      ACallBack: TMBMCallBack);
    procedure ReadInputRegisters(AMBType: TMBType; AAddres: byte; AStartReg, ACount: Word;
      ACallBack: TMBMCallBack);

    procedure ReadStatus(AMBType: TMBType; AAddres: byte; ACallBack: TMBMCallBack);

    procedure UserFunction(AMBType: TMBType; AAddres: byte; AFunc: byte; AData: PKRBuffer;
      ADataLen: integer; ACallBack: TMBMCallBack);

    procedure WriteCoil(AMBType: TMBType; AAddres: byte; ACoilNum: Word; AData: boolean;
      ACallBack: TMBMCallBack);
    procedure WriteCoils(AMBType: TMBType; AAddres: byte; AStartCoil, ACount: Word; AData: TKRBytes;
      ACallBack: TMBMCallBack);
    procedure WriteHoldingRegister(AMBType: TMBType; AAddres: byte; AStartReg: Word; AData: Word;
      ACallBack: TMBMCallBack);
    procedure WriteHoldingRegisters(AMBType: TMBType; AAddres: byte; AStartReg: Word; AData: TKRRegisters;
      ACallBack: TMBMCallBack);

    procedure SendPack(AMBType: TMBType; AFunc: TMBFunc; APPack: PKRBuffer; APkLen: byte; ACallBack: TMBMCallBack; ARecvLen: byte);

    function ReadReadCoilsPack(AMBType: TMBType; AAddres: byte; AStartCoil, ACount: Word;
      APPack: PKRBuffer; out ARecvLen: byte): byte;
    function ReadDiscretInputsPack(AMBType: TMBType; AAddres: byte; AStartInput, ACount: Word;
      APPack: PKRBuffer; out ARecvLen: byte): byte;
    function ReadHoldingRegistersPack(AMBType: TMBType; AAddres: byte; AStartReg, ACount: Word;
      APPack: PKRBuffer; out ARecvLen: byte): byte;
    function ReadInputRegistersPack(AMBType: TMBType; AAddres: byte; AStartReg, ACount: Word;
      APPack: PKRBuffer; out ARecvLen: byte): byte;

    function ReadStatusPack(AMBType: TMBType; AAddres: byte; APPack: PKRBuffer;
      out ARecvLen: byte): byte;

    function UserFunctionPack(AMBType: TMBType; AAddres: byte; AFunc: byte; AData: PKRBuffer;
      ADataLen: integer; APPack: PKRBuffer): byte;

    function WriteCoilPack(AMBType: TMBType; AAddres: byte; ACoilNum: Word; AData: boolean;
      APPack: PKRBuffer; out ARecvLen: byte): byte;
    function WriteCoilsPack(AMBType: TMBType; AAddres: byte; AStartCoil, ACount: Word; AData: TKRBytes;
      APPack: PKRBuffer; out ARecvLen: byte): byte;
    function WriteHoldingRegisterPack(AMBType: TMBType; AAddres: byte; AStartReg: Word; AData: Word;
      APPack: PKRBuffer; out ARecvLen: byte): byte;
    function WriteHoldingRegistersPack(AMBType: TMBType; AAddres: byte; AStartReg: Word; AData: TKRRegisters;
      APPack: PKRBuffer; out ARecvLen: byte): byte;

    property Active: boolean read GetActive write SetActive;
    property QueueCount: integer read GetQueueCount;
  published
    property Connector: TKRConnector read FConnector write SetConnector;
    property OnRuntimeError: TKRRuntimeErrorEv read GetRuntimeErrorEv write SetRuntimeErrorEv;
    property WaitTime: Cardinal read GetWaitTime write SetWaitTime default 20;
    property WaitPauseTime: Cardinal read GetWaitPauseTime write SetWaitPauseTime default 1000;
    property CheckID: boolean read GetCheckID write SetCheckID;
  end;

  TKRMBThread = class(TKRThread)
  private
    F_ID: byte;
    FQueue: TKRThreadQueue;
    FCheckID: boolean;
    FModbus: TKRModbusMaster;
    procedure _CallBack(AError: integer; APack: PKRBuffer; ALength: integer; AData: Pointer);

    procedure DoTCP(APack: PMBPack);
    procedure DoSendTCP(APack: PMBPack; APBuf: PKRBuffer; ABufLen: byte; ARecvLen: byte);
    procedure doTCPReadCoils(APack: PMBPack);
    procedure doTCPReadDiscretInputs(APack: PMBPack);
    procedure doTCPReadHoldingRegisters(APack: PMBPack);
    procedure doTCPReadInputRegisters(APack: PMBPack);
    procedure doTCPReadStatus(APack: PMBPack);
    procedure doTCPUserFunction(APack: PMBPack);
    procedure doTCPWriteCoil(APack: PMBPack);
    procedure doTCPWriteCoils(APack: PMBPack);
    procedure doTCPWriteHoldingRegister(APack: PMBPack);
    procedure doTCPWriteHoldingRegisters(APack: PMBPack);

    function chTCPReadCoils(APack: PKRBuffer; ALength: byte; var ABytes: TKRBytes): integer;
    function chTCPReadDiscretInputs(APack: PKRBuffer; ALength: byte; var ABytes: TKRBytes): integer;
    function chTCPReadHoldingRegisters(APack: PKRBuffer; ALength: byte; var ARegs: TKRRegisters): integer;
    function chTCPReadInputRegisters(APack: PKRBuffer; ALength: byte; var ARegs: TKRRegisters): integer;
    function chTCPUserFunction(APack: PKRBuffer; ALength: byte; var AData: TKRBytes): integer;
    function chTCPReadStatus(APack: PKRBuffer; ALength: byte; var AStatus: Byte): integer;
    function chTCPWriteHoldingRegister(APack: PKRBuffer; ALength: byte): integer;
    function chTCPWriteCoil(APack: PKRBuffer; ALength: byte): integer;
    function chTCPWriteCoils(APack: PKRBuffer; ALength: byte): integer;
    function chTCPWriteHoldingRegisters(APack: PKRBuffer; ALength: byte): integer;

    procedure DoRTU(APack: PMBPack);
    procedure DoSendRTU(APack: PMBPack; APBuf: PKRBuffer; ABufLen: byte; ARecvLen: byte);
    procedure doRTUReadCoils(APack: PMBPack);
    procedure doRTUReadDiscretInputs(APack: PMBPack);
    procedure doRTUReadHoldingRegisters(APack: PMBPack);
    procedure doRTUReadInputRegisters(APack: PMBPack);
    procedure doRTUReadStatus(APack: PMBPack);
    procedure doRTUUserFunction(APack: PMBPack);
    procedure doRTUWriteCoil(APack: PMBPack);
    procedure doRTUWriteCoils(APack: PMBPack);
    procedure doRTUWriteHoldingRegister(APack: PMBPack);
    procedure doRTUWriteHoldingRegisters(APack: PMBPack);

    function chRTUReadCoils(APack: PKRBuffer; ALength: byte; var ABytes: TKRBytes): integer;
    function chRTUReadDiscretInputs(APack: PKRBuffer; ALength: byte; var ABytes: TKRBytes): integer;
    function chRTUReadHoldingRegisters(APack: PKRBuffer; ALength: byte; var ARegs: TKRRegisters): integer;
    function chRTUReadInputRegisters(APack: PKRBuffer; ALength: byte; var ARegs: TKRRegisters): integer;
    function chRTUUserFunction(APack: PKRBuffer; ALength: byte; var AData: TKRBytes): integer;
    function chRTUReadStatus(APack: PKRBuffer; ALength: byte; var AStatus: Byte): integer;
    function chRTUWriteCoil(APack: PKRBuffer; ALength: byte): integer;
    function chRTUWriteCoils(APack: PKRBuffer; ALength: byte): integer;
    function chRTUWriteHoldingRegister(APack: PKRBuffer; ALength: byte): integer;
    function chRTUWriteHoldingRegisters(APack: PKRBuffer; ALength: byte): integer;

    procedure DoASCII(APack: PMBPack);
    procedure DoSendASCII(APack: PMBPack; APBuf: PKRBuffer; ABufLen: byte; ARecvLen: byte);
    procedure doASCIIReadCoils(APack: PMBPack);
    procedure doASCIIReadDiscretInputs(APack: PMBPack);
    procedure doASCIIReadHoldingRegisters(APack: PMBPack);
    procedure doASCIIReadInputRegisters(APack: PMBPack);
    procedure doASCIIReadStatus(APack: PMBPack);
    procedure doASCIIUserFunction(APack: PMBPack);
    procedure doASCIIWriteCoil(APack: PMBPack);
    procedure doASCIIWriteCoils(APack: PMBPack);
    procedure doASCIIWriteHoldingRegister(APack: PMBPack);
    procedure doASCIIWriteHoldingRegisters(APack: PMBPack);

    function chASCIIReadCoils(APack: PKRBuffer; ALength: byte; var ABytes: TKRBytes): integer;
    function chASCIIReadDiscretInputs(APack: PKRBuffer; ALength: byte; var ABytes: TKRBytes): integer;
    function chASCIIReadHoldingRegisters(APack: PKRBuffer; ALength: byte; var ARegs: TKRRegisters): integer;
    function chASCIIReadInputRegisters(APack: PKRBuffer; ALength: byte; var ARegs: TKRRegisters): integer;
    function chASCIIUserFunction(APack: PKRBuffer; ALength: byte; var AData: TKRBytes): integer;
    function chASCIIReadStatus(APack: PKRBuffer; ALength: byte; var AStatus: Byte): integer;
    function chASCIIWriteCoil(APack: PKRBuffer; ALength: byte): integer;
    function chASCIIWriteCoils(APack: PKRBuffer; ALength: byte): integer;
    function chASCIIWriteHoldingRegister(APack: PKRBuffer; ALength: byte): integer;
    function chASCIIWriteHoldingRegisters(APack: PKRBuffer; ALength: byte): integer;

  protected
    procedure _exec(APack: PMBPack);
    procedure KRExecute; override;
  public
    constructor CreateTh(AModbus: TKRModbusMaster; AQueue: TKRThreadQueue);
    destructor Destroy;override;
  end;

implementation

//------ Modbus Master Functions -----------------------------------------------

function MBMReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfReadCoils;
  BytesFromWord(AStartCoil,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(ACount,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  Result:=6;
  ARecvLen:=3+ (ACount div 8);
  if(ACount mod 8 > 0)then inc(ARecvLen);
end;

function MBMReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfReadDiscretInputs;
  BytesFromWord(AStartInput,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(ACount,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  Result:=6;
  ARecvLen:=3+ (ACount div 8);
  if(ACount mod 8 > 0)then inc(ARecvLen);
end;

function MBMReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfReadHoldingRegisters;
  BytesFromWord(AStartReg,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(ACount,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  Result:=6;
  ARecvLen:=3+ACount*2;
end;

function MBMReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfReadInputRegisters;
  BytesFromWord(AStartReg,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(ACount,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  Result:=6;
  ARecvLen:=3+ACount*2;
end;

function MBMReadStatus(ADevAddr: byte; AFrom: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfReadStatus;
  Result:=2;
  ARecvLen:=3;
end;

function MBMUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; AFrom: byte; ABuffer: PKRBuffer): Byte;
var
  i,k,n: integer;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=AFunc;
  k:=AFrom+2;
  n:=AFrom+ADataLen+1;
  for i := k to n do ABuffer^[i]:=AData^[i-k];
  Result:=ADataLen+2;
end;

function MBMWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfWriteCoil;
  BytesFromWord(ACoilNum,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  if(AData)then ABuffer^[AFrom+4]:=$FF
  else ABuffer^[AFrom+4]:=$00;
  ABuffer^[AFrom+5]:=$00;
  Result:=6;
  ARecvLen:=6;
end;

function MBMWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  cnt,i: integer;
begin
  cnt:=Length(AData);
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfWriteCoils;
  BytesFromWord(AStartCoil,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(ACount,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  ABuffer^[AFrom+6]:=cnt;
  for I := 0 to cnt-1 do ABuffer^[AFrom+7+1]:=AData[i];
  Result:=7+cnt;
  ARecvLen:=6;
end;

function MBMWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfWriteHoldingRegister;
  BytesFromWord(AStartReg,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(AData,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  Result:=6;
  ARecvLen:=6;
end;

function MBMWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; AFrom: byte; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  rcnt,dcnt: byte;
  i: integer;
begin
  rcnt:=Length(AData);
  dcnt:=rcnt*2;
  ABuffer^[AFrom]:=ADevAddr;
  ABuffer^[AFrom+1]:=mbfWriteHoldingRegisters;
  BytesFromWord(AStartReg,ABuffer^[AFrom+3],ABuffer^[AFrom+2]);
  BytesFromWord(rcnt,ABuffer^[AFrom+5],ABuffer^[AFrom+4]);
  ABuffer^[AFrom+6]:=dcnt;
  for i:=0 to rcnt-1 do begin
    BytesFromWord(AData[i],ABuffer^[AFrom+8+i*2],ABuffer^[AFrom+7+i*2]);
  end;
  Result:=7+dcnt;
  ARecvLen:=6;
end;

//------ Modbus RTU Master Functions -------------------------------------------

function MBMRTUReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMReadCoils(ADevAddr,AStartCoil,ACount,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMReadDiscretInputs(ADevAddr,AStartInput,ACount,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMReadHoldingRegisters(ADevAddr,AStartReg,ACount,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMReadInputRegisters(ADevAddr,AStartReg,ACount,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUReadStatus(ADevAddr: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;
begin
  Result:=MBMReadStatus(ADevAddr,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; ABuffer: PKRBuffer): Byte;
begin
  Result:=MBMUserFunction(ADevAddr,AFunc,AData,ADataLen,0,ABuffer);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
end;

function MBMRTUWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMWriteCoil(ADevAddr,ACoilNum,AData,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMWriteCoils(ADevAddr,AStartCoil,ACount,AData,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMWriteHoldingRegister(ADevAddr,AStartReg,AData,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

function MBMRTUWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  Result:=MBMWriteHoldingRegisters(ADevAddr,AStartReg,AData,0,ABuffer,ARecvLen);
  KRCRC16(ABuffer,Result,ABuffer^[Result+1],ABuffer^[Result]);
  Result:=Result+2;
  ARecvLen:=ARecvLen+2;
end;

//------ Modbus TCP Master Functions -------------------------------------------

function MBMTCPReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMReadCoils(ADevAddr,AStartCoil,ACount,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMReadDiscretInputs(ADevAddr,AStartInput,ACount,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMReadHoldingRegisters(ADevAddr,AStartReg,ACount,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMReadInputRegisters(ADevAddr,AStartReg,ACount,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPReadStatus(ADevAddr: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMReadStatus(ADevAddr,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; ABuffer: PKRBuffer): Byte;
begin
  ABuffer^[5]:=MBMUserFunction(ADevAddr,AFunc,AData,ADataLen,6,ABuffer);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
end;

function MBMTCPWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMWriteCoil(ADevAddr,ACoilNum,AData,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMWriteCoils(ADevAddr,AStartCoil,ACount,AData,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMWriteHoldingRegister(ADevAddr,AStartReg,AData,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

function MBMTCPWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
begin
  ABuffer^[5]:=MBMWriteHoldingRegisters(ADevAddr,AStartReg,AData,6,ABuffer,ARecvLen);
  ABuffer^[0]:=0;
  ABuffer^[1]:=0;
  ABuffer^[2]:=0;
  ABuffer^[3]:=0;
  ABuffer^[4]:=0;
  Result:=ABuffer^[5]+6;
  ARecvLen:=ARecvLen+6;
end;

//------ Modbus ASCII Master Functions -----------------------------------------

function MBMASCIIReadCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMReadCoils(ADevAddr,AStartCoil,ACount,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIReadDiscretInputs(ADevAddr: byte; AStartInput, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMReadDiscretInputs(ADevAddr,AStartInput,ACount,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIReadHoldingRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMReadHoldingRegisters(ADevAddr,AStartReg,ACount,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIReadInputRegisters(ADevAddr: byte; AStartReg, ACount: Word;
    ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMReadInputRegisters(ADevAddr,AStartReg,ACount,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIReadStatus(ADevAddr: byte; ABuffer: PKRBuffer;
    out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMReadStatus(ADevAddr,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;


function MBMASCIIUserFunction(ADevAddr: byte; AFunc: byte; AData: PKRBuffer;
    ADataLen: integer; ABuffer: PKRBuffer): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMUserFunction(ADevAddr,AFunc,AData,ADataLen,0,p);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
end;

function MBMASCIIWriteCoil(ADevAddr: byte; ACoilNum: Word;
    AData: boolean; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMWriteCoil(ADevAddr,ACoilNum,AData,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIWriteCoils(ADevAddr: byte; AStartCoil, ACount: Word;
    AData: TKRBytes; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMWriteCoils(ADevAddr,AStartCoil,ACount,AData,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIWriteHoldingRegister(ADevAddr: byte; AStartReg: Word;
    AData: Word; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMWriteHoldingRegister(ADevAddr,AStartReg,AData,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

function MBMASCIIWriteHoldingRegisters(ADevAddr: byte; AStartReg: Word;
    AData: TKRRegisters; ABuffer: PKRBuffer; out ARecvLen: Byte): Byte;
var
  p: PKRBuffer;
  i: integer;
  wd: Word;
  bt: byte;
begin
  ABuffer^[0]:=58;
  New(p);
  Result:=MBMWriteHoldingRegisters(ADevAddr,AStartReg,AData,0,p,ARecvLen);
  wd:=0;
  for i := 0 to Result-1 do begin
    wd:=WordRec(wd).Lo + p^[i];
    ABuffer^[i*2+1]:=MBHEX_CHARS[p^[i] shr 4];
    ABuffer^[i*2+2]:=MBHEX_CHARS[p^[i] and $F]
  end;
  Dispose(p);
  Result:=Result*2+1;
  bt:=$ff-WordRec(wd).Lo;
  ABuffer^[Result]:=MBHEX_CHARS[bt shr 4];
  Inc(Result);
  ABuffer^[Result]:=MBHEX_CHARS[bt and $F];
  Inc(Result);
  ABuffer^[Result]:=13;
  Inc(Result);
  ABuffer^[Result]:=10;
  Inc(Result);
  ARecvLen:=ARecvLen*2+5;
end;

{ TKRModbusMaster }

constructor TKRModbusMaster.Create(AOwner: TComponent);
begin
  inherited;
  FQueue:=TKRThreadQueue.Create;
  FThread:=TKRMBThread.CreateTh(Self,FQueue);
end;

destructor TKRModbusMaster.Destroy;
begin
  FThread.Terminate;
  while FThread.Working do Sleep(50);
  FThread.Free;
  FQueue.Free;
  inherited;
end;

procedure TKRModbusMaster.DoRuntimeError(ADesc: String; E: Exception);
begin
  REEvent(FRuntimeErrorEv,Self,ADesc,E);
end;

function TKRModbusMaster.ErrorMsg(AError: integer; var ALevel: String): String;
var
  err: integer;
begin
  if AError>0 then begin
    ALevel:='������ �������';
    if(AError<=MB_ERRORS_COUNT)then Result:=MODBUS_ERRORS_MSG[AError]
    else Result:='����������� ������.';
  end else if(AError<0)AND(AError>-100)then begin
    ALevel:='������ ��������� ������';
    err:=-AError;
    if(err<=MBM_ERRORS_COUNT)then Result:=MB_PARSER_ERRORS_MSG[err]
  end else if AError<-100 then begin
    ALevel:='������ �������� ������';
    err:=-AError-100;
    Result:=FConnector.ErrorMsg(err);
  end else if AError=0 then begin
    ALevel:='';
    Result:='��� ������.';
  end else begin
    ALevel:='';
    Result:='����������� ������.';
  end;
end;

function TKRModbusMaster.GetActive: boolean;
begin
  Result:=FThread.Active;
end;

function TKRModbusMaster.GetCheckID: boolean;
begin
  Result:=FThread.FCheckID;
end;

function TKRModbusMaster.GetRuntimeErrorEv: TKRRuntimeErrorEv;
begin
  RECS_Enter;
  Result:=FRuntimeErrorEv;
  RECS_Leave;
end;

function TKRModbusMaster.GetQueueCount: integer;
begin
  Result:=FQueue.Count;
end;

function TKRModbusMaster.GetWaitPauseTime: Cardinal;
begin
  Result:=FThread.WaitPauseTime;
end;

function TKRModbusMaster.GetWaitTime: Cardinal;
begin
  Result:=FThread.WaitTime;
end;

procedure TKRModbusMaster.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if(Operation = opRemove)then
    if (AComponent = FConnector)then FConnector:= nil;
end;

procedure TKRModbusMaster.ReadDiscretInputs(AMBType: TMBType; AAddres: byte;
  AStartInput, ACount: Word; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfReadDiscretInputs;
  _pk.Start:=AStartInput;
  _pk.Count:=ACount;
  _pk.Data:=nil;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.ReadDiscretInputsPack(AMBType: TMBType; AAddres: byte;
  AStartInput, ACount: Word; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUReadDiscretInputs(AAddres,AStartInput,ACount,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPReadDiscretInputs(AAddres,AStartInput,ACount,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIReadDiscretInputs(AAddres,AStartInput,ACount,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.ReadHoldingRegisters(AMBType: TMBType; AAddres: byte;
  AStartReg, ACount: Word; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfReadHoldingRegisters;
  _pk.Start:=AStartReg;
  _pk.Count:=ACount;
  _pk.Data:=nil;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.ReadHoldingRegistersPack(AMBType: TMBType;
  AAddres: byte; AStartReg, ACount: Word; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUReadHoldingRegisters(AAddres,AStartReg,ACount,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPReadHoldingRegisters(AAddres,AStartReg,ACount,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIReadHoldingRegisters(AAddres,AStartReg,ACount,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.ReadInputRegisters(AMBType: TMBType; AAddres: byte;
  AStartReg, ACount: Word; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfReadInputRegisters;
  _pk.Start:=AStartReg;
  _pk.Count:=ACount;
  _pk.Data:=nil;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk)
end;

function TKRModbusMaster.ReadInputRegistersPack(AMBType: TMBType;
  AAddres: byte; AStartReg, ACount: Word; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUReadInputRegisters(AAddres,AStartReg,ACount,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPReadInputRegisters(AAddres,AStartReg,ACount,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIReadInputRegisters(AAddres,AStartReg,ACount,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.ReadReadCoils(AMBType: TMBType; AAddres: byte;
  AStartCoil, ACount: Word; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfReadCoils;
  _pk.Start:=AStartCoil;
  _pk.Count:=ACount;
  _pk.Data:=nil;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk)
end;

function TKRModbusMaster.ReadReadCoilsPack(AMBType: TMBType; AAddres: byte;
  AStartCoil, ACount: Word; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUReadCoils(AAddres,AStartCoil,ACount,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPReadCoils(AAddres,AStartCoil,ACount,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIReadCoils(AAddres,AStartCoil,ACount,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.ReadStatus(AMBType: TMBType; AAddres: byte;
  ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfReadStatus;
  _pk.Data:=nil;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk)
end;

function TKRModbusMaster.ReadStatusPack(AMBType: TMBType; AAddres: byte;
  APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUReadStatus(AAddres,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPReadStatus(AAddres,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIReadStatus(AAddres,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.SendPack(AMBType: TMBType; AFunc: TMBFunc; APPack: PKRBuffer; APkLen: byte;
  ACallBack: TMBMCallBack; ARecvLen: byte);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.MBType:=AMBType;
  _pk.MBFunc:=AFunc;
  _pk.Data:=nil;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=APPack;
  _pk.bLen:=APkLen;
  _pk.bRLen:=ARecvLen;
  FQueue.Push(_pk);
end;

procedure TKRModbusMaster.SetActive(const Value: boolean);
begin
  FThread.Active:=Value;
end;

procedure TKRModbusMaster.SetCheckID(const Value: boolean);
begin
  FThread.FCheckID:=Value;
end;

procedure TKRModbusMaster.SetConnector(const Value: TKRConnector);
begin
  if FConnector<>Value then begin
    SetActive(false);
    if Assigned(FConnector) then FConnector.RemoveFreeNotification(Self);
    FConnector := Value;
    if Assigned(FConnector) then begin
      SetActive(false);
      FConnector.FreeNotification(Self);
    end;
  end;
end;

procedure TKRModbusMaster.SetRuntimeErrorEv(const Value: TKRRuntimeErrorEv);
begin
  RECS_Enter;
  FRuntimeErrorEv:=Value;
  RECS_Leave;
end;

procedure TKRModbusMaster.SetWaitPauseTime(const Value: Cardinal);
begin
  Fthread.WaitPauseTime:=Value;
end;

procedure TKRModbusMaster.SetWaitTime(const Value: Cardinal);
begin
  Fthread.WaitTime:=Value;
end;

procedure TKRModbusMaster.UserFunction(AMBType: TMBType; AAddres, AFunc: byte;
  AData: PKRBuffer; ADataLen: integer; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=AFunc;
  _pk.Count:=ADataLen;
  _pk.uData:=AData;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.UserFunctionPack(AMBType: TMBType; AAddres,
  AFunc: byte; AData: PKRBuffer; ADataLen: integer; APPack: PKRBuffer): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUUserFunction(AAddres,AFunc,AData,ADataLen,APPack);
    mbtTCP: Result:=MBMTCPUserFunction(AAddres,AFunc,AData,ADataLen,APPack);
    mbtASCII: Result:=MBMASCIIUserFunction(AAddres,AFunc,AData,ADataLen,APPack);
  end;
end;

procedure TKRModbusMaster.WriteCoil(AMBType: TMBType; AAddres: byte;
  ACoilNum: Word; AData: boolean; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfWriteCoil;
  _pk.Start:=ACoilNum;
  SetLength(_pk.DataBt,1);
  _pk.DataBt[0]:=SetBitTo(0,0,AData);
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.WriteCoilPack(AMBType: TMBType; AAddres: byte;
  ACoilNum: Word; AData: boolean; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUWriteCoil(AAddres,ACoilNum,AData,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPWriteCoil(AAddres,ACoilNum,AData,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIWriteCoil(AAddres,ACoilNum,AData,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.WriteCoils(AMBType: TMBType; AAddres: byte;
  AStartCoil, ACount: Word; AData: TKRBytes; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfWriteCoils;
  _pk.Start:=AStartCoil;
  _pk.Count:=ACount;
  _pk.DataBt:=AData;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.WriteCoilsPack(AMBType: TMBType; AAddres: byte;
  AStartCoil, ACount: Word; AData: TKRBytes; APPack: PKRBuffer;
  out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUWriteCoils(AAddres,AStartCoil,ACount,AData,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPWriteCoils(AAddres,AStartCoil,ACount,AData,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIWriteCoils(AAddres,AStartCoil,ACount,AData,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.WriteHoldingRegister(AMBType: TMBType; AAddres: byte;
  AStartReg, AData: Word; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfWriteHoldingRegister;
  _pk.Start:=AStartReg;
  _pk.Count:=1;
  SetLength(_pk.Data,1);
  _pk.Data[0]:=AData;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.WriteHoldingRegisterPack(AMBType: TMBType;
  AAddres: byte; AStartReg, AData: Word; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUWriteHoldingRegister(AAddres,AStartReg,AData,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPWriteHoldingRegister(AAddres,AStartReg,AData,APPack,ARecvLen);
    mbtASCII: Result:=MBMASCIIWriteHoldingRegister(AAddres,AStartReg,AData,APPack,ARecvLen);
  end;
end;

procedure TKRModbusMaster.WriteHoldingRegisters(AMBType: TMBType; AAddres: byte;
  AStartReg: Word; AData: TKRRegisters; ACallBack: TMBMCallBack);
var
  _pk: PMBPack;
begin
  if not Active then begin
    if Assigned(ACallBack)then ACallBack(-mbmeModbusNotActive,nil);
    exit;
  end;
  if not Assigned(FConnector) then begin
    if Assigned(ACallBack)then ACallBack(-mbmeNotConnector,nil);
    exit;
  end;
  if FQueue.AtLeast(MB_QUEUE_MAX_ITEMS)then begin
    if Assigned(ACallBack)then ACallBack(-mbmeQueueOverflowed,nil);
    exit;
  end;

  New(_pk);
  _pk.Addres:=AAddres;
  _pk.MBType:=AMBType;
  _pk.MBFunc:=mbfWriteHoldingRegisters;
  _pk.Start:=AStartReg;
  _pk.Count:=Length(AData);
  _pk.Data:=AData;
  _pk.CallBack:=ACallBack;
  _pk.pBuf:=nil;
  _pk.bLen:=0;
  FQueue.Push(_pk);
end;

function TKRModbusMaster.WriteHoldingRegistersPack(AMBType: TMBType;
  AAddres: byte; AStartReg: Word; AData: TKRRegisters; APPack: PKRBuffer; out ARecvLen: byte): byte;
begin
  Result:=0;
  case AMBType of
    mbtRTU: Result:=MBMRTUWriteHoldingRegisters(AAddres,AStartReg,AData,APPack,ARecvLen);
    mbtTCP: Result:=MBMTCPWriteHoldingRegisters(AAddres,AStartReg,AData,APPack,ARecvLen);
  end;
end;

{ TKRMBThread }

function TKRMBThread.chASCIIReadCoils(APack: PKRBuffer; ALength: byte;
  var ABytes: TKRBytes): integer;
var
  n,i: integer;
begin
  Result:=0;
  n:=MBHexToValue(APack^[5],APack^[6]);
  SetLength(ABytes,n);
  for i := 0 to n-1 do ABytes[i]:=MBHexToValue(APack^[i*2+6],APack^[i*2+7]);
end;

function TKRMBThread.chASCIIReadDiscretInputs(APack: PKRBuffer; ALength: byte;
  var ABytes: TKRBytes): integer;
var
  n,i: integer;
begin
  Result:=0;
  n:=MBHexToValue(APack^[5],APack^[6]);
  SetLength(ABytes,n);
  for i := 0 to n-1 do ABytes[i]:=MBHexToValue(APack^[i*2+6],APack^[i*2+7]);
end;

function TKRMBThread.chASCIIReadHoldingRegisters(APack: PKRBuffer;
  ALength: byte; var ARegs: TKRRegisters): integer;
var
  n, i: integer;
begin
  Result:=0;
  n:=MBHexToValue(APack^[5],APack^[6]) div 2;
  if n<1 then begin
    SetLength(ARegs,1);
    ARegs[0]:=0;
  end else begin
    SetLength(ARegs,n);
    for i := 0 to n-1 do
      ARegs[i]:=BytesToWord(
        MBHexToValue(APack^[i*4+9],APack^[i*4+10]),
        MBHexToValue(APack^[i*4+7],APack^[i*4+8])
      );
  end;
end;

function TKRMBThread.chASCIIReadInputRegisters(APack: PKRBuffer; ALength: byte;
  var ARegs: TKRRegisters): integer;
var
  n, i: integer;
begin
  Result:=0;
  n:=MBHexToValue(APack^[5],APack^[6]) div 2;
  if n<1 then begin
    SetLength(ARegs,1);
    ARegs[0]:=0;
  end else begin
    SetLength(ARegs,n);
    for i := 0 to n-1 do
      ARegs[i]:=BytesToWord(
        MBHexToValue(APack^[i*4+9],APack^[i*4+10]),
        MBHexToValue(APack^[i*4+7],APack^[i*4+8])
      );
  end;
end;

function TKRMBThread.chASCIIReadStatus(APack: PKRBuffer; ALength: byte;
  var AStatus: Byte): integer;
begin
  Result:=0;
  AStatus:=MBHexToValue(APack^[5],APack^[6]);
end;

function TKRMBThread.chASCIIUserFunction(APack: PKRBuffer; ALength: byte;
  var AData: TKRBytes): integer;
var
  i, n: integer;
begin
  Result:=0;
  n:=ALength-2;
  if n<0 then n:=0;
  SetLength(AData,n);
  for i := 0 to n-1 do AData[i]:=MBHexToValue(APack^[i*2+5],APack^[i*2+6]);
end;

function TKRMBThread.chASCIIWriteCoil(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chASCIIWriteCoils(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chASCIIWriteHoldingRegister(APack: PKRBuffer;
  ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chASCIIWriteHoldingRegisters(APack: PKRBuffer;
  ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chRTUReadCoils(APack: PKRBuffer; ALength: byte;
  var ABytes: TKRBytes): integer;
var
  i: integer;
begin
  Result:=0;
  SetLength(ABytes,APack^[2]);
  for i := 0 to APack^[2]-1 do ABytes[i]:=APack^[3+i];
end;

function TKRMBThread.chRTUReadDiscretInputs(APack: PKRBuffer; ALength: byte;
  var ABytes: TKRBytes): integer;
var
  i: integer;
begin
  Result:=0;
  SetLength(ABytes,APack^[2]);
  for i := 0 to APack^[2]-1 do ABytes[i]:=APack^[3+i];
end;

function TKRMBThread.chRTUReadHoldingRegisters(APack: PKRBuffer; ALength: byte;
  var ARegs: TKRRegisters): integer;
var
  n, i: integer;
begin
  Result:=0;
  n:=APack^[2] div 2;
  if n<1 then begin
    SetLength(ARegs,1);
    ARegs[0]:=0;
  end else begin
    SetLength(ARegs,n);
    for i := 0 to n-1 do ARegs[i]:=BytesToWord(APack^[4+i*2],APack^[3+i*2]);
  end;
end;

function TKRMBThread.chRTUReadInputRegisters(APack: PKRBuffer; ALength: byte;
  var ARegs: TKRRegisters): integer;
var
  n, i: integer;
begin
  Result:=0;
  n:=APack^[2] div 2;
  if n<1 then begin
    SetLength(ARegs,1);
    ARegs[0]:=0;
  end else begin
    SetLength(ARegs,n);
    for i := 0 to n-1 do ARegs[i]:=BytesToWord(APack^[4+i*2],APack^[3+i*2]);
  end;
end;

function TKRMBThread.chRTUReadStatus(APack: PKRBuffer; ALength: byte;
  var AStatus: Byte): integer;
begin
  Result:=0;
  AStatus:=APack^[2];
end;

function TKRMBThread.chRTUUserFunction(APack: PKRBuffer; ALength: byte;
  var AData: TKRBytes): integer;
var
  i, n: integer;
begin
  Result:=0;
  n:=ALength-2;
  if n<0 then n:=0;
  SetLength(AData,n);
  for i := 0 to n-1 do AData[i]:=APack^[i+2];
end;

function TKRMBThread.chRTUWriteCoil(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chRTUWriteCoils(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chRTUWriteHoldingRegister(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chRTUWriteHoldingRegisters(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chTCPReadCoils(APack: PKRBuffer; ALength: byte;
  var ABytes: TKRBytes): integer;
var
  i: integer;
begin
  Result:=0;
  SetLength(ABytes,APack^[8]);
  for i := 0 to APack^[8]-1 do ABytes[i]:=APack^[9+i];
end;

function TKRMBThread.chTCPReadDiscretInputs(APack: PKRBuffer; ALength: byte;
  var ABytes: TKRBytes): integer;
var
  i: integer;
begin
  Result:=0;
  SetLength(ABytes,APack^[8]);
  for i := 0 to APack^[8]-1 do ABytes[i]:=APack^[9+i];
end;

function TKRMBThread.chTCPReadHoldingRegisters(APack: PKRBuffer;
  ALength: byte; var ARegs: TKRRegisters): integer;
var
  n, i: integer;
begin
  Result:=0;
  n:=APack^[8] div 2;
  if n<1 then begin
    SetLength(ARegs,1);
    ARegs[0]:=0;
  end else begin
    SetLength(ARegs,n);
    for i := 0 to n-1 do ARegs[i]:=BytesToWord(APack^[10+i*2],APack^[9+i*2]);
  end;
end;

function TKRMBThread.chTCPReadInputRegisters(APack: PKRBuffer;
  ALength: byte; var ARegs: TKRRegisters): integer;
var
  n, i: integer;
begin
  Result:=0;
  n:=APack^[8] div 2;
  if n<1 then begin
    SetLength(ARegs,1);
    ARegs[0]:=0;
  end else begin
    SetLength(ARegs,n);
    for i := 0 to n-1 do ARegs[i]:=BytesToWord(APack^[10+i*2],APack^[9+i*2]);
  end;
end;

function TKRMBThread.chTCPReadStatus(APack: PKRBuffer; ALength: byte;
  var AStatus: Byte): integer;
begin
  Result:=0;
  AStatus:=APack^[8];
end;

function TKRMBThread.chTCPUserFunction(APack: PKRBuffer; ALength: byte;
  var AData: TKRBytes): integer;
var
  i, n: integer;
begin
  Result:=0;
  n:=ALength-8;
  if n<0 then n:=0;
  SetLength(AData,n);
  for i := 0 to n-1 do AData[i]:=APack^[i+8];
end;

function TKRMBThread.chTCPWriteCoil(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chTCPWriteCoils(APack: PKRBuffer; ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chTCPWriteHoldingRegister(APack: PKRBuffer;
  ALength: byte): integer;
begin
  Result:=0;
end;

function TKRMBThread.chTCPWriteHoldingRegisters(APack: PKRBuffer;
  ALength: byte): integer;
begin
  Result:=0;
end;

constructor TKRMBThread.CreateTh(AModbus: TKRModbusMaster; AQueue: TKRThreadQueue);
begin
  FQueue:=AQueue;
  FModbus:=AModbus;
  F_ID:=0;
  FCheckID:=true;
  inherited Create;
end;

destructor TKRMBThread.Destroy;
begin
  inherited;
end;

procedure TKRMBThread.DoASCII(APack: PMBPack);
var
  _buf: PKRBuffer;
begin
  try
    if APack.bLen>0 then begin
      New(_buf);
      _buf^:=APack.pBuf^;
      DoSendASCII(APack,_buf,APack.bLen,APack.bRLen);
    end else case APack.MBFunc of
      mbfReadCoils: doASCIIReadCoils(APack);
      mbfReadDiscretInputs: doASCIIReadDiscretInputs(APack);
      mbfReadHoldingRegisters: doASCIIReadHoldingRegisters(APack);
      mbfReadInputRegisters: doASCIIReadInputRegisters(APack);
      mbfReadStatus: doASCIIReadStatus(APack);
      mbfWriteCoil: doASCIIWriteCoil(APack);
      mbfWriteCoils: doASCIIWriteCoils(APack);
      mbfWriteHoldingRegister: doASCIIWriteHoldingRegister(APack);
      mbfWriteHoldingRegisters: doASCIIWriteHoldingRegisters(APack)
      else doASCIIUserFunction(APack);
    end;
  except on E: Exception do
    FModbus.DoRuntimeError('TKRMBThread[FModbus.Name="'+
      FModbus.Name+'"] procedure DoASCII;',E);
  end;
end;

procedure TKRMBThread.doASCIIReadCoils(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIReadCoils(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIReadDiscretInputs(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIReadDiscretInputs(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIReadHoldingRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIReadHoldingRegisters(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIReadInputRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIReadInputRegisters(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIReadStatus(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIReadStatus(APack^.Addres,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIUserFunction(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len: byte;
begin
  New(_buf);
  _len:=MBMASCIIUserFunction(APack^.Addres,APack^.MBFunc,PKRBuffer(APack^.uData),APack^.Count,_buf);
  DoSendASCII(APack,_buf,_len,0);
end;

procedure TKRMBThread.doASCIIWriteCoil(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIWriteCoil(APack^.Addres,APack^.Start,GetBit(APack^.DataBt[0],0),_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIWriteCoils(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIWriteCoils(APack^.Addres,APack^.Start,APack^.Count,APack^.DataBt,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIWriteHoldingRegister(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIWriteHoldingRegister(APack^.Addres,APack^.Start,APack^.Data[0],_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doASCIIWriteHoldingRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMASCIIWriteHoldingRegisters(APack^.Addres,APack^.Start,APack^.Data,_buf,rlen);
  DoSendASCII(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.DoRTU(APack: PMBPack);
var
  _buf: PKRBuffer;
begin
  try
    if APack.bLen>0 then begin
      New(_buf);
      _buf^:=APack.pBuf^;
      DoSendRTU(APack,_buf,APack.bLen,APack.bRLen);
    end else case APack.MBFunc of
      mbfReadCoils: doRTUReadCoils(APack);
      mbfReadDiscretInputs: doRTUReadDiscretInputs(APack);
      mbfReadHoldingRegisters: doRTUReadHoldingRegisters(APack);
      mbfReadInputRegisters: doRTUReadInputRegisters(APack);
      mbfReadStatus: doRTUReadStatus(APack);
      mbfWriteCoil: doRTUWriteCoil(APack);
      mbfWriteCoils: doRTUWriteCoils(APack);
      mbfWriteHoldingRegister: doRTUWriteHoldingRegister(APack);
      mbfWriteHoldingRegisters: doRTUWriteHoldingRegisters(APack)
      else doRTUUserFunction(APack);
    end;
  except on E: Exception do
    FModbus.DoRuntimeError('TKRMBThread[FModbus.Name="'+
      FModbus.Name+'"] procedure DoRTU;',E);
  end;
end;

procedure TKRMBThread.doRTUReadCoils(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUReadCoils(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUReadDiscretInputs(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUReadDiscretInputs(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUReadHoldingRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUReadHoldingRegisters(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUReadInputRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUReadInputRegisters(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUReadStatus(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUReadStatus(APack^.Addres,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUUserFunction(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len: byte;
begin
  New(_buf);
  _len:=MBMRTUUserFunction(APack^.Addres,APack^.MBFunc,PKRBuffer(APack^.uData),APack^.Count,_buf);
  DoSendRTU(APack,_buf,_len,0);
end;

procedure TKRMBThread.doRTUWriteCoil(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUWriteCoil(APack^.Addres,APack^.Start,GetBit(APack^.DataBt[0],0),_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUWriteCoils(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUWriteCoils(APack^.Addres,APack^.Start,APack^.Count,APack^.DataBt,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUWriteHoldingRegister(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUWriteHoldingRegister(APack^.Addres,APack^.Start,APack^.Data[0],_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doRTUWriteHoldingRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMRTUWriteHoldingRegisters(APack^.Addres,APack^.Start,APack^.Data,_buf,rlen);
  DoSendRTU(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.DoSendASCII(APack: PMBPack; APBuf: PKRBuffer; ABufLen,
  ARecvLen: byte);
begin
  FModbus.FConnector.Send(APBuf,ABufLen,_CallBack,APack,true,ARecvLen,$0D0A,2);
end;

procedure TKRMBThread.DoSendRTU(APack: PMBPack; APBuf: PKRBuffer;
  ABufLen: byte; ARecvLen: byte);
begin
  FModbus.FConnector.Send(APBuf,ABufLen,_CallBack,APack,true,ARecvLen);
end;

procedure TKRMBThread.DoSendTCP(APack: PMBPack; APBuf: PKRBuffer;
  ABufLen: byte; ARecvLen: byte);
begin
  if FCheckID then begin
    APack^.id:=F_ID;
    APBuf^[0]:=F_ID;
    Inc(F_ID);
  end;
  FModbus.FConnector.Send(APBuf,ABufLen,_CallBack,APack,true,ARecvLen);
end;

procedure TKRMBThread.DoTCP(APack: PMBPack);
var
  _buf: PKRBuffer;
begin
  try
    if APack.bLen>0 then begin
      New(_buf);
      _buf^:=APack.pBuf^;
      DoSendTCP(APack,_buf,APack.bLen,APack.bRLen);
    end else case APack.MBFunc of
      mbfReadCoils: doTCPReadCoils(APack);
      mbfReadDiscretInputs: doTCPReadDiscretInputs(APack);
      mbfReadHoldingRegisters: doTCPReadHoldingRegisters(APack);
      mbfReadInputRegisters: doTCPReadInputRegisters(APack);
      mbfReadStatus: doTCPReadStatus(APack);
      mbfWriteCoil: doTCPWriteCoil(APack);
      mbfWriteCoils: doTCPWriteCoils(APack);
      mbfWriteHoldingRegister: doTCPWriteHoldingRegister(APack);
      mbfWriteHoldingRegisters: doTCPWriteHoldingRegisters(APack)
      else doTCPUserFunction(APack);
    end;
  except on E: Exception do
    FModbus.DoRuntimeError('TKRMBThread[FModbus.Name="'+
      FModbus.Name+'"] procedure DoTCP;',E);
  end;
end;

procedure TKRMBThread.doTCPReadCoils(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPReadCoils(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPReadDiscretInputs(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPReadDiscretInputs(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPReadHoldingRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPReadHoldingRegisters(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPReadInputRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPReadInputRegisters(APack^.Addres,APack^.Start,APack^.Count,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPReadStatus(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len, rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPReadStatus(APack^.Addres,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPUserFunction(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len: byte;
begin
  New(_buf);
  _len:=MBMTCPUserFunction(APack^.Addres,APack^.MBFunc,PKRBuffer(APack^.uData),APack^.Count,_buf);
  DoSendTCP(APack,_buf,_len,0);
end;

procedure TKRMBThread.doTCPWriteCoil(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPWriteCoil(APack^.Addres,APack^.Start,GetBit(APack^.DataBt[0],0),_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPWriteCoils(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPWriteCoils(APack^.Addres,APack^.Start,APack^.Count,APack^.DataBt,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPWriteHoldingRegister(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPWriteHoldingRegister(APack^.Addres,APack^.Start,APack^.Data[0],_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.doTCPWriteHoldingRegisters(APack: PMBPack);
var
  _buf: PKRBuffer;
  _len,rlen: byte;
begin
  New(_buf);
  _len:=MBMTCPWriteHoldingRegisters(APack^.Addres,APack^.Start,APack^.Data,_buf,rlen);
  DoSendTCP(APack,_buf,_len,rlen);
end;

procedure TKRMBThread.KRExecute;
begin
  if FQueue.Count>0 then _exec(FQueue.Pop);
end;

procedure TKRMBThread._CallBack(AError: integer; APack: PKRBuffer;
  ALength: integer; AData: Pointer);
var
  _Data: PMBPack;
  _Regs: TKRRegisters;
  _err: integer;
  _DataBt: TKRBytes;
  bt: byte;
  p: pointer;


{  s: String;
  i: integer;}
begin


  _Data:=AData;
  p:=nil;
  try
    _err:=0;
    if AError<>0 then _err:=AError*-1-100 else begin
      if _Data^.MBType=mbtTCP then begin
        if FCheckID and(_Data^.id<>APack^[0]) then _err:=-mbmeIncorrectID else begin
          if APack^[7] AND $7F <> _Data^.MBFunc then _err:=-mbmeIncorrectFunction else begin
            if GetBit(APack^[7],7) then _err:=APack^[8] else begin
              case _Data^.MBFunc of
                mbfReadCoils: begin
                  _err:=chTCPReadCoils(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
                mbfReadDiscretInputs: begin
                  _err:=chTCPReadDiscretInputs(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
                mbfReadHoldingRegisters: begin
                  _err:=chTCPReadHoldingRegisters(APack, ALength, _Regs);
                  p:=@_Regs;
                end;
                mbfReadInputRegisters: begin
                  _err:=chTCPReadInputRegisters(APack, ALength, _Regs);
                  p:=@_Regs;
                end;
                mbfReadStatus: begin
                  _err:=chTCPReadStatus(APack, ALength, bt);
                  p:=@bt;
                end;
                mbfWriteCoil: _err:=chTCPWriteCoil(APack, ALength);
                mbfWriteCoils: _err:=chTCPWriteCoils(APack, ALength);
                mbfWriteHoldingRegister: _err:=chTCPWriteHoldingRegister(APack, ALength);
                mbfWriteHoldingRegisters: _err:=chTCPWriteHoldingRegisters(APack, ALength)
                else begin
                  _err:=chTCPUserFunction(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
              end;
            end;
          end;
        end;
      end else if _Data^.MBType=mbtRTU then begin
        if KRCRC16(APack,ALength-2)<>BytesToWord(APack^[ALength-1],APack^[ALength-2]) then _err:=-mbmeCRC else begin
          if APack^[1] AND $7F <> _Data^.MBFunc then _err:=-mbmeIncorrectFunction else begin
            if GetBit(APack^[1],7) then _err:=APack^[2]
            else begin
              case _Data^.MBFunc of
                mbfReadCoils: begin
                  _err:=chRTUReadCoils(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
                mbfReadDiscretInputs: begin
                  _err:=chRTUReadDiscretInputs(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
                mbfReadHoldingRegisters: begin
                  _err:=chRTUReadHoldingRegisters(APack, ALength, _Regs);
                  p:=@_Regs;
                end;
                mbfReadInputRegisters: begin
                  _err:=chRTUReadInputRegisters(APack, ALength, _Regs);
                  p:=@_Regs;
                end;
                mbfReadStatus: begin
                  _err:=chRTUReadStatus(APack, ALength, bt);
                  p:=@bt;
                end;
                mbfWriteCoil: _err:=chRTUWriteCoil(APack, ALength);
                mbfWriteCoils: _err:=chRTUWriteCoils(APack, ALength);
                mbfWriteHoldingRegister: _err:=chRTUWriteHoldingRegister(APack, ALength);
                mbfWriteHoldingRegisters: _err:=chRTUWriteHoldingRegisters(APack, ALength)
                else begin
                  _err:=chRTUUserFunction(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
              end;
            end;
          end;
        end;
      end else if _Data^.MBType=mbtASCII then begin

{s:='';
for i := 0 to ALength do s:=s+Chr(APack^[i]);
REAddLog('RECV: '+s);
REAddLog('CRC: '+Chr(APack^[ALength-4])+Chr(APack^[ALength-3]));
REAddLog('CRC: '+IntToStr(MBHexToValue(APack^[ALength-4],APack^[ALength-3])));
REAddLog('LRC: '+IntToStr(MBLRC(APack,ALength)));}

        if MBLRC(APack,ALength)<>MBHexToValue(APack^[ALength-4],APack^[ALength-3])then _err:=-mbmeCRC else begin
          bt:=MBHexToValue(APack^[3],APack^[4]);
          if bt AND $7F <> _Data^.MBFunc then _err:=-mbmeIncorrectFunction else begin
            if GetBit(bt,7) then _err:=MBHexToValue(APack^[5],APack^[6])
            else begin
              case _Data^.MBFunc of
                mbfReadCoils: begin
                  _err:=chASCIIReadCoils(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
                mbfReadDiscretInputs: begin
                  _err:=chASCIIReadDiscretInputs(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
                mbfReadHoldingRegisters: begin
                  _err:=chASCIIReadHoldingRegisters(APack, ALength, _Regs);
                  p:=@_Regs;
                end;
                mbfReadInputRegisters: begin
                  _err:=chASCIIReadInputRegisters(APack, ALength, _Regs);
                  p:=@_Regs;
                end;
                mbfReadStatus: begin
                  _err:=chASCIIReadStatus(APack, ALength, bt);
                  p:=@bt;
                end;
                mbfWriteCoil: _err:=chASCIIWriteCoil(APack, ALength);
                mbfWriteCoils: _err:=chASCIIWriteCoils(APack, ALength);
                mbfWriteHoldingRegister: _err:=chASCIIWriteHoldingRegister(APack, ALength);
                mbfWriteHoldingRegisters: _err:=chASCIIWriteHoldingRegisters(APack, ALength)
                else begin
                  _err:=chASCIIUserFunction(APack, ALength, _DataBt);
                  p:=@_DataBt;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    if Assigned(_Data^.CallBack) then _Data^.CallBack(_err,p);
  except on E: Exception do
    FModbus.DoRuntimeError('TKRMBThread[FModbus.Name="'+
      FModbus.Name+'"] procedure _CallBack; ',E);
  end;

  try

  Dispose(APack);
  Dispose(_Data);
  except on E: Exception do
    FModbus.DoRuntimeError('TKRMBThread[FModbus.Name="'+
      FModbus.Name+'"] procedure _CallBack; ',E);
  end;
end;

procedure TKRMBThread._exec(APack: PMBPack);
begin
  case APack.MBType of
    mbtTCP: doTCP(APack);
    mbtRTU: doRTU(APack);
    mbtASCII: doASCII(APack);
  end;
end;

end.
