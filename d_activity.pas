unit d_activity;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

    { TfrmActivity }

    TfrmActivity = class(TForm)
        Label2: TLabel;
        LabelStatus: TLabel;
        ShapeIdleTrigger: TShape;
        ShapeMainTrigger: TShape;
    private

    public

    end;

var
    frmActivity: TfrmActivity;

implementation

{$R *.lfm}

end.

