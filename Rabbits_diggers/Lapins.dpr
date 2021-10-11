program Lapins;

uses
  Forms,
  Lap01 in 'Lap01.pas' {FMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
