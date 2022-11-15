unit d_Control;

{$mode ObjFPC}{$H+}

interface

uses
  {$IFNDEF Windows}baseunix, Unix,{$ENDIF}Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls;

type

  { TfrmControl }

  TfrmControl = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    btnDelayDec: TBitBtn;
    btnDelayInc: TBitBtn;
    BitBtn7: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure btnDelayDecClick(Sender: TObject);
    procedure btnDelayIncClick(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
	procedure UpdateGUI;
  public
    Silent : boolean;
    Reboot : boolean;
    CloseApp : boolean;
    Delay:	integer;

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

  Panel1.Color := clDkGray;
  if (Silent = true) then Panel1.Color := clLime;
  Panel2.Color := clDkGray;
  Panel3.Color := clDkGray;
  UpdateGUI;

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
    Panel1.Color := clLime;
  end
  else
  begin
	Panel1.Color := clDkGray;
  end;
   ModalResult := mrOk;
end;

procedure TfrmControl.BitBtn3Click(Sender: TObject);
begin
  Reboot := not Reboot;
  if (Reboot = True) then
  begin
    Panel2.Color := clLime;
  end
  else
  begin
	Panel2.Color := clDkGray;
  end;
  {$IFDEF Unix}
  fpSystem('reboot');
  {$ENDIF}

   ModalResult := mrOk;
end;

procedure TfrmControl.BitBtn4Click(Sender: TObject);
begin
  CloseApp := not CloseApp;
  if (CloseApp = True) then
  begin
    Panel3.Color := clLime;
  end
  else
  begin
	Panel3.Color := clDkGray;
  end;
   ModalResult := mrOk;

end;

procedure TfrmControl.BitBtn7Click(Sender: TObject);
begin
  Delay := 0;
  UpdateGUI;
end;

procedure TfrmControl.btnDelayDecClick(Sender: TObject);
begin
	Delay := Delay - 5;
    UpdateGUI;
end;

procedure TfrmControl.btnDelayIncClick(Sender: TObject);
begin
  Delay := Delay + 5;
  UpdateGUI;
end;
procedure TfrmControl.UpdateGUI;
begin

    if (Delay < 0) then
    begin
    	btnDelayDec.Caption := IntToStr (Delay);
	    btnDelayInc.Caption := '+';
    end;

    if (Delay = 0) then
    begin
      	btnDelayDec.Caption := '-';
  	    btnDelayInc.Caption := '+';
    end;

    if (Delay > 0) then
    begin
      	btnDelayDec.Caption := '-';
  	    btnDelayInc.Caption := IntToStr (Delay);
    end;

end;

procedure TfrmControl.FormMouseLeave(Sender: TObject);
begin

end;

end.
