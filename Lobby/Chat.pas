unit Chat;

interface

uses Graphics;

type
  User = class
  name, text: string;
  color: TColor;
 constructor Create();
End;

const
  MAXMESSAGES = 100;

type
  Module = class
  Chatters: array of User;
 procedure RollUp(user, text: string);
End;

procedure initialize();

var
  i: integer;
  Session: Module;

implementation

uses Main;

constructor User.Create();
begin
  name := '';
  text := '';
  color := $FFFFFF;
End;

procedure Module.RollUp(user, text: string);
var
  i: integer;
begin
  main.Form1.Memo1.Lines.Add(user+': '+text);

  for i := 0 to length(Session.chatters)-2 do begin
    Session.chatters[i].name := Session.chatters[i+1].name;
    Session.chatters[i].text := Session.chatters[i+1].text;
  end;

  Session.chatters[MAXMESSAGES-1].name := user;
  Session.chatters[MAXMESSAGES-1].text := text;
End;

procedure Initialize();
var
  i: integer;
begin
  Session := Module.create;
  SetLength(Session.Chatters, MAXMESSAGES);

  for i := 0 to MAXMESSAGES-1 do
    Session.Chatters[i] := User.Create;
End;

begin
END.

