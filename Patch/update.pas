unit update;  //handles updates ful kod

interface

procedure CheckVersion();   //check version
procedure LoadVersion();    //load version from file
procedure ResetVersion(old: string); //reset version
Function CheckRegistrationKey(key: string; IsKeyGen: boolean): Boolean; external 'dll/License.dll';    //check registration key
procedure SetHost(host:string); external 'dll/Hostcfg.dll';    //set host

var dlProgress: integer;

implementation

uses MainGui, vcl.dialogs, Shellapi, WinApi.windows, vcl.forms, SysUtils, dbMgr;


Procedure ResetVersion(old: string);   //reset version
var
inf: textFile;
begin
  assignFile(inf,'conf/Version.inf');

    rewrite(inf);

    writeln(inf, old);

  closefile(inf);
 main.laVersion.caption := old;
end;


procedure LoadVersion();    //load current version
var
versionfile: TextFile;
begin
if not FileExists('conf/Version.inf') then ResetVersion(maingui.version);

if FileExists('conf/Version.inf') then begin
     assignfile(versionfile, 'conf/Version.inf');
      reset(versionfile);
        readln(versionfile, maingui.version);
     closeFile(versionFile);
     main.laVersion.caption := maingui.version;
end;

end;

procedure CheckVersion();      //check latest version
var
  versionfile: textFile;
  newVersion, host, port: string;
  outDated: boolean;
  w : integer;
  new: PwiDeChar;
  hProc: THandle;

begin

maingui.dlToolsProgress := 0;
main.updating.Enabled := true;
main.updatestatus.Caption := 'Connecting Server..';

AssignFile(versionfile, 'conf/Host.cfg');
reset(versionfile);
readln(versionfile, host);
readln(versionfile, port);
closefile(versionfile);

main.updater.host := host;
main.updater.port := StrToInt(port);



try
  if main.updater.connected = false then main.updater.connect;

    if main.updater.Connected = false then main.updatestatus.caption := 'Unreachable Host' else begin
     main.updatestatus.caption := 'Fetching Data..';

     main.pbupdate.max := main.updater.size('theversion.txt');
                                                                       //overwrite old version file
     main.updater.Get('theversion.txt', 'conf/Version.inf', true);

     assignfile(versionfile, 'conf/Version.inf');  //read version file
       reset(versionfile);
       readln(versionfile, newVersion);
     closeFile(versionFile);


        if newVersion > maingui.version then outdated := true else outdated := false;
        if outdated = true then main.updatestatus.Caption := 'Outdated Version!' else main.updatestatus.Caption := 'Version Ok.';

  if outdated = false then main.Visible  := true;


  if outdated = true then begin


  w := MessageDlg('Your Update Tool Is Out, Update?'+#10+#13+#10+#13+'( takes a moment to download )',mtWarning, mbOKCancel, 0);

  if w = 2 then begin //rewrite old version to version file
     assignfile(versionfile, 'conf/Version.inf');
        rewrite(versionfile);
        writeln(versionfile, maingui.version);
     closeFile(versionFile);
  main.Visible  := true;
      dbMgr.save(dbmgr.db.location, true);
      db.loaded := false; //skip unloading
      end;
  end;


  if w <> 2 then begin        //download updated updating tools
      maingui.dlToolsProgress := 0;
      main.pbUpdate.max := main.updater.Size('bin/UpdateHost.exe');

      main.updatestatus.caption := 'Fetching Data..';
      main.updater.Get('bin/UpdateHost.exe', 'bin/UpdateHost.exe', true);
      main.pbUpdate.max := main.updater.Size('dll/Update.dll');
      main.updater.Get('dll/Update.dll', 'dll/Update.dll', true);
      main.updatestatus.Caption := 'Updater Downloaded.';
      main.updating.Enabled := false;
      main.pbUpdate.Position := main.pbUpdate.max;


      w := MessageDlg('Do You Wish To Apply Updates?'+#10+#13+'(Cancel To Ignore This Update)',mtWarning, mbOKCancel, 0);
      if w <> 2 then begin
      maingui.NewVersion := NewVersion;

      ShellExecute(0, 'open', PChar(ExtractFilePath(Application.exename)+'/bin/UpdateHost.exe'), PChar(maingui.version+#10+#13+maingui.newversion), nil, SW_SHOWNORMAL);
      main.close;                  //run the external updater, so that we may update main executable
end;

      end;
  end;

maingui.dlToolsProgress := main.pbupdate.max;




 if main.updater.Connected = true then main.updater.Disconnect;

 main.updating.Enabled := false;
 main.pbUpdate.Position := 100;

except
 main.updating.Enabled := false;
 main.pbUpdate.Position := 0;
 main.updatestatus.caption := 'Error Occured.';
end;
end;



begin


end.
