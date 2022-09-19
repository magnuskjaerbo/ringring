unit uIO;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, d_Debug, GPIOInterface;

Type
  TIO = class
    private
      FDebug : TfrmDebug;
      GPIO : TGpioInterface;
    public
      constructor Create ();
      function ReadMotionSensor () : boolean;
      procedure WriteRing (AState : boolean);
  end;


implementation

constructor TIO.Create ();
begin

  GPIO := TGpioInterface.Create;
  GPIO.Setup(26, ioOutput);
  GPIO.Setup(20, ioOutput);
  GPIO.Output(26, false);
  GPIO.Output(20, true);

  GPIO.Setup (18, ioInput);
  {$IFDEF Windows}
    FDebug := TfrmDebug.Create(nil);
  {$ENDIF}

    exit;




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

  GPIO.Output(26, AState);
  GPIO.Output(20, not AState);



end;

function TIO.ReadMotionSensor () : boolean;
begin



  {$IFDEF Windows}
    result :=  FDebug.CheckBox1.Checked;
  {$ENDIF}

  if (GPIO.Output(18, true) > 0) then
    begin
      result := true;
    end;


end;

end.

