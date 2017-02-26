unit Player;

interface


uses Graphics, Windows, PlayerClass, SysUtils;

type
  Entity = class
 public
  name, ip, team: string;
  x, y: double;
  color: TColor;
  size: integer;
  PlayerClass: TPlayerClass;
 constructor Create();
 procedure Movement(modX, modY: double);
 function px():double;
 function py():double;
End;

procedure initialize();


var
  Player: Character.Entity;

implementation

function Entity.px():double;
begin
  if PlayerClass.stealth = true then result := -500 else
  result := x;
End;

function Entity.py():double;
begin
  if PlayerClass.stealth = true then result := -500 else
  result := y;
End;


constructor Entity.create();
begin
  randomize;
  x := 600.0;
  y := 300.0;
  write('Player-Name: ');
  readln(name);
  size := 14;
  team := 'team2';
  color := clFuchsia;

  writeln(''+name+': Joined the game at '+inttostr(trunc(x))+','+inttostr(trunc(y)));

  PlayerClass := TplayerClass.create('Hero');
End;


procedure Entity.Movement(modX,modY: double);
begin
  x := x+modX;
  y := y+modY;
End;

procedure Initialize();
begin
  Player := Character.Entity.create;
  Player.PlayerClass := TPlayerClass.create('Hero');
End;

begin
END.
