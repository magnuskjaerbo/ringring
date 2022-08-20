unit d_Debug;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
    RTTICtrls;

type

    { TfrmDebug }

    TfrmDebug = class(TForm)
        CheckBox1: TCheckBox;
        PIN17: TCheckBox;
        procedure CheckBox1Change(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    private

    public

    end;

var
    frmDebug: TfrmDebug;

implementation

{$R *.lfm}

{ TfrmDebug }

procedure TfrmDebug.CheckBox1Change(Sender: TObject);
begin

end;

procedure TfrmDebug.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    CanClose := false;
end;

end.

