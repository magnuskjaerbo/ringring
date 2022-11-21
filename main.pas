unit Main;

{$mode objfpc}{$H+}

interface


uses
  {$IFNDEF Windows}baseunix, Unix,{$ENDIF}Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls,
  IpHtml, Ipfilebroker, uSettings,
  SQLDB, DateUtils, uEvents, uIO, d_Control, d_Clock, d_NextRing, d_OnlineEvents;

type

  { TForm1 }

  TForm1 = class(TForm)
    IdleTimer1: TIdleTimer;
    LabelStatus: TLabel;
    Label2: TLabel;
    PanelOnlineEvents: TPanel;
    PanelClock: TPanel;
    PanelMain: TPanel;
    PanelBottomLed: TPanel;
    ShapeIdleTrigger: TShape;
    ShapeMainTrigger: TShape;
    TimerMain: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
  private
    FClock: TfrmClock;
    //FNextRing: TfrmNextRing;
    FOnlineEvents: TfrmOnlineEvents;
    FMainTimerCheckRemote: integer;
    FMainTimerClearStatus: integer;
    FRingOnce: boolean;
    FSettings: TfrmSettings;
    Events: TEvents;
    FNextEvent: TEvent;
    FIO: TIO;
    procedure ReadFromRemote;
    procedure ExecuteRingEvent(AEvent: TEvent);
    procedure Delay(dt: DWORD);
    procedure BlinkScreen();
    procedure CheckRemote();
    procedure ExecuteControls (Sender: TObject);
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
  Label2.Caption := '1.1.16';
  DoubleBuffered := True;
  FMainTimerCheckRemote := 0;
  FMainTimerClearStatus := 0;

  DefaultFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  DefaultFormatSettings.ShortTimeFormat := 'hh:nn:ss';

  BorderStyle := bsNone;

  Color := clBlack;

  {$IFDEF Windows}
  Width := 1024;
  Height := 600;
  {$ELSE}
  Left := -2;
  Top := -2;
  Width := Screen.Width + 4;
  Height := Screen.Height + 4;
  WindowState := wsFullScreen;
    {$endif}


  FClock := TfrmClock.Create (PanelClock);
  FClock.Parent := PanelClock;
  FClock.Align := alClient;
  FClock.OnClick := @ExecuteControls;
  FClock.LabelClock.OnClick := @ExecuteControls;
  FClock.ImageSilent.OnClick := @ExecuteControls;
  FClock.PaintBox1.OnClick := @ExecuteControls;
  FClock.Show ();

  //FNextRing := TfrmNextRing.Create (PanelNextRing);
  //FNextRing.Parent := PanelNextRing;
  //FNextRing.Align := alClient;
  //FNextRing.Show ();

  FOnlineEvents := TfrmOnlineEvents.Create (PanelOnlineEvents);
  FOnlineEvents.Parent := PanelOnlineEvents;
  FOnlineEvents.Align := alClient;
  FOnlineEvents.Show ();

  FSettings := TfrmSettings.Create(Self, LabelStatus);
  FSettings.Parent := Self;
  Events := TEvents.Create(LabelStatus, FSettings);
  FNextEvent := Events.NextEvent(Now);
  FIO := TIO.Create();

end;

{------------------------------------------------------------------------------}
procedure TForm1.FormShow(Sender: TObject);
begin
  Color := clBlack;
end;

{------------------------------------------------------------------------------}
procedure TForm1.IdleTimer1Timer(Sender: TObject);
begin
  if (ShapeIdleTrigger.Brush.Color = clBlack) then
    ShapeIdleTrigger.Brush.Color := clBlue
  else
    ShapeIdleTrigger.Brush.Color := clBlack;
end;

{------------------------------------------------------------------------------}
procedure TForm1.ExecuteControls(Sender: TObject);
var
  control : TfrmControl;
begin

  control := TfrmControl.Create(self);
  control.Silent:=FClock.Silent;
  control.Delay := FClock.Delay;
  if (control.ShowModal = mrOk) then
  begin
  	FClock.Silent := control.Silent;
    FClock.Delay:=control.Delay;

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
  activated: boolean;
begin

  	if (FMainTimerClearStatus > 4) then
  	begin
    	LabelStatus.Caption := '';
    	FMainTimerClearStatus := 0;
  	end;

  	TimerMain.Enabled := False;
  	BeginFormUpdate;
  	FClock.UpdateGUI(FNextEvent);
	//FNextRing.UpdateGUI (FNextEvent);

  	if (ShapeMainTrigger.Brush.Color = clBlack) then
    	ShapeMainTrigger.Brush.Color := clGray
  	else
    	ShapeMainTrigger.Brush.Color := clBlack;


  	activated := Events.Activate(FNextEvent, FClock.Delay);
  	if (FRingOnce or activated) then
  	begin
    	FRingOnce := False;
    	ExecuteRingEvent(FNextEvent);
    	if (activated) then
    	begin
    		FNextEvent := Events.NextEvent(IncMinute(FNextEvent.Occurance));
        	FClock.Delay := 0;
    	end;
  	end;

  	if (FMainTimerCheckRemote = 60) or (FMainTimerCheckRemote = 0) then
  	begin
    	FMainTimerCheckRemote := 1;
    	CheckRemote();
  	end;

  	EndFormUpdate;

  	Inc(FMainTimerCheckRemote);
  	Inc(FMainTimerClearStatus);
	TimerMain.Enabled := True;
end;

{------------------------------------------------------------------------------}
procedure TForm1.ExecuteRingEvent(AEvent: TEvent);
var
  durArr: TStringArray;
  dur: string;
  odd: boolean;
begin

  if (FClock.Silent = False) then
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

  FOnlineEvents.UpdateGUI (1, Events1);

  if Length(Events1) > 0 then
  begin
    Events.NextRemoteEvent(Events2, incDay(Events1[0].Occurance));
    FOnlineEvents.UpdateGUI (2, Events2);
  end;
end;


end.
