unit d_OnlineEvents;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, uSettings, DateUtils;

type

    { TfrmOnlineEvents }

    TfrmOnlineEvents = class(TForm)
        Image1: TImage;
        Image2: TImage;
        LabelNextEvent1: TLabel;
        LabelNextEvent2: TLabel;
        LabelNextEvent3: TLabel;
        LabelNextEvent4: TLabel;
        Shape1: TShape;
        Shape2: TShape;
        procedure FormCreate(Sender: TObject);
        procedure FormMouseEnter(Sender: TObject);
        procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
    private
    	procedure HandleEvent(LabelMessage, LabelDate: TLabel; Image: TImage; AEvents: array of TEvent);
    public
	    procedure UpdateGUI (AEventLine: integer; AEvents: array of TEvent);
    end;

var
    frmOnlineEvents: TfrmOnlineEvents;

implementation

{$R *.lfm}

{ TfrmOnlineEvents }

procedure TfrmOnlineEvents.FormCreate(Sender: TObject);
begin
  Color := clBlack;
  LabelNextEvent1.Font.Color := clSilver;
  LabelNextEvent2.Font.Color := clGray;
  LabelNextEvent3.Font.Color := clSilver;
  LabelNextEvent4.Font.Color := clGray;

end;

procedure TfrmOnlineEvents.FormMouseEnter(Sender: TObject);
begin
    Screen.Cursor := crDefault;
end;

procedure TfrmOnlineEvents.FormMouseMove(Sender: TObject; Shift: TShiftState;
    X, Y: Integer);
begin
    Screen.Cursor := crDefault;
end;

procedure TfrmOnlineEvents.UpdateGUI (AEventLine: integer; AEvents: array of TEvent);
begin

  if (AEventLine = 1) then HandleEvent (LabelNextEvent1, LabelNextEvent2, Image1, AEvents);
  if (AEventLine = 2) then HandleEvent(LabelNextEvent3, LabelNextEvent4, Image2, AEvents);

  //ImageSilent.Visible := Silent;
  //if (Parent <> nil) then
  //begin
  //	ImageSilent.Height:=Parent.Height - 16;
  //  ImageSilent.Width:=Parent.Height - 16;
  //  ImageSilent.Left := 8;
  //  ImageSilent.Top := 8;
  //end;
  //
  //LabelClock.Caption := FormatDateTime('hh:nn', Now);
  //CalcLabelSize (LabelClock, Parent.Width, Parent.Height);

end;
procedure TfrmOnlineEvents.HandleEvent(LabelMessage, LabelDate: TLabel; Image: TImage; AEvents: array of TEvent);
begin

  if Length(AEvents) > 0 then
  begin
    if (LabelMessage.Tag > Length(AEvents) - 1) then LabelMessage.Tag := 0;
    LabelMessage.Caption := AEvents[LabelMessage.Tag].Message;
    if Length(AEvents) > 1 then
    begin
      LabelDate.Caption := DateToStr(AEvents[LabelMessage.Tag].Occurance) +
        '  ' + IntToStr(LabelMessage.Tag + 1) + ' / ' + IntToStr(Length(AEvents));
    end
    else
    begin
      LabelDate.Caption := DateToStr(AEvents[LabelMessage.Tag].Occurance);
    end;
    Image.Visible := True;
    LabelMessage.Tag := LabelMessage.Tag + 1;
  end
  else
  begin
    LabelMessage.Caption := '';
    LabelDate.Caption := '';
    Image.Visible := False;
  end;
end;
end.

