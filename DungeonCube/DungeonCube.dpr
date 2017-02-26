program DungeonCube;

 {$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.dres}

uses
  Forms,
  LoaderUnit in 'LoaderUnit.pas' {Loader},
  Main in 'Main.pas' {RenderForm},
  Playmon in 'Playmon.pas',
  Camera in 'Camera.pas',
  Keyboard in 'Keyboard.pas',
  Entities in 'Entities.pas',
  Chat in 'Chat.pas',
  Collision in 'Collision.pas',
  Network in 'Network.pas',
  Ping in 'Ping.pas',
  Hint in 'Hint.pas',
  Initializer in 'Initializer.pas',
  Vcl.Themes,
  Vcl.Styles,
  SelectClassUnit in 'SelectClassUnit.pas' {SelectClass},
  MobControl in 'MobControl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRenderForm, RenderForm);
  Application.CreateForm(TLoader, Loader);
  Application.CreateForm(TSelectClass, SelectClass);
  Application.Run;
end.
