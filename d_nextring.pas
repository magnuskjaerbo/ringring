unit d_NextRing;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    uEvents, uStringUtil, uSettings, DateUtils;

type

    { TfrmNextRing }

    TfrmNextRing = class(TForm)
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
//  LabelNext.Font.Color := $00FF8000;


end;

procedure TfrmNextRing.UpdateGUI (ANextEvent : TEvent);
var
    wid : integer;
    timeleft: int64;
begin

  LabelNext.Font.Height:= LabelNext.Height;
  LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance);
  if (Delay > 0) then
  begin
	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + ' +' + IntToStr (Delay);
  end;

  if (Delay < 0) then
  begin
	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + ' -' + IntToStr (Delay);
  end;


  //LabelNextEventMessage.Caption := FNextEvent.Message;

  wid := LabelNext.Canvas.TextWidth(LabelNext.Caption);

  while (wid > LabelNext.Width) do
  begin
	LabelNext.Font.Height:= LabelNext.Font.Height - 5;
	wid := LabelNext.Canvas.TextWidth(LabelNext.Caption);
  end;

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

