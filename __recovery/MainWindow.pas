unit MainWindow;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.MPlayer, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.Menus, Winapi.MMsystem,
  SoundSystem, PlaylistSystem,
  System.IOUtils, System.Generics.Collections;

type

    MCI_STATUS_PARMS = record
        dwCallback: DWORD;
        dwReturn: DWORD;
        dwItem: DWORD;
        dwTrack: DWORD;
    end;

    TPanel = class (Vcl.ExtCtrls.TPanel)
        public
        property Canvas;
    end;

    TListBoxState = (PLAYLISTS, TRACKS);

    TMainForm = class(TForm)
        DisplayPanel: TPanel;
        TrackProgressBar: TProgressBar;
        MenuPanel: TPanel;
        PlayButtonImage: TImage;
        PlaceHolder: TImage;
        PlayerTimer: TTimer;
        OpenDialog1: TOpenDialog;
        TimeLabel: TLabel;
        PauseButtonImage: TImage;
        PlaylistPanel: TPanel;
        VolumeTrackBar: TTrackBar;
        FullScreenButtonImage: TImage;
        FocusButton: TButton;
        PlaylistSubpanel: TPanel;
        Splitter: TPanel;
        PlaylistListBox: TListBox;
        PlaylistPopupMenu: TPopupMenu;
        PlaylistOpenButton: TMenuItem;
        N4: TMenuItem;
        N5: TMenuItem;
        FileOpenDialog1: TFileOpenDialog;
        N3: TMenuItem;
        TrackPopupMenu: TPopupMenu;
        N6: TMenuItem;
        N7: TMenuItem;
        N8: TMenuItem;
        N9: TMenuItem;
        MediaPlayer: TMediaPlayer;
        FormMainMenu: TMainMenu;
        N1: TMenuItem;
        N2: TMenuItem;
        procedure AdjustPadding;
        procedure ClearDisplay;
        procedure PrepareDisplay;
        procedure FieldsInitialization;
        procedure UpdateDisplay;
        procedure ResizeSubpanel();
        procedure OnCreate(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure PlayButtonImageClick(Sender: TObject);
        procedure PlayerTimerTimer(Sender: TObject);
        procedure TrackProgressBarMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure N2Click(Sender: TObject);
        procedure PauseButtonImageClick(Sender: TObject);
        procedure FullScreenButtonImageClick(Sender: TObject);
        procedure FocusButtonKeyPress(Sender: TObject; var Key: Char);
        procedure VolumeTrackBarChange(Sender: TObject);
        procedure SplitterMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure SplitterMouseUp(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure SplitterMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
        procedure PlaylistListBoxMouseUp(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
        procedure RefreshSinglePlaylist;
        procedure PlaylistOpenButtonClick(Sender: TObject);
        procedure PlaylistDeleteButtonClick(Sender: TObject);
        procedure PlaylistRenameButtonClick(Sender: TObject);
        procedure PlaylistRefreshButtonClick(Sender: TObject);
        procedure TrackPlayButtonClick(Sender: TObject);
        procedure TrackDeleteButtonClick(Sender: TObject);
        procedure TrackRenameButtonClick(Sender: TObject);
        procedure TrackRefershButtonClick(Sender: TObject);
    procedure TrackProgressBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrackProgressBarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
    procedure DisplayPanelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
        private
            FIsPlaying: Boolean;
            FIsFullscreen: Boolean;
            function GetVolume: Integer;
            procedure SetVolume(const Value: integer);
            procedure SetIsPlaying(const Value: Boolean);
            procedure SetIsFullscreen(Const Value: Boolean);
            procedure RefreshPlaylists;
    procedure PlayTrack(Index: Integer);
        public
            property Volume: Integer Read GetVolume Write SetVolume;
            property IsPlaying: Boolean Read FIsPlaying Write SetIsPlaying;
            property IsFullscreen: Boolean Read FIsFullscreen Write SetIsFullscreen;
    end;

const
    PROGRESS_BAR_PADDING = 18;
    PLAYLIST_SUBPANEL_PADDING = 18;
    TIME_SPLITTER = ':';
    INCORRECT_FILE_MESSAGE = '???????????? ???????? ???? ?????????? ???????? ????????????';
    PLAY_BUTTON_IMAGE_HINT = '??????????????????????????????' + #13#10 + '???????? ???????????????? ????????, ???? ?????????????? ????????';
    DELETING_ENSURANCE_MESSAGE = '???? ?????????????????????????? ???????????? ?????????????? ???????? ?????????????????';
    EDIT_BOX_NAME = '??????????????????????????';
    EDIT_BOX_CAPTION = '?????????????? ?????????? ??????';
    EDIT_BOX_ERROR = '?????????????? ???????????????????? ?????????? ??????';
    IS_PLAYING_EDIT_BOX_ERROR = '???????? ???????? ???????????? ??????????????????????????/?????????????? ?????? ?????? ???? ?????????????????????????????? ?? ???????????? ????????????';
    TO_ADD_PLAYLIST_BUTTON = '???????????????? ????????????????...';
    TO_ADD_TRACK_BUTTON = '???????????????? ????????...';
    HELP_MESSAGE = '?????????? ????????????????????!' + #13#10 +
                    '?????? ???????????? ?????????????????? ?????????????? ???????????????? ?? ???????????? ???????????????????? ?? ???????????? ?????????? ????????.' + #13#10 +
                    '?????? ??????????????????/???????????????? ?????????????????? ?????????????? ???? ???????? ???????????? ?????????????? ????????.' + #13#10 +
                    '?????? ??????????????????/???????????????? ?????????? ?? ?????????????????? ?????????? ?????????????? ???? ???????? ???????????? ?????????????? ????????.' + #13#10 +
                    '?????? ?????????? ?? ???????????????????????? ?????????? ?????????????? ???? ???????????? ?? ???????? ?????? ?????????????? "F" ???? ????????????????????.' + #13#10 +
                    '?????? ???????????? ???? ???????????????????????????? ???????????? ?????????????? ?????????????? "Esc" ???? ????????????????????.' + #13#10 +
                    '?????????????????? ??????????????????????????!';
    ABOUT_AUTHOR = '???????????????? ???????????? ???? ???????????????????? "???????????? ???????????????????????????? ?? ????????????????????????????????"' + #13#10 +
                    '???????? 1' + #13#10 +
                    '???????????????????? ????????' + #13#10 +
                    '???????????? 051007' + #13#10 +
                    '??????????, 2021';

var
  MainForm: TMainForm;
  IsLoaded: Boolean;
  XBeforeSizing, YBeforeSizing: Integer;
  IsResizing, IsRewinding: Boolean;
  TrackList: TList<TPlaylist>;
  PlaylistsStrings: TStringList;
  ListBoxState: TListBoxState;
  SelectedPlaylist, SelectedItem, OpenedPlaylist: Integer;

implementation

{$R *.dfm}

procedure TMainForm.ClearDisplay;
begin
    MediaPlayer.Close;
    DisplayPanel.Canvas.Brush.Color := $535353;
    DisplayPanel.Canvas.Rectangle(0, 0, DisplayPanel.Width, DisplayPanel.Height);
    PlaceHolder.Visible := True;
    TrackProgressBar.Position := 0;
    TimeLabel.Caption := '--:--/--:--';
end;

procedure TMainForm.DisplayPanelClick(Sender: TObject);
begin
    if IsLoaded then
        IsPlaying := not IsPlaying;
end;

procedure TMainForm.ResizeSubpanel();
begin
    PlaylistSubpanel.Top := PLAYLIST_SUBPANEL_PADDING;
    PlaylistSubpanel.Left := PLAYLIST_SUBPANEL_PADDING;
    PlaylistSubpanel.Height := PlaylistPanel.Height - 2*PLAYLIST_SUBPANEL_PADDING;
    PlaylistSubpanel.Width := PlaylistPanel.Width - 2*PLAYLIST_SUBPANEL_PADDING;
end;

procedure TMainForm.SetIsFullscreen(const Value: Boolean);
begin
    if Value then
    {Turning fullscreen ON}
    begin
        if not IsFullscreen then
        begin
            DisplayPanel.Align := alCustom;
            XBeforeSizing := MainForm.Width;
            YBeforeSizing := MainForm.Height;
            MainForm.Width := GetDeviceCaps(GetDC(0), HORZRES) + 3;
            MainForm.Height := GetDeviceCaps(GetDC(0), VERTRES);
            MainForm.BorderStyle := bsNone;
            MainForm.Left := -3;
            MainForm.Top := -30;
            DisplayPanel.Width := MainForm.Width;
            DisplayPanel.Height := MainForm.Height;
            if IsLoaded then
                MediaPlayer.DisplayRect := Rect(0,0,DisplayPanel.Width,DisplayPanel.Height);
            FIsFullScreen := True;
        end;
    end
    else
    {Turning fullscreen OFF}
    begin
        MainForm.Width := XBeforeSizing;
        MainForm.Height := YBeforeSizing;
        DisplayPanel.Align := alLeft;
        MainForm.BorderStyle := bsSizeable;
        MainForm.Top := 20;
        MainForm.Left := 20;
        if IsLoaded then
            MediaPlayer.DisplayRect := Rect(0,0,DisplayPanel.Width,DisplayPanel.Height);
        FIsFullScreen := False;
    end;
end;

procedure TMainForm.RefreshPlaylists;
var
    CurrentPlaylist: TPlaylist;
begin
    TrackList.Clear;
    RetrievePlaylists(TrackList);
    PlaylistListBox.Clear;
    for CurrentPlaylist in Tracklist do
        PlaylistListBox.Items.Add(CurrentPlaylist.PlaylistName);
    PlaylistListBox.Items.Add(TO_ADD_PLAYLIST_BUTTON);
end;

procedure TMainForm.PlayTrack(Index: Integer);
begin
    ClearDisplay;
    IsLoaded := True;
    try
        MediaPlayer.FileName := TrackList[SelectedPlaylist].Videos[Index - 1].FilePath;
        MediaPlayer.Open;
    except
        on EMCIDeviceError do
        begin
            IsLoaded := False;
            IsPlaying := False;
            MessageDlg(INCORRECT_FILE_MESSAGE, mtError, [mbOk], 0);
        end;
    end;
    if IsLoaded then
    begin
        PlaceHolder.Visible := False;
        MediaPlayer.Position := 0;
        MediaPlayer.DisplayRect := Rect(0, 0, DisplayPanel.Width - 1, DisplayPanel.Height - 1);
        TrackProgressBar.Width := MenuPanel.Width - PROGRESS_BAR_PADDING - TrackProgressBar.Left;
        IsPlaying := True;
    end;
end;

procedure TMainForm.RefreshSinglePlaylist;
var
    CurrentFile: TVideoFile;
    TmpList: TList<TVideoFile>;
begin
    TmpList := TList<TVideoFile>.Create;
    TrackList[SelectedPlaylist].Videos.Clear;
    TmpList.Clear;
    RetrieveSinglePlaylist(TrackList[SelectedPlaylist].PlaylistName, TmpList);
    PlaylistListBox.Clear;
    PlaylistlistBox.Items.Add('..');
    for CurrentFile in TmpList do
    begin
        PlaylistListBox.Items.Add(CurrentFile.FileName);
        TrackList[SelectedPlaylist].Videos.Add(CurrentFile);
    end;
    PlaylistListBox.Items.Add(TO_ADD_TRACK_BUTTON);
end;

procedure TMainForm.AdjustPadding;
begin
    XBeforeSizing := MainForm.Width;
    YBeforeSizing := MainForm.Height;
    MainForm.Left := 20;
    MainForm.Top := 20;
end;

procedure TMainForm.PrepareDisplay;
begin
    MediaPlayer.DisplayRect := Rect(0, 0, DisplayPanel.Width - 1,DisplayPanel.Height - 1);
    MediaPlayer.Display := DisplayPanel;
    MediaPlayer.DisplayRect := DisplayPanel.Canvas.ClipRect;
    MediaPlayer.DisplayRect := ClientRect;
    TimeLabel.Caption := '--:--/--:--';
end;

procedure TMainForm.FieldsInitialization;
begin
    FIsPlaying := False;
    IsLoaded := False;
    FIsFullscreen := False;
    PlaceHolder.Visible := True;
    PlaylistsStrings := TStringList.Create;
    PlayButtonImage.Hint := PLAY_BUTTON_IMAGE_HINT;
    PlaceHolder.Parent.DoubleBuffered := True;
    ListBoxState := PLAYLISTS;
    Tracklist := TList<TPlaylist>.Create;
    PlaylistListBox.Color := $484949;
    PlaylistListBox.Font.Color := $70d9ff; //ffd970
    PlaylistListBox.Font.Size := 10;
end;

procedure TMainForm.UpdateDisplay;
var
    Ratio: Real;
begin
  if IsLoaded then
  begin
    Ratio := DisplayPanel.Height / MediaPlayer.Height;
    MediaPlayer.DisplayRect := Rect(0, 0, Trunc(MediaPlayer.Width * Ratio), DisplayPanel.Height);
    if IsPlaying then
        IsPlaying := True
    else
        IsPlaying := False;
  end;
end;

procedure TMainForm.SetIsPlaying(const Value: Boolean);
begin
    if IsLoaded then
        if Value then
        {Turning ON}
        begin
            MediaPlayer.Play;
            PauseButtonImage.Visible := True;
            PlayButtonImage.Visible := False;
            FIsPlaying := True;
        end
        else
        {Turning OFF}
        begin
            MediaPlayer.Pause;
            PauseButtonImage.Visible := False;
            PlayButtonImage.Visible := True;
            FIsPlaying := False;
        end
    else
        if Value then
            N2Click(TObject.Create);
end;

procedure TMainForm.FocusButtonKeyPress(Sender: TObject; var Key: Char);
begin
    case Key of
        #27:
        begin
            IsFullscreen := False;
        end;

        #32:
        begin
            IsPlaying := not IsPlaying;
        end;

        'f', '??':
        begin
            IsFullscreen := True;
        end;
    end;
end;

function TMainForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    ShowMessage('hi');
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
    DisplayPanel.Width := MainForm.Width - Splitter.Width - PlaylistPanel.Width - 14;
    UpdateDisplay;
    TrackProgressBar.Width := MenuPanel.Width - PROGRESS_BAR_PADDING - TrackProgressBar.Left;
    ResizeSubpanel;
end;

procedure TMainForm.FullScreenButtonImageClick(Sender: TObject);
begin
    IsFullscreen := True;
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
    MessageDlg(HELP_MESSAGE, mtInformation, [mbOk], 0);
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
    MessageDlg(ABOUT_AUTHOR, mtInformation, [mbOk], 0);
end;

procedure TMainForm.TrackRefershButtonClick(Sender: TObject);
begin
    RefreshSinglePlaylist;
end;

procedure TMainForm.TrackRenameButtonClick(Sender: TObject);
var
    NewName: String;
begin
    NewName := InputBox(EDIT_BOX_NAME, EDIT_BOX_CAPTION,
        TrackList[SelectedPlaylist].Videos[SelectedItem - 1].FileName);
    if (NewName <> '') and (NewName <> TrackList[SelectedPlaylist].PlaylistName) then
    begin
        try
            RenameSingleTrack(TrackList[SelectedPlaylist],
                TrackList[SelectedPlaylist].Videos[SelectedItem - 1].FileName , NewName);
        except
            on EInOutError do
                MessageDlg(IS_PLAYING_EDIT_BOX_ERROR, mtError, [mbOk], 0);
        end;
        RefreshSinglePlaylist;
    end
    else
        MessageDlg(EDIT_BOX_ERROR, mtError, [mbOk], 0);
end;

procedure TMainForm.PlaylistRenameButtonClick(Sender: TObject);
var
    NewName: String;
begin
    if OpenedPlaylist = SelectedPlaylist then
        MessageDlg(IS_PLAYING_EDIT_BOX_ERROR, mtError, [mbOk], 0)
    else
    begin
        NewName := InputBox(EDIT_BOX_NAME, EDIT_BOX_CAPTION,
            TrackList[SelectedPlaylist].PlaylistName);
        if (NewName <> '') and (NewName <> TrackList[SelectedPlaylist].PlaylistName) then
        begin
            try
                RenameSinglePlaylist(TrackList[SelectedPlaylist].PlaylistName, NewName);
            except
                MessageDlg(EDIT_BOX_ERROR, mtError, [mbOk], 0);
            end;
            RefreshPlaylists;
        end
        else
            MessageDlg(EDIT_BOX_ERROR, mtError, [mbOk], 0);
    end;
end;

procedure TMainForm.PlaylistDeleteButtonClick(Sender: TObject);
begin
    if MessageDlg(DELETING_ENSURANCE_MESSAGE, mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
        RemoveSinglePlaylist(TrackList[SelectedPlaylist].PlaylistName);
        RefreshPlaylists;
    end;
end;

procedure TMainForm.OnCreate(Sender: TObject);
var
    Tmp: String;
begin
    PlayerTimer.Enabled := False;
    FieldsInitialization;
    RefreshPlaylists;
    PrepareDisplay;
    AdjustPadding;
    PlayerTimer.Enabled := True;
    {DisplayPanel.Parent.DoubleBuffered := True;
    MediaPlayer.DoubleBuffered := True;
    MediaPlayer.Display.DoubleBuffered := True;
    MediaPlayer.Display.Parent.DoubleBuffered := True;
    MediaPlayer.ParentDoubleBuffered := True; }
end;

procedure TMainForm.SplitterMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    IsResizing := True;
end;

procedure TMainForm.SplitterMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
    if IsResizing then
    begin
        DisplayPanel.Width := DisplayPanel.Width + X;
        PlaylistPanel.Width := PlaylistPanel.Width - X;
        UpdateDisplay;
        ResizeSubpanel;
    end;
end;

procedure TMainForm.SplitterMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    IsResizing := False;
end;

procedure TMainForm.TrackDeleteButtonClick(Sender: TObject);
begin
    try
        RemoveSingleTrack(TrackList[SelectedPlaylist], SelectedItem - 1);
    except
        on EInOutError do
            MessageDlg(IS_PLAYING_EDIT_BOX_ERROR, mtError, [mbOk], 0);
    end;
    RefreshSinglePlaylist;
end;

procedure TMainForm.TrackPlayButtonClick(Sender: TObject);
begin
    ClearDisplay;
    IsLoaded := True;
    try
        MediaPlayer.FileName := TrackList[SelectedPlaylist].Videos[SelectedItem - 1].FilePath;
        MediaPlayer.Open;
    except
        on EMCIDeviceError do
        begin
            IsLoaded := False;
            MessageDlg(INCORRECT_FILE_MESSAGE, mtError, [mbOk], 0);
        end;
    end;
    if IsLoaded then
    begin
        PlaceHolder.Visible := False;
        MediaPlayer.Position := 0;
        MediaPlayer.DisplayRect := Rect(0, 0, DisplayPanel.Width - 1,DisplayPanel.Height - 1);
        TrackProgressBar.Width := MenuPanel.Width - PROGRESS_BAR_PADDING - TrackProgressBar.Left;
        IsPlaying := True;
    end;
end;

procedure TMainForm.PauseButtonImageClick(Sender: TObject);
begin
    IsPlaying := False;
end;

procedure TMainForm.PlayButtonImageClick(Sender: TObject);
begin
    IsPlaying := True;
end;

function SecondsToTime(Seconds: Double): String;
var
    Hour, Minute, Second: Word;
begin
    MainForm.MediaPlayer.TimeFormat := tfMilliseconds;
    Seconds := (Seconds / 1000);
    Hour := Trunc((Seconds)/(60*60));
    Minute := Trunc((Seconds)/60) mod 60;
    Second := Trunc(Seconds) mod 60;
    Result := '';
    if Hour = 0 then
        Result := ''
    else
        Result := IntToStr(Hour) + TIME_SPLITTER;
    if Minute < 10 then
        Result := Result + '0';
    Result := Result + IntToStr(Minute) + TIME_SPLITTER;
    if Second < 10 then
        Result := Result + '0';
    Result := Result + IntToStr(Second);
end;

procedure TMainForm.PlayerTimerTimer(Sender: TObject);
begin
    if IsLoaded then
    begin
        TrackProgressBar.Max := MediaPlayer.Length;
        TrackProgressBar.Position := MediaPlayer.Position;
        TimeLabel.Caption := SecondsToTime(MediaPlayer.Position) + ' / ' +
            SecondsToTime(TrackProgressBar.max);
    end;
    FocusButton.SetFocus();
end;

procedure TMainForm.PlaylistListBoxMouseUp(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    APoint, NPoint: TPoint;
    Index: Integer;
    Current: TVideoFile;
begin
    with PlaylistListBox do
    begin
        APoint.X := X;
        APoint.Y := Y;
        Index := ItemAtPos(APoint, False);
        if Index = Items.Count then
            Dec(Index);
        Selected[Index] := True;
        SelectedItem := Index;
        case ListBoxState of
            PLAYLISTS:
            begin
                if Index = Items.Count - 1 then
                begin
                    if FileOpenDialog1.Execute then
                        AddPlaylist(FileOpenDialog1.FileName);
                    RefreshPlaylists;
                end
                else
                    if Button = mbLeft then
                    begin
                        SelectedPlaylist := Index;
                        OpenedPlaylist := Index;
                        RefreshSinglePlaylist;
                        ListBoxState := TRACKS;
                    end
                    else
                    begin
                        GetCursorPos(APoint);
                        NPoint := APoint;
                        SelectedPlaylist := Index;
                        PlaylistPopupMenu.Popup(NPoint.X, NPoint.Y);
                    end;
            end;

            TRACKS:
            begin
                if Index = Items.Count - 1 then
                begin
                    if OpenDialog1.Execute then
                        AddTrack(OpenDialog1.FileName, TrackList[SelectedPlaylist]);
                    RefreshSinglePlaylist;
                end
                else
                    if Index = 0 then
                    begin
                        RefreshPlaylists;
                        ListBoxState := PLAYLISTS;
                        OpenedPlaylist := -1;
                    end
                    else
                        if Button = mbLeft then
                        begin
                            PlayTrack(Index);
                        end
                        else
                        begin
                            GetCursorPos(APoint);
                            NPoint := APoint;
                            SelectedItem := Index;
                            TrackPopupMenu.Popup(NPoint.X, NPoint.Y);
                        end;
            end;
        end;
    end;
end;

procedure TMainForm.PlaylistOpenButtonClick(Sender: TObject);
var
    Current: TVideoFile;
begin
    PlaylistListBox.Clear;
    PlaylistListBox.Items.Add('..');
    for Current in TrackList[SelectedPlaylist].Videos do
        PlaylistListBox.Items.Add(Current.FileName);
    ListBoxState := TRACKS;
end;

procedure TMainForm.PlaylistRefreshButtonClick(Sender: TObject);
begin
    RefreshPlaylists;
end;

procedure TMainForm.TrackProgressBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbLeft then
    begin
        IsRewinding := True;
        IsPlaying := False;
    end;
end;

procedure TMainForm.TrackProgressBarMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
    if IsLoaded then
    begin
        if IsRewinding then
        begin
            TrackProgressBar.Position := round(
                (TrackProgressBar.max/(TrackProgressBar.Width-2))*X);
            MediaPlayer.Position := TrackProgressBar.Position;
        end;
    end;
end;

procedure TMainForm.TrackProgressBarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbLeft then
    begin
        IsRewinding := False;
        IsPlaying := True;
    end;
end;

procedure TMainForm.VolumeTrackBarChange(Sender: TObject);
begin
    Volume := TTrackBar(Sender).Position * 100;
end;

function TMainForm.GetVolume: Integer;
var
    Ctrl: TController;
begin
    if IsLoaded then
        Result := Ctrl.GetMPVolume(MediaPlayer)
    else
        Result := 1000;
end;

procedure TMainForm.SetVolume(const Value: Integer);
var
    Ctrl: TController;
begin
    if IsLoaded then
        Ctrl.SetMPVolume(MediaPlayer, Value);
end;

end.
