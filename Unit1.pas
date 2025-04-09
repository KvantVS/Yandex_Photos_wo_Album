unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.JSON, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ExtCtrls,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  MSHTML, ActiveX, IdCookieManager, IdCookie, IdURI, Vcl.Buttons,
  math, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, strUtils, libwebp,
  System.ImageList, Vcl.ImgList, ShellApi,
  common, Vcl.ComCtrls,
  ES.BaseControls, ES.Images, ES.Layouts;


// ,GDIPAPI, GDIPOBJ

type
  TForm1 = class(TForm)
    Panel_top: TPanel;
    IdHTTP1: TIdHTTP;
    IdCookieManager1: TIdCookieManager;
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    btnLoad: TBitBtn;
    ImageList1: TImageList;
    ScrollBar1: TScrollBar;
    Panel3: TPanel;
    Image8: TImage;
    btnAddManyToAlbum: TBitBtn;
    btnAddToAlbumPrototype: TBitBtn;
    checkboxImage: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    btnCancel: TBitBtn;
    btnUpdateScripts: TBitBtn;
    StatusBar1: TStatusBar;
    btnHide: TBitBtn;
    btnSelectAll: TBitBtn;
    Label1: TLabel;
    BitBtn5: TBitBtn;
    btnDelete: TBitBtn;
    btnUpdateAlbums: TBitBtn;
    Panel2: TPanel;
    Memo1: TMemo;
    Panel1: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    // procedure SetCookies;
    procedure btnLoadClick(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Image1MouseLeave(Sender: TObject);
    procedure btnAddToAlbumClick(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure checkboxImageClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAddManyToAlbumClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnUpdateScriptsClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure BitBtn5Click(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpdateAlbumsClick(Sender: TObject);
    procedure btnLoadMouseEnter(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  protected
//    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
    procedure ShowOrHideButtons;
  end;
  tArrayOfString = array of string;

const
//  excludedFile: string = 'Excluded photos.txt';
  iw: integer = 186;
  ih: integer = 105;
  imargin: byte = 4;

var
  Form1: TForm1;
  iimageCounter: integer = 0;
  igRowReadedCounter: integer = 0;
  irow : integer = 0;
  icol :integer = 0;
  myfilepos : int64 = 0;

  // лок: Если мышка находится в границах кнопки, то не обрабатывать исчезание кнопки (Image1MouseLeave). Ставится в OnMouseMove по границам кнопок
  globalMouseLock : boolean = False;
  aiGlobalChecked : array of integer;

/// <summary> Исключаем фотографии из последующей выдачи, помечая их решёткой (#) в файле данных </summary>
procedure ExcludePhotosFromFile(photoIds: string);


implementation

uses unit_albums;

{$R *.dfm}

function isFileWebp(fn: string): boolean;
var
  buffer: TBytes;
  fs: TFileStream;
  sig: PAnsiChar;
  sigStr: string;
begin
  result := false;
  setLength(buffer, 12);
  fs := TFileStream.Create(fn, fmOpenRead);
  fs.Position := 0;
  fs.ReadBuffer(buffer, 12);

  sig := @buffer[8];
  sigStr := sig;
  setLength(sigStr, 4);

  result := lowercase(sigStr) = 'webp';

  setLength(buffer, 0);
  fs.Free;
end;

procedure LoadWebpFile(fn: string; bmp: TBitmap);
//procedure LoadWebpFile(fn: string; bmp2: TImage);
var
  fs: TFileStream;
  Data: PByte;
  buffer: TBytes;
  w, h: integer;
  ix, iy: integer;
//  bmp: TBitmap;
begin

//    with bmp do
//    begin
//      Height := FHeight;
//      Width := FWidth;
//      Draw(Canvas, 0, 0, Index);
//    end;

//  if isFileWebp(fn) then
    try
      fs := TFileStream.Create(fn, fmOpenRead);
      fs.Position := 0;
      setLength(buffer, fs.Size);
      fs.ReadBuffer(buffer, fs.Size);

      if WebPGetInfo(@buffer[0], fs.Size, @w, @h) > 0 then
      begin
//        bmp := tbitmap.Create;
        bmp.PixelFormat := pf24bit;
        bmp.Width := w;
        bmp.Height := h;

        Data := WebPDecodeBGR(@buffer[0], fs.Size, @w, @h);
        for iy := 0 to h - 1 do
          MoveMemory(bmp.ScanLine[iy], @Data[iy * w * 3], w * 3);
//        bmp2.picture.Bitmap.Assign(bmp);
//        bmp2.canvas.Draw(0, 0, bmp);
      end;
    finally
//      bmp.Free;
      setLength(buffer, 0);
      fs.Free;
      WebpFree(Data);
    end;
end;

Function GetStringedSize(d: single): string;
const
  prefixes: array [0 .. 5] of string = ('B', 'KB', 'MB', 'GB', 'TB', 'PB');
var
  i: byte;
begin
  for i := 0 to high(prefixes) do
    if d > 1024 then
      d := d / 1024
    else
      break;
  result := format('%.2f %s', [d, prefixes[i]]);
end;

//function GetButtonByPhotoNum(num: integer): TComponent;
//begin
//  //
//end;


//function isPhotoExcluded(photoId: string): boolean;
//var
//  s:  string;
//begin
//  result := false;
//  for s in globalExcluded do
//    if s = photoId then
//    begin
//      result := True;
//      break;
//    end;
//end;


procedure ExcludePhotosFromFile(photoIds: string);
var
  s: string;
  f: textfile;
  asIds: TArray<string>;
  i: integer;
  stream: TStringStream;
begin
  asIds := photoIds.Split([' ::: ']);
  stream := TStringStream.Create('', 65001);

  assignFile(f, fnPhotoWoAlbum, 65001);
  reset(f);
  try
    while not eof(f) do
    begin
      readln(f, s);
      // Смотрим, есть ли в этой строке исключённый айдишник
      for i := Low(asIds) to High(asIds) do
        if s.Contains(asIds[i]) then
          s:='# ' + s;
        stream.WriteString(s + #$D#$A);
    end;
  finally
    closeFile(f);
  end;

  try
    stream.SaveToFile(fnPhotoWoAlbum);
  finally
    stream.Free;
  end;
end;

// -----------------------------------------------------------------------------


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
//  globalChecked := globalChecked + [257, 128];
  setlength(aiGlobalChecked, length(aiGlobalChecked) + 1);
  aiGlobalChecked[high(aiGlobalChecked)] := 255;

//  if 255 in globalChecked then
//    caption :=' 255 true';
//  if 257 in globalChecked then
//    caption:=caption + '257 True';



//  caption := string(globalChecked);
end;

procedure TForm1.ShowOrHideButtons;
var
  b: boolean;
begin
  b := length(aiGlobalChecked) > 0;
  btnCancel.visible := b;
  btnDelete.Visible := b;
  btnAddManyToAlbum.Visible := b;
  btnHide.Visible := b;
  bitbtn5.Visible := b;
end;


procedure TForm1.btnLoadClick(Sender: TObject);
var
  f: textfile;
  img: TImage;
  a_photoInfo: TArray<String>;
  photo, ext, filename: string;
  iCurrentImagesCount: integer;
  iStartRow: integer;
  i, iLeft, iTop:  integer;
begin
  scrollbar1.visible:=True;
  iCurrentImagesCount := 0;
  iStartRow := iRow;

  if not fileexists(fnPhotoWoAlbum) then
    exit;

  // Основная процедура отображения фоток --------------------------------------
  try
    assignFile(f, fnPhotoWoAlbum, 65001);
    reset(f);

    // Пропускаем уже открытые фотки (пагинация). Причём счётчик идёт только по недобавленным в альбом.
    // Добавленные в альбом у нас в массиве Tar.
    for i := 1 to igRowReadedCounter do
      if not EOF(f) then
        readln(f, photo)
      else break;

    // Читаем дальше файл фоток без альбома
    while not eof(f) do
    begin
      readln(f, photo);
      a_photoInfo := photo.Split([' ::: ']);

      if photo.StartsWith('# ') then
//      if isPhotoExcluded(a_photoinfo[5]) then
      begin
        inc(igRowReadedCounter);
        continue;
      end;

      filename := ExtractFileName(replaceStr(a_photoInfo[5], '/', '\'));
      ext := ExtractFileExt(filename);
      if lowercase(ext) = '.mp4' then
      begin
        ext := '.jpg';
        filename := ChangeFileExt(filename, '.jpg');
      end;

      iLeft := (iw + imargin) * icol + 4;
      iTop := (ih + imargin) * irow + 4;
      //with TImage.Create(Form1) do  // img := TImage.Create(Panel1);    // Panel1  Form1
      img := TImage.Create(Panel1);
      begin
        img.Name := 'img_' + inttostr(igRowReadedCounter);
        img.Left := iLeft;
        img.Top := iTop;
        img.Height := ih;
        img.Width := iw;
        img.Stretch := True;
        img.Proportional := True;
        img.Hint := folderWithPhotos + filename + ' ::: ' + a_photoInfo[5] + ' ::: ' + a_photoInfo[7];
        img.Cursor := crHandPoint;
        img.OnMouseMove := Image1MouseMove;
        img.OnMouseEnter := Image1MouseEnter;
        img.OnMouseLeave := Image1MouseLeave;
        img.OnMouseDown := Image1MouseDown;
//        img.OnMouseUp := Image1MouseUp;
//        img.OnClick := Image1Click;
        LoadWebpFile(folderWithPhotos + filename, img.picture.Bitmap);
        img.Repaint;
        img.Parent := Panel1;

        with TCheckBox.Create(img) do
        begin
          Name := 'chb_' + inttostr(igRowReadedCounter);
          left := iLeft + 2;
          top := iTop + 2;
          width := 13;  // D10: 13 = ideal, D11: 17=ideal
          height := 13;
          caption := '';
          checked := False;
          visible := False;
          onClick := checkboxImageClick;
          Parent := panel1;
        end;

        if a_photoInfo[5].EndsWith('.mp4', True) then
        with TLabel.Create(img) do begin
          name := 'lbl_' + inttostr(igRowReadedCounter);
          left := iLeft+2 + 17+2;
          top := iTop + 2;
          width := 40;
          height := 17;
          ParentFont := False;
          Font.Name := 'Font Awesome 6 Free Solid';
          caption := '▶';   //  '▶';
          Font.Color:=clWhite;
          onMouseEnter := Image1MouseEnter;
          visible := true;
          parent := Panel1;
          bringToFront;
        end;

//        with TBitBtn.Create(img) do begin
//          Name := 'btnAddToAlb_' + inttostr(igRowReadedCounter);
//          left := l + 2 + 21 + 2;
//          top := t + 2;
//          width := 40;
//          height := 17;
//          caption := '+Альб';
//          OnClick := btnAddToAlbumClick;
//          onMouseEnter := Image1MouseEnter;
////          OnMouseLeave := Image1MouseLeave;
//          visible:=false;
//          parent := Panel1;
////          BringToFront;
//        end;
      end;
      inc(iimageCounter);
      inc(iCurrentImagesCount);
      inc(igRowReadedCounter);
      icol := iimageCounter mod 4;
      // irow := ceil(iImageCounter div 4);
      irow := iimageCounter div 4;
      if iCurrentImagesCount >= 40 then break;
    end;

    scrollBar1.Max := (ih + imargin) * (irow+1 - 1) + 4;  // -4 - это сколько рядов помещается на один экран
    panel1.Height := panel1.Height + (ih + imargin) * (iRow - iStartRow) + 4;
    ScrollBar1.PageSize := form1.ClientHeight - panel_Top.Height - panel2.Height - statusbar1.Height; //      panel1.Height div (ih+iMargin);
    //    scrollBar1.PageSize :=  100; //panel3.Height; // (ih + imargin) * 4;  // 464
    scrollBar1.LargeChange := scrollBar1.PageSize; // panel3.Height; // (ih + imargin) * 4;

  finally
    {if assigned(f) then } closeFile(f);
  end;

end;


procedure TForm1.btnLoadMouseEnter(Sender: TObject);
begin
  statusbar1.SimpleText := (sender as TControl).Hint;
end;

procedure TForm1.btnHideClick(Sender: TObject);
var
  i:  integer;
  img:  TComponent;
begin
  // Удаляем изображения с панели;
  for i := 0 to length(aiGlobalChecked)-1 do
  begin
    img := panel1.FindComponent('img_' + inttostr(aiGlobalChecked[i])) as TControl;
    img.Free;  // Чекбокс удаляется тоже, т.к. img является его владельцем
  end;

  // Обнуляем GlobalChecked
  setlength(aiGlobalChecked, 0);

  ShowOrHideButtons;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var
  asPhotoIds: tArrayOfString;
  sForExclude : string;
  i:  integer;
  img:  TControl;
  chb:  TComponent;
  snumber:  string;
  photoId:  string;
begin
  setlength(asPhotoIds, 0);

  // Ищем image, которые Checked и вытаскиваем из них photoId (в .Hint)
  for I := 0 to Panel1.ComponentCount - 1 do
  begin
    img := panel1.Components[i] as TControl;
    snumber := copy(img.Name, pos('_', img.Name) + 1, 1000);
    if string(img.Name).StartsWith('img_') then
    begin
//        chb := img.FindChildControl('chb_' + snumber);
      chb := img.FindComponent('chb_' + snumber);
      if chb <> nil then
        if (chb as TCheckBox).Checked then
        begin
          photoId := string(img.Hint).Split([' ::: '])[1];
          setlength(asPhotoIds, length(asPhotoIds) + 1);
          asPhotoIds[high(asPhotoIds)] := photoId;
        end;
    end;
  end;

  sForExclude := string.Join(' ::: ', asPhotoIds);
  ExcludePhotosFromFile(sForExclude);
end;

procedure TForm1.btnUpdateAlbumsClick(Sender: TObject);
var
  sl: TStringList;
  i:  integer;
  sei: TSHELLEXECUTEINFO;
begin
//  ShellExecute(handle, 'open', 'python', 'Scripts\get_only_albums_list.py', nil, SW_SHOWNORMAL);
//  ShellExecute(handle, 'open', 'cmd', '/K python Scripts\get_only_albums_list.py', nil, SW_SHOWNORMAL);
  FillChar(sei, sizeOf(sei), 0);

  sei.cbSize := sizeof(TSHELLEXECUTEINFO);
  sei.fMask := SEE_MASK_NOCLOSEPROCESS;  // + SEE_MASK_NO_CONSOLE;
  sei.Wnd := Application.Handle;
  sei.lpVerb := 0;
  sei.lpFile := PChar('python.exe');  // TODO: sPython
  sei.lpParameters := PChar(scriptGetAlbums);
  sei.lpDirectory := PChar(GetCurrentDir);
  sei.nShow := SW_SHOW;
  sei.hInstApp := 0;
  ShellExecuteEx(@sei);
  WaitForSingleObject(sei.hProcess, INFINITE);
  CloseHandle(sei.hProcess);

  sl := TstringList.Create;
  sl.LoadFromFile(fnAlbumsList, TEncoding.UTF8);
  sl.Sort;
  for i := 0 to sl.Count-1 do
    sl[i] := inttostr(i+1) + ') ' + sl[i];
  Form2.ListBox1.Items.Clear;
  Form2.ListBox1.Items.Assign(sl);
  sl.Free;
end;

procedure TForm1.btnUpdateScriptsClick(Sender: TObject);
begin
//   запускаем скрипты
  ShellExecute(handle, 'open', 'python', 'Scripts\startHere.py', nil, SW_SHOWNORMAL);  // TODO: sPython
  // TODO доделать
end;

procedure TForm1.btnAddManyToAlbumClick(Sender: TObject);
var
  albumId, albumName, photoId, sResultPhotosIds: string;
  I: Integer;
  img: TImage;
  chb: TComponent;
  sForExclude: string;
  asPhotoIds : tArrayOfString;
begin
  photoId := '';
  sResultPhotosIds := '';
  setlength(asPhotoIds, 0);

  if form2.ShowModal <> mrOk then exit;

//  if Form2.ShowModal = mrOk then
//  begin
  albumName := Form2.ListBox1.Items[Form2.ListBox1.ItemIndex];
  albumId := '"' + albumName.Split([' ::: '])[1] + '"';
  albumName := albumName.Split([' ::: '])[0];
  albumName := copy(albumName, pos(')', albumName)+2, 1000);

  // Ищем image, которые Checked и вытаскиваем из них photoId (в .Hint)
  for I := 0 to Panel1.ComponentCount - 1 do
  begin
    img := panel1.Components[i] as TImage;

    if string(img.Name).StartsWith('img_') then
    begin
      chb := img.FindComponent('chb_' + copy(img.Name, 5, length(img.Name) - 4));
      if chb <> nil then begin
        if (chb as TCheckBox).Checked then
        begin
          // Формируется массив с ID'шниками фоток, из которого потом формируется строка для
          // помечания (#) решеткой в файле
          photoId := string(img.Hint).Split([' ::: '])[1];
          setlength(asPhotoIds, length(asPhotoIds) + 1);
          asPhotoIds[high(asPhotoIds)] := photoId;

          // Формируется строка для передачи аргументом в python-скрипт, который добавляет фото в альбомы в Я.Диске
          photoId := '""' + photoId + '"",';
          memo1.Lines.Add(photoId);
          sResultPhotosIds := sResultPhotosIds + photoId;
        end;
      end;
    end;
  end;

  // Доформировываем строку для передачи в скрипт
  Delete(sResultPhotosIds, length(sResultPhotosIds), 1);  // удаляем запятую
  sResultPhotosIds := '"[' + sResultPhotosIds + ']"';     // оборачиваем в список
  memo1.Lines.Add(inttostr(length(asPhotoIds)) + ' фото добавлен(-о,-ы) в альбом "' + albumName + '"');

  // Выполняем python-скрипт удаления файлов с яндекс.диска
  ShellExecute(handle, 'open', 'python', PWideChar(sAddToAlbumScript + ' ' + albumId + ' ' + sResultPhotosIds), nil, SW_SHOWMINIMIZED);
  //TODO: sPython

  // Исключаем фото/видео из дальнейшей выдачи, помечая строку с файлом решёткой #
  sForExclude := string.Join(' ::: ', asPhotoIds);
  ExcludePhotosFromFile(sForExclude);

//    // Удаляем изображения с панели;
//    for i := 0 to length(aiglobalChecked)-1 do
//    begin
//      img := panel1.FindComponent('img_' + inttostr(aiglobalChecked[i])) as TControl;
//      img.Free;
//    end;
//
//    // Обнуляем GlobalChecked
//    setlength(GlobalChecked, 0);


//  end;

end;

procedure TForm1.btnAddToAlbumClick(Sender: TObject);
var
  albumId, photoId: string;
  arr: TArray<String>;
  I: Integer;
  cmp : TComponent;
  s, sPhotoNum, sForExclude: string;
begin
  if Form2.ShowModal = mrOk then
  begin
    albumId := Form2.ListBox1.Items[Form2.ListBox1.ItemIndex];
    albumId := '"' + albumId.Split([' ::: '])[1] + '"';

    s := (Sender as TWincontrol).name;
    sPhotoNum := midstr(s, pos('_', s) + 1, 1000000);
    for I := 0 to Panel1.ComponentCount-1 do
    begin
      cmp := panel1.Components[i];
      if cmp.Name = 'img_' + sPhotoNum then
      begin
        photoId := (cmp as TControl).Hint;
        arr := photoId.Split([' ::: ']);
        sForExclude := arr[1];
        photoId := '"[""' + arr[1] + '""]"';
        break;
      end;
    end;

    ShellExecute(handle, 'open', 'python', PWideChar(sAddToAlbumScript + ' ' + albumId + ' ' + PhotoId), nil, SW_SHOWNORMAL);  //TODO: sPython
    ExcludePhotosFromFile(sForExclude);
  end;
end;


procedure TForm1.btnCancelClick(Sender: TObject);
var
  I: Integer;
  img: TComponent;
  chb: TCheckBox;
begin
  setlength(aiGlobalChecked, 0);

  for I := 0 to panel1.ComponentCount - 1 do
  begin
    img := panel1.Components[i];
    if string(img.Name).StartsWith('img_') then
    begin
      memo1.Lines.Add(img.Name + ', compCount: ' + inttostr(img.ComponentCount));
      chb:=TCheckBox(img.FindComponent('chb_' + copy(img.Name, 5, length(img.Name) - 4)));
      chb.Checked:=False;
      chb.Visible:=False;
    end;
  end;
end;


procedure TForm1.btnDeleteClick(Sender: TObject);
var
  photoId, sResultPhotosIds: string;
  I: Integer;
  img: TImage;
  chb: TComponent;
  sForExclude: string;
  asPhotoIds : tArrayOfString;
begin
  photoId := '';
  sResultPhotosIds := '';
  setlength(asPhotoIds, 0);

  if MessageBox(handle, 'Удалить фото?', 'Удаление', MB_YESNO) = mrNo then
    exit;

  // Ищем image, которые Checked и вытаскиваем из них photoId (в .Hint) в массив asPhotoIds
  // TODO: Можно же идти просто по массиву aiGlobalChecked
  for I := 0 to Panel1.ComponentCount - 1 do
  begin
    img := panel1.Components[i] as TImage;

    if string(img.Name).StartsWith('img_') then
    begin
      chb := img.FindComponent('chb_' + copy(img.Name, 5, length(img.Name) - 4));
      if chb <> nil then begin
        if (chb as TCheckBox).Checked then
        begin
          // Формируется массив с удаляемыми ID'шниками фоток, из которого потом формируется строка для
          // помечания (#) решеткой в файле
          photoId := string(img.Hint).Split([' ::: '])[1];
          setlength(asPhotoIds, length(asPhotoIds) + 1);
          asPhotoIds[high(asPhotoIds)] := photoId;

          // Формируется строка для передачи аргументом в python-скрипт, который удаляет фото с Я.Диска
          photoId := '""' + photoId + '"",';
          memo1.Lines.Add(photoId);
          sResultPhotosIds := sResultPhotosIds + photoId;

//          // Пометим Image крестом
//          img.Canvas.Pen.Style:=psSolid;
//          img.Canvas.Pen.width:=4;
//          img.Canvas.Pen.Color:=clBlack;
//          img.Canvas.MoveTo(0, 0);
//          img.Canvas.LineTo(img.canvas.ClipRect.Width, img.Canvas.clipRect.Height);
//          img.Canvas.MoveTo(0, img.Canvas.clipRect.height);
//          img.Canvas.LineTo(img.canvas.ClipRect.Width, 0);
        end;
      end;
    end;
  end;

  // Доформировываем строку для передачи в скрипт
  Delete(sResultPhotosIds, length(sResultPhotosIds), 1);  // удаляем запятую
  sResultPhotosIds := '"[' + sResultPhotosIds + ']"';     // оборачиваем в список
  memo1.Lines.Add(inttostr(length(asPhotoIds)) + ' фото удалено');

  // Выполняем python-скрипт удаления файлов с яндекс.диска
  ShellExecute(handle, 'open', 'python', PWideChar(scriptDelPhoto + ' ' + sResultPhotosIds), nil, SW_SHOWNORMAL);  // SW_SHOWMINIMIZED
  //TODO: sPython

  // Исключаем фото/видео из дальнейшей выдачи, помечая строку с файлом решёткой #
  sForExclude := string.Join(' ::: ', asPhotoIds);
  ExcludePhotosFromFile(sForExclude);
  memo1.lines.add(sForExclude);

  // Удаляем изображения с панели (решил не удалять, заменил на крест, хотя можно вернуть);
  for i := 0 to length(aiGlobalChecked)-1 do
  begin
    img := TImage(panel1.FindComponent('img_' + inttostr(aiGlobalChecked[i])));
    img.Free;
  end;
  // Обнуляем GlobalChecked
  setlength(aiGlobalChecked, 0);
  // Скрываем кнопки
  ShowOrHideButtons;
end;


procedure TForm1.btnSelectAllClick(Sender: TObject);
var
  i:  integer;
  img:  TComponent;
  j: Integer;
begin
  for i := 0 to panel1.ComponentCount-1 do
  begin
    img := panel1.Components[i];
    if string(img.Name).StartsWith('img_') then
      for j := 0 to img.ComponentCount-1 do
        if img.Components[j] is TCheckBox then
        begin
          (img.Components[j] as TCheckBox).Checked := True;
          (img.Components[j] as TCheckBox).visible := True;
        end;
  end;
end;


procedure TForm1.checkboxImageClick(Sender: TObject);
var
  sID: string;
  I, index, id: Integer;
begin
  sID := (Sender as TComponent).Name;
  id := strtoint(copy(sID, pos('_', sID) + 1, length(sID)));

  if (sender as TCheckbox).Checked then
  begin
    setlength(aiGlobalChecked, length(aiGlobalChecked) + 1);
    aiGlobalChecked[high(aiGlobalChecked)] := id;
  end

  else
  // выключили чекбокс, убираем айдишник из массива выбранных
  begin
    index := -1;
    for i := 0 to length(aiGlobalChecked) - 1 do
      if aiGlobalChecked[i] = id then
      begin
        index := i;
        break;
      end;
    if index <> -1 then
    begin
      for i := index to length(aiGlobalChecked) - 2 do
        aiGlobalChecked[i] := aiGlobalChecked[i+1];
      setlength(aiGlobalChecked, length(aiGlobalChecked) - 1);
    end;
  end;

  ShowOrHideButtons;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  panel1.Width:=clientWidth;
//  DoubleBuffered := True;  // DoubleBuffered не влияет на наследников TGraphicControl
//  Panel1.DoubleBuffered := True;
//  ControlStyle := ControlStyle + [csOpaque];
//  panel1.ControlStyle := panel1.ControlStyle + [csOpaque];
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  scrollBar1.Position := scrollBar1.Position + 12;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  scrollBar1.Position := scrollBar1.Position - 12;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
//  ControlStyle := ControlStyle + [csOpaque];
//  panel1.ControlStyle := panel1.ControlStyle + [csOpaque];
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  ScrollBar1.PageSize := form1.ClientHeight - panel_Top.Height - panel2.Height - statusbar1.Height;
  scrollBar1.LargeChange := scrollBar1.PageSize;
end;

function IdInGlobalChecked(photoid: integer): boolean;
var
  I: Integer;
begin
  result := false;
  for I := low(aiGlobalChecked) to high(aiGlobalChecked) do
    if aiGlobalChecked[i] = photoid then
    begin
      result:=true;
      break;
    end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  filename: string;
  i:  integer;
  img: TImage;
begin
  img := Sender as TImage;

  // ЛКМ
  if button = TMouseButton.mbLeft then
  begin
    for i := 0 to img.ComponentCount - 1 do
      if img.Components[i].ClassName = 'TCheckBox' then
        (img.Components[i] as TCheckBox).Checked := not (img.Components[i] as TCheckBox).Checked;
  end

  // ПКМ - открывает в просмотрщике
  else
  if button = TMouseButton.mbRight then
  begin
    filename := (Sender as TImage).Hint.Split([' ::: '])[0];
    ShellExecute(Handle, 'open', PWideChar(filename), nil, nil, SW_SHOWNORMAL);
    //  ShellExecute(Handle, 'open', 'rundll32.exe',
    //    PWideChar(Format('C:\\WINDOWS\\System32\\shimgvw.dll,ImageView_Fullscreen %s', [filename])),
    //    nil, SW_SHOWNORMAL);
  end

  // Средняя кнопка мыши - открывает в браузере
  else
  if button = mbMiddle then
  begin
    filename := (Sender as TImage).Hint.Split([' ::: '])[2];
    shellExecute(handle, 'open', PWideChar(filename), nil, nil, SW_SHOWNORMAL);
  end;

end;

procedure TForm1.Image1MouseEnter(Sender: TObject);
var
  sname: string;
  i: integer;
  img : TComponent;
begin
  img := (sender as TComponent);
  sname := img.Name;
  sname := copy(sname, pos('_', sname) + 1, 1000000);
  for i := 0 to img.ComponentCount - 1 do
    TControl(TControl(img).Components[i]).Visible := true;

  statusbar1.SimpleText := sname + ': ' + (sender as TControl).Hint;
end;

// Когда уводим мышку, ищем кнопки и чекбокс и скрываем их
procedure TForm1.Image1MouseLeave(Sender: TObject);
var
  sname: string;
  i: integer;
  cmp : TComponent;
begin
  if not globalMouseLock then
  begin
    sname := (sender as TComponent).Name;
    sname := copy(sname, pos('_', sname) + 1, 1000000);
    for i := 0 to (sender as TComponent).ComponentCount-1 do begin
      cmp := (sender as TComponent).Components[i];
      if (cmp.Name = 'btnAddToAlb_' + sname)
      or ((cmp.Name = 'chb_' + sname) and not IdInGlobalChecked(StrToInt(sname))) then
        (cmp as TControl).Visible := False;
    end;
  end;
  statusbar1.SimpleText := '';
end;


procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  // Ставим лок: Если мышка находится в границах кнопки, то не обрабатывать исчезание кнопки (Image1MouseLeave)
  globalMouseLock := (x >= 2) and (x <= 42+17) and (y >= 2) and (y <= 19);
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
  scrollBar1.PageSize := panel1.ClientHeight;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
//  form1.LockDrawing;  Решает проблему с мерцанием компонентов  в D10 недоступна
  panel1.DoubleBuffered:=True;
  panel1.Top := -(scrollbar1.position);  // -(scrollbar1.position - 41);
  if scrollbar1.position > scrollbar1.max - scrollbar1.pagesize then
    scrollbar1.position := scrollbar1.max - scrollbar1.pagesize;
//  form1.UnlockDrawing;   в D10 недоступна
end;


end.

