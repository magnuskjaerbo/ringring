unit d_Clock;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    ComCtrls, uutil, uSettings, DateUtils;

type

    { TfrmClock }

    TfrmClock = class(TForm)
        ImageSilent: TImage;
        LabelClock: TLabel;
        LabelMessage: TLabel;
        LabelNext: TLabel;
        PanelSplit: TPanel;
        Shape1: TShape;
        Shape10: TShape;
        Shape11: TShape;
        Shape12: TShape;
        Shape2: TShape;
        Shape3: TShape;
        Shape4: TShape;
        Shape5: TShape;
        Shape6: TShape;
        Shape7: TShape;
        Shape8: TShape;
        Shape9: TShape;
        Timer1: TTimer;
        procedure FormCreate(Sender: TObject);
    private
        Bitmap : TBitmap;
        Initialized : boolean;
        Shapes : array of TShape;
    public
        Silent : boolean;
        Delay : integer;
        procedure UpdateGUI (ANextEvent : TEvent);
        procedure Initialize ();
        procedure UpdateGUI2 (ANextEvent : TEvent);

    end;

var
    frmClock: TfrmClock;

implementation

{$R *.lfm}

procedure TfrmClock.FormCreate(Sender: TObject);
begin
  Initialized := false;
  Silent := false;
  Color := clBlack;
  //Shape1.Top := Image1.Top + 72;
  //Shape1.Left := 130;
  //Shape1.Tag:=5;
  //Shape1.Visible:=false;

  LabelClock.Font.Color := $00FF8000;
  LabelClock.Tag := 1;
  LabelNext.Font.Color := clWhite;
  LabelMessage.Font.Color := clWhite;
  Bitmap := TBitmap.Create;
  SetLength (Shapes, 12);
  Shapes[0] := Shape1;
  Shapes[1] := Shape2;
  Shapes[2] := Shape3;
  Shapes[3] := Shape4;
  Shapes[4] := Shape5;
  Shapes[5] := Shape6;
  Shapes[6] := Shape7;
  Shapes[7] := Shape8;
  Shapes[8] := Shape9;
  Shapes[9] := Shape10;
  Shapes[10] := Shape11;
  Shapes[11] := Shape12;


//  LabelClock.
  //UpdateGUI;
end;

procedure TfrmClock.Initialize ();
var
    szClock : real;
    szClockRest : real;
    currTop : integer;
    prevLeft : integer;
	shape : TShape;
begin
	if (Initialized = false) then
  	begin

    	szClock := 0.6;
    	szClockRest := 1.0 - szClock;

        currTop := 0;
        LabelClock.Left:=0;
        LabelClock.Top:=0;
        LabelClock.Width:=Parent.Width;
        LabelClock.Height:=Trunc (Parent.ClientHeight * szClock);
        currTop := currTop + LabelClock.Height;

        PanelSplit.Left := 0;
        PanelSplit.Top := currTop;
        PanelSplit.Height:=6;
        PanelSplit.Width := Parent.Width;

        currTop := currTop + PanelSplit.Height + 8;

        prevLeft := 0;
        for shape in Shapes do
        begin
          shape.Left:=prevLeft;
          shape.Top:=0;
          shape.Brush.Color:=clSilver;
          shape.Height:=PanelSplit.Height;
          shape.Width:= Trunc (PanelSplit.Width / 12);
          prevLeft := shape.Left + shape.Width;
        end;

        LabelMessage.Left:=0;
        LabelMessage.Top:=currTop;
        LabelMessage.Width:=Parent.Width;
        LabelMessage.Height:=Trunc (Parent.ClientHeight * szClockRest * 0.3);
        currTop := currTop + LabelMessage.Height - 24;

        LabelNext.Left:=0;
        LabelNext.Top:=currTop;
        LabelNext.Width:=Parent.Width;
        LabelNext.Height:=Trunc (Parent.ClientHeight * szClockRest * 0.63-12);
        currTop := currTop + LabelNext.Height;

      	ImageSilent.Height:=Trunc (Parent.ClientHeight * szClock) - 16;
        ImageSilent.Width:=ImageSilent.Height;
        ImageSilent.Left := Parent.Width - ImageSilent.Width - 8;
        ImageSilent.Top := 8;

		Initialized := true;
    end;

end;


procedure TfrmClock.UpdateGUI (ANextEvent : TEvent);
var
     Hh,MM,SS,MS : Word;
     shape : TShape;
begin

  DeCodeTime (Time,Hh,MM,SS,MS);

  for shape in Shapes do
  begin
    shape.Brush.Color:=clSilver;
  end;

  SS := Trunc (ss / 5);
  Shapes[SS mod 12].Brush.Color:=$00FF8000;



  	DisableAlign;

	Initialize;

 	ImageSilent.Visible := Silent;

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

  EnableAlign;

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

