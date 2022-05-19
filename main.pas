unit Main;

{$mode objfpc}{$H+}

interface

uses
  {$IFNDEF Windows}baseunix,{$ENDIF}Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls, LazHelpHTML, ExtendedNotebook, IpHtml, Iphttpbroker,
  Ipfilebroker, uLogger, uSettings, SQLDB, DateUtils, uEvents;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    ExtendedNotebook1: TExtendedNotebook;
    IdleTimer1: TIdleTimer;
    Image1: TImage;
	Image2: TImage;
	Image3: TImage;
    Label1: TLabel;
    LabelNextEvent: TLabel;
    LabelNextEvent1: TLabel;
    LabelNextEvent2: TLabel;
    LabelNextEventMessage: TLabel;
    LogMemo: TMemo;
    Panel1: TPanel;
	Panel2: TPanel;
    PanelTimeScreen: TPanel;
    PanelBottomLed: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    ShapeTimeOut: TShape;
    ShapeIdleTrigger: TShape;
	ShapeMainTrigger: TShape;
	Shape4: TShape;
    tsBlack: TTabSheet;
    TimerScreenBlanc: TTimer;
	TimerIsRinging: TTimer;
	TimerCheckRemote: TTimer;
    tsConfig: TTabSheet;
    tsLog: TTabSheet;
    tsFront: TTabSheet;
    TimerMain: TTimer;
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
	procedure FormShow(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Label1DblClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Shape1ChangeBounds(Sender: TObject);
    procedure Shape6ChangeBounds(Sender: TObject);
    procedure ShapeIdleTrigger1ChangeBounds(Sender: TObject);
    procedure ShapeIdleTriggerChangeBounds(Sender: TObject);
    procedure TimerScreenBlancTimer(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
	procedure TimerCheckRemoteTimer(Sender: TObject);
	procedure TimerIsRingingTimer(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
    procedure tsBlackMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
       MouseAlive     : integer;
       FSleepTime     : integer;

       FLogger        : TLogger;
       FSettings      : TfrmSettings;
       Events		  : TEvents;
       FNextEvent     : TEvent;
       function TimeBetweenStr (AFrom, ATo: TDateTime) : string;
       function DownloadHTTP(URL, TargetFile: string): Boolean;
       procedure SwapToFront;
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
     debug : boolean = true;

implementation

{$R *.lfm}

{ TForm1 }


function TForm1.DownloadHTTP(URL, TargetFile: string): Boolean;
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
var
Response: TStringList;

begin

   //fpSystem('tput civis');

   mouse.CursorPos.SetLocation(0,0);
   Cursor:=crNone;

   MouseAlive := 1;
  DefaultFormatSettings.ShortDateFormat:='yyyy-mm-dd';
  ExtendedNotebook1.ShowTabs := False;
  BorderStyle := bsNone;

  LabelNextEvent1.Caption:='';
  LabelNextEvent2.Caption:='';
  Image1.Visible:=false;
  FSleepTime := 20;
  ShapeTimeOut.Width := FSleeptime;
  Color := clBlack;


  if (debug = true) then
  begin
    Width := 1024;
    Height := 600;
  end
  else
  begin
    Left :=-2;
    Top := -2;
    Width := Screen.Width+4;
    Height := Screen.Height+4;
  end;
  FLogger := TLogger.Create(LogMemo);

  FSettings := TfrmSettings.Create(tsConfig, FLogger);
  FSettings.Parent := tsConfig;
  FSettings.Align:= alClient;
  FSettings.Color := Color;
  FSettings.Font := ExtendedNotebook1.Font;
  FSettings.Show;

  ExtendedNotebook1.ActivePage := tsFront;

  Events := TEvents.Create (FLogger, FSettings);
  FNextEvent := Events.NextEvent (Now);

end;

procedure TForm1.SwapToFront;
begin
     if ExtendedNotebook1.ActivePage = tsBlack then
     begin
        Application.ProcessMessages;
        Sleep(2000);

     end;
   ExtendedNotebook1.ActivePage := tsFront;
end;

procedure TForm1.FormMouseEnter(Sender: TObject);
begin
  Form1.Cursor:=crNone;

end;

procedure TForm1.FormMouseLeave(Sender: TObject);
begin

end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   Screen.Cursor:=crNone;
   Form1.Cursor:= crNone;
   SwapToFront;
   TimerScreenBlanc.Enabled := true;
   ShapeTimeOut.width := FSleeptime;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
     Form1.Cursor:=crNone;
  Color := clBlack;
  ExtendedNotebook1.Color:=clBlack;
  tsFront.Color:= clBlack;
  Label1.Color:=clBlack;
  LabelNextEventMessage.Color:=clBlack;
  LabelNextEvent.Color:=clBlack;

end;

procedure TForm1.IdleTimer1Timer(Sender: TObject);
  var
  fileDesc: integer;
  buttonStatus: string[1] = '1';
begin
   if (ShapeIdleTrigger.Brush.Color = clBlack) then
      ShapeIdleTrigger.Brush.Color := clBlue
   else
      ShapeIdleTrigger.Brush.Color := clBlack;


   {$IFNDEF Windows}
   try

    { Open SoC pin 18 (pin 12 on GPIO port) in read-only mode: }
    fileDesc := fpopen('/sys/class/gpio/gpio18/value', O_RdOnly);
    if fileDesc > 0 then
    begin
      { Read status of this pin (0: button pressed, 1: button released): }
      gReturnCode := fpread(fileDesc, buttonStatus[1], 1);


      if buttonStatus = '0' then
            ShapeIdleTrigger1.Brush.Color := clWhite
      else
      begin
          ShapeIdleTrigger1.Brush.Color := clLime;
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

procedure TForm1.Image4Click(Sender: TObject);
begin

end;

procedure TForm1.Label1DblClick(Sender: TObject);
begin
  ExtendedNotebook1.ShowTabs := not ExtendedNotebook1.ShowTabs;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.Shape1ChangeBounds(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Shape6ChangeBounds(Sender: TObject);
begin

end;

procedure TForm1.ShapeIdleTrigger1ChangeBounds(Sender: TObject);
begin

end;

procedure TForm1.ShapeIdleTriggerChangeBounds(Sender: TObject);
begin

end;

procedure TForm1.TimerScreenBlancTimer(Sender: TObject);
begin

  if ExtendedNotebook1.ActivePage = tsFront then
  begin
       ShapeTimeOut.Width := ShapeTimeOut.width -1;
       if ShapeTimeOut.Width < 1 then
       begin
              ExtendedNotebook1.ActivePage := tsBlack;
              TimerScreenBlanc.Enabled := false;
              ShapeTimeOut.Width := FSleepTime;
       end;
  end;

end;

procedure TForm1.TimerMainTimer(Sender: TObject);
var
  timeleft : Int64;
begin
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

  if (Events.Activate (FNextEvent)) then
  begin
       TimerMain.Enabled := false;
  	   TimerIsRinging.Enabled := true;

       //ExtendedNotebook1.ActivePage := tsRingRing;


       FNextEvent := Events.NextEvent (IncMinute (FNextEvent.Occurance));
  end;

end;

procedure TForm1.TimerCheckRemoteTimer(Sender: TObject);
var
   Event : TEvent;
begin
     Event := Events.NextRemoteEvent(Now);
     if Event.Message <> '' then
     begin
  	 	  LabelNextEvent1.Caption:=Event.Message;
          LabelNextEvent2.Caption:=DateToStr (Event.Occurance);
          Image1.Visible:=true;
	 end
     else
     begin
   	  	  LabelNextEvent1.Caption:='';
       	  LabelNextEvent2.Caption:='';
       	  Image1.Visible:=false;

	 end;
end;

procedure TForm1.TimerIsRingingTimer(Sender: TObject);
begin
        TimerMain.Enabled:= true;
   	   	TimerIsRinging.Enabled := false;
        SwapToFront;
end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
var
    fileDesc: integer;
begin
  {$IFNDEF Windows}
  {
  if ToggleBox1.Checked then
    begin
      { Swith SoC pin 17 on: }
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
      { Switch SoC pin 17 off: }
      try
        fileDesc := fpopen('/sys/class/gpio/gpio17/value', O_WrOnly);
        gReturnCode := fpwrite(fileDesc, PIN_OFF[0], 1);
        FLogger.Add('write: ' + IntToStr(gReturnCode));
      finally
        gReturnCode := fpclose(fileDesc);
        FLogger.Add('close: ' + IntToStr(gReturnCode));
      end;
    end;
    }
    {$ENDIF}
end;

procedure TForm1.tsBlackMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
//  if ExtendedNotebook1.ActivePage = tsBlack then
//  begin
         SwapToFront;
         TimerScreenBlanc.Enabled := true;
         ShapeTimeOut.width := FSleeptime;
//  end;

end;


procedure TForm1.FormActivate(Sender: TObject);
  var
  fileDesc: integer;
begin
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

procedure TForm1.BitBtn2Click(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
begin

end;

function TForm1.TimeBetweenStr (AFrom, ATo: TDateTime) : string;
var
   weeks : integer;
   days  : integer;
   ddays  : double;
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

end.



