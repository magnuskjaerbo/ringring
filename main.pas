unit Main;

{$mode objfpc}{$H+}

interface

uses
  {$IFNDEF Windows}baseunix,{$ENDIF}Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls,
   IpHtml,  Ipfilebroker, uLogger, uSettings,
  SQLDB, DateUtils, uEvents, uIO;

type

  { TForm1 }

  TForm1 = class(TForm)
    IdleTimer1: TIdleTimer;
    Image1: TImage;
	ImageLeftBell: TImage;
	ImageRightBell: TImage;
    ImMotion: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelNextEvent: TLabel;
    LabelNextEvent1: TLabel;
    LabelNextEvent2: TLabel;
    LabelNextEventMessage: TLabel;
    Panel1: TPanel;
	Panel2: TPanel;
    PanelMain: TPanel;
    PanelBottomLed: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    ShapeIdleTrigger: TShape;
	ShapeMainTrigger: TShape;
	Shape4: TShape;
	TimerCheckRemote: TTimer;
    TimerMain: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
	procedure FormShow(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Shape3ChangeBounds(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
	procedure TimerCheckRemoteTimer(Sender: TObject);
	procedure TimerIsRingingTimer(Sender: TObject);

  private
       MouseAlive     : integer;
       FRingOnce      : boolean;

       FLogger        : TLogger;
       FSettings      : TfrmSettings;
       Events		  : TEvents;
       FNextEvent     : TEvent;
       FIO            : TIO;
       function TimeBetweenStr (AFrom, ATo: TDateTime) : string;
       procedure ExecuteRingEvent (AEvent : TEvent);
       procedure Delay(dt: DWORD);
       procedure BlinkScreen ();
  public

  end;

const
     PIN_17: PChar = '17';
     PIN_18: PChar = '18';
     PIN_ON: PChar = '1';
     PIN_OFF: PChar = '0';
     OUT_DIRECTION: PChar = 'out';
     IN_DIRECTION: PChar = 'in';

var
  Form1: TForm1;
  gReturnCode: longint; {stores the result of the IO operation}

const
     debug : boolean = false;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

   //fpSystem('tput civis');


   {$IFDEF Windows}
   {$endif}
    Label2.Caption := 'v 1.0.2';
    mouse.CursorPos.SetLocation(0,0);
    Cursor:=crNone;
    DoubleBuffered := True;
    MouseAlive := 1;
    DefaultFormatSettings.ShortDateFormat:='yyyy-mm-dd';

    BorderStyle := bsNone;

    LabelNextEvent1.Caption:='';
    LabelNextEvent2.Caption:='';
    ImageLeftBell.Visible:=false;
    ImageRightBell.Visible:=false;
    Color := clBlack;

    {$IFDEF Windows}
        Width := 1280;
        Height := 720;
    {$ELSE}
        Left :=-2;
        Top := -2;
        Width := Screen.Width+4;
        Height := Screen.Height+4;
        WindowState := wsFullScreen;
    {$endif}

    FSettings := TfrmSettings.Create(Self, FLogger);
    FSettings.Parent := Self;
    Events := TEvents.Create (FLogger, FSettings);
    FNextEvent := Events.NextEvent (Now);
    FIO := TIO.Create();

end;

{------------------------------------------------------------------------------}
procedure TForm1.FormMouseEnter(Sender: TObject);
begin
  Form1.Cursor:=crNone;
end;
{------------------------------------------------------------------------------}
procedure TForm1.FormMouseLeave(Sender: TObject);
begin

end;
{------------------------------------------------------------------------------}
procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   Screen.Cursor:=crNone;
   Form1.Cursor:= crNone;

   Shape3.Visible:=false;
   PanelMain.Visible:=true;

end;

procedure TForm1.FormResize(Sender: TObject);
begin
  ImageRightBell.Left := Self.Width - ImageRightBell.Width - 64;
  ImageLeftBell.Left := 64;
end;

{------------------------------------------------------------------------------}
procedure TForm1.FormShow(Sender: TObject);
begin
    Form1.Cursor:=crNone;
    Color := clBlack;
    Label1.Color:=clBlack;
    LabelNextEventMessage.Color:=clBlack;
    LabelNextEvent.Color:=clBlack;

    ImageLeftBell.Visible:=false;
    ImageRightBell.Visible:=false;

end;
{------------------------------------------------------------------------------}
procedure TForm1.IdleTimer1Timer(Sender: TObject);
var
    rc : boolean;
begin
   if (ShapeIdleTrigger.Brush.Color = clBlack) then
      ShapeIdleTrigger.Brush.Color := clBlue
   else
      ShapeIdleTrigger.Brush.Color := clBlack;

   rc := FIO.ReadMotionSensor();

   if rc = false then
   begin
     ImMotion.Visible := false;
     TimerCheckRemote.Enabled:=true;
   end
   else
     begin
       ImMotion.Visible := true;
       Shape3.Visible:=false;
       PanelMain.Visible:=true;
     end;

end;
{------------------------------------------------------------------------------}
procedure TForm1.Label1Click(Sender: TObject);
begin
    FRingOnce := true;
end;

procedure TForm1.Shape3ChangeBounds(Sender: TObject);
begin

end;

{------------------------------------------------------------------------------}
procedure TForm1.BlinkScreen ();
  var
      shape : TShape;
  begin
      PanelMain.Visible := false;
      shape := TShape.Create(Self);
      shape.Parent := Self;

      shape.Left := 0;
      shape.Top := 0;
      shape.Width := self.Width;
      shape.Height := 1;
      shape.Visible := true;
      shape.BringToFront;
      shape.Update;

      shape.Brush.Color:=clRed;
      shape.Top := 0;
      shape.Height := self.Height;
      Delay (1000);
      shape.Brush.Color:=clGreen;
      Delay (1000);
      shape.Brush.Color:=clBlue;
      Delay (1000);
      shape.Brush.Color:=clWhite;
      Delay (1000);
      shape.Destroy;
      PanelMain.Visible := true;
end;
{------------------------------------------------------------------------------}
procedure TForm1.TimerMainTimer(Sender: TObject);
var
  timeleft : Int64;
  activated : boolean;
begin
  TimerMain.Enabled := false;
  BeginFormUpdate;
  Label1.Caption := FormatDateTime ('hh:nn', Now);


  LabelNextEvent.Caption := TimeBetweenStr (Now, FNextEvent.Occurance);
  LabelNextEventMessage.Caption := FNextEvent.Message;

  if (ShapeMainTrigger.Brush.Color = clBlack) then
    ShapeMainTrigger.Brush.Color := clGray
  else
    ShapeMainTrigger.Brush.Color := clBlack;


  timeleft := SecondsBetween (FNextEvent.Occurance, Now);
  if (timeleft < Panel2.Width) then
  begin
    Shape4.BorderSpacing.Left:=Round ((Panel2.Width - timeleft) * 0.5);
    Shape4.BorderSpacing.Right:=Shape4.BorderSpacing.Left;
    end
  else
  begin
    Shape4.BorderSpacing.Left:=0;
    Shape4.BorderSpacing.Right:=0;
  end;


  activated := Events.Activate (FNextEvent);
  if (FRingOnce or activated) then
  begin

       FRingOnce := false;
       ExecuteRingEvent (FNextEvent);
       if (activated) then FNextEvent := Events.NextEvent (IncMinute (FNextEvent.Occurance));
  end;
  EndFormUpdate;
  TimerMain.Enabled := true;
end;
 {------------------------------------------------------------------------------}
procedure TForm1.ExecuteRingEvent (AEvent : TEvent);
var
    durArr: TStringArray;
    dur: String;
    odd : boolean;
begin

    durArr := AEvent.Durations.Split(',');

    odd := true;
    for dur in durArr do
    begin
        if odd then
        begin
            ImageLeftBell.Visible:=true;
            ImageRightBell.Visible:=true;
            FIO.WriteRing(true);
            Delay (dur.ToInteger * 100);
            FIO.WriteRing(false);
            ImageLeftBell.Visible:=false;
            ImageRightBell.Visible:=false;
        end
        else
        begin
            Delay (dur.ToInteger * 100);
            FIO.WriteRing(false);
        end;
      odd:= not odd;
    end;

    ImageRIghtBell.Visible:=false;
    ImageLeftBell.Visible:=false;
    FIO.WriteRing(false);
    BlinkScreen ();
end;
{------------------------------------------------------------------------------}
procedure TForm1.TimerCheckRemoteTimer(Sender: TObject);
var
   Event : TEvent;
   sectonext : integer;
begin



  sectonext := SecondsBetween(Now, FNextEvent.Occurance);


  if (sectonext > 30) or (sectonext < 0) then
  begin
    FSettings.Destroy;
    Events.Destroy;

    FSettings := TfrmSettings.Create(Self, FLogger);
    FSettings.Parent := Self;
    Events := TEvents.Create (FLogger, FSettings);
    FNextEvent := Events.NextEvent (Now);

  end;


  TimerCheckRemote.Interval := 60 * 1000;
  Events.GetRemoteData;
  Event := Events.NextRemoteEvent(Now);
     if Event.Message <> '' then
     begin
  	 	  LabelNextEvent1.Caption:=Event.Message;
          LabelNextEvent2.Caption:=DateToStr (Event.Occurance);
	 end
     else
     begin
   	  	  LabelNextEvent1.Caption:='';
       	  LabelNextEvent2.Caption:='';
	 end;
end;
{------------------------------------------------------------------------------}
procedure TForm1.TimerIsRingingTimer(Sender: TObject);
begin
end;
{------------------------------------------------------------------------------}
function TForm1.TimeBetweenStr (AFrom, ATo: TDateTime) : string;
var

   days  : integer;

   sec : integer;
   minutes : integer;
   dhours : double;
   rem : double;
   hours : integer;
   strDays : string;
   strHours : string;
   strMinutes : string;
begin
     sec := SecondsBetween(AFrom, ATo);

     days := sec div (3600 * 24);
     sec := sec - ((3600 * 24) * days);
     dhours := sec / 3600;
     hours := sec div 3600;
     rem := dhours - hours;
     minutes := Round (60 * rem + 0.5);


     if (minutes = 60) then
     begin
         minutes := 0;
         hours := hours + 1;
	 end;
     if (hours = 24) then
     begin
       hours := 0;
       days := days +1;
	 end;

     strDays := '';
     if (days > 1) then
     begin
            strDays := intToStr (days) + ' dagar ';
     end
     else if (days = 1) then
     begin
            strDays := intToStr (days) + ' dag ';
     end;

     strHours := '';
     if (hours > 1) then
     begin
            strHours := intToStr (hours) + ' tímar ';
     end
     else if (hours = 1) then
     begin
            strHours := intToStr (hours) + ' tíma ';
     end;

     strminutes := '';
     if (minutes > 1) then
     begin
            strminutes := intToStr (minutes) + ' minuttir ';
     end
     else if (minutes = 1) then
     begin
            strminutes := intToStr (minutes) + ' minutt ';
     end;


     result := '';
     if (strDays <> '') then
     begin
        result := result + strDays;
     end;

     if (strHours <> '') then
     begin
       if result <> '' then result := result + ' og ' + strHours;
       if result = '' then result := strHours;
     end;

     if (strMinutes <> '') then
     begin
       if result <> '' then result := result + ' og ' + strMinutes;
       if result = '' then result := strMinutes;
     end;
end;
{------------------------------------------------------------------------------}
procedure TForm1.Delay(dt: DWORD);
var
  tc : DWORD;
begin
  tc := GetTickCount64;
  while (GetTickCount64 < tc + dt) and (not Application.Terminated) do
    Application.ProcessMessages;
end;
end.



