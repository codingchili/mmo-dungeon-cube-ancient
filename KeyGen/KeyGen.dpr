program KeyGen;   //generate valid keys keygen.exe

{$APPTYPE CONSOLE}

{$R *.res}

uses
  ShareMem,
  System.SysUtils,
  ClipBoard,
    WinApi.Windows;

Function CheckRegistrationKey(key: string; isKeyGen: boolean): boolean; external 'License.dll';  //check with register.dll, just to se

var                                                       // |value|
  letters : array [0..62] of string = ('e','9','q','C','0','B','p','y','t','m','i','A','6','E','x','2','s','F','d','5','G','J','l','K','M','f','w','L','r','z','H','o','3','b','N','h','8','I','O','Q','T','4','R','u','S','c','Y','W','n','Y','7','V','k','X','g','Z','a','Y','1','D','P','j','U');
  theKey: string;
  tries, average, count: integeR;


Function MakeRegistrationKey(): string; export; //generate key format
var
  j,w: integeR;
  key: string;
  clipboard: TClipBoard;
begin
 Randomize;
 key := '';
 tries := 0;
 count := count+1;

  repeat
  key := '';

      for j := 1 to 25 do
      key := key+letters[random(62)];

  tries := tries+1;
  until
  CheckRegistrationKey(key, true) = true;     //true parameter - do not add to blacklist, test key

 average := tries+average;
 write('key: '+key+' copied to clipboard.'+'  Average#:'+intToStr(average DIV count));

 clipboard := TClipBoard.Create;
  Clipboard.AsText := key;

 readln;
 MakeRegistrationKey;
end;


begin
tries := 0;
count := 0;
average := 0;

SetConsoleTextAttribute(GetStdHandle(
                          STD_OUTPUT_HANDLE),
                          FOREGROUND_Green);

SetConsoleTitle('Nameless Keygen.');

MakeRegistrationKey;

end.
