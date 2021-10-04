unit FileChecker;

interface

implementation

uses
   Classes, SysUtils;

const
   TAG_VERSION_2_3 = 3;
   ID3V2_FRAME_COUNT = 7;

type
    TagInfo = record
        ID: array [1..3] of AnsiChar;
        Version: Byte;
        Revision: Byte;
        Flags: Byte;
        Size: array [1..4] of Byte;
        FileSize: Integer;
        Frame: array [1..ID3V2_FRAME_COUNT] of string;
   end;

   TFileChecker = class(TObject)
       function IsCorrectFile(const FileName: string): Boolean;
   end;


var
    HeaderInf: TFileChecker;


function TFileChecker.IsCorrectFile(const FileName: string): Boolean;
var
   SourceFile: file;
   Transferred: Integer;
   Tag: TagInfo;
begin
   try
     Result := true;
     { Set read-access and open file }
     AssignFile(SourceFile, FileName);
     FileMode := 0;
     Reset(SourceFile, 1);
     { Read header and get file size }
     BlockRead(SourceFile, Tag, 10, Transferred);
     Tag.FileSize := FileSize(SourceFile);
     CloseFile(SourceFile);
     { if transfer is not complete }
     if Transferred < 10 then Result := false;
     if Tag.ID <> 'ID3' then Result := false;
   except
     { Error }
     Result := false;
   end;
end;
end.
