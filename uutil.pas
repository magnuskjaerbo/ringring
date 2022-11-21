unit uutil;

{$mode ObjFPC}{$H+}


interface



uses
    Classes, Controls, Forms, SysUtils, DateUtils, Graphics, StdCtrls, ExtCtrls;

function TimeBetweenStr(AFrom, ATo: TDateTime): string;
procedure CalcLabelSize (ALabel : TLabel; AWidth, AHeight: integer);
procedure CalcFontSize (AText : String; ACanvas : TCanvas; AWidth, AHeight: integer);

implementation

procedure CalcLabelSize (ALabel : TLabel; AWidth, AHeight: integer);
var
  wid : integer;
begin
  ALabel.Font.Height:= AHeight;
  wid := ALabel.Canvas.TextWidth (ALabel.Caption);

  while (wid > AWidth) do
  begin
	ALabel.Font.Height:= ALabel.Font.Height - 5;
	wid := ALabel.Canvas.TextWidth (ALabel.Caption);
  end;
end;

procedure CalcFontSize (AText : String; ACanvas : TCanvas; AWidth, AHeight: integer);
var
  wid : integer;
begin
  ACanvas.Font.Size:= AHeight;
  wid := ACanvas.TextWidth (AText);

  while (wid > AWidth) do
  begin
	ACanvas.Font.Size:= ACanvas.Font.Size - 5;
	wid := ACanvas.TextWidth (AText);
  end;


end;


function TimeBetweenStr(AFrom, ATo: TDateTime): string;
var
  days: integer;
  sec: integer;
  minutes: integer;
  dhours: double;
  rem: double;
  hours: integer;
  strDays: string;
  strHours: string;
  strMinutes: string;
begin
  sec := SecondsBetween(AFrom, ATo);

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
    strminutes := IntToStr(minutes) + ' min. ';
  end
  else if (minutes = 1) then
  begin
    strminutes := IntToStr(minutes) + ' min. ';
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

