program VideoBox;

uses
  Vcl.Forms,
  MainWindow in 'MainWindow.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles,
  FileChecker in 'FileChecker.pas',
  SoundSystem in 'SoundSystem.pas',
  PlaylistSystem in 'PlaylistSystem.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Obsidian');
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
