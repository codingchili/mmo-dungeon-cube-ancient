unit MobControl;

interface

uses SysUtils, Playmon, Math, System.Types;

//mob input / output comes from  network.
//the server should control these.

const
DISABLED = true;

procedure Initialize;

type
Tmob = class
public
  at: array[0..2] of TPlayer;

  procedure TickRegen();
  procedure UpdateState(mob: TPlayer);
  procedure AI();
  procedure WalkTo(mob: Tplayer; x, y : integer);
end;

var
mob: Tmob;

implementation

uses Network, collision, camera, initializer;

//fix this pls
function LocatePlayer(x, y, maxrange : double): TPoint;
var
i: integer;
pnear, target: TPoint;
begin
pnear.X := trunc(player.x);
pnear.Y := trunc(player.y);

for I := 0 to High(Network.Multiplayer) do begin
target.X := trunc(Network.Multiplayer[i].x);
target.Y := trunc(Network.Multiplayer[i].y);

if (trunc(abs(target.X-X)+abs(target.Y-y))) = 0 then continue;

if (abs(target.X-X) + abs(target.Y-Y)) < abs(pnear.X-X) + abs(pnear.Y-Y) then
  pnear := target;

{if (abs(pnear.X-X)+abs(pnear.Y-y) > maxrange) then
  writeln('Not In Range, distance: ' + inttostr(trunc(abs(pnear.X-X)+abs(pnear.Y-y))) + ' - ['+IntToStr(pnear.x)+ ':' + IntToStr(pnear.Y)+']')
else
writeln('Found, distance: ' + inttostr(trunc(abs(pnear.X-X)+abs(pnear.Y-y))) + ' - ['+IntToStr(pnear.x)+ ':' + IntToStr(pnear.Y)+']');  }
end;

result := pnear;
end;

//heavy function, dont to this for every frame.
procedure TMob.AI();
var
i, spell: integer;
begin
if (DISABLED) or (initializer.peermode <> 'server') then exit;

randomize;

//if random(40) < 40 then
for I := 0 to high(mob.at) do begin
spell := random(7);

   if (self.at[i].spell[spell].OnCooldown(self.at[i].silence) = false) then
   if (LocatePlayer(self.at[i].X, self.at[i].Y, self.at[i].spell[spell].range).x) <> 0 then
   if (self.at[i].spell[spell].SpellCost(trunc(self.at[i].power))) = true then begin
    self.at[i].Cast(spell, LocatePlayer(self.at[i].x+cam.x, self.at[i].y+cam.Y, self.at[i].spell[spell].range));
    //self.at[i].power := self.at[i].power-self.at[i].spell[spell].cost;
   end;
  //run the AI.
  //run toward near players
  //fire against near players when not on cooldown.
  //self.at[i].dir := LocatePlayer(self.at[i].GetX, self.at[i].GetY);
  //network.Send2XY(self.at[i], 50.0);
   //if collision.blocks.Collide(self.at[i].getX, self.at[i].getY) = False and (self.at[i].dir <> 0.0) then
   //  self.at[i].Movement;

end;
end;

procedure TMob.WalkTo(mob: TPlayer; x, y : integer);
var
dist, range: double;
begin
  // check if player is near + walk into range.
  if (mob.class_name = 'Warrior') then range := 20.0;
  if (mob.class_name = 'Thief') then range := 80.0;
  if (mob.class_name = 'Mage') then range := 130.0;

    //determine distance to players, //run walkto algorithm axis-based, cross axis once and from there line to player?

  Network.Send2XY(mob, dist);
end;

procedure TMob.UpdateState(mob: TPlayer);
begin
if (DISABLED) then exit;
  Network.Send('p-xy&'+NetFormat(mob.name)+'&'+inttostr(trunc(mob.px))+
  '&'+inttostr(trunc(mob.py))+'&'+inttostr(trunc((mob.hp)))+
  '&'+inttostr(mob.level));
end;

procedure TMob.TickRegen();
var
i: integer;
begin
  for i := 0 to high(mob.at) do
   if mob.at[i].alive = true then begin
    mob.at[i].tickRegen;
    mob.at[i].ProcessCooldowns;
   end;
end;


procedure initialize;
var
class_name: string;
i: integer;
begin
randomize;
mob := Tmob.Create;

  for I := 0 to length(mob.at)-1 do begin
    case (random(0)) of
      0: class_name := 'Thief';
      1: class_name := 'Warrior';
      2: class_name := 'Mage';
    end;

    mob.at[i] := TPlayer.Create(inttostr(random(999)) + '.' + class_name, class_name, true);

    mob.at[i].Reset;
    mob.at[i].alive := true;
    mob.at[i].MakeStats;
    mob.at[i].shield := 0;
    mob.UpdateState(mob.at[i]);
  end;
end;

begin
randomize;
end.
