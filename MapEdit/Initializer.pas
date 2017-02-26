unit Initializer;

interface

uses
  SysUtils, Vectors2px, AbstractDevices, AbstractCanvas, AsphyreImages, AsphyreFonts,
  AsphyreArchives, AsphyreRenderTargets, vcl.forms, dialogs;

var
  DisplaySize: TPoint2px;
  GameDevice: TAsphyreDevice = nil;
  GameCanvas: TAsphyreCanvas = nil;
  GameImages: TAsphyreImages = nil;
  GameFonts : TAsphyreFonts  = nil;
  MediaFile : TAsphyreArchive = nil;
  RenderTarget: TAsphyreRenderTargets = nil;


implementation

uses Camera, Keyboard, Main;


begin
writeln('Initializer OK');
END.
