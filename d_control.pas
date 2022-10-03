unit d_Control;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls;

type

  { TfrmControl }

  TfrmControl = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    Silent : boolean;
    Reboot : boolean;
    CloseApp : boolean;

  end;

var
  frmControl: TfrmControl;

implementation

{$R *.lfm}

{ TfrmControl }

procedure TfrmControl.FormShow(Sender: TObject);
var
  own: TWinControl;
begin
  own := Owner as TWinControl;

  Top := own.Top;
  Left := own.Left;
  Width := own.Width;

  Panel1.Color := clGray;
  if (Silent = true) then Panel1.Color := clHighlight;
  Panel2.Color := clGray;
  Panel3.Color := clGray;


end;

procedure TfrmControl.BitBtn1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmControl.BitBtn2Click(Sender: TObject);
begin
  Silent := not Silent;
  if (Silent = True) then
  begin
    Panel1.Color := clHighlight;
  end
  else
  begin
	Panel1.Color := clGray;
  end;
end;

procedure TfrmControl.BitBtn3Click(Sender: TObject);
begin
  Reboot := not Reboot;
  if (Reboot = True) then
  begin
    Panel2.Color := clHighlight;
  end
  else
  begin
	Panel2.Color := clGray;
  end;
end;

procedure TfrmControl.BitBtn4Click(Sender: TObject);
begin
  CloseApp := not CloseApp;
  if (CloseApp = True) then
  begin
    Panel3.Color := clHighlight;
  end
  else
  begin
	Panel3.Color := clGray;
  end;

end;

end.
