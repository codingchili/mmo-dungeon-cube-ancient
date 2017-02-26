Library License; //license

uses
  FastShareMem,
  SysUtils,
  math;
  //System.Classes,
  //Web.Win.Sockets,
  //IdFTP;

const
  SerialHi = 2326632141;   //valid key compositions   +05=max 7k=min
  SerialLo = 8979;

  var
  letters : array [0..62] of string = ('e','9','q','C','0','B','p','y','t','m','i','A','6','E','x','2','s','F','d','5','G','J','l','K','M','f','w','L','r','z','H','o','3','b','N','h','8','I','O','Q','T','4','R','u','S','c','Y','W','n','Y','7','V','k','X','g','Z','a','Y','1','D','P','j','U');  //secret on server
  theKey, HostAddr: string;
  tries,average,count,port: integer;
  low,hi,value: extended;
  //ftp : TIdFtp;
  blacklist, host: textFile;

{$R *.res}

Function CheckRegistrationKey(key: string; isKeyGen: boolean): boolean; export;
var
j,w: integer;
blackkey: string;
begin
if length(key) <> 25 then begin result := false; exit; end;

value := 0;


   for j := 1 to length(key) do begin
    w := -1;
    repeat                //calculate key value
      w := w+1;
    until
    letters[w] = key[j];

    value := value+(w*j);

    case w of
    2: value := value+(math.power(j,w));
    4: value := value+(math.power(j,w));
    5: value := value+(math.power(j,w));
    8: value := value+(math.power(j,w));
    20: value := value+(math.power(j,2));
    10: value := value+86;
    13: value := value+(w*j);
    14: value := value+94;
    19: value := value+(w*j)+1;
    23: value := value+77;
    end;
   end;

   if value < low then low := value;
   if value > hi then hi := value;

  if (value <> serialHi) and (value <> serialLo) then result := false else
  result := true;
end;

Function MakeRegistrationKey(isKeyGen: boolean): string; export;
var
  j,w: integeR;
  x: string;
begin

Randomize;
x := '';

  repeat              //generate test keys
  x := '';

      for j := 1 to 25 do
      x := x+letters[random(62)];

  until
  CheckRegistrationKey(x, isKeyGen) = true;

result := x;
end;


exports MakeRegistrationKey, CheckRegistrationKey;


begin
low := 2326632142;
end.

