unit uSettings;

{$mode objfpc}{$H+}

interface

uses
  Controls, Classes, SysUtils, StdCtrls, Forms, Graphics, Dialogs, ExtCtrls,
  Buttons, IniFiles, dateutils, httpsend;

type

  TEventType = (etNormal, etDayOff, etRemoteOccurance);

  TEventTime = record
    Hour: word;
    Minute: word;
    Second: word;
    MilliSecond: word;
  end;

  TEvent = record
    EventType: TEventType;
    Day: integer;
    Time: TEventTime;
    Durations: string;
    Occurance: TDateTime;
    Valid: boolean;
    Message: string;
  end;

  { TfrmSettings }

  TfrmSettings = class(TForm)
    Panel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FIni: TIniFile;
    procedure ReadConfig();
    procedure ReadConfigSection(ASection: integer);
  public
    FEvents: array of TEvent;
    constructor Create(AOwner: TComponent; StatusLabel: TLabel);

  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.lfm}

{ TfrmSettings }
procedure TfrmSettings.FormCreate(Sender: TObject);
begin
end;

constructor TfrmSettings.Create(AOwner: TComponent; StatusLabel: TLabel);
var
  filePath: string;
  iniFile: string;
  commandFile: string;
  Response: TStringList;
  url: string;
  res:string;
begin
  inherited Create(AOwner);
  url := 'www.skopunarskuli.fo/RingRing/config.ini';
  StatusLabel.Caption := 'Reading settings from ' + url;
  Response := TStringList.Create();
  HttpGetText(url, Response);

  filePath := ExtractFilePath(ParamStr(0));
  iniFile := filePath + 'config.ini';
  if Response.Count <> 0 then
  begin
    Response.SaveToFile(iniFile);
  end;
  Response.Destroy;

  url := 'https://skopunarskuli.fo/RingRing/reboot.php';
  StatusLabel.Caption := 'Reading Commands from ' + url;
  Response := TStringList.Create();
  HttpGetText(url, Response);

  res := Response.Text;
  if (res = '1') then
  begin
    {$IFDEF Unix}
    fpSystem('reboot');
    {$ENDIF}
    Application.Terminate;
  end;

  res := Response.CommaText;
  if (res = '1') then
  begin
    {$IFDEF Unix}
    fpSystem('reboot');
    {$ENDIF}
    Application.Terminate;
  end;


  Response.Destroy;

  FIni := TIniFile.Create(iniFile);
  ReadConfig;
end;

procedure TfrmSettings.FormActivate(Sender: TObject);
begin

end;

procedure TfrmSettings.BitBtn1Click(Sender: TObject);
begin
end;

procedure TfrmSettings.ReadConfig;
begin

  ReadConfigSection(2);
  ReadConfigSection(3);
  ReadConfigSection(4);
  ReadConfigSection(5);
  ReadConfigSection(6);
end;

procedure TfrmSettings.ReadConfigSection(ASection: integer);
var
  Content: string;
  Event: TEvent;
  Count: integer;
  nEvents: integer;
begin

  if (not FIni.SectionExists(IntToStr(ASection))) then exit;

  Event.Day := ASection;
  Event.EventType := etNormal;
  for Count := 1 to 20 do
  begin
    Event.Time.Hour := 0;
    Event.Time.Minute := 0;
    Event.Time.Second := 0;
    Event.Durations := '';

    Content := IntToStr(Count) + '.Time.Hour';
    if FIni.ValueExists(IntToStr(ASection), Content) then
    begin
      Event.Time.Hour := FIni.ReadInteger(IntToStr(ASection), Content, -1);
    end
    else
    begin
      if FIni.ValueExists('Default', Content) then
      begin
		Event.Time.Hour := FIni.ReadInteger('Default', Content, -1);
      end;
   end;


    Content := IntToStr(Count) + '.Time.Minute';
    if FIni.ValueExists(IntToStr(ASection), Content) then
    begin
      Event.Time.Minute := FIni.ReadInteger(IntToStr(ASection), Content, -1);
    end
    else
    begin
      if FIni.ValueExists('Default', Content) then
      begin
		Event.Time.Minute := FIni.ReadInteger('Default', Content, -1);
      end;
    end;

    Content := IntToStr(Count) + '.Duration';
    if FIni.ValueExists(IntToStr(ASection), Content) then
    begin
      Event.Durations := FIni.ReadString(IntToStr(ASection), Content, '');
    end
    else
    begin
      if FIni.ValueExists('Default', Content) then
      begin
		Event.Durations := FIni.ReadString('Default', Content, '');
      end;
    end;

    Content := IntToStr(Count) + '.Message';
    if FIni.ValueExists(IntToStr(ASection), Content) then
    begin
      Event.Message := FIni.ReadString(IntToStr(ASection), Content, '');
    end
    else
    begin
      if FIni.ValueExists('Default', Content) then
      begin
		Event.Message := FIni.ReadString('Default', Content, '');
      end;
    end;

    if (Event.Durations <> '') and (Event.Time.Hour <> 0) then
    begin
      nEvents := Length(FEvents);
      nEvents := nEvents + 1;
      SetLength(FEvents, nEvents);
      FEvents[nEvents - 1] := Event;
    end;

  end;

end;


end.
