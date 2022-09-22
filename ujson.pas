unit uJSON;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, uSettings, uLogger;

Type
  TOEvents = array of TEvent;
  TDateChecker = class
    private
      FString : string;
      FEvents : array of TEvent;
      FLogger: TLogger;
    public
      function ValidDate (ADate : TDateTime) : boolean;
      //function NextEvent (ADate : TDateTime; AType : TEventType) : OEvents;
      procedure NextEvent (var OEvents : TOEvents; ADate : TDateTime; AType : TEventType);
      procedure SetJSON (AStr: string);
      procedure Clear ();
      constructor Create (ALogger: TLogger);
  end;




implementation

constructor TDateChecker.Create (ALogger: TLogger);
begin
	 FLogger := ALogger;
     SetLength (FEvents, 0);
end;

procedure TDateChecker.Clear;
begin
     SetLength (FEvents, 0);
end;

procedure TDateChecker.SetJSON (AStr: string);
var
  jData   		  : TJSONData;
  jDataEvents 	  : TJSONData;
  jObject 		  : TJSONObject;
  jObjectEvents	  : TJSONObject;
  jObjectCells 	  : TJSONObject;
  jObjectCategory : TJSONObject;
  jArray : TJSONArray;
  jArrayCells : TJSONArray;
  jArrayEvents : TJSONArray;
  jArrayCategory : TJSONArray;
  jEnum : TJSONEnum;
  jEnumCells : TJSONEnum;
  jEnumEvents : TJSONEnum;
  jEnumCategory : TJSONEnum;
  s: string;
  date: string;
  title: string;
  dateBeg : string;
  Event : TEvent;
  nEvents : integer;
begin

     if AStr.Length = 0 then exit;
     FString := AStr;
     jData := GetJSON(FString);

     if jData.IsNull then exit;
     jArray := TJSONArray (jData);
     for jEnum in jArray do begin

         jObject := TJSONObject (jEnum.Value);

         jDataEvents := jObject.Find('Cells');
         jArrayCells := TJSONArray (jDataEvents);
         for jEnumCells in jArrayCells do begin

             jObjectCells := TJSONObject (jEnumCells.Value);

             date := jObjectCells.FindPath('date').AsString;
             Event.Occurance:=StrToDate (date);
             if (Event.Occurance < Now) then continue;

             jDataEvents := jObjectCells.Find('Events');
             jArrayEvents := TJSONArray (jDataEvents);
             for jEnumEvents in jArrayEvents do
             begin
             	  jObjectEvents := TJSONObject (jEnumEvents.Value);
                  title := jObjectEvents.FindPath('Title').AsString;
                  dateBeg := jObjectEvents.FindPath('BeginS').AsString;

                  if (dateBeg <> date) then
                  begin
                     continue;
                  end;
                  Event.Message:= title;
                  Event.EventType:=etRemoteOccurance;
                  jArrayCategory := TJSONArray (jObjectEvents.Find('Category'));
                  if (not jArrayCategory.IsNull) then
                  begin
                    for jEnumCategory in jArrayCategory do
                    begin
                    	 jObjectCategory := TJSONObject (jEnumCategory.Value);
                    	 s := jObjectCategory.FindPath('slug').AsString;
                         if (s = 'fri') then
                         begin
                         	  Event.EventType:=etDayOff;
						 end;
					end;
				  end;
             	  nEvents := Length (FEvents);
               	  nEvents := nEvents + 1;
               	  SetLength (FEvents, nEvents);
               	  FEvents[nEvents-1] := Event;
             end;
         end;
     end;

end;

function TDateChecker.ValidDate (ADate : TDateTime) : boolean;
var
  Event : TEvent;
  strDate : string;
  strDateC : string;
begin
     result := true;
     strDate := DateToStr (ADate);
	 for Event in FEvents do
     begin
     	  strDateC := DateToStr (Event.Occurance);
          if strDateC = strDate then
          begin
           	  if Event.EventType = etDayOff then
              begin
                result := false;
			  end;
		 end;
	 end;
end;

procedure TDateChecker.NextEvent (var OEvents : TOEvents; ADate : TDateTime; AType : TEventType);
var
  Event : TEvent;
  ClosestEvent : TEvent;
  strDate : string;
  minDiff, diff : double;
  count : integer;
begin

     OEvents := default (TOEvents);
     count := 0;
     strDate := DateToStr (ADate);
     minDiff := 100000000;
	 for Event in FEvents do
     begin
  	 	  strDate := DateToStr (ADate);
         if (Event.Occurance < StrToDate (strDate)) then Continue;

         diff := Event.Occurance - ADate;
         if (diff < minDiff) then
         begin
             inc (count);
             ClosestEvent := Event;
             minDiff := diff;
		 end;
	 end;


     if count > 0 then
     begin
        count := 1;
        SetLength (OEvents, count);
        OEvents[count-1] := ClosestEvent;
	    for Event in FEvents do
         begin
  	 	     strDate := DateToStr (ADate);
             if (Event.Occurance <> ClosestEvent.Occurance) then Continue;
             if (Event.EventType <> AType) then Continue;
             if (ClosestEvent.Message = Event.Message) then Continue;
             inc (count);
             SetLength (OEvents, count);
             OEvents[count-1] := Event;
	     end;
     end;


end;

end.

