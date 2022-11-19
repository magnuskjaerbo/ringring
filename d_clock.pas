unit d_Clock;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    uutil, uSettings, DateUtils;

type

    { TfrmClock }

    TfrmClock = class(TForm)
        Image1: TImage;
        ImageSilent: TImage;
        LabelClock: TLabel;
        LabelMessage: TLabel;
        LabelNext: TLabel;
        Shape1: TShape;
        Timer1: TTimer;
        procedure FormCreate(Sender: TObject);
        procedure Timer1Timer(Sender: TObject);
    private

    public
        Silent : boolean;
        Delay : integer;
        procedure UpdateGUI (ANextEvent : TEvent);

    end;

var
    frmClock: TfrmClock;

implementation

{$R *.lfm}

procedure TfrmClock.FormCreate(Sender: TObject);
begin
  Silent := false;
  Color := clBlack;
  Shape1.Top := Image1.Top + 72;
  Shape1.Left := 130;
  Shape1.Tag:=10;

  LabelClock.Font.Color := $00FF8000;
  LabelNext.Font.Color := clWhite;
  LabelMessage.Font.Color := clWhite;

//  LabelClock.
  //UpdateGUI;
end;

procedure TfrmClock.Timer1Timer(Sender: TObject);
begin
	Shape1.Left := Shape1.Left + Shape1.Tag;
    if (Shape1.Left <= 130) then Shape1.Tag := Shape1.Tag * -1;
    if (Shape1.Left >= Parent.Width) then Shape1.Tag := Shape1.Tag * -1;
end;

procedure TfrmClock.UpdateGUI (ANextEvent : TEvent);
var
    timeleft: int64;
	szClock : real;
    szClockRest : real;
begin


  szClock := 0.6;
  szClockRest := 1.0 - szClock;

  LabelClock.Left:=0;
  LabelClock.Top:=0;
  LabelClock.Width:=Parent.Width;
  LabelClock.Height:=Trunc (Parent.Height * szClock);

  Image1.Top := LabelClock.Height - 88;
  Image1.Left:= 0;

  LabelMessage.Left:=0;
  LabelMessage.Top:=LabelClock.Height;
  LabelMessage.Width:=Parent.Width;
  LabelMessage.Height:=Trunc (Parent.Height * szClockRest * 0.33);

  LabelNext.Left:=0;
  LabelNext.Top:=LabelClock.Height + LabelMessage.Height;
  LabelNext.Width:=Parent.Width;
  LabelNext.Height:=Trunc (Parent.Height * szClockRest * 0.66);

  ImageSilent.Visible := Silent;
  if (Parent <> nil) then
  begin
  	ImageSilent.Height:=Trunc (Parent.Height * szClock) - 16;
    ImageSilent.Width:=ImageSilent.Height;
    ImageSilent.Left := Parent.Width - ImageSilent.Width - 8;
    ImageSilent.Top := 8;
  end;

  LabelClock.Caption := FormatDateTime('hh:nn', Now);
  CalcLabelSize (LabelClock, Parent.Width, LabelClock.Height);

  LabelMessage.Caption := ANextEvent.Message;
  CalcLabelSize (LabelMessage, Parent.Width, LabelMessage.Height);

  LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance);
  if (Delay > 0) then
  begin
	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + '+' + IntToStr (Delay) + 'min.';
  end;

  if (Delay < 0) then
  begin
	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + IntToStr (Delay) + 'min.';
  end;

  CalcLabelSize (LabelNext, Parent.Width, LabelNext.Height);

  Shape1.Top := Image1.Top + 70;


  //timeleft := SecondsBetween(ANextEvent.Occurance, Now);
  //if (timeleft < Parent.Width) then
  //begin
  //  ShapeNextTop.BorderSpacing.Left := Round((Parent.Width - timeleft) * 0.5);
  //  ShapeNextTop.BorderSpacing.Right := ShapeNextTop.BorderSpacing.Left;
  //end
  //else
  //begin
  //  ShapeNextTop.BorderSpacing.Left := 0;
  //  ShapeNextTop.BorderSpacing.Right := 0;
  //end;



end;

end.

