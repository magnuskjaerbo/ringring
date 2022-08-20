unit uIO;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, d_Debug;

Type
  TIO = class
    private
      FDebug : TfrmDebug;
    public
      constructor Create ();
      function ReadMotionSensor () : boolean;
      procedure WriteRing (AState : boolean);
  end;


implementation

constructor TIO.Create ();
begin
    {$IFDEF Windows}
    FDebug := TfrmDebug.Create(nil);
    {$ENDIF}

    {$IFNDEF Windows}
   { Prepare SoC pin 17 (pin 11 on GPIO port) for access: }
   try
     fileDesc := fpopen('/sys/class/gpio/export', O_WrOnly);
     gReturnCode := fpwrite(fileDesc, PIN_17[0], 2);
     FLogger.Add('Prepare SoC pin 17 (pin 11 on GPIO port) for access: write: ' + IntToStr(gReturnCode));
   finally
     gReturnCode := fpclose(fileDesc);
     FLogger.Add('Prepare SoC pin 17 (pin 11 on GPIO port) for access: close: ' + IntToStr(gReturnCode));
   end;
   { Set SoC pin 17 as output: }
   try
     fileDesc := fpopen('/sys/class/gpio/gpio17/direction', O_WrOnly);
     gReturnCode := fpwrite(fileDesc, OUT_DIRECTION[0], 3);
     FLogger.Add('Set SoC pin 17 as output: write: ' + IntToStr(gReturnCode));
   finally
     gReturnCode := fpclose(fileDesc);
     FLogger.Add('Set SoC pin 17 as output: close: ' + IntToStr(gReturnCode));
   end;

   { Prepare SoC pin 18 (pin 12 on GPIO port) for access: }
    try
      fileDesc := fpopen('/sys/class/gpio/export', O_WrOnly);
      gReturnCode := fpwrite(fileDesc, PIN_18[0], 2);
      FLogger.Add(IntToStr(gReturnCode));
    finally
      gReturnCode := fpclose(fileDesc);
      FLogger.Add(IntToStr(gReturnCode));
    end;
    { Set SoC pin 18 as input: }
    try
      fileDesc := fpopen('/sys/class/gpio/gpio18/direction', O_WrOnly);
      gReturnCode := fpwrite(fileDesc, IN_DIRECTION[0], 2);
      FLogger.Add(IntToStr(gReturnCode));
    finally
      gReturnCode := fpclose(fileDesc);
      FLogger.Add(IntToStr(gReturnCode));
    end;
 {$ENDIF}


end;

procedure TIO.WriteRing (AState : boolean);
begin

  {$IFDEF Windows}
    if FDebug <> nil then
    begin
      FDebug.PIN17.Checked := AState;
      FDebug.PIN17.Update;
    end;
  {$ENDIF}

  {$IFNDEF Windows}

  if AState then
    begin
      // Swith SoC pin 17 on:
      try
        fileDesc := fpopen('/sys/class/gpio/gpio17/value', O_WrOnly);
        gReturnCode := fpwrite(fileDesc, PIN_ON[0], 1);
        FLogger.Add('write: ' + IntToStr(gReturnCode));
      finally
        gReturnCode := fpclose(fileDesc);
        FLogger.Add('close: ' + IntToStr(gReturnCode));
      end;
    end
    else
    begin
       // Switch SoC pin 17 off:
      try
        fileDesc := fpopen('/sys/class/gpio/gpio17/value', O_WrOnly);
        gReturnCode := fpwrite(fileDesc, PIN_OFF[0], 1);
        FLogger.Add('write: ' + IntToStr(gReturnCode));
      finally
        gReturnCode := fpclose(fileDesc);
        FLogger.Add('close: ' + IntToStr(gReturnCode));
      end;
    end;


  {$ENDIF}

end;

function TIO.ReadMotionSensor () : boolean;
begin

  {$IFDEF Windows}
    result :=  FDebug.CheckBox1.Checked;
  {$ENDIF}

  {$IFNDEF Windows}
  try
   { Open SoC pin 18 (pin 12 on GPIO port) in read-only mode: }
   fileDesc := fpopen('/sys/class/gpio/gpio18/value', O_RdOnly);
   if fileDesc > 0 then
   begin
     { Read status of this pin (0: button pressed, 1: button released): }
     gReturnCode := fpread(fileDesc, buttonStatus[1], 1);


     if buttonStatus = '0' then
       ImMotion->Visible := false;
     else
       begin
           ImMotion->Visible := true;
       end;

     FLogger.Add(IntToStr(gReturnCode) + ': ' + buttonStatus);
     if buttonStatus = '0' then
       Image2.Visible := False
     else
       begin
         Image2.Visible := True;
         TimerScreenBlanc.Enabled := true;
         ShapeTimeOut.Width := FSleeptime;
         if ExtendedNotebook1.ActivePage = tsBlack then
         begin
              SwapToFront;
         end;
       end;
   end;
 finally
   { Close SoC pin 18 (pin 12 on GPIO port) }
   gReturnCode := fpclose(fileDesc);
   Flogger.Add(IntToStr(gReturnCode));
 end;
  {$ENDIF}

end;

end.

