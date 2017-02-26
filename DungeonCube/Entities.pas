unit Entities;

interface

// It is of great importance that the device screen matches the
// native resolution of the display.

uses Graphics, Sysutils, Controls, Math;

type
Projectile = class
 public
  speed, x, y, x_end, y_end, dir, range, impact_dmg: double;
  size: integer;
  color: TColor;
  impact: integer;
  owner: string; //set effect       //blow, spell, arrow, spell1, burn, poison
 constructor Create(x,y,x_end, y_end, range, impact, impact_dmg, speed: double); overload;
 constructor Create(); overload;
End;

type
Projectile_List = class
 public
  Entity: array of Projectile;
 constructor Create();
 procedure Move();
 procedure Fire(x,y, x_end, y_end , range, impact_dmg, speed: double; impact_type: integer; player: string);
procedure  FastFire(dir, x, y, impact_dmg, speed: double; impact_type: integer; player: string; range: double);
 procedure Orphan(start: integer = 0);
End;

procedure initialize();

var
  list: Projectile_list;

implementation

uses Character, Camera, Collision, Network, Playmon;

constructor Projectile.Create(x,y,x_end,y_end, range, impact, impact_dmg, speed: double);
begin
//
End;

constructor Projectile.Create();
begin
  self.color := clAqua;
  self.size := 20;
  self.range := 50;
  self.speed := 3.65;
  self.impact_dmg := 20.0;
  self.impact := BASIC;
End;


constructor Projectile_List.Create;
begin
setLength(self.Entity, 0);
end;


procedure Projectile_list.Orphan(start: integer);
var
  index: Cardinal;
begin
try

  if length(list.entity) > 0 then
    for index := start to Length(list.Entity)-1 do begin
      list.Entity[index].range := list.Entity[index].range-1;

      if (list.Entity[index].range < 0) then begin
        if length(list.entity) = 1 then setLength(list.Entity, 0) else begin
          list.entity[index] := list.entity[length(list.entity)-1];
          setLength(list.entity, length(list.entity)-1);
        end;
      Orphan(index);
      break;
    end;
  end;
except
//
end;
End;


procedure Projectile_list.Move();
var
  len, i: integer;
begin
try
  len := length(self.Entity)-1;

  For i := 0 to len do begin

  if Collision.blocks.Collide(trunc(Entity[i].x), trunc(Entity[i].y)) then
      self.Entity[i].range := -1;

    self.Entity[i].x := self.Entity[i].x+self.entity[i].speed*Cos(self.Entity[i].dir);
    self.Entity[i].y := self.Entity[i].y+self.entity[i].speed*Sin(self.Entity[i].dir);
  end;
except
//
end;
End;

procedure Projectile_List.FastFire(dir, x, y, impact_dmg, speed: double; impact_type: integer; player: string; range: double);
var
  len: integer;
begin
try
  setLength(Entity, length(entity)+1);
  len := Length(Entity)-1;
  self.Entity[len] := Projectile.Create();

  self.entity[len].x := x;
  self.entity[len].y := y;
  self.entity[len].range := range;
  self.entity[len].dir := dir;
  self.entity[len].impact_dmg := impact_dmg;
  self.Entity[len].impact := impact_type;
  self.entity[len].owner := player;
  self.entity[len].speed := speed;
except
//
end;
End;


procedure Projectile_List.Fire(x,y, x_end, y_end , range, impact_dmg, speed: double; impact_type: integer; player: string);
var
projectile_format: string;
dir: double;
begin
  if (x = 0.0) and (y = 0.0) then
    exit;

  X := X-playmon.Player.size/2;
  Y := Y-playmon.Player.size/2;

  x_end := x_end-cam.X;
  y_end := y_end-cam.Y;

  dir := ArcTan2(y_end-y, x_end-x);

  projectile_format := 'projectile-update&'+
  floattostr(dir)+'&'+
  IntToStr(trunc(x))+'&'+
  IntToStr(trunc(y))+'&'+
  IntToStr(trunc(impact_dmg))+'&'+
  FloatToStr(speed)+'&'+
  IntToStr(impact_type)+'&'+
  NetFormat(player)+'&'+
  IntToStr(trunc(range));

  Network.NetFire(projectile_format);

End;

procedure Initialize();
begin
  Entities.list := Projectile_List.Create;
  SetLength(list.Entity, 0);
End;

begin
END.
