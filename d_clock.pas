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
        PaintBox1: TPaintBox;
        Shape1: TShape;
        Timer1: TTimer;
        procedure FormCreate(Sender: TObject);
        procedure PaintBox1Click(Sender: TObject);
        procedure PaintBox1Paint(Sender: TObject);
        procedure Timer1Timer(Sender: TObject);
    private
        Bitmap : TBitmap;

    public
        Silent : boolean;
        Delay : integer;
        procedure UpdateGUI (ANextEvent : TEvent);
        procedure UpdateGUI2 (ANextEvent : TEvent);

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
  Shape1.Tag:=5;
  Shape1.Visible:=false;

  LabelClock.Font.Color := $00FF8000;
  LabelNext.Font.Color := clWhite;
  LabelMessage.Font.Color := clWhite;
  Bitmap := TBitmap.Create;


//  LabelClock.
  //UpdateGUI;
end;

procedure TfrmClock.PaintBox1Click(Sender: TObject);
begin

end;

procedure TfrmClock.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0,0,Bitmap);

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
  LabelClock.Height:=Trunc (Parent.ClientHeight * szClock);

  Image1.Top := LabelClock.Height - 88;
  Image1.Left:= 0;

  LabelMessage.Left:=0;
  LabelMessage.Top:=LabelClock.Height;
  LabelMessage.Width:=Parent.Width;
  LabelMessage.Height:=Trunc (Parent.ClientHeight * szClockRest * 0.3);

  LabelNext.Left:=0;
  LabelNext.Top:=LabelClock.Height + LabelMessage.Height;
  LabelNext.Width:=Parent.Width;
  LabelNext.Height:=Trunc (Parent.ClientHeight * szClockRest * 0.6);

  ImageSilent.Visible := Silent;
  if (Parent <> nil) then
  begin
  	ImageSilent.Height:=Trunc (Parent.ClientHeight * szClock) - 16;
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

procedure TfrmClock.UpdateGUI2 (ANextEvent : TEvent);
var
    timeleft: int64;
	szClock : real;
    szClockRest : real;
    tw, th1 : integer;
    cent: integer;
begin
  Bitmap.Canvas.Brush.Style:=bsClear;
  Bitmap.Height:=Parent.Height;
  Bitmap.Width:=Parent.Width;
  Bitmap.Transparent:=true;
  //Bitmap.TransparentColor:=clCyan;
  Bitmap.TransparentMode:=tmAuto;
  Bitmap.Canvas.Font.Color := $00FF8000;
  Bitmap.Canvas.Font.Style:=[fsBold];




  szClock := 0.6;
  szClockRest := 1.0 - szClock;

  CalcFontSize (FormatDateTime('hh:nn', Now), Bitmap.Canvas, Parent.Width, Trunc (Parent.ClientHeight * szClock));
  th1 := Bitmap.Canvas.Font.Height;
  tw := Bitmap.Canvas.TextWidth(FormatDateTime('hh:nn', Now));

  cent := Trunc (Parent.Width * 0.5) - Trunc (tw*0.5);
//  Bitmap.Canvas.TextOut(cent, Bitmap.Canvas.Font.Height, FormatDateTime('hh:nn', Now));
    Bitmap.Canvas.TextOut(cent, 0, FormatDateTime('hh:nn', Now));

  PaintBox1.Repaint;


 // LabelClock.Left:=0;
 // LabelClock.Top:=0;
 // LabelClock.Width:=Parent.Width;
 // LabelClock.Height:=Trunc (Parent.ClientHeight * szClock);
 //
 // Image1.Top := LabelClock.Height - 88;
 // Image1.Left:= 0;
 //
 // LabelMessage.Left:=0;
 // LabelMessage.Top:=LabelClock.Height;
 // LabelMessage.Width:=Parent.Width;
 // LabelMessage.Height:=Trunc (Parent.ClientHeight * szClockRest * 0.32);
 //
 // LabelNext.Left:=0;
 // LabelNext.Top:=LabelClock.Height + LabelMessage.Height;
 // LabelNext.Width:=Parent.Width;
 // LabelNext.Height:=Trunc (Parent.ClientHeight * szClockRest * 0.65);
 //
 // ImageSilent.Visible := Silent;
 // if (Parent <> nil) then
 // begin
 // 	ImageSilent.Height:=Trunc (Parent.ClientHeight * szClock) - 16;
 //   ImageSilent.Width:=ImageSilent.Height;
 //   ImageSilent.Left := Parent.Width - ImageSilent.Width - 8;
 //   ImageSilent.Top := 8;
 // end;
 //
 // LabelClock.Caption := FormatDateTime('hh:nn', Now);
 // CalcLabelSize (LabelClock, Parent.Width, LabelClock.Height);
 //
 // LabelMessage.Caption := ANextEvent.Message;
 // CalcLabelSize (LabelMessage, Parent.Width, LabelMessage.Height);
 //
 // LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance);
 // if (Delay > 0) then
 // begin
	//LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + '+' + IntToStr (Delay) + 'min.';
 // end;
 //
 // if (Delay < 0) then
 // begin
	//LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + IntToStr (Delay) + 'min.';
 // end;
 //
 // CalcLabelSize (LabelNext, Parent.Width, LabelNext.Height);
 //
 // Shape1.Top := Image1.Top + 70;


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

