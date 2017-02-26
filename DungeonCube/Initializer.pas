unit Initializer;

interface

uses
  Windows, SysUtils, Vectors2px, AbstractDevices, AbstractCanvas, AsphyreImages, AsphyreFonts,
  AsphyreArchives, vcl.forms;

var
  DisplaySize: TPoint2px;
  GameDevice: TAsphyreDevice = nil;
  GameCanvas: TAsphyreCanvas = nil;
  GameImages: TAsphyreImages = nil;
  GameFonts : TAsphyreFonts  = nil;
  Media_effects :   TAsphyreArchive = nil;
  Media_models : TAsphyreArchive = nil;
  Media_maps :   TAsphyreArchive = nil;
  Media_gui : TAsphyreArchive = nil;
  Media_deadmap: TAsphyreArchive = nil;

  playername, peermode, master, map: string;
  masterport: integer;

  Tinit,Tpost,Ttotal: TDateTime;

implementation

uses LoaderUnit, Main, Camera, Ping, Keyboard, Playmon,  Collision, Hint, Chat,
Entities, Network, MobControl;


begin
//receive parameters here, player name, server ip, hosting mode, player class
Tinit:=Now;
Loader := TLoader.Create(nil);
Loader.Show;
Loader.SetLoadText('Setting up network..');

sleep(500);

application.ProcessMessages;

try
playername := (paramstr(1));
peermode := (paramstr(2));
master := (paramstr(3));
masterport := StrToInt(paramstr(4));
map := (paramstr(5));
except
playername := 'Stranger_'+inttostr(random(999));
peermode := 'server';
master := '127.0.0.1';
masterport := 1556;
map := 'map_chili';
end;

  screen.Cursors[0] := LoadCursor(HInstance, 'MAINCUR');
  screen.Cursor := screen.Cursors[0];
                                                 Collision.Initialize;
  //Loader.SetLoadText('Loading Character..');     Abilities.Initialize;
  Loader.SetLoadText('Adding Input Devices..');  Keyboard.Initialize;
  Loader.SetLoadText('Invoking Hint.. ');        Hint.Initialize;
  Loader.SetLoadText('Adding player..');         Playmon.initialize;
  Loader.SetLoadText('Invoking Chat.. ');        Chat.Initialize;
  Loader.SetLoadText('Loading Entities..');      Entities.Initialize;
  Loader.SetLoadText('Initiating Network... ');  Network.Initialize;
  Loader.SetLoadText('Starting up Graphics..');  Ping.Initialize;

  //the server should handle mob controls.
  if (peermode = 'server') then
    Loader.SetLoadText('Loading Creatures..');     MobControl.initialize;


  Tpost:=Now;
  Ttotal:=TPost-Tinit;

  Loader.SetLoadText('Loading completed in: '+FormatDateTime('s.z', Ttotal)+' seconds.');
  Loader.SetProgress(100);
  Loader.FinishLoading;
END.
