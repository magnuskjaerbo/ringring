unit Main;

{$mode objfpc}{$H+}

interface

uses
  {$IFNDEF Windows}baseunix, Unix,{$ENDIF}Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls,
  IpHtml, Ipfilebroker, uLogger, uSettings,
  SQLDB, DateUtils, uEvents, uIO, d_Control;

type

  { TForm1 }

  TForm1 = class(TForm)
    IdleTimer1: TIdleTimer;
    Image1: TImage;
    Image2: TImage;
    ImageSilent: TImage;
    ImMotion: TImage;
    LabelStatus: TLabel;
    LabelClock: TLabel;
    Label2: TLabel;
    LabelNextEvent: TLabel;
    LabelNextEvent1: TLabel;
    LabelNextEvent2: TLabel;
    LabelNextEvent3: TLabel;
    LabelNextEvent4: TLabel;
    LabelNextEventMessage: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    PanelMain: TPanel;
    PanelBottomLed: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    ShapeIdleTrigger: TShape;
    ShapeMainTrigger: TShape;
    Shape4: TShape;
    TimerMain: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure FormShow(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure LabelClockClick(Sender: TObject);
    procedure LabelClockMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure Shape3ChangeBounds(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);


  private
    FDimValue : Real;
    FMainTimerCheckRemote: integer;
    FMainTimerClearStatus: integer;
    FRingOnce: boolean;
    FLogger: TLogger;
    FSettings: TfrmSettings;
    Events: TEvents;
    FNextEvent: TEvent;
    FIO: TIO;
    procedure HandleEvent(LabelMessage, LabelDate: TLabel; Image: TImage;
      AEvents: array of TEvent);
    procedure ReadFromRemote;
    function TimeBetweenStr(AFrom, ATo: TDateTime): string;
    procedure ExecuteRingEvent(AEvent: TEvent);
    procedure Delay(dt: DWORD);
    procedure BlinkScreen();
    procedure CheckRemote();
    procedure DimDisplay();
  public

  end;


var
  Form1: TForm1;


const
  debug: boolean = False;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

  {$IFDEF Unix}
  //fpSystem('xrandr --output HDMI-1 --brightness 0.5');
  {$ENDIF}

  //xrandr --output HDMI-1 --brightness 1

   {$IFDEF Windows}
   {$endif}
  Label2.Caption := '1.0.14';
  DoubleBuffered := True;
  FMainTimerCheckRemote := 0;
  FMainTimerClearStatus := 0;

  DefaultFormatSettings.ShortDateFormat := 'yyyy-mm-dd';

  BorderStyle := bsNone;

  LabelNextEvent1.Caption := '';
  LabelNextEvent2.Caption := '';
  LabelNextEvent3.Caption := '';
  LabelNextEvent4.Caption := '';
  Image1.Visible := False;
  Image2.Visible := False;
  Color := clBlack;

  {$IFDEF Windows}
  Width := 1280;
  Height := 720;
  {$ELSE}
  Left := -2;
  Top := -2;
  Width := Screen.Width + 4;
  Height := Screen.Height + 4;
  WindowState := wsFullScreen;
    {$endif}

  FSettings := TfrmSettings.Create(Self, LabelStatus);
  FSettings.Parent := Self;
  Events := TEvents.Create(LabelStatus, FSettings);
  FNextEvent := Events.NextEvent(Now);
  FIO := TIO.Create();

end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  Screen.Cursor := crDefault;
end;

{------------------------------------------------------------------------------}
procedure TForm1.FormShow(Sender: TObject);
begin
  Color := clBlack;
  LabelClock.Color := clBlack;
  LabelNextEventMessage.Color := clBlack;
  LabelNextEvent.Color := clBlack;

end;

{------------------------------------------------------------------------------}
procedure TForm1.IdleTimer1Timer(Sender: TObject);
begin
  if (ShapeIdleTrigger.Brush.Color = clBlack) then
    ShapeIdleTrigger.Brush.Color := clBlue
  else
    ShapeIdleTrigger.Brush.Color := clBlack;

  //   rc := FIO.ReadMotionSensor();

  //   if rc = false then
  //  begin
  //     ImMotion.Visible := false;
  //     TimerCheckRemote.Enabled:=true;
  //   end
  //   else
  //     begin
  //       ImMotion.Visible := true;
  //       PanelMain.Visible:=true;
  //     end;

end;

{------------------------------------------------------------------------------}
procedure TForm1.LabelClockClick(Sender: TObject);
var
  control : TfrmControl;
begin

  control := TfrmControl.Create(self);
  control.Silent:=ImageSilent.Visible;
  if (control.ShowModal = mrOk) then
  begin
  	ImageSilent.Visible := control.Silent;

    if (control.Reboot = True) then
    begin
      {$IFDEF Unix}
      fpSystem('reboot');
      {$ENDIF}
    end;

    if (control.CloseApp = True) then
    begin
      Close;
    end;
  end;
  control.Destroy;

end;

procedure TForm1.LabelClockMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin

end;

procedure TForm1.Shape3ChangeBounds(Sender: TObject);
begin

end;


{------------------------------------------------------------------------------}
procedure TForm1.BlinkScreen();
var
  shape: TShape;
begin
  PanelMain.Visible := False;
  shape := TShape.Create(Self);
  shape.Parent := Self;

  shape.Left := 0;
  shape.Top := 0;
  shape.Width := self.Width;
  shape.Height := 1;
  shape.Visible := True;
  shape.BringToFront;
  shape.Update;

  shape.Brush.Color := clRed;
  shape.Top := 0;
  shape.Height := self.Height;
  Delay(1000);
  shape.Brush.Color := clGreen;
  Delay(1000);
  shape.Brush.Color := clBlue;
  Delay(1000);
  shape.Brush.Color := clWhite;
  Delay(1000);
  shape.Destroy;
  PanelMain.Visible := True;
end;

{------------------------------------------------------------------------------}
procedure TForm1.TimerMainTimer(Sender: TObject);
var
  timeleft: int64;
  activated: boolean;
begin

  if (FMainTimerClearStatus > 4) then
  begin
    LabelStatus.Caption := '';
    FMainTimerClearStatus := 0;
  end;

  TimerMain.Enabled := False;
  BeginFormUpdate;
  LabelClock.Caption := FormatDateTime('hh:nn', Now);


  LabelNextEvent.Caption := TimeBetweenStr(Now, FNextEvent.Occurance);
  LabelNextEventMessage.Caption := FNextEvent.Message;

  if (ShapeMainTrigger.Brush.Color = clBlack) then
    ShapeMainTrigger.Brush.Color := clGray
  else
    ShapeMainTrigger.Brush.Color := clBlack;


  timeleft := SecondsBetween(FNextEvent.Occurance, Now);
  if (timeleft < Panel2.Width) then
  begin
    Shape4.BorderSpacing.Left := Round((Panel2.Width - timeleft) * 0.5);
    Shape4.BorderSpacing.Right := Shape4.BorderSpacing.Left;
  end
  else
  begin
    Shape4.BorderSpacing.Left := 0;
    Shape4.BorderSpacing.Right := 0;
  end;




  activated := Events.Activate(FNextEvent);
  if (FRingOnce or activated) then
  begin
    FRingOnce := False;
    ExecuteRingEvent(FNextEvent);
    if (activated) then FNextEvent :=
        Events.NextEvent(IncMinute(FNextEvent.Occurance));
  end;

  if (FMainTimerCheckRemote = 60) or (FMainTimerCheckRemote = 0) then
  begin
    FMainTimerCheckRemote := 1;
    CheckRemote();
  end;

  EndFormUpdate;

  Inc(FMainTimerCheckRemote);
  Inc(FMainTimerClearStatus);
//  DimDisplay();
  TimerMain.Enabled := True;
end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
begin

end;

{------------------------------------------------------------------------------}
procedure TForm1.ExecuteRingEvent(AEvent: TEvent);
var
  durArr: TStringArray;
  dur: string;
  odd: boolean;
begin

  if (ImageSilent.Visible = False) then
  begin
    durArr := AEvent.Durations.Split(',');

    odd := True;
    for dur in durArr do
    begin
      if odd then
      begin
        FIO.WriteRing(True);
        Delay(dur.ToInteger * 100);
        FIO.WriteRing(False);
      end
      else
      begin
        Delay(dur.ToInteger * 100);
        FIO.WriteRing(False);
      end;
      odd := not odd;
    end;

    FIO.WriteRing(False);

  end;
  BlinkScreen();
end;

{------------------------------------------------------------------------------}
function TForm1.TimeBetweenStr(AFrom, ATo: TDateTime): string;
var

  days: integer;

  sec: integer;
  minutes: integer;
  dhours: double;
  rem: double;
  hours: integer;
  strDays: string;
  strHours: string;
  strMinutes: string;
begin
  sec := SecondsBetween(AFrom, ATo);

  days := sec div (3600 * 24);
  sec := sec - ((3600 * 24) * days);
  dhours := sec / 3600;
  hours := sec div 3600;
  rem := dhours - hours;
  minutes := Round(60 * rem + 0.5);


  if (minutes = 60) then
  begin
    minutes := 0;
    hours := hours + 1;
  end;
  if (hours = 24) then
  begin
    hours := 0;
    days := days + 1;
  end;

  strDays := '';
  if (days > 1) then
  begin
    strDays := IntToStr(days) + ' dagar ';
  end
  else if (days = 1) then
  begin
    strDays := IntToStr(days) + ' dag ';
  end;

  strHours := '';
  if (hours > 1) then
  begin
    strHours := IntToStr(hours) + ' tímar ';
  end
  else if (hours = 1) then
  begin
    strHours := IntToStr(hours) + ' tíma ';
  end;

  strminutes := '';
  if (minutes > 1) then
  begin
    strminutes := IntToStr(minutes) + ' minuttir ';
  end
  else if (minutes = 1) then
  begin
    strminutes := IntToStr(minutes) + ' minutt ';
  end;


  Result := '';
  if (strDays <> '') then
  begin
    Result := Result + strDays;
  end;

  if (strHours <> '') then
  begin
    if Result <> '' then Result := Result + ' og ' + strHours;
    if Result = '' then Result := strHours;
  end;

  if (strMinutes <> '') then
  begin
    if Result <> '' then Result := Result + ' og ' + strMinutes;
    if Result = '' then Result := strMinutes;
  end;
end;

procedure TForm1.ReadFromRemote;
var
  sectonext: integer;
begin
  sectonext := SecondsBetween(Now, FNextEvent.Occurance);

  if (sectonext > 30) or (sectonext < 0) then
  begin
    FSettings.Destroy;
    Events.Destroy;

    FSettings := TfrmSettings.Create(Self, LabelStatus);
    FSettings.Parent := Self;
    Events := TEvents.Create(LabelStatus, FSettings);
    FNextEvent := Events.NextEvent(Now);
  end;
end;

procedure TForm1.HandleEvent(LabelMessage, LabelDate: TLabel;
  Image: TImage; AEvents: array of TEvent);
begin

  if Length(AEvents) > 0 then
  begin
    if (LabelMessage.Tag > Length(AEvents) - 1) then LabelMessage.Tag := 0;
    LabelMessage.Caption := AEvents[LabelMessage.Tag].Message;
    if Length(AEvents) > 1 then
    begin
      LabelDate.Caption := DateToStr(AEvents[LabelMessage.Tag].Occurance) +
        '  ' + IntToStr(LabelMessage.Tag + 1) + ' / ' + IntToStr(Length(AEvents));
    end
    else
    begin
      LabelDate.Caption := DateToStr(AEvents[LabelMessage.Tag].Occurance);
    end;
    Image.Visible := True;
    LabelMessage.Tag := LabelMessage.Tag + 1;
  end
  else
  begin
    LabelMessage.Caption := '';
    LabelDate.Caption := '';
    Image.Visible := False;
  end;
end;

{------------------------------------------------------------------------------}
procedure TForm1.Delay(dt: DWORD);
var
  tc: DWORD;
begin
  tc := GetTickCount64;
  while (GetTickCount64 < tc + dt) and (not Application.Terminated) do
    Application.ProcessMessages;
end;

{------------------------------------------------------------------------------}
procedure TForm1.CheckRemote();
var
  Events1: array of TEvent;
  Events2: array of TEvent;
begin

  ReadFromRemote;

  Events.GetRemoteData;

  setLength(Events1, 0);
  setLength(Events2, 0);

  Events.NextRemoteEvent(Events1, Now);
  HandleEvent (LabelNextEvent1, LabelNextEvent2, Image1, Events1);

  if Length(Events1) > 0 then
  begin
    Events.NextRemoteEvent(Events2, incDay(Events1[0].Occurance));
    HandleEvent(LabelNextEvent3, LabelNextEvent4, Image2, Events2);
  end;
end;

procedure TForm1.DimDisplay();
var
  MinToNext : integer;
  command : String;
begin

  MinToNext := MinutesBetween(Now, FNextEvent.Occurance);


  FDimValue := 1;

  case MinToNext of
  	5 : FDimValue := 0.75;
    4 : FDimValue := 0.8;
    3 : FDimValue := 0.85;
    2 : FDimValue := 0.9;
    1 : FDimValue := 0.95;
    0 : FDimValue := 1.0;
    else
      FDimValue := 0.7;
      if (HourOf (Now) > 18) then FDimValue:=0.5;
      if (HourOf (Now) < 8) then FDimValue:=0.5;
  end;

  command := 'xrandr --output HDMI-1 --brightness ' + FLoatToStr (FDimValue);

  {$IFDEF Unix}
  fpSystem(command);
  {$ENDIF}

end;

end.
