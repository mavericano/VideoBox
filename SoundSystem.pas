unit SoundSystem;

interface

uses
    System.SysUtils, Winapi.Windows, Vcl.MPlayer, Winapi.MMSystem;

const
    MCI_SETAUDIO = $0873;
    MCI_DGV_SETAUDIO_VOLUME = $4002;
    MCI_DGV_SETAUDIO_ITEM = $00800000;
    MCI_DGV_SETAUDIO_VALUE = $01000000;
    MCI_DGV_STATUS_VOLUME = $4019;

type
    MCI_DGV_SETAUDIO_PARMS = record
        dwCallback: DWORD;
        dwItem: DWORD;
        dwValue: DWORD;
        dwOver: DWORD;
        lpstrAlgorithm: PChar;
        lpstrQuality: PChar;
    end;
    TController = class
        Parms: MCI_DGV_SETAUDIO_PARMS;
        procedure SetMPVolume(MP: TMediaPlayer; Volume: Integer);
        function GetMPVolume(MP: TMediaPlayer): Integer;
    end;

implementation

procedure TController.SetMPVolume(MP: TMediaPlayer; Volume: Integer);
var
  MP_PARAMS: MCI_DGV_SETAUDIO_PARMS;
begin
    MP_PARAMS.dwCallback := 0;
    MP_PARAMS.dwItem := MCI_DGV_SETAUDIO_VOLUME;
    MP_PARAMS.dwValue := Volume;
    MP_PARAMS.dwOver := 0;
    MP_PARAMS.lpstrAlgorithm := nil;
    MP_PARAMS.lpstrQuality := nil;
    mciSendCommand(MP.DeviceID, MCI_SETAUDIO, MCI_DGV_SETAUDIO_VALUE or MCI_DGV_SETAUDIO_ITEM, Cardinal(@MP_PARAMS));
end;

function TController.GetMPVolume(MP: TMediaPlayer): Integer;
var
  MP_PARAMS: MCI_STATUS_PARMS;
begin
  MP_PARAMS.dwCallback := 0;
  MP_PARAMS.dwItem := MCI_DGV_STATUS_VOLUME;
  mciSendCommand(MP.DeviceID, MCI_STATUS, MCI_STATUS_ITEM, Cardinal(@MP_PARAMS));
  Result := MP_PARAMS.dwReturn;
end;

end.
