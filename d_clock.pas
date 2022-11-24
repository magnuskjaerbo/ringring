unit d_Clock;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    ComCtrls, uutil, uSettings, DateUtils;

type

    { TfrmClock }

    TfrmClock = class(TForm)
        Image1: TImage;
        ImageSilent: TImage;
        LabelClock: TLabel;
        LabelMessage: TLabel;
        LabelNext: TLabel;
        PanelSplit: TPanel;
        Timer1: TTimer;
        procedure FormCreate(Sender: TObject);
        procedure FormMouseEnter(Sender: TObject);
        procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
        procedure LabelClockMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
        procedure LabelMessageMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
        procedure Shape6ChangeBounds(Sender: TObject);
    private
        Bitmap : TBitmap;
        Initialized : boolean;
        Shapes : array of TShape;
        ShapesToRing : array of TShape;
    public
        Silent : boolean;
        Delay : integer;
        marcueeNormal : TColor;
        marcueeMid : TColor;
        marcueeMid2 : TColor;
        marcueeMid3 : TColor;
        marcueeHot : TColor;
        procedure UpdateGUI (ANextEvent : TEvent);
        procedure Initialize ();
        procedure UpdateGUI2 (ANextEvent : TEvent);

    end;

var
    frmClock: TfrmClock;

implementation

{$R *.lfm}

procedure TfrmClock.FormCreate(Sender: TObject);
var
    shape : TShape;
    ix: integer;
    c1, c2: TColor;
    r1, r2, r3 :Byte;
    g1, g2, g3 :Byte;
    b1, b2, b3 :Byte;
begin
  Initialized := false;
  Silent := false;
  Color := clBlack;
  marcueeNormal := clMaroon;
  marcueeHot := clGreen;
  marcueeMid := Trunc ((marcueeNormal + marcueeHot)/2);
  marcueeMid2:= Trunc ((marcueeNormal*2 + marcueeHot)/3);

  r1 := Red (marcueeNormal);
  r2 := Red (marcueeHot);
  g1 := Green (marcueeNormal);
  g2 := Green (marcueeHot);
  b1 := Blue (marcueeNormal);
  b2 := Blue (marcueeHot);

  r3 := Trunc ((r1 + r2)/2);
  g3 := Trunc ((g1 + g2)/2);
  b3 := Trunc ((b1 + b2)/2);
  marcueeMid := RGBToColor (r3, g3, b3);

  r3 := Trunc ((r1*2 + r2)/3);
  g3 := Trunc ((g1*2 + g2)/3);
  b3 := Trunc ((b1*2 + b2)/3);
  marcueeMid2 := RGBToColor (r3, g3, b3);

  r3 := Trunc ((r1*3 + r2)/4);
  g3 := Trunc ((g1*3 + g2)/4);
  b3 := Trunc ((b1*3 + b2)/4);
  marcueeMid3 := RGBToColor (r3, g3, b3);


  LabelClock.Font.Color := marcueeHot; //$00FF8000;
  LabelClock.Tag := 1;
  LabelNext.Font.Color := marcueeNormal; //clWhite;
  LabelMessage.Font.Color := marcueeNormal; //clWhite;
  Bitmap := TBitmap.Create;

  SetLength (Shapes, 60);
  for ix:=0 to Length (Shapes)-1 do
  begin
  	shape := TShape.Create (PanelSplit);
    shape.Parent :=PanelSplit;
    shape.Pen.JoinStyle:=pjsMiter;
    shape.Brush.Style:=bsSolid;
	Shapes[ix] := shape;
  end;
  //Shapes[0] := Shape1;
  //Shapes[1] := Shape2;
  //Shapes[2] := Shape3;
  //Shapes[3] := Shape4;
  //Shapes[4] := Shape5;
  //Shapes[5] := Shape6;
  //Shapes[6] := Shape7;
  //Shapes[7] := Shape8;
  //Shapes[8] := Shape9;
  //Shapes[9] := Shape10;
  //Shapes[10] := Shape11;
  //Shapes[11] := Shape12;



end;

procedure TfrmClock.FormMouseEnter(Sender: TObject);
begin
    Screen.Cursor := crDefault;
end;

procedure TfrmClock.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
begin
    Screen.Cursor := crDefault;
end;

procedure TfrmClock.LabelClockMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
begin
    Screen.Cursor := crDefault;
end;

procedure TfrmClock.LabelMessageMouseMove(Sender: TObject; Shift: TShiftState;
    X, Y: Integer);
begin
    Screen.Cursor := crDefault;
end;

procedure TfrmClock.Shape6ChangeBounds(Sender: TObject);
begin

end;

procedure TfrmClock.Initialize ();
var
    szClock : real;
    szClockRest : real;
    currTop, space : integer;
    prevLeft, prevTop, wid : integer;
	shape : TShape;
begin
	if (Initialized = false) then
  	begin

    	szClock := 0.6;
    	szClockRest := 1.0 - szClock;

        currTop := 0;
        currTop := -Trunc (currTop + LabelClock.Height * 0.25);
        LabelClock.Left:=0;
        LabelClock.Top:=currTop;
        LabelClock.Width:=Parent.Width;
        LabelClock.Height:=Trunc (Parent.ClientHeight * szClock);
        currTop := Trunc (currTop + LabelClock.Height);
        Image1.Left := 0;
        Image1.Top := 0;
        Image1.Width := LabelClock.Width;
        Image1.Height := LabelClock.Height;


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
          shape.Brush.Color:=marcueeNormal;
          shape.Pen.Style:=psClear;
          shape.Height:=PanelSplit.Height;
          shape.Width:= Round ((PanelSplit.Width / Length(Shapes)));
          prevLeft := shape.Left + shape.Width;
        end;

        LabelMessage.Left:=0;
        LabelMessage.Top:=currTop;
        LabelMessage.Width:=Parent.Width;
        LabelMessage.Height:=Trunc ((Parent.ClientHeight - currTop)* 0.33);
        currTop := currTop + LabelMessage.Height; // - 24;

        LabelNext.Left:=0;
        LabelNext.Top:=currTop;
        LabelNext.Width:=Parent.Width;
        LabelNext.Height:=Trunc ((Parent.ClientHeight - currTop) * 0.90);

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
     pct : real;
     XX: integer;
     XXp, XXn: integer;
     XXpp, XXnn: integer;
     XXppp, XXnnn: integer;
     ix:integer;
     shape : TShape;
     timeStr: String;
begin

   	DisableAlign;
	Initialize;

    DeCodeTime (Time,Hh,MM,SS,MS);

    for shape in Shapes do
    begin
    	shape.Brush.Color:=marcueeNormal;
    end;

    MS := SS * 1000 + MS;
    pct := MS / 60000.0;
    XX := Round (pct * (Length (Shapes)-1));
    XXp := XX-1;
    XXpp := XX-2;
    XXppp := XX-3;
    XXn := XX+1;
    XXnn := XX+2;
    XXnnn := XX+3;
    if (XXn > Length (Shapes)-1) then XXn := -1;
    if (XXnn > Length (Shapes)-1) then XXnn := -1;
    if (XXnnn > Length (Shapes)-1) then XXnnn := -1;

    if (XXp > 0) then Shapes[XXp].Brush.Color:=marcueeMid;
    if (XXpp > 0) then Shapes[XXpp].Brush.Color:=marcueeMid2;
    if (XXppp > 0) then Shapes[XXppp].Brush.Color:=marcueeMid3;

    if (XXn > 0) then Shapes[XXn].Brush.Color:=marcueeMid;
    if (XXnn > 0) then Shapes[XXnn].Brush.Color:=marcueeMid2;
    if (XXnnn > 0) then Shapes[XXnnn].Brush.Color:=marcueeMid3;
    Shapes[XX].Brush.Color:=marcueeHot;

 	ImageSilent.Visible := Silent;

    timeStr := FormatDateTime('h:nn', Now);
    if (timeStr <> LabelClock.Caption) then
    begin
	  	LabelClock.Caption := timeStr;
  		CalcLabelSize (LabelClock, Parent.Width, LabelClock.Height);
    end;

    if (LabelMessage.Caption <> ANextEvent.Message) then
    begin
	  	LabelMessage.Caption := ANextEvent.Message;
  		CalcLabelSize (LabelMessage, Parent.Width, LabelMessage.Height-12);
    end;

    LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance);
    if (Delay > 0) then
    begin
	    LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + '+' + IntToStr (Delay) + 'min.';
    end;

    if (Delay < 0) then
    begin
    	LabelNext.Caption := TimeBetweenStr(Now, ANextEvent.Occurance) + IntToStr (Delay) + 'min.';
    end;
  	CalcLabelSize (LabelNext, Parent.Width, LabelNext.Height-24);

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

