unit uStringUtil;

{$mode ObjFPC}{$H+}


interface



uses
    Classes, SysUtils, DateUtils;

function TimeBetweenStr(AFrom, ATo: TDateTime): string;

implementation

function TimeBetweenStr(AFrom, ATo: TDateTime): string;
var

  days: integer;

  sec: int64;
  minutes: integer;
  dhours: double;
  rem: double;
  hours: integer;
  strDays: string;
  strHours: string;
  strMinutes: string;
  //TDateTime
begin
  sec := SecondsBetween(AFrom, ATo);

//  dhours := sec / 3600;
//  hours := sec div 3600;
//  rem := dhours - hours;
//  minutes := Round(60 * rem + 0.5);
//
////  TimeDifference := AFrom - ATo;
//  Result := FormatDateTime('hh" : "nn" : "ss', AFrom - ATo);

 // Result := Format ('%.2d:%.2d:%.2d',[hours, minutes, ]);
//  exit;
//  Result :=



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
    if Result <> '' then Result := Result + 'og ' + strHours;
    if Result = '' then Result := strHours;
  end;

  if (strMinutes <> '') then
  begin
    if Result <> '' then Result := Result + 'og ' + strMinutes;
    if Result = '' then Result := strMinutes;
  end;
end;

end.

