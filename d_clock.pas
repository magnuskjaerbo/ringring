unit d_Clock;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, uutil;

type

    { TfrmClock }

    TfrmClock = class(TForm)
        ImageSilent: TImage;
        LabelClock: TLabel;
        Panel1: TPanel;
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
  //UpdateGUI;
end;

procedure TfrmClock.UpdateGUI;
var
    wid: integer;
begin

  ImageSilent.Visible := Silent;
  if (Parent <> nil) then
  begin
  	ImageSilent.Height:=Parent.Height - 16;
    ImageSilent.Width:=Parent.Height - 16;
    ImageSilent.Left := 8;
    ImageSilent.Top := 8;
  end;

  Panel1.Caption := FormatDateTime('hh:nn', Now);
  Panel1.Font.Height:= Parent.Height;

  wid := Panel1.Canvas.TextWidth (Panel1.Caption);

  while (wid > Panel1.Width) do
  begin
	Panel1.Font.Height:= Panel1.Font.Height - 5;
	wid := Panel1.Canvas.TextWidth (Panel1.Caption);
  end;


  //CalcLabelSize (LabelClock, Parent.Width, Parent.Height);

end;

end.

