unit Network;

//multiplayer mob state, group by ip:port pairs, for host.

interface

uses Classes, SysUtils, Dialogs, idSocketHandle,
idUDPserver, Graphics, Windows, Playmon;

type
  THandler = class
  class procedure Server_Read(AThread: TIdUDPListenerThread; AData: TBytes; ABinding: TIdSocketHandle);
End;

type
  TMultiplayer = class
  name, ip: string;
  x, y, hp, dir, speed, dist: double;
  color: TColor;
  ping, level, port, size: integer;
  class_name: string;
  dc_warning: integer;
 constructor create();
 procedure kick(reason:string);
 function image(): integer;
End;

procedure Movement();
procedure initialize();
Procedure Send(data:string);
Procedure BroadCast(data:string);
Procedure SendChat(sender, text: string);
procedure SendXP(receiver: string; amount: integer);
procedure SendHint(style, text: string; x, y: integer);
procedure Send2XY(target: TPlayer; dist: double);
Procedure SendXY(target: TPlayer);
Procedure ReplyTo(ip: string; port: integer; data: string);
procedure NetFire(); overload; //sends the last created entity thrugh the network
Procedure NetFire(projectile_format: string); overload;
function NetFormat(text: string): UnicodeString;

var
  Server:         TidUdpServer;
  Multiplayer:    array of TMultiplayer;
  host, peermode: string;
  hostport: integer;
  input, output: longint;

implementation

Uses Hint, Entities, Chat, Initializer, MobControl, Main;

procedure Movement();
var
i: integer;
begin
  for i := 0 to length(multiplayer)-1 do begin

    if Multiplayer[i].dist <= 0.0 then continue;

    Multiplayer[i].dist := Multiplayer[i].dist-Multiplayer[i].speed;

    Multiplayer[i].x := Multiplayer[i].x+Multiplayer[i].speed*Cos(Multiplayer[i].dir);
    Multiplayer[i].y := Multiplayer[i].y+Multiplayer[i].speed*Sin(Multiplayer[i].dir);
  end;
End;

procedure TMultiplayer.kick(reason:string);
var
  i: integer;
begin

for i := 0 to length(Multiplayer)-1 do begin
  if Multiplayer[i].name = self.name then begin
    if length(Multiplayer) > 1 then
      multiplayer[i] := multiplayer[length(multiplayer)-1];

    setLength(multiplayer, length(multiplayer)-1);
  end;
end;
End;

function TMultiplayer.image(): integer;
begin

 if (class_name = 'Thief') then
   result := Main.MODEL_THIEF;
 if (class_name = 'Mage') then
   result := Main.MODEL_MAGE;
 if (class_name = 'Warrior') then
   result := Main.MODEL_WARRIOR;

end;

constructor TMultiplayer.create();
begin
 size := 14;
 color := $FFFFFFF;
 name := 'Stranger';
End;

function NetFormat(text: string): UnicodeString;
var
  i: integer;
begin
  for i := 0 to length(text)-1 do
    if text[i] = ' ' then
      text[i] := '%';

  result := text;
end;

function ReadFormat(text: string): UnicodeString;
var
  i: integer;
begin
  for i := 0 to length(text)-1 do
    if text[i] = '%' then
      text[i] := ' ';

  result := text;
end;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
 ListOfStrings.Clear;
 ListOfStrings.Delimiter     := Delimiter;
 ListOfStrings.DelimitedText := Str;
end;

function SafeFloat( pText : string ): Double;
var
  is_euro: boolean;
  i: integer;
  dummy: double;
  dummy_str: string;
begin
  dummy := 1/2;
  dummy_str := FloatToStr(dummy);                             //swap depending on host machine

  for i := 0 to length(dummy_str)-1 do begin
    if dummy_str[i] = '.' then is_euro := true;
    if dummy_str[i] = ',' then is_euro := false;
  end;

  if is_euro = false then
    pText := StringReplace(pText, '.', ',', [rfIgnoreCase, rfReplaceAll]);

  if is_euro = true then
    pText := StringReplace(pText, ',' ,'.', [rfIgnoreCase, rfReplaceAll]);

result := StrToFloat(pText);
End;


class procedure THandler.Server_Read(AThread: TIdUDPListenerThread; AData: TBytes; ABinding: TIdSocketHandle);
var
  DataList: TStringList;
  s, text: string;
  i,j: integer;
begin
input := input + (sizeof(AData));
DataList := TStringList.Create();
DataList.encoding.UTF8;
  try
    try
       s := TEncoding.Unicode.GetString( AData );//(BytesToString(AData, length(AData)));

       //writeln(s);

      //split string into data here.
      Split('&', s, DataList);

      if datalist.strings[0] = 'chat-message' then begin
        text := datalist.strings[2];
        Chat.Session.RollUp(datalist.strings[1], ReadFormat(text));
      end;

      if datalist.strings[0] = 'GAME_JOIN' then
        ReplyTo(ABinding.PeerIP, ABinding.PeerPort, 'GAME_RUNNING&'+Initializer.map);


      //if ABinding.PeerIP <> '127.0.0.1' then
      if datalist.strings[0] = 'projectile-update' then                            //y                       //dmg                           //speed                       //type               //id from abilities                     //range
        Entities.list.FastFire(SafeFloat(datalist.strings[1]),StrToInt(datalist.strings[2]), StrToInt(datalist.strings[3]), StrToInt(datalist.Strings[4]), SafeFloat(datalist.Strings[5]), StrToInt(datalist.strings[6]), datalist.strings[7], StrToInt(datalist.strings[8]));


      if datalist.strings[0] = 'player-xp' then begin
        if datalist.strings[1] = player.name then begin
          player.GainExp(strtoint(datalist.strings[2]));
          player.score := player.score+strtoint(datalist.Strings[2]);
        end;

        if initializer.peermode = 'server' then
          for i := 0 to High(mob.at) do
           if (mob.at[i].name = datalist.Strings[1]) then
            mob.at[i].GainExp(strtoint(datalist.Strings[2]));
          //Hint.text_hint.RollUp('experience', '+'+datalist.strings[2], trunc(player.x), trunc(player.y), false);
        end;

      if datalist.strings[0] = 'hint' then begin
        Hint.text_hint.RollUp(ReadFormat(datalist.strings[1]), ReadFormat(datalist.strings[2]), StrToInt(datalist.strings[3]), StrToInt(datalist.strings[4]), false);
      end;

//do something with S here.
      if (datalist.strings[0] = 'p-xy') or (Datalist.Strings[0] = 'p2-xy') then begin

        for i := 0 to Length(Multiplayer)-1 do begin
          j := i;
          if Multiplayer[i].name = DataList.Strings[1] then
          break;
        end;

        if (j = length(multiplayer)-1) and (Multiplayer[j].name <> DataList.Strings[1]) then begin
          SetLength(MultiPlayer, length(multiplayer)+1);
          j := j+1;
          Multiplayer[j] := TMultiplayer.Create;
          Multiplayer[j].ip := ABinding.PeerIP;
          Multiplayer[j].port := ABinding.PeerPort;
        end;


    Multiplayer[j].name := DataList.Strings[1];

    if datalist.Strings[0] = 'p2-xy' then begin
    Multiplayer[j].dir  := SafeFloat(DataList.Strings[2]);
    Multiplayer[j].speed := SafeFloat(DataList.Strings[3]);
    Multiplayer[j].dist  := SafeFloat(DataList.Strings[4]);
    Multiplayer[j].hp := trunc(StrToInt(DataList.Strings[7]));
    Multiplayer[j].level := trunc(StrToInt(DataList.Strings[8]));
    Multiplayer[j].class_name := Datalist.Strings[9];
    end else begin
    Multiplayer[j].x := SafeFloat(DataList.Strings[2]);       //not exist add
    Multiplayer[j].y := SafeFloat(DataList.Strings[3]);
    Multiplayer[j].hp := trunc(StrToInt(DataList.Strings[4]));
    Multiplayer[j].level := trunc(StrToInt(DataList.Strings[5]));
    end;

    end;

    if peermode = 'server' then begin
     for i := 0 to length(multiplayer)-1 do
       if (multiplayer[i].ip <> ABinding.IP) and (multiplayer[i].ip <> '127.0.0.1') then
        ReplyTo(Multiplayer[i].ip, Multiplayer[i].port, s);
      end;


    except
      on E: Exception do begin
        //writeln('EXCEPTION OCCURED');
      end;
    end;
  finally
    //
  end;
End;

procedure SendHint(style, text: string; x, y: integer);
begin
  Send('hint&'+NetFormat(style)+'&'+NetFormat(text)+'&'+inttostr(x)+'&'+inttostr(y));
      output := output+4;
end;

procedure SendChat(sender,text: string);
begin
  Send('chat-message&'+NetFormat(sender)+'&'+NetFormat(text));
  SendHint('chat', NetFormat(text), trunc(player.x-(length(text)*4)), trunc(player.y));
end;

procedure SendXP(receiver: string; amount: integer);
begin
  Send('player-xp&'+NetFormat(receiver)+'&'+inttostr(amount));
end;

Procedure SendXY(target: TPlayer);
begin
 Network.Send('p-xy&'+NetFormat(target.name)+'&'+inttostr(trunc(target.px))+'&'+inttostr(trunc(target.py))+
 '&'+inttostr(trunc(target.hp))+
 '&'+inttostr(target.level));
     output := output+4;
end;

Procedure Send2XY(target: Tplayer; dist:double);
begin
 Network.Send('p2-xy&'+NetFormat(target.name)+'&'+FloatToStr(target.dir)+
    '&'+FloatToStr(target.getSpeed)+'&'+floatToStr(dist)+'&'+inttostr(trunc(target.px))
    +'&'+inttostr(trunc(target.py))+'&'+inttostr(trunc((target.hp)))
    +'&'+inttostr(target.level)+'&'+target.class_name);
        output := output+4;
end;


// NetFire fires the last fired projectile from FastFire through the network :)
Procedure NetFire();
var
projectile_format: string;
len: integer;
begin
len := Length(Entities.list.Entity)-1;
     output := output+4;
projectile_format := 'projectile-update&'+
  floattostr(list.Entity[len].dir)+'&'+
  IntToStr(trunc(Entities.list.Entity[len].x))+'&'+
  IntToStr(trunc(Entities.list.Entity[len].y))+'&'+
  IntToStr(trunc(Entities.list.Entity[len].impact_dmg))+'&'+
  FloatToStr(Entities.list.Entity[len].speed)+'&'+
  IntToStr(Entities.list.Entity[len].impact)+'&'+
  NetFormat(player.name)+'&'+
  IntToStr(trunc(Entities.list.entity[len].range));

Network.Send(projectile_format);
End;

Procedure NetFire(projectile_format: string);
begin
Network.Send(projectile_format);
    output := output+4;
End;


Procedure BroadCast(data:string);   //server should call this OnReply
var
  i: integer;
begin     //if host mode send to server ip only, peer mode broadcast all
  try
    for i := 0 to length(multiplayer)-1 do begin
      Server.Send(multiplayer[i].ip, multiplayer[i].port, data);
      //writeln('OUTGOING:'+multiplayer[i].ip+' - '+data);
    end;
  except
  //
  end;
End;

Procedure ReplyTo(ip: string; port: integer; data: string);  //peers/clients should call this
begin     //if host mode send to server ip only, peer mode broadcast all
  try
    Server.Send(ip, port, data, TEncoding.Unicode);
    output := output+4;
    //writeln('OUTGOING:'+host+' - '+data);
  except
  //
  end;
End;

Procedure Send(data: UnicodeString);  //peers/clients should call this
begin     //if host mode send to server ip only, peer mode broadcast all
  try
    Server.Send(host, hostport, data, TEncoding.Unicode);
    output := output+4;
    //writeln('OUTGOING:'+host+' - '+data);
  except
  //
  end;
End;



procedure Initialize();
begin
  host := Initializer.master;
  hostport := Initializer.masterPort;
  peermode := Initializer.peermode;

  if peermode = 'server' then
    host := '127.0.0.1';

  server := TidUDPServer.Create(nil);
  server.Bindings.Add.IP := '0.0.0.0';
  server.Bindings.Add.Port := hostport;
  server.BufferSize := 8196;
  server.BroadcastEnabled := true;
  server.ThreadedEvent := true;

  server.OnUDPRead := THandler.Server_Read;

  server.Active := true;

  SetLength(Multiplayer, 1);
  Multiplayer[0] := TMultiplayer.create;
  Multiplayer[0].name := initializer.playername;
  Multiplayer[0].ip := host; //send updates to server too ;-)
  Multiplayer[0].x := 0;
  Multiplayer[0].y := 0;

  Chat.Session.RollUp('SYSTEM', 'Game Joined.');
  SendChat(initializer.playername, 'Has Joined the Game.');
End;

begin
END.
