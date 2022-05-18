unit uLogger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;


Type
  TLogger = class
    private
      FMemo : TMemo;
    public
      constructor Create (M : TMemo);
      procedure Add(AText: string);

  end;

implementation

constructor TLogger.Create (M : TMemo);
begin
     FMemo := M;

end;

procedure TLogger.Add (AText: string);
var
  S : string;
begin
     S := '[' + FormatDateTime ('hh:nn:ss', Now) + '] ' + AText;
//       S = '[';
     FMemo.Lines.Add (S);
end;

end.
