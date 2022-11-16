unit d_Clock;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

    { TfrmClock }

    TfrmClock = class(TForm)
        ImageSilent: TImage;
        LabelClock: TLabel;
        procedure FormCreate(Sender: TObject);
    private

    public
        Silent : boolean;
        procedure UpdateGUI;

    end;

var
    frmClock: TfrmClock;

implementation

{$R *.lfm}

procedure TfrmClock.FormCreate(Sender: TObject);
begin
  Silent := false;
  Color := clBlack;
  LabelClock.Font.Color := $00FF8000;
  UpdateGUI;
end;

procedure TfrmClock.UpdateGUI;
var
    wid : integer;
begin

  ImageSilent.Visible := Silent;
  if (Parent <> nil) then
  begin
  	ImageSilent.Height:=Parent.Height - 16;
    ImageSilent.Width:=Parent.Height - 16;
    ImageSilent.Left := 8;
    ImageSilent.Top := 8;
  end;

  LabelClock.Caption := FormatDateTime('hh:nn', Now);
  if (Parent <> nil) then LabelClock.Font.Height:=Parent.Height;

  wid := LabelClock.Canvas.TextWidth(LabelClock.Caption);

  while (wid > LabelClock.Width) do
  begin
	LabelClock.Font.Height:= LabelClock.Font.Height - 5;
	wid := LabelClock.Canvas.TextWidth(LabelClock.Caption);
  end;

end;

end.

