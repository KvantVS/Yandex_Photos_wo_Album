unit common;

interface

uses system.SysUtils;  //, ES.Images;

//type
//  TSomeEnumType = ES.Images.TImageStretch;

var
  teststring23: string = 'asddds';
  resultFolder: string = 'Result';
  fnDataFromClusters: string;
  fnDataFromAlbums: string;
  fnAlbumsList: string;
  fnDetailedAlbumsList: string;
  fnPhotoWoAlbum: string;
  fnPhotoFromLimitedStorage: string;
  fnPhotosFromLimitedInsideAlbums: string;
  folderWithPhotos: string;
  folderProject : string;
  f: textfile;
  s: string;
  sFnCommon: string;

  sAddToAlbumScript: string;
  scriptDelPhoto: string;
  scriptGetAlbums: string;
  sPython: string;

implementation

function getQuotedTextForVar(s: string): string;
var
  k,k2: integer;
begin

  k := pos('''', s);
  k2 := pos('''', s, k+1);
  result := copy(s, k+1, k2-k-1);
end;

initialization
//  folderProject := ExtractFilePath(ExtractFileDir(ExtractFileDir(paramstr(0))));
  folderProject := ExtractFileDir(paramstr(0));
  if not folderProject.EndsWith('\') then
    folderProject := folderProject + '\';

  sFnCommon := folderProject + '\Scripts\common.py';
  assignFile(f, sFnCommon, 65001);
  reset(f);
  while not eof(f) do
  begin
    readln(f, s);
    if s.StartsWith('fn_data_from_clusters')                     then fnDataFromClusters := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)
    else if s.StartsWith('fn_data_from_albums')                  then fnDataFromAlbums := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)
    else if s.StartsWith('fn_albums_list')                       then fnAlbumsList := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)
    else if s.StartsWith('fn_detailed_albums_list')              then fnDetailedAlbumsList  := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)
    else if s.StartsWith('fn_photo_wo_album')                    then fnPhotoWoAlbum := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)  // Scripts\Result\Фотки без альбома_sorted.txt
    else if s.StartsWith('fn_photo_from_limited_storage')        then fnPhotoFromLimitedStorage := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)
    else if s.StartsWith('fn_photos_from_limited_inside_albums') then fnPhotosFromLimitedInsideAlbums := folderProject + 'Scripts\Result\' + getQuotedTextForVar(s)
    else if s.StartsWith('folder_with_photos')                   then folderWithPhotos := getQuotedTextForVar(s) + '\';  // 'C:\Users\kvant\Pictures\yandexdisk_wo_album\';
  end;
  CloseFile(f);

  sAddToAlbumScript := folderProject + 'Scripts\add_to_album.py';  //  'test.py';
  scriptDelPhoto    := folderProject + 'Scripts\delete_photo.py';
  scriptGetAlbums   := folderProject + 'Scripts\get_only_albums_list.py';
  sPython := 'python';
end.
