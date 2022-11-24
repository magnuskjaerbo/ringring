unit uEvents;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uJSON, StdCtrls, uSettings, dateutils, ssl_openssl, httpsend;

type
  TEvents = class
  private
    FDateChecker: TDateChecker;
    FEvents: array of TEvent;
    StatusLabel: TLabel;
    function tryNextEvent(ADateTime: TDateTime): TEvent;

  public
    procedure GetRemoteData();
    function NextEvent(ADateTime: TDateTime): TEvent;
    procedure NextRemoteEvent(var OEvents: TOEvents; ADateTime: TDateTime);
    function Activate(AEvent: TEvent; ADelay : integer): boolean;
    constructor Create(AStatusLabel: TLabel; ASettings: TfrmSettings);
  end;



implementation

constructor TEvents.Create(AStatusLabel: TLabel; ASettings: TfrmSettings);
begin
  StatusLabel := AStatusLabel;
  FDateChecker := TDateChecker.Create();
  FEvents := ASettings.FEvents;
end;

procedure TEvents.GetRemoteData();
var
  Response: TStringList;
  url: string;
  y, m, d: word;
begin

  FDateChecker.Clear();
  DecodeDate(Now, y, m, d);

  url := 'www.skopunarskuli.fo/wp-content/plugins/MJK-PostDate/' + IntToStr(y) + '-' + Format('%.*d', [2, m]) + '.txt';
  StatusLabel.Caption := 'Reading JSON from ' + url;
  Response := TStringList.Create();
  HttpGetText(url, Response);

  FDateChecker.SetJSON(Response.GetText);
  Response.Destroy;

  m := m + 1;
  if (m = 13) then
  begin
    m := 1;
    y := y + 1;
  end;
  url := 'www.skopunarskuli.fo/wp-content/plugins/MJK-PostDate/' + IntToStr(y) + '-' + Format('%.*d', [2, m]) + '.txt';

  StatusLabel.Caption := 'Reading settings from ' + url;
  Response := TStringList.Create();
  HttpGetText(url, Response);
  FDateChecker.SetJSON(Response.GetText);
  Response.Destroy;

end;

function TEvents.NextEvent(ADateTime: TDateTime): TEvent;
var
  Event: TEvent;
begin

  Event := tryNextEvent(ADateTime);
  while not FDateChecker.ValidDate(Event.Occurance) do
  begin
    Event := tryNextEvent(IncDay(Event.Occurance, 1));
  end;

  Result := Event;

end;

function TEvents.tryNextEvent(ADateTime: TDateTime): TEvent;
var
  theDay: integer;
  theTime: TEventTime;
  Event: TEvent;
  ClosestEvent: TEvent;
  dayDiff: integer;
  occurance: TDateTime;
  minDiff: double;
  dateDiff: double;
  strDate: string;
begin

  theDay := DayOfWeek(ADateTime);

  DecodeTime(ADateTime, theTime.Hour, theTime.Minute, theTime.Second,
    theTime.MilliSecond);

  ClosestEvent.Valid := False;

  minDiff := 100000000;
  for Event in FEvents do
  begin
    dayDiff := Event.Day - theDay;
    if (dayDiff < 0) then dayDiff := 7 + dayDiff;
    strDate := DateToStr(ADateTime);
    occurance := StrToDate(strDate);
    occurance := IncDay(occurance, dayDiff);
    occurance := occurance + EncodeTime(Event.Time.Hour, Event.Time.Minute, 0, 0);

    dateDiff := occurance - ADateTime;
    if (dateDiff < 0) then
      Continue;
    if dateDiff < minDiff then
    begin
      ClosestEvent := Event;
      ClosestEvent.Occurance := occurance;
      ClosestEvent.Valid := True;
      minDiff := dateDiff;
    end;
  end;
  Result := ClosestEvent;
end;

function TEvents.Activate(AEvent: TEvent; ADelay: integer): boolean;
var
  mins: int64;
begin
  Result := False;
  mins := SecondsBetween(AEvent.Occurance, Now) + ADelay*60;
  if (mins < 1) then Result := True;
end;

procedure TEvents.NextRemoteEvent(var OEvents: TOEvents; ADateTime: TDateTime);
begin
  FDateChecker.NextEvent(OEvents, ADateTime, etRemoteOccurance);
end;


end.
