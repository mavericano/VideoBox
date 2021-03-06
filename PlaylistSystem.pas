unit PlaylistSystem;

interface

uses
    System.Generics.Collections, System.Classes, System.IOUtils, System.SysUtils,
    Vcl.Forms, Vcl.Dialogs;

type
    TVideoFile = record
        FileName: String[100];
        FilePath: String[255];
    end;
    TPlaylist = record
        PlaylistName: String[40];
        Videos: TList<TVideoFile>;
        function Add(ToAdd: String): Boolean;
    end;

procedure RetrievePlaylists(var TrackList: TList<TPlaylist>);
procedure RetrieveSinglePlaylist(Name: String; var TrackList: TList<TVideoFile>);
procedure RemoveSinglePlaylist(Name: String);
procedure RenameSinglePlaylist(Name: String; NewName: String);
procedure AddPlaylist(Path: String);
procedure RemoveSingleTrack(Playlist: TPlaylist; Number: Integer);
procedure RenameSingleTrack(Playlist: TPlaylist;Name: String; NewName: String);
procedure AddTrack(Path: String; Playlist: TPlaylist);

implementation

procedure ExtractName(CurrentFile: string; var CurrentFileName: string);
var
  I: Integer;
  Flag: Boolean;
begin
    I := Length(CurrentFile);
    Flag := True;
    while Flag do
    begin
    if CurrentFile[I] = '\' then
        Flag := False;
    Dec(I);
    end;
    CurrentFileName := CurrentFile;
    Delete(CurrentFileName, 1, I + 1);
end;

function CaptureProgramDirectory(): String;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

procedure AddTrack(Path: String; Playlist: TPlaylist);
var
    ProgramDirectory, Name: String;
begin
    ProgramDirectory := CaptureProgramDirectory;
    ExtractName(Path, Name);
    TFile.Copy(Path, ProgramDirectory + 'playlists\' + Playlist.PlaylistName +
        '\' + Name, True);
end;

procedure RemoveSingleTrack(Playlist: TPlaylist; Number: Integer);
var
    ProgramDirectory: String;
begin
    ProgramDirectory := CaptureProgramDirectory;
    TFile.Delete(ProgramDirectory + 'playlists\' + Playlist.PlaylistName +
        '\' + Playlist.Videos[Number].FileName);
end;

procedure AddPlaylist(Path: String);
var
    Name, ProgramDirectory: String;
begin
    ProgramDirectory := CaptureProgramDirectory;
    ExtractName(Path, Name);
    TDirectory.Copy(Path, ProgramDirectory + 'playlists\' + Name);
end;

procedure RenameSingleTrack(Playlist: TPlaylist;Name: String; NewName: String);
var
    ProgramDirectory: String;
begin
    ProgramDirectory := CaptureProgramDirectory;
    TFile.Move(ProgramDirectory + 'playlists\' + Playlist.PlaylistName +
        '\' + Name, ProgramDirectory + 'playlists\' + Playlist.PlaylistName +
        '\' + NewName + '.avi');
end;

procedure RenameSinglePlaylist(Name: String; NewName: String);
var
    ProgramDirectory: String;
begin
    ProgramDirectory := CaptureProgramDirectory;
    TDirectory.Move(ProgramDirectory + 'playlists\' + Name, ProgramDirectory +
        'playlists\' + NewName);
end;

procedure RemoveSinglePlaylist(Name: String);
var
    ProgramDirectory: String;
begin
    ProgramDirectory := CaptureProgramDirectory;
    TDirectory.Delete(ProgramDirectory + 'playlists\' + Name, True);
end;

function TPlaylist.Add(ToAdd: String): Boolean;
begin

end;

procedure RetrievePlaylists(var TrackList: TList<TPlaylist>);
var
    CurrentDirectory, ProgramDirectory, CurrentDirectoryName: String;
    TmpPlaylist: TPlaylist;
begin
    ProgramDirectory := CaptureProgramDirectory;
    ForceDirectories(ProgramDirectory + 'playlists');
    for CurrentDirectory in TDirectory.GetDirectories(ProgramDirectory + 'playlists') do
    begin
        ExtractName(CurrentDirectory, CurrentDirectoryName);
        TmpPlaylist.PlaylistName := CurrentDirectoryName;
        TmpPlaylist.Videos := TList<TVideoFile>.Create;
        RetrieveSinglePlaylist(CurrentDirectoryName, TmpPlaylist.Videos);
        TrackList.Add(TmpPlaylist);
    end;
end;

procedure RetrieveSinglePlaylist(Name: String; var TrackList: TList<TVideoFile>);
var
    CurrentDirectory, ProgramDirectory: String;
    CurrentFile, CurrentFileName: String;
    TmpVideo: TVideoFile;
begin
    ProgramDirectory := CaptureProgramDirectory;
    CurrentDirectory := ProgramDirectory + 'playlists' + '\' + Name;
    for CurrentFile in TDirectory.GetFiles(CurrentDirectory, '*.avi') do
    begin
        ExtractName(CurrentFile, CurrentFileName);
        TmpVideo.FileName := CurrentFileName;
        TmpVideo.FilePath := CurrentFile;
        TrackList.Add(TmpVideo);
    end;
end;

end.
