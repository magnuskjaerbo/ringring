program RingRing;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
   {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  lazcontrols,
  runtimetypeinfocontrols,
  Main,
  uLogger,
  uSettings,
  uJSON,
  uEvents,
  d_Debug,
  uIO, d_Control, d_Clock { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;

  Application.Title := 'ringring';
  Application.Scaled := False;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
    Application.CreateForm(TfrmControl, frmControl);
    Application.CreateForm(TfrmClock, frmClock);
  Application.Run;
end.
