unit Main;

{$mode objfpc}{$H+}

interface

uses
  {$IFNDEF Windows}baseunix, Unix,{$ENDIF}Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls,
   IpHtml,  Ipfilebroker, uLogger, uSettings,
  SQLDB, DateUtils, uEvents, uIO;

type

  { TForm1 }

  TForm1 = class(TForm)
      ButtonOk: TButton;
      ButtonReboot: TButton;
      ButtonClose: TButton;
    IdleTimer1: TIdleTimer;
    Image1: TImage;
    Image2: TImage;
    ImageSilent: TImage;
    ImMotion: TImage;
    LabelStatus: TLabel;
    LabelClock: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabelNextEvent: TLabel;
    LabelNextEvent1: TLabel;
    LabelNextEvent2: TLabel;
    LabelNextEvent3: TLabel;
    LabelNextEvent4: TLabel;
    LabelNextEventMessage: TLabel;
    Panel1: TPanel;
	Panel2: TPanel;
    Panel3: TPanel;
    PanelMain: TPanel;
    PanelBottomLed: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    ShapeIdleTrigger: TShape;
	ShapeMainTrigger: TShape;
	Shape4: TShape;
    SpeedButtonSilent: TSpeedButton;
    TimerMain: TTimer;
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonRebootClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
	procedure FormShow(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure LabelClockClick(Sender: TObject);
    procedure Shape3ChangeBounds(Sender: TObject);
    procedure SpeedButtonSilentClick(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);


  private
    FMainTimerCheckRemote : integer;
    FMainTimerClearStatus : integer;
	FRingOnce      : boolean;
    FLogger        : TLogger;
    FSettings      : TfrmSettings;
    Events		  : TEvents;
    FNextEvent     : TEvent;
    FIO            : TIO;
    procedure HandleEvent (LabelMessage, LabelDate : TLabel; Image : TImage; AEvents : array of TEvent);
    procedure ReadFromRemote;
    function TimeBetweenStr (AFrom, ATo: TDateTime) : string;
    procedure ExecuteRingEvent (AEvent : TEvent);
    procedure Delay(dt: DWORD);
    procedure BlinkScreen ();
    procedure CheckRemote ();
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
    Label2.Caption := '1.0.11';
    Label3.Caption := 'RingRing v ' + Label2.Caption;
    DoubleBuffered := True;
    FMainTimerCheckRemote := 0;
    FMainTimerClearStatus := 0;

    DefaultFormatSettings.ShortDateFormat:='yyyy-mm-dd';

    BorderStyle := bsNone;

    LabelNextEvent1.Caption:='';
    LabelNextEvent2.Caption:='';
    LabelNextEvent3.Caption:='';
    LabelNextEvent4.Caption:='';
    Image1.Visible:=false;
    Image2.Visible:=false;
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

    FSettings := TfrmSettings.Create(Self, LabelStatus);
    FSettings.Parent := Self;
    Events := TEvents.Create (LabelStatus, FSettings);
    FNextEvent := Events.NextEvent (Now);
    FIO := TIO.Create();

end;

procedure TForm1.ButtonOkClick(Sender: TObject);
begin
    Panel3.Visible := false;
end;

procedure TForm1.ButtonRebootClick(Sender: TObject);
begin
  {$IFDEF Windows}
  {$ELSE}
  fpSystem('reboot');
  {$ENDIF}
end;

procedure TForm1.ButtonCloseClick(Sender: TObject);
begin
    Close;
end;

{------------------------------------------------------------------------------}
procedure TForm1.FormShow(Sender: TObject);
begin
    Form1.Cursor:=crNone;
    Color := clBlack;
    LabelClock.Color:=clBlack;
    LabelNextEventMessage.Color:=clBlack;
    LabelNextEvent.Color:=clBlack;

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
begin
    Panel3.Visible := true;
end;

procedure TForm1.Shape3ChangeBounds(Sender: TObject);
begin

end;

procedure TForm1.SpeedButtonSilentClick(Sender: TObject);
begin
	 ImageSilent.Visible:= not ImageSilent.Visible;
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

    if (FMainTimerClearStatus > 4) then
    begin
	    LabelStatus.Caption:='';
        FMainTimerClearStatus := 0;
    end;

  	TimerMain.Enabled := false;
  	BeginFormUpdate;
  	LabelClock.Caption := FormatDateTime ('hh:nn', Now);


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

  	if (FMainTimerCheckRemote = 60) or (FMainTimerCheckRemote = 0) then
  	begin
      	FMainTimerCheckRemote := 1;
      	CheckRemote ();
  	end;

  	EndFormUpdate;

    inc (FMainTimerCheckRemote);
    inc (FMainTimerClearStatus);

  	TimerMain.Enabled := true;
end;
 {------------------------------------------------------------------------------}
procedure TForm1.ExecuteRingEvent (AEvent : TEvent);
var
    durArr: TStringArray;
    dur: String;
    odd : boolean;
begin

	 if (ImageSilent.Visible = false) then
     begin
         durArr := AEvent.Durations.Split(',');

        odd := true;
        for dur in durArr do
        begin
            if odd then
            begin
                FIO.WriteRing(true);
                Delay (dur.ToInteger * 100);
                FIO.WriteRing(false);
            end
            else
            begin
                Delay (dur.ToInteger * 100);
                FIO.WriteRing(false);
            end;
          odd:= not odd;
		end;

        FIO.WriteRing(false);

     end;
	 BlinkScreen ();
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
      Events := TEvents.Create (LabelStatus, FSettings);
      FNextEvent := Events.NextEvent (Now);
    end;
end;

procedure TForm1.HandleEvent (LabelMessage, LabelDate : TLabel; Image : TImage; AEvents : array of TEvent);
begin
    if Length (AEvents) > 0 then
    begin
   		if (LabelMessage.Tag > Length (AEvents) - 1) then LabelMessage.Tag := 0;
       	LabelMessage.Caption := AEvents[LabelMessage.Tag].Message;
       	if Length (AEvents) > 1 then
       	begin
       		LabelDate.Caption := DateToStr (AEvents[LabelMessage.Tag].Occurance) + '  ' + IntToStr (LabelMessage.Tag+1) + ' / ' + IntToStr (Length (AEvents));
       	end
       	else
       	begin
       	   	LabelDate.Caption := DateToStr (AEvents[LabelMessage.Tag].Occurance);
       	end;
       	Image.Visible:=true;
       	LabelMessage.Tag := LabelMessage.Tag + 1;
    end
    else
    begin
    	LabelMessage.Caption:='';
      	LabelDate.Caption:='';
      	Image.Visible:=false;
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

{------------------------------------------------------------------------------}
procedure TForm1.CheckRemote ();
var
   Events1 : array of TEvent;
   Events2 : array of TEvent;
begin

	ReadFromRemote;

  	Events.GetRemoteData;

    setLength (Events1, 0);
    setLength (Events2, 0);
  	Events.NextRemoteEvent(Events1, Now);
  	HandleEvent (LabelNextEvent1, LabelNextEvent2, Image1, Events1);

    if Length (Events1) > 0 then
  	begin
    	Events.NextRemoteEvent(Events2, incDay(Events1[0].Occurance));
        HandleEvent (LabelNextEvent3, LabelNextEvent4, Image2, Events2);
    end;
end;
end.
