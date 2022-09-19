unit GPIOInterface;

{$mode objfpc}{$H+}

interface
uses {$IFNDEF Windows}Unix, BaseUnix,{$ENDIF}Classes, SysUtils, FileUtil;

const
  MinGpio = 2;
  MaxGpIO = 27;

  ERR_MODE_NOT_INPUT	 = -1;
  ERR_MODE_NOT_OUTPUT	 = -2;

type

  TAvailableGpio = MinGpio..MaxGpio;
  TGpioStatus = (ioInput,ioOutput,ioUnset);
  TGpioInterface = class(TObject)
    private
      FReturnCode: longint;
      FGpioStatus: array [TAvailableGpio] of TGpioStatus;
      function ReadGpioStatus(i: TAvailableGpio): TGpioStatus;
    public
      constructor Create; overload;
      procedure ResetGPIO;
      function ResetPin(GpioNumber: TAvailableGpio): longint;
      function Setup(GpioNumber: TAvailableGpio; Mode: TGpioStatus): longint;
      function Output(GpioNumber: TAvailableGpio; HighLevel: boolean): longint;
      property GpioStatus[i: TAvailableGpio] : TGpioStatus read ReadGpioStatus;
      property ReturnCode: longint read FReturnCode;
  end;


implementation


{
 *******************************************************************************
 TGpioInterface
 *******************************************************************************
}
constructor TGpioInterface.Create;
begin
  ResetGPIO;
end;
{
 Reset all PINs
}
procedure TGpioInterface.ResetGPIO;
var
  i: integer;
begin
  for i := MinGpio to MaxGpio do
  begin
    ResetPin(i);
  end;
end;

{
 Get current PIN status
}
function TGpioInterface.ReadGpioStatus(i: TAvailableGpio): TGpioStatus;
begin
  Result := FGpioStatus[i];
end;
{
 Reset PIN to unset
}
function TGpioInterface.ResetPin(GpioNumber: TAvailableGpio): longint;

var
  ioFile: integer;
  portNum: string;
  portBuf: PChar;

begin

  // Only if compiled for Raspi
  //FReturnCode := fpsystem(format('echo "%d" > /sys/class/gpio/unexport',[GpioNumber]));

  // Unexport port
  portNum := IntToStr(GpioNumber) + #0;
  portBuf := StrAlloc(Length(portNum));
  StrPCopy(portBuf,portNum);
  {$ifdef CPUARM}
  try
    ioFile := FpOpen('/sys/class/gpio/unexport', O_WrOnly);
    FReturnCode := FpWrite(ioFile, portBuf[0], length(portNum)-1);
  finally
    FReturnCode := FpClose(ioFile);
  end;
  {$else}
  FReturnCode := 0;
  {$endif}
  if FReturnCode = 0 then
  begin
    FGpioStatus[GpioNumber] := ioUnset;
  end;
  Result := FReturnCode;
end;

{
 Set PIN to input or output
}
function TGpioInterface.Setup(GpioNumber: TAvailableGpio; Mode: TGpioStatus): longint;
{$ifdef CPUARM}
var
  ioFile: integer;
  portNum: string;
  portBuf: PChar;
{$endif}
begin
  {$ifdef CPUARM}

  // Export port
  portNum := IntToStr(GpioNumber) + #0;
  portBuf := StrAlloc(Length(portNum));
  StrPCopy(portBuf,portNum);
  try
    ioFile := FpOpen('/sys/class/gpio/export', O_WrOnly);
    FReturnCode := FpWrite(ioFile, portBuf[0], length(portNum)-1);
  finally
    FReturnCode := FpClose(ioFile);
  end;

  Sleep(100); // had to insert a little delay to avoid error in open or write

  if FReturnCode = 0 then //length(s) -1 then
  begin
    try
      ioFile := FpOpen(Format('/sys/class/gpio/gpio%d/direction',[GpioNumber]), O_WrOnly);
      case Mode of
        ioInput: FReturnCode := FpWrite(ioFile, 'in', 2);
        ioOutput: FReturnCode := FpWrite(ioFile, 'out', 3);
      end;
    finally
      FReturnCode := FpClose(ioFile);
    end;
    if FReturnCode = 0 then //3 then
    begin
      FReturnCode := 0;
    end;
    Result := FReturnCode;
  end;
  {$else}
  FReturnCode := 0;
  {$endif}
  if FReturnCode = 0 then
  begin
    FGpioStatus[GpioNumber] := Mode;
  end;
  Result := FReturnCode;
end;

{
 Write value to PIN
 GpioNumber: GPIO Number
 HighLevel: boolean True to turn PIN on , False to turn PIN off
}
function TGpioInterface.Output(GpioNumber: TAvailableGpio; HighLevel: boolean): longint;
{$ifdef CPUARM}
var
  ioFile: integer;
  valStr: string;
  valBuf: PChar;
{$endif}
begin
  Result := 0;
  if (FGpioStatus[GpioNumber] = ioOutput) then
  begin
    {$ifdef CPUARM}
    if HighLevel then
    begin
      valStr := '1'#0;
    end
    else
    begin
      valStr := '0'#0;
    end;
//    FReturnCode := fpsystem(format('echo "%s" > /sys/class/gpio/gpio%d/value',[value,GpioNumber]));

    // Set port value
    valBuf := StrAlloc(2);
    StrPCopy(valBuf,valStr);
    try
      ioFile := FpOpen(Format('/sys/class/gpio/gpio%d/value',[GpioNumber]), O_WrOnly);
      FReturnCode := FpWrite(ioFile, valBuf[0], 1);
    finally
      FReturnCode := FpClose(ioFile);
    end;
    {$else}
    FReturnCode := 0;
    {$endif}
    if FReturnCode = 0 then
    begin
      FGpioStatus[GpioNumber] := ioOutput;
    end;
  end
  if (FGpioStatus[GpioNumber] = ioInput) then
  begin
    {$ifdef CPUARM}
    if HighLevel then
    begin
      valStr := '1'#0;
    end
    else
    begin
      valStr := '0'#0;
    end;
//    FReturnCode := fpsystem(format('echo "%s" > /sys/class/gpio/gpio%d/value',[value,GpioNumber]));

    // Set port value
    valBuf := StrAlloc(2);
    StrPCopy(valBuf,valStr);
    try
      ioFile := FpOpen(Format('/sys/class/gpio/gpio%d/value',[GpioNumber]), O_RdOnly);
      FReturnCode := FpWrite(ioFile, valBuf[0], 1);
    finally
      FReturnCode := FpClose(ioFile);
    end;
    {$else}
    FReturnCode := 0;
    {$endif}
    if FReturnCode = 0 then
    begin
      FGpioStatus[GpioNumber] := ioOutput;
    end;
  end
  else
  begin
    FReturnCode := ERR_MODE_NOT_OUTPUT; // Pin is not in output mode
  end;
   Result := FReturnCode;
end;
end.

