unit uSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Arrow, Spin, EditBtn, IniFiles, uLogger, dateutils;

type

  TEventType = (etNormal, etDayOff, etRemoteOccurance);

  TEventTime = record
    Hour : Word;
    Minute : Word;
    Second : Word;
    MilliSecond : Word;
  end;

  TEvent = record
    EventType	 : TEventType;
    Day          : integer;
    Time         : TEventTime;
    Durations    : string;
    Occurance    : TDateTime;
    Valid        : boolean;
    Message      : string;
  end;

  { TfrmSettings }

  TfrmSettings = class(TForm)
    Panel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FIni : TIniFile;
    FLogger : TLogger;
    procedure ReadConfig();
    procedure ReadConfigSection (ASection : integer);
  public
    FEvents : array of TEvent;
    constructor Create (AOwner: TComponent; ALogger: TLogger);

  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.lfm}

{ TfrmSettings }
procedure TfrmSettings.FormCreate(Sender: TObject);
begin
end;

constructor TfrmSettings.Create (AOwner: TComponent; ALogger: TLogger);
var
  filePath : string;
  iniFile : string;
begin
     inherited Create (AOwner);
     FLogger := ALogger;
     //ShowMessage(ParamStr(0));
  	 filePath := ExtractFilePath (ParamStr(0));
  	 iniFile :=filePath + 'config.ini';
     //ShowMessage(iniFile);
     FIni := TIniFile.Create(iniFile);
     if (FLogger <> nil) then FLogger.Add('Loaded: ' + FIni.FileName);
     //Memo1.Lines.LoadFromFile(iniFile);
     ReadConfig;
end;

procedure TfrmSettings.FormActivate(Sender: TObject);
begin

end;

procedure TfrmSettings.BitBtn1Click(Sender: TObject);
begin
end;

procedure TfrmSettings.ReadConfig;
var
  Section : String;
begin
     ReadConfigSection (2);
     ReadConfigSection (3);
     ReadConfigSection (4);
     ReadConfigSection (5);
     ReadConfigSection (6);
end;

procedure TfrmSettings.ReadConfigSection (ASection : integer);
var
  Content : String;
  Event : TEvent;
  count : integer;
  nEvents : integer;
begin

     if (not FIni.SectionExists (IntToStr (ASection))) then exit;

     Event.Day:= ASection;
     Event.EventType:=etNormal;
     for count := 1 to 20 do
     begin
          Event.Time.Hour:=0;
          Event.Time.Minute:=0;
          Event.Time.Second:=0;
          Event.Durations:='';

          Content := IntToStr (count) + '.Time.Hour';
          if FIni.ValueExists(IntToStr (ASection), Content) then
          begin
               Event.Time.Hour := FIni.ReadInteger(IntToStr (ASection), Content, -1);
          end;

          Content := IntToStr (count) + '.Time.Minute';
          if FIni.ValueExists(IntToStr (ASection), Content) then
          begin
               Event.Time.Minute := FIni.ReadInteger(IntToStr (ASection), Content, -1);
          end;

          Content := IntToStr (count) + '.Duration';
          if FIni.ValueExists(IntToStr (ASection), Content) then
          begin
               Event.Durations := FIni.ReadString (IntToStr (ASection), Content, '');
          end;

          Content := IntToStr (count) + '.Message';
          if FIni.ValueExists(IntToStr (ASection), Content) then
          begin
               Event.Message := FIni.ReadString (IntToStr (ASection), Content, '');
          end;

          if Event.Durations <> '' then
          begin
               nEvents := Length (FEvents);
               nEvents := nEvents + 1;
               SetLength (FEvents, nEvents);
               FEvents[nEvents-1] := Event;
          end;

     end;


end;


end.

