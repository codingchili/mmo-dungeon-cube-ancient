unit Collision;

//this unit handles collision, if collision is detected then tell the
//server to broadcast a health update. Only if the PLAYER is hit the
//update should be sent, reducing collision control. PLAYER CAN
//collide with other objects resulting in a movement block or damage
//Depending on collision type.

interface

Uses Sysutils, Controls;

const
BLOCKING = -1;
WALKABLE = 0;
LAVA = 1;
WATER = 2;
ENDPOINT = 3;
ENTRYPOINT = 4;


type
TBlocks = Class
  blocktype: array [0..100, 0..100] of integer;
  constructor create;
  function Collide(x, y: integer): boolean;
  function MediumType(x, y: integer): integer;
  procedure SaveToFile;
  public
  procedure LoadFromFile();
End;

procedure Detection();
procedure Initialize();


var
blocks: TBlocks;

implementation

uses Hint, Network, Entities, Playmon, Camera, Main, Initializer, MobControl;



constructor TBlocks.create;
var
i, j: integer;
begin
for j := 0 to high(Blocktype) do
for I := 0 to high(Blocktype) do
  blocktype[j, i] := (-1);
end;

Procedure TBlocks.LoadFromFile();
var
blockFile: textFile;
i: integer;
j: Integer;
begin
assignFile(blockFile, 'media/'+Initializer.map+'.bmap');
reset(blockFile);

for j := 0 to high(blocks.blocktype) do
for i := 0 to high(blocks.blocktype) do
readln(blockFile, blocks.blocktype[j, i]);

closefile(blockFile);
end;

Procedure TBlocks.SaveToFile();
var
blockFile: textFile;
i: integer;
j: Integer;
begin
assignFile(blockFile, 'media/'+Initializer.map+'.bmap');
rewrite(blockFile);

for j := 0 to high(blocks.blocktype) do
for i := 0 to high(blocks.blocktype) do
writeln(blockFile, Blocks.blocktype[j, i]);

closefile(blockFile);
end;


function TBlocks.Collide(x, y: integer): boolean;
begin
x := trunc((x-(x mod 30))/30)-8;
y := trunc((y-(y mod 30))/30)-8;

if Blocktype[x, y] = BLOCKING then result := true else
result := false;
End;

function TBlocks.MediumType(x, y: integer): integer;
begin
x := trunc((x-(x mod 30))/30)-8;
y := trunc((y-(y mod 30))/30)-8;

result := BlockType[x, y];
end;

procedure Detection();
var
  i, j, k: integer;
begin
  with Entities.list do begin

// --------------- CHECK PLAYER COLLISION -------------------------------
    for i := 0 to length(Entity)-1 do begin

      if (Entity[i].x < player.x+player.size) and (Entity[i].x > player.x-player.size-1) then
      if (Entity[i].y < player.y+player.size) and (Entity[i].y > player.y-player.size-1) then begin


      //comment this out to enable self-harm for debugging
        if Entity[i].owner = player.name then
          continue;

        Player.Damage(Entity[i].impact_dmg, Entity[i].impact, Entity[i].owner);
        Network.Send2XY(player, player.dist);

        Entity[i].range := -1; //orphan next frame
      end;
    end;

//--------------------------- CHECK MULTIPLAYER COLLISION ---------------------------

    for i := 0 to length(Entity)-1 do
      for j := 0 to length(Multiplayer)-1 do begin
        if (Entity[i].x < Multiplayer[j].x+Multiplayer[j].size) and (Entity[i].x > Multiplayer[j].x-Multiplayer[j].size-1) then
          if (Entity[i].y < Multiplayer[j].y+Multiplayer[j].size) and (Entity[i].y > Multiplayer[j].y-Multiplayer[j].size-1) then begin
            if multiplayer[j].name = Entity[i].owner then continue else

              //If multiplayer name in MobControl then damage it? xD
              if (initializer.peermode = 'server') then
              for k := 0 to length(mob.at) - 1 do
                if (multiplayer[j].name = mob.at[k].name) then begin
                 mob.at[k].Damage(Entity[i].impact_dmg, Entity[i].impact, Entity[i].owner);
                 mob.UpdateState(mob.at[k]);
                 //broadcast mob status ? :D
               end;

              if Entity[i].owner = player.name then    //your spell hit an enemy
                Player.SpellImpact(Entity[i].impact);


          Entity[i].range := -1;
        end;
      end;

//--------------------------- CHECK MOUSE HINT HOVER -----------------------------------------


    //hover_hint.x := -500;
    //hover_hint.y := -500;

    hover_hint.text := '';

    for j := 0 to length(Multiplayer)-1 do begin
      if (mouse.cursorpos.X-cam.x < Multiplayer[j].x+Multiplayer[j].size*2) and (mouse.cursorpos.X-cam.x > Multiplayer[j].x-Multiplayer[j].size*2) then
        if (mouse.cursorpos.Y-cam.y < Multiplayer[j].y+Multiplayer[j].size*2) and (mouse.cursorpos.Y-cam.y > Multiplayer[j].y-Multiplayer[j].size*2) then begin
          hover_hint.text := Multiplayer[j].name+' lv.'+inttostr(Multiplayer[j].level)+#13+#10+'HP: '+IntToStr(Trunc(Multiplayer[j].hp));


          {hover_hint.text := BoolToStr(Blocks.Collide(Player.getX, player.getY), true);  }
          hover_hint.x := trunc(mouse.cursorpos.X-length(hover_hint.text)*4);
          hover_hint.y := trunc(mouse.cursorpos.Y+30);
        end;
    end;
  end;
End;

Procedure Initialize();
begin
  blocks := TBlocks.create;
  blocks.LoadFromFile();
end;


begin
END.
