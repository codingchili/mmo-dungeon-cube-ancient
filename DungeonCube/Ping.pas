unit Ping;

interface

uses
  Classes,IdBaseComponent, IdComponent, IdRawBase, IdRawClient, IdIcmpClient,
   SysUtils, Network, Vcl.forms;


type
  TPingReply = procedure (Latency: Cardinal);

  TPingThread = class(TThread)
  public
      procedure Execute; override;
  private
    FHost: string;
    FTimeout: Integer;
    FOnReply: TPingReply;
    FIdCmp: TIdIcmpClient;
  protected

    procedure OnPingReply(ASender: TComponent; const AReplyStatus: TReplyStatus);
  public
    property Host: string read FHost write FHost;
    property Timeout: Integer read FTimeout write FTimeout;
    property OnReply: TPingReply read FOnReply write FOnReply;
    procedure Ping;
    destructor Destroy; override;
  end;

  procedure Initialize;

  var
  RoundTripMs: integer;
  PingThread: TPingThread;
  pingwarning: integer;

implementation

{ TPingThread }

uses Initializer, Windows, Dialogs;

destructor TPingThread.Destroy;
begin
  FIdCmp.Free;
  inherited;
end;

procedure TPingThread.Execute;
begin
  FIdCmp := TIdIcmpClient.Create(nil);
  FIdCmp.Host := Network.host;
  FIdCmp.ReceiveTimeout := 500;
  FIdCmp.PacketSize := 28;
  FIdCmp.Port := 1559;
  pingwarning := 0;

  FIdCmp.OnReply := OnPingReply;


while not terminated do begin
    self.Sleep(1000);
    Ping;
  end;
end;

procedure TPingThread.OnPingReply(ASender: TComponent; const AReplyStatus: TReplyStatus);
begin
 { WriteLn(Format('%d Byte From %s: icmp_seq=%d ttl=%d Time%s%d ms',
    [AReplyStatus.BytesReceived,
    AReplyStatus.FromIpAddress,
    AReplyStatus.SequenceId,
    AReplyStatus.TimeToLive,
    ' ', AReplyStatus.MsRoundTripTime]));  }


    RoundTripMs := AReplyStatus.MsRoundTripTime;

    if (RoundTripMs > 300) then
      inc(pingwarning);

    if (RoundTripMs < 300) then
      pingwarning := 0;

    if (pingwarning > 5) then begin
       application.ShowMainForm := false;
       showmessage('Lost connection to game.');
       application.Terminate;
    end;
    //autokick-system
  {for i := 0 to Length(Multiplayer)-1 do begin
    if Multiplayer[i].ip = AReplyStatus.FromIpAddress then begin
      Multiplayer[i].ping := AReplyStatus.MsRoundTripTime;
      writeln('Ping Reply: '+Multiplayer[i].ip + #9 +'time: ' + IntToStr(RoundTripMs) + 'ms.');
      temp := Multiplayer[i].ping;

      if RoundTripMs > 200 then begin writeln('Warning: High Ping!');  Multiplayer[i].dc_warning := Multiplayer[i].dc_warning+1 end else
        Multiplayer[i].dc_warning := 0;
      if Multiplayer[i].dc_warning = 10 then begin writeln('Banned player. (High Ping)'); Multiplayer[i].kick('Max ping exceeded.'); end;

      break;
    end;
  end;  }
end;


procedure TPingThread.Ping;
var
i: integer;
begin
try
//Ping host.

if (initializer.peermode = 'client') then begin
  fIdCmp.Host := Network.host;
  FIdCmp.Ping
  end else
 for i := 1 to High(Multiplayer) do begin
  fIdCmp.Host := Multiplayer[i].ip;
  FidCmp.Ping;
  sleep(0);
 end;
except
Self.Destroy; //no admin privs
end;
end;

procedure Initialize();
begin
  PingThread := TPingThread.Create;
end;

begin
end.
