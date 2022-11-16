unit d_NextRing;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    uutil, uSettings, DateUtils;

type

    { TfrmNextRing }

    TfrmNextRing = class(TForm)
        LabelMessage: TLabel;
        LabelNext: TLabel;
        ShapeNextTop: TShape;
        procedure FormCreate(Sender: TObject);
    private

    public
        Delay : integer;
        procedure UpdateGUI (ANextEvent : TEvent);
    end;

var
    frmNextRing: TfrmNextRing;

implementation

{$R *.lfm}

{ TfrmNextRing }

procedure TfrmNextRing.FormCreate(Sender: TObject);
begin
  Color := clBlack;
  LabelNext.Font.Color := $00FF8000;
  LabelMessage.Font.Color := $00FF8000;


end;

procedure TfrmNextRing.UpdateGUI (ANextEvent : TEvent);
var
    timeleft: int64;
begin

  LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance);
  if (Delay > 0) then
  begin
	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + '+' + IntToStr (Delay) + 'min.';
  end;

  if (Delay < 0) then
  begin
	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + IntToStr (Delay) + 'min.';
  end;

  CalcLabelSize (LabelNext, Parent.Width, Trunc (Parent.Height * 0.75)-3 - ShapeNextTop.Height);

  LabelMessage.Caption := ANextEvent.Message;
  CalcLabelSize (LabelMessage, Parent.Width, Trunc (Parent.Height * 0.25)-3-ShapeNextTop.Height);


  timeleft := SecondsBetween(ANextEvent.Occurance, Now);
  if (timeleft < Parent.Width) then
  begin
    ShapeNextTop.BorderSpacing.Left := Round((Parent.Width - timeleft) * 0.5);
    ShapeNextTop.BorderSpacing.Right := ShapeNextTop.BorderSpacing.Left;
  end
  else
  begin
    ShapeNextTop.BorderSpacing.Left := 0;
    ShapeNextTop.BorderSpacing.Right := 0;
  end;




end;

end.

