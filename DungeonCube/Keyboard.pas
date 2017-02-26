unit Keyboard;

interface

//This unit controls keyboard and mouse events.

uses Windows, Forms, Controls, Playmon, Camera, Dialogs, Entities, SysUtils, Network, Chat, Math;

procedure Update();
procedure Initialize();

var
  key_block, i,
  move_block: integer;
  in_chat : boolean;
  chat_string: UnicodeString;
  hotkeys: array[0..7] of integer = (1, 81, 87, 69, 82, 84, 68, 70); //TODO: load from settings later
  chars: Array [0..254] of boolean;

implementation

uses Main, Hint, SelectClassUnit, Collision;

procedure Initialize();
begin
  key_block := 0;
  move_block := 0;
  in_chat := false;
End;


procedure Movement();
var
dir, dist: double;
i: integer;
begin
if getAsyncKeyState(VK_RBUTTON) = 0 then exit;

  dec(move_block);
  if move_block > 0 then exit;

  dir := ArcTan2(mouse.CursorPos.Y-cam.Y-(player.y+player.size/2-2), mouse.CursorPos.X-cam.X-(player.x+player.size/2-2));
  dist :=(power(player.x-(mouse.CursorPos.X-cam.X)+player.size/2-2, 2))+power(player.y-(mouse.cursorpos.Y-cam.Y)+player.size/2-2, 2);
  dist := power(dist, 0.5);

  for i := 1 to round(dist) do
    if (Blocks.collide(trunc(player.x+i*cos(dir)), trunc(player.y+i*sin(dir)))) = true then begin
     dist := i-10;
     break;
  end;

  player.dir := dir;
  player.dist := dist;

  if player.dist < 0.0 then
    player.dist := 0.0;

  Network.Send2XY(player, player.dist);
  move_block := 2; // 30x per sec
End;

Procedure Attack();
var
i: integer;
begin
for i := 0 to 7 do
  if (HiByte(getAsyncKeyState(hotkeys[i])) <> 0)  then begin
    if Player.spell[i].OnCooldown(player.silence) = false then
      if Player.spell[i].SpellCost(trunc(player.power)) = true then begin
        Player.Cast(i, mouse.CursorPos);
        Player.power := player.power-player.spell[i].cost;
      end;
  end;
End;


function GetCharFromVKey(vkey: Word): string;
var
   keystate: TKeyboardState;
   retcode: Integer;
begin
   Win32Check(GetKeyboardState(keystate)) ;
   SetLength(Result, 2) ;
   retcode := ToAscii(vkey,
     MapVirtualKey(vkey, 0),
     keystate, @Result[1],
     0) ;
   case retcode of
     0: Result := '';
     1: SetLength(Result, 1) ;
     2: ;
     else
       Result := '';
   end;
end;

Procedure Chat();
var
i: integer;
begin

if (GetAsyncKeyState(VK_RETURN) <> 0) and (in_chat = true) then begin
  in_chat := false;
  Network.SendChat(Player.name, chat_string);
  chat_string := '';
end;

  if (getAsyncKeyState(VK_SHIFT) <> 0) then
     in_chat := true;

  if in_chat = true then
    for i := 0 to length(chars) do
      if getAsyncKeyState(i) <> 0 then begin               //true false - enabled or not - must release before repress
      if chars[i] = false then begin
        chat_string := chat_string+GetCharFromVkey(i);

        if (i = VK_BACK) then
          SetLength(chat_string, length(chat_string)-2);   //remove last char


        chars[i] := true;
        end;

        end else
        chars[i] := false;

End;

Procedure Stats();
begin
    if getAsyncKeyState(VK_f1) <> 0 then player.addStat('CON'); key_block := 15;
    if getAsyncKeyState(VK_f2) <> 0 then player.addStat('DEX'); key_block := 15;
    if getAsyncKeyState(VK_f3) <> 0 then player.addStat('STR'); key_block := 15;
    if getAsyncKeyState(VK_f5) <> 0 then player.addStat('WIS'); key_block := 15;
    if getAsyncKeyState(VK_f4) <> 0 then player.addStat('INT'); key_block := 15;
  key_block := 1000;
End;

procedure Update();
begin
  if main.RenderForm.Handle <> GetForeGroundWindow then
    exit;

      Chat();
      Movement();

    if in_chat = true then
     exit;

  if getAsyncKeyState(ord('P')) <> 0 then begin
     playmon.Player.alive := false;
     SelectClass.Show;
  end;

  Attack();
  Stats();

  if (getAsyncKeyState(VK_UP) <> 0) then
   player.GainExp(500);

  if getAsyncKeyState(VK_ESCAPE) <> 0 then
    RenderForm.Close;
End;

begin
END.
