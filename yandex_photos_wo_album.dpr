program yandex_photos_wo_album;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  libwebp in 'libwebp.pas',
  WebpHelpers in 'WebpHelpers.pas',
  unit_albums in 'unit_albums.pas' {Form2},
  common in 'common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
