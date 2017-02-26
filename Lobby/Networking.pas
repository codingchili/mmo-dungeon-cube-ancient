unit Networking;

interface

uses Classes, SysUtils, Dialogs, idSocketHandle,
idUDPserver, Graphics, Windows, ShellApi, VCL.controls, WinSock;

//game commands should only be sent to GAME SERVER IP
//lobby commands and chat should be sent to lobby SERVEr
//and broadcast to lobby users.                          ,

type
  THandler = class
  class procedure Server_Read(AThread: TIdUDPListenerThread; AData: TBytes; ABinding: TIdSocketHandle);
End;

type
TUser = class
  ip, name: string;
  port: integer;
end;

var
  Server:         TidUdpServer;
  users: array of TUser;
  inGame: array of TUser;
  host, peermode, gamehost: string;
  gameport: integer;

  Procedure SendMsg(user, text: string);
  Procedure StartGame();
  Function GetIPAddress(): String;


implementation

uses Chat, Main;

Function GetIPAddress: String;
type pu_long = ^u_long;
var varTWSAData : TWSAData;
  varPHostEnt : PHostEnt;
  varTInAddr : TInAddr;
  namebuf : Array[0..255] of ansichar;
begin
  try
    try
      If WSAStartup($101,varTWSAData) <> 0 Then
        Result := ''
      Else Begin
        gethostname(namebuf,sizeof(namebuf));
        varPHostEnt := gethostbyname(namebuf);
        varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
        Result := inet_ntoa(varTInAddr);
      End;
    except
      Result := '???';
    end;
  finally
  WSACleanup;
  end;
end;


function NetFormat(text: string): string;
var
  i: integer;
begin
  for i := 0 to length(text)-1 do
    if text[i] = ' ' then
      text[i] := '%';

  result := text;
end;

function ReadFormat(text: string): string;
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

class procedure THandler.Server_Read(AThread: TIdUDPListenerThread; AData: TBytes; ABinding: TIdSocketHandle);
var
  DataList: TStringList;
  s: String;
  i: integer;
  exist: boolean;
begin
DataList := TStringList.Create();
DataList.Encoding.UTF8;
  try
    try
      //DataStringStream.CopyFrom(AData, AData.Size);
      //s := BytesToString(AData, length(AData));

      s := TEncoding.Unicode.GetString(AData);

      //split string into data here.
      Split('&', s, DataList);

      writeln('IN: '+s);

      exist := false;


      if datalist.Strings[0] = 'GAME_RUNNING' then begin
        Main.GameMap := datalist.Strings[1];
        Session.RollUp('SYSTEM','Starting the Game..');
        ShellExecute(0,'open', 'ARENA.exe', PChar(username+#10+#13+'client'+#10+#13+ABinding.PeerIP+#10+#13+inttostr(ABinding.PeerPort)+#10+#13+gameMap), nil, SW_SHOWNORMAL) ;
      end;

      if datalist.Strings[0] = 'PING_REPLY' then begin
        Session.RollUp('Lobby','Connected.');
        exit;
      end;

      if datalist.Strings[0] = 'USER_LIST' then begin
        main.form1.Memo1.Lines.Add(Readformat(Datalist.Strings[1]));
        exit;
      end;

      if datalist.Strings[0] = 'WHO_THERE' then begin
        for i := 0 to length(users)-1 do
          ABinding.SendTo(ABinding.PeerIP, ABinding.PeerPort, 'USER_LIST&'+NetFormat(users[i].name+' - '+users[i].ip+':'+inttostr(users[i].port)), server.IPVersion , TEncoding.Unicode);
        exit;
      end;

      if datalist.Strings[0] = 'GAME_JOIN_REPLY' then begin
        Session.RollUp('Game','Connected.');
        exit;
      end;

      if datalist.Strings[0] = 'GAME_START' then begin
          gameMap := datalist.Strings[1];
          Session.RollUp('Game','Starting Game..');
          ShellExecute(0,'open', 'ARENA.exe', PChar(username+#10+#13+'client'+#10+#13+gamehost+#10+#13+inttostr(gameport)+#10+#13+gameMap), nil, SW_SHOWNORMAL) ;
          exit;
      end;

      if datalist.Strings[0] = 'PING' then begin
        aBinding.SendTo(ABinding.PeerIP, ABinding.PeerPort, 'PING_REPLY', server.IPVersion, TEncoding.Unicode);
        exit;
      end;


      if datalist.Strings[0] = 'GAME_LEAVE' then begin
        for I := 0 to length(inGame)-1 do
          if inGame[i].ip = ABinding.PeerIP then begin
            inGame[i].ip := inGame[length(inGame)-1].ip;
            SetLength(inGame, length(inGame)-1);
            break;
          end;
          main.UpdateGame();
          exit;
      end;


      if datalist.Strings[0] = 'GAME_JOIN' then begin
        aBinding.SendTo(ABinding.PeerIP, ABinding.PeerPort, 'GAME_JOIN_REPLY', server.IPVersion, TEncoding.Unicode);
            SetLength(inGame, length(inGame)+1);
            inGame[length(inGame)-1] := TUser.Create;
            inGame[length(inGame)-1].ip := ABinding.PeerIP;
            inGame[length(inGame)-1].port := ABinding.PeerPort;
            inGame[length(inGame)-1].name := Datalist.Strings[1];

            main.UpdateGame();
            exit;
      end;

      exist := false;

      for i := 0 to length(users)-1 do
        if users[i].ip = ABinding.PeerIP then exist := true;

      if exist = false then begin
        setlength(Users, Length(users)+1);
        users[length(users)-1] := TUser.create;
        users[length(users)-1].name := datalist.Strings[1];
        users[length(users)-1].ip   := ABinding.PeerIP;
        users[length(users)-1].port := ABinding.PeerPort;
        Chat.Session.RollUp(DataList.Strings[1], 'Joined The Lobby');
      end else begin
        users[length(users)-1].name := datalist.Strings[1];
      end;

      if datalist.strings[0] = 'lobby-chat' then
        Chat.Session.RollUp(ReadFormat(datalist.strings[1]), ReadFormat(datalist.strings[2]));


    if peermode = 'server' then begin
        for i := 0 to length(users)-1 do begin        //split horizon           //and (Users[i].ip <> Abinding.PeerIP)
          if (users[i].ip <> '127.0.0.1') and (users[i].ip <> ABinding.IP) then begin
          ABinding.SendTo(Users[i].ip, Users[i].port, s, server.IPVersion, TEncoding.Unicode);
           writeln('REDISTRIBUTE: '+s);
          end;
        end;
      end;


    except
      on E: Exception do begin
        //showmessage('SOME EXCEPTION??');
      end;
    end;
  finally
    //
  end;
End;


Procedure StartGame();
var
i: integer;
begin
 for i := 0 to length(inGame)-1 do
    Server.Send(inGame[i].ip, inGame[i].port,'GAME_START&'+gameMap, TEncoding.Unicode);
end;

Procedure SendMsg(user, text: string);
var
i: integer;
begin
Server.Send(networking.host, 1558, 'lobby-chat&'+NetFormat(user)+'&'+NetFormat(text), TEncoding.Unicode);
end;

begin
  host := 'dungeon0.datagig.se';    //default host
  networking.gameport := 1556;

  server := TidUDPServer.Create(nil);
  server.Bindings.Add.IP := '0.0.0.0';
  server.Bindings.Add.Port := 1558;
  server.BufferSize := 225;
  server.BroadcastEnabled := true;
  server.ThreadedEvent := true;

  server.OnUDPRead := THandler.Server_Read;
  SetLength(users, 0);
  SetLength(inGame, 0);

  peermode := 'client';
  server.Active := true;

  Chat.initialize;

  //Session.rollup('Lobby', 'Probing Master..');
//Networking.Client.Send(datalist.Strings[1], 1558, 'PING&'+username);
Networking.Server.Send(networking.host, 1558, 'PING&'+username, TEncoding.Unicode);

end.
