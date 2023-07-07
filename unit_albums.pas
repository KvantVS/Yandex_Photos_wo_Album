unit unit_albums;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  common;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BitBtn1: TBitBtn;
    btnCancel: TBitBtn;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation


// r'["/photounlim/2022-08-17 12-11-47.JPG","/photounlim/2022-08-17 12-11-41.JPG","/photounlim/2022-08-17 12-11-39.JPG"]'


{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
var
  sl: TStringList;
  i:  integer;
begin
  sl := TStringList.Create;
  sl.LoadFromFile(fnAlbumsList, TEncoding.UTF8);
  sl.Sort;
  for i := 0 to sl.Count-1 do
    sl[i] := inttostr(i) + ') ' + sl[i];


  listbox1.Items.Assign(sl);
//  listbox1.Items.LoadFromFile(fnAlbumsList, TEncoding.UTF8);
//  (listbox1.Items as TStringList).Sort;
end;

end.
