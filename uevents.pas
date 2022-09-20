unit uEvents;

{$mode objfpc}{$H+}

interface

uses
		Classes, SysUtils, uJSON, uSettings, uLogger,dateutils, ssl_openssl, httpsend;
type
	TEvents = class
	private
	       FDateChecker	   : TDateChecker;
           FLogger : TLogger;
    	   FEvents 		   : array of TEvent;
           //FNextEvent 	   : TEvent;
           function tryNextEvent (ADateTime : TDateTime) : TEvent;

  	public
           procedure GetRemoteData ();
           function NextEvent (ADateTime : TDateTime) : TEvent;
           function NextRemoteEvent (ADateTime : TDateTime) : TEvent;
           function Activate (AEvent : TEvent) : boolean;
           constructor Create (ALogger: TLogger; ASettings: TfrmSettings);
end;



implementation

constructor TEvents.Create (ALogger: TLogger; ASettings: TfrmSettings);
begin
  FDateChecker := TDateChecker.Create (ALogger);
  FLogger := ALogger;
//  FDateChecker.Clear();
//  GetRemoteData ();
  FEvents := ASettings.FEvents;
end;

procedure TEvents.GetRemoteData ();
var
  Response: TStringList;
  url : string;
  y, m, d: word;
begin

  FDateChecker.Clear();
  DecodeDate(Now, y, m, d);

  url := 'www.skopunarskuli.fo/wp-content/plugins/MJK-PostDate/' + IntToStr (y) + '-' + Format('%.*d',[2, m]) + '.txt';
  if (FLogger <> nil) then FLogger.Add('Reading JSON object from ' + url);
  Response := TStringList.Create();
  HttpGetText (url, Response);
  if (FLogger <> nil) then FLogger.Add('JSON object: ' + Response.Text);
  FDateChecker.SetJSON(Response.GetText);
  Response.Destroy;

  m := m + 1;
  if (m = 13) then
  begin
       m := 1;
       y := y +1;
  end;
  url := 'www.skopunarskuli.fo/wp-content/plugins/MJK-PostDate/' + IntToStr (y) + '-' + Format('%.*d',[2, m]) + '.txt';
  if (FLogger <> nil) then FLogger.Add('Reading JSON object from ' + url);
  Response := TStringList.Create();
  HttpGetText (url, Response);
  FDateChecker.SetJSON(Response.GetText);
  Response.Destroy;

end;

function TEvents.NextEvent (ADateTime : TDateTime) : TEvent;
var
  Event     : TEvent;
begin

  Event := tryNextEvent (ADateTime);
  while not FDateChecker.ValidDate (Event.Occurance) do
  begin
  	   Event := tryNextEvent (IncDay (Event.Occurance, 1));
  end;

  result := Event;

end;

function TEvents.tryNextEvent (ADateTime : TDateTime) : TEvent;
var
  theDay    : integer;
  theTime   : TEventTime;
  Event     : TEvent;
  ClosestEvent : TEvent;
  dayDiff      : integer;
  occurance    : TDateTime;
  minDiff      : double;
  dateDiff     : double;
  strDate      : string;
begin

  theDay  := DayOfWeek(ADateTime);

  DecodeTime (ADateTime, theTime.Hour, theTime.Minute, theTime.Second, theTime.MilliSecond);

  ClosestEvent.Valid := false;

  minDiff := 100000000;
  for Event in FEvents do
  begin
       dayDiff := Event.Day - theDay;
       if (dayDiff < 0) then dayDiff := 7 + dayDiff;
       strDate := DateToStr (ADateTime);
       occurance := StrToDate (strDate);
       occurance := IncDay (occurance, dayDiff);
       occurance := occurance + EncodeTime (Event.Time.Hour, Event.Time.Minute, 0, 0);

       dateDiff := occurance - ADateTime;
       if (dateDiff < 0) then
          Continue;
       if dateDiff < minDiff then
       begin
            ClosestEvent := Event;
            ClosestEvent.Occurance := occurance;
            ClosestEvent.Valid := true;
            minDiff := dateDiff;
       end;
  end;
  result := ClosestEvent;
end;

function TEvents.Activate (AEvent : TEvent) : boolean;
var
  mins : Int64;
begin
  	 result := false;
  	 mins := SecondsBetween (AEvent.Occurance, Now);
	 if (mins < 1) then result := true;
end;

function TEvents.NextRemoteEvent (ADateTime : TDateTime) : TEvent;
begin
  result := FDateChecker.NextEvent(ADateTime, etRemoteOccurance);
end;


end.
