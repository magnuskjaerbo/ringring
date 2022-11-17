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
  LabelClock.Font.Color := clWhite;
  //UpdateGUI;
end;

procedure TfrmClock.UpdateGUI;
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
  CalcLabelSize (LabelClock, Parent.Width, Parent.Height);

end;

end.

