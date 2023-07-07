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
  common, Vcl.ComCtrls;


// ,GDIPAPI, GDIPOBJ

type
  TForm1 = class(TForm)
    Panel_top: TPanel;
    IdHTTP1: TIdHTTP;
    IdCookieManager1: TIdCookieManager;
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    BitBtn2: TBitBtn;
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
    Memo1: TMemo;
    Panel1: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    btnUpdateScripts: TBitBtn;
    StatusBar1: TStatusBar;
    BitBtn4: TBitBtn;
    btnSelectAll: TBitBtn;
    Label1: TLabel;
    BitBtn5: TBitBtn;
    btnDelete: TBitBtn;
    btnUpdateAlbums: TBitBtn;
    // procedure SetCookies;
    procedure BitBtn2Click(Sender: TObject);
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
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BitBtn4Click(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure BitBtn5Click(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpdateAlbumsClick(Sender: TObject);
  private
    { Private declarations }
  protected
//    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
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
//  globalChecked : set of byte;
  globalChecked : array of integer;
//  globalExcluded: TArray<string>;


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

// -----------------------------------------------------------------------------


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
//  globalChecked := globalChecked + [257, 128];
  setlength(globalChecked, length(globalChecked) + 1);
  globalChecked[high(globalChecked)] := 255;

//  if 255 in globalChecked then
//    caption :=' 255 true';
//  if 257 in globalChecked then
//    caption:=caption + '257 True';



//  caption := string(globalChecked);
end;


procedure ExcludePhotosFromFile(photoIds: string);
var
  s: string;
  f: textfile;  //f2
  f3: file;
  arr: TArray<string>;
  i: integer;
  stream: TStringStream;
begin
  arr := photoIds.Split([' ::: ']);
  stream := TStringSTream.Create('', 65001);

  assignFile(f, fnPhotoWoAlbum, 65001);
  reset(f);
  try
    while not eof(f) do
    begin
      readln(f, s);
      // Смотрим, есть ли в этой строке исключённый айдишник
      for i := Low(arr) to High(arr) do
        if s.Contains(arr[i]) then
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


procedure TForm1.BitBtn2Click(Sender: TObject);
var
  s: string;
  photo, ext, filename: string;
  f: textfile;
  a_photoInfo: TArray<String>;
  img: TImage;
//  jpg: TJpegImage;
  iCurrentImagesCount : integer;
  i: Integer;
  b: boolean;
  iStartRow : integer;
  l,t,h,w:  integer;
//  tar: TArray<string>;
  j: Integer;
begin
  b := False;
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

      l := (iw + imargin) * icol + 4;
      t := (ih + imargin) * irow + 4;
      //with TImage.Create(Form1) do  // img := TImage.Create(Panel1);    // Panel1  Form1
      img := TImage.Create(Panel1);
      begin
        img.Name := 'img_' + inttostr(igRowReadedCounter);
        img.Left := l;
        img.Top := t;
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
        img.OnMouseUp := Image1MouseUp;
//        img.OnClick := Image1Click;
        LoadWebpFile(folderWithPhotos + filename, img.picture.Bitmap);
        img.Repaint;
        img.Parent := Panel1;

        with TCheckBox.Create(img) do
        begin
          Name := 'chb_' + inttostr(igRowReadedCounter);
          left := l + 2;
          top := t + 2;
          width := 17;
          height := 17;
          caption := '';
          checked := False;
          visible := False;
          onClick := checkboxImageClick;
          Parent := panel1;
        end;

        if a_photoInfo[5].EndsWith('.mp4', True) then
        with TLabel.Create(img) do begin
          name := 'lbl_' + inttostr(igRowReadedCounter);
          left := l+2 + 17+2;
          top := t + 2;
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
      if iCurrentImagesCount >= 32 then break;
    end;
    scrollBar1.Max := (ih + imargin) * (irow+1 - 4) + 4;  // -4 - это сколько рядов помещается на один экран
    panel1.Height := panel1.Height + (ih + imargin) * (iRow - iStartRow) + 4;
    scrollBar1.PageSize :=  100; //panel3.Height; // (ih + imargin) * 4;  // 464
    scrollBar1.LargeChange := panel3.Height; // (ih + imargin) * 4;
  finally
    {if assigned(f) then } closeFile(f);
  end;

end;


procedure TForm1.BitBtn4Click(Sender: TObject);
var
  i:  integer;
  img:  TComponent;
begin
  // Удаляем изображения с панели;
  for i := 0 to length(globalChecked)-1 do
  begin
    img := panel1.FindComponent('img_' + inttostr(globalChecked[i])) as TControl;
    img.Free;
  end;

  // Обнуляем GlobalChecked
  setlength(GlobalChecked, 0);
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
begin
  ShellExecute(handle, 'open', 'python', 'Scripts\get_only_albums_list.py', nil, SW_SHOWNORMAL);
  sl := TstringList.Create;
  sl.LoadFromFile(fnAlbumsList, TEncoding.UTF8);
  sl.Sort;
  for i := 0 to sl.Count-1 do
    sl[i] := inttostr(i) + ') ' + sl[i];
  Form2.ListBox1.Items.Clear;
  Form2.ListBox1.Items.Assign(sl);
  sl.Free;
end;

procedure TForm1.btnUpdateScriptsClick(Sender: TObject);
begin
//   запускаем скрипты
  ShellExecute(handle, 'open', 'python', 'Scripts\startHere.py', nil, SW_SHOWNORMAL);
end;

procedure TForm1.btnAddManyToAlbumClick(Sender: TObject);
var
  albumId, albumName, photoId, resultPhotosIds: string;
  arr: TArray<String>;
  photoNum: integer;
  I, j: Integer;
  cmp : TComponent;
  img: TControl;    //TControl
  chb: TComponent;
//  chb: TCheckBox;
  s, sName, sPhotoNum, sForExclude: string;
  snumber: string;
  asPhotoIds : tArrayOfString;
begin
  photoId := '';
  resultPhotosIds := '';
  setlength(asPhotoIds, 0);

  if Form2.ShowModal = mrOk then
  begin
    albumName := Form2.ListBox1.Items[Form2.ListBox1.ItemIndex];
    albumId := '"' + albumName.Split([' ::: '])[1] + '"';
    albumName := albumName.Split([' ::: '])[0];
    albumName := copy(albumName, pos(')', albumName)+2, 1000);

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

            photoId := '""' + photoId + '"",';
            memo1.Lines.Add(photoId);
            resultPhotosIds := resultPhotosIds + photoId;
          end;
      end;
    end;

    // Доформировываем строку для передачи в скрипт
    Delete(resultPhotosIds, length(resultPhotosIds), 1);  // удаляем запятую
    resultPhotosIds := '"[' + resultPhotosIds + ']"';     // оборачиваем в список
    memo1.Lines.Add(inttostr(length(asPhotoIds)) + ' фото добавлен(-о,-ы) в альбом "' + albumName + '"');
//    memo1.Lines.Add(resultPhotosIds);

    ShellExecute(handle, 'open', 'python', PWideChar(sAddToAlbumScript + ' ' + albumId + ' ' + resultPhotosIds), nil, SW_SHOWMINIMIZED);

    sForExclude := string.Join(' ::: ', asPhotoIds);
    ExcludePhotosFromFile(sForExclude);

//    // Удаляем изображения с панели;
//    for i := 0 to length(globalChecked)-1 do
//    begin
//      img := panel1.FindComponent('img_' + inttostr(globalChecked[i])) as TControl;
//      img.Free;
//    end;
//
//    // Обнуляем GlobalChecked
//    setlength(GlobalChecked, 0);
  end;

end;

procedure TForm1.btnAddToAlbumClick(Sender: TObject);
var
  albumId, photoId: string;
  arr: TArray<String>;
  photoNum: integer;
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

    ShellExecute(handle, 'open', 'python', PWideChar(sAddToAlbumScript + ' ' + albumId + ' ' + PhotoId), nil, SW_SHOWNORMAL);
    ExcludePhotosFromFile(sForExclude);
  end;
end;


procedure TForm1.btnCancelClick(Sender: TObject);
var
  I: Integer;
  j: Integer;
  img: TComponent;
begin
  setlength(globalChecked, 0);
  for I := 0 to panel1.ComponentCount - 1 do
  begin
    img := panel1.Components[i];
    if string(img.Name).StartsWith('img_') then
      for j := 0 to img.ComponentCount - 1 do
        if img.Components[j].ClassName = 'TCheckBox' then
        begin
          (img.Components[j] as TCheckBox).Checked := False;
          (img.Components[j] as TCheckBox).visible := False;
        end;
  end;
end;


procedure TForm1.btnDeleteClick(Sender: TObject);
var
  albumId, albumName, photoId, resultPhotosIds: string;
  arr: TArray<String>;
  photoNum: integer;
  I, j: Integer;
  cmp : TComponent;
  img: TControl;    //TControl
  chb: TComponent;
//  chb: TCheckBox;
  s, sName, sPhotoNum, sForExclude: string;
  snumber: string;
  asPhotoIds : tArrayOfString;
begin
  photoId := '';
  resultPhotosIds := '';
  setlength(asPhotoIds, 0);

  if MessageBox(handle, 'Удалить фото?', 'Удаление', MB_YESNO) = mrNo then
  exit;

  // Ищем image, которые Checked и вытаскиваем из них photoId (в .Hint)
  for I := 0 to Panel1.ComponentCount - 1 do
  begin
    img := panel1.Components[i] as TControl;
    snumber := copy(img.Name, pos('_', img.Name) + 1, 1000);

    if string(img.Name).StartsWith('img_') then
    begin
      chb := img.FindComponent('chb_' + snumber);
      if chb <> nil then begin
        if (chb as TCheckBox).Checked then
        begin
          photoId := string(img.Hint).Split([' ::: '])[1];
          setlength(asPhotoIds, length(asPhotoIds) + 1);
          asPhotoIds[high(asPhotoIds)] := photoId;

          photoId := '""' + photoId + '"",';
          memo1.Lines.Add(photoId);
          resultPhotosIds := resultPhotosIds + photoId;
        end;
      end;
    end;
  end;

  // Доформировываем строку для передачи в скрипт
  Delete(resultPhotosIds, length(resultPhotosIds), 1);  // удаляем запятую
  resultPhotosIds := '"[' + resultPhotosIds + ']"';     // оборачиваем в список
  memo1.Lines.Add(inttostr(length(asPhotoIds)) + ' фото удалено');
  //    memo1.Lines.Add(resultPhotosIds);

  //ShellExecute(handle, 'open', 'python', PWideChar(scriptDelphoto + ' ' + ' ' + resultPhotosIds), nil, SW_SHOWMINIMIZED);
  ShellExecute(handle, 'open', 'python', PWideChar(scriptDelphoto + ' ' + ' ' + resultPhotosIds), nil, SW_SHOWNORMAL);

  sForExclude := string.Join(' ::: ', asPhotoIds);
  ExcludePhotosFromFile(sForExclude);


//    // Удаляем изображения с панели;
//    for i := 0 to length(globalChecked)-1 do
//    begin
//      img := panel1.FindComponent('img_' + inttostr(globalChecked[i])) as TControl;
//      img.Free;
//    end;
//
//    // Обнуляем GlobalChecked
//    setlength(GlobalChecked, 0);

end;

procedure TForm1.btnSelectAllClick(Sender: TObject);
var
  i:  integer;
  cmp, img:  TComponent;
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
    setlength(globalChecked, length(globalChecked) + 1);
    globalChecked[high(globalChecked)] := id;
  end

  else
  // выключили чекбокс, убираем айдишник из массива выбранных
  begin
    index := -1;
    for i := 0 to length(globalChecked) - 1 do
      if globalChecked[i] = id then
      begin
        index := i;
        break;
      end;
    if index <> -1 then
    begin
      for i := index to length(globalChecked) - 2 do
        globalChecked[i] := globalChecked[i+1];
      setlength(globalChecked, length(globalChecked) - 1);
    end;
  end;

  btnCancel.visible := length(globalChecked) > 0;
  btnAddManyToAlbum.Visible := length(globalChecked) > 0;
  btnDelete.Visible := length(globalChecked) > 0;

//  for i := 0 to length(globalChecked) - 1 do
//    caption := caption + ' ' + inttostr(globalChecked[i]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  DoubleBuffered := True;
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
  ControlStyle := ControlStyle + [csOpaque];
  panel1.ControlStyle := panel1.ControlStyle + [csOpaque];
end;

function IdInGlobalChecked(photoid: integer): boolean;
var
  I: Integer;
begin
  result := false;
  for I := low(globalchecked) to high(globalchecked) do
    if globalchecked[i] = photoid then
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

  if button = TMouseButton.mbLeft then
  begin
//    (Sender as TImage).Cursor:=crHandPoint;
    for i := 0 to img.ComponentCount - 1 do
      if img.Components[i].ClassName = 'TCheckBox' then
        (img.Components[i] as TCheckBox).Checked := not (img.Components[i] as TCheckBox).Checked;
  end

  else
  if button = TMouseButton.mbRight then
  begin
    filename := (Sender as TImage).Hint.Split([' ::: '])[0];
    ShellExecute(Handle, 'open', PWideChar(filename), nil, nil, SW_SHOWNORMAL);
    //  ShellExecute(Handle, 'open', 'rundll32.exe',
    //    PWideChar(Format('C:\\WINDOWS\\System32\\shimgvw.dll,ImageView_Fullscreen %s', [filename])),
    //    nil, SW_SHOWNORMAL);
  end

  else
  if button = mbMiddle then
  begin
    filename := (Sender as TImage).Hint.Split([' ::: '])[2];
    shellExecute(handle, 'open', PWideChar(filename), nil, nil, SW_SHOWNORMAL);
  end;


//  if button = mbRight then
//    shellExecute(handle, 'open',

end;

procedure TForm1.Image1MouseEnter(Sender: TObject);
var
  sname: string;
  i: integer;
//  k,k2: integer;
  cmp, img : TComponent;
begin
  img := (sender as TComponent);
  sname := img.Name;
  sname := copy(sname, pos('_', sname) + 1, 1000000);
  for i := 0 to img.ComponentCount-1 do
  begin
    TControl(TControl(img).Components[i]).Visible := true;
//    cmp := (sender as TComponent).Components[i];
//    if (cmp.Name = 'btnAddToAlb_' + sname) or (cmp.Name = 'chb_' + sname) then
//      (cmp as TControl).Visible := True;
  end;
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
//  cursor := crDefault;
end;


procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  // Ставим лок: Если мышка находится в границах кнопки, то не обрабатывать исчезание кнопки (Image1MouseLeave)
  globalMouseLock := (x >= 2) and (x <= 42+17) and (y >= 2) and (y <= 19);
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  img: TImage;
begin
  img := Sender as TImage;
//  if button = mbLeft then
//    img.Cursor:=crDefault;
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
  scrollBar1.PageSize := panel1.ClientHeight;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  form1.LockDrawing;
  caption := inttostr(scrollbar1.Position);
  panel1.Top := -(scrollbar1.position - 41);
  form1.UnlockDrawing;
end;

//procedure TForm1.WMEraseBkgnd(var Message: TWMEraseBkgnd);
//begin
//  Message.Result :=0;
//end;

end.

// memo1.Lines.Add('id: ' + a_photoInfo[0]);
      // memo1.Lines.Add('Дата: ' + a_photoInfo[1]);
      // memo1.Lines.Add('Размер: ' + GetStringedSize(strtofloat(a_photoInfo[2])));
      // memo1.Lines.Add('Тип: ' + a_photoInfo[3]);
      // memo1.Lines.Add('Хранилище: ' + a_photoInfo[4]);
      // memo1.Lines.Add('Путь: ' + a_photoInfo[5]);
      /// /      memo1.Lines.Add('М-ка: ' + a_photoInfo[6]);
      // memo1.Lines.Add('Ссылка: ' + a_photoInfo[7]);
