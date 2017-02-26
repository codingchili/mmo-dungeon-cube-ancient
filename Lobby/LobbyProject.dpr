program LobbyProject;


{$R *.dres}

uses
  FastShareMem,
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  Networking in 'Networking.pas',
  Chat in 'Chat.pas',
  Reg in 'Reg.pas' {RegisterForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TRegisterForm, RegisterForm);
  Application.Run;
end.
