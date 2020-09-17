unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, memds, db, odbcconn, FileUtil, PrintersDlgs,
  LR_Class, LR_DBSet, LR_BarC, LR_RRect, LR_Shape, LR_DSet, LR_Desgn, LR_View,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  PairSplitter, Buttons, Spin, unit2, unit3, printers, LConvEncoding, LazUTF8, unit4;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    fr_dane: TfrDBDataSet;
    memDataSource: TDataSource;
    ed_ety_fraza: TEdit;
    frBarCodeObject1: TfrBarCodeObject;
    frDesigner1: TfrDesigner;
    frReport1: TfrReport;
    frRoundRectObject1: TfrRoundRectObject;
    frShapeObject1: TfrShapeObject;
    Label3: TLabel;
    Label4: TLabel;
    labEtySel: TLabel;
    labEtyAsort: TLabel;
    lv_ety_asort: TListView;
    lv_ety_sel: TListView;
    lv1: TListView;
    memDS: TMemDataset;
    od1: TOpenDialog;
    ODBC1: TODBCConnection;
    OD2: TOpenDialog;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    lab_selected_printer: TPanel;
    lab_selected_ety: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    SpeedButton1: TSpeedButton;
    sb_OdwrocZaznaczenieR: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    sb_ZaznaczWszystkoL: TSpeedButton;
    sb_OdznaczWszystkoL: TSpeedButton;
    sb_OdwrocZaznaczenieL: TSpeedButton;
    sb_ZaznaczWszystkoR: TSpeedButton;
    sb_OdznaczWszystkoR: TSpeedButton;
    se_ety_count: TSpinEdit;
    sqlq: TSQLQuery;
    sqlt: TSQLTransaction;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lv1DblClick(Sender: TObject);
    procedure lv_ety_asortChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lv_ety_selChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure sb_ZaznaczWszystkoLClick(Sender: TObject);
    procedure sb_OdznaczWszystkoLClick(Sender: TObject);
    procedure sb_OdwrocZaznaczenieLClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    odbc_file : string;

    procedure FillDataSet;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button8Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  i   : integer;
  err : integer;
  l   : TListItem;
  dbg : string;
begin
  if MessageDlg('Pytanie', 'Czy na pewno chcesz utrwalić zmiany ?', mtConfirmation, [mbYes, mbNo],0) <> mrYes then exit;
  if MessageDlg('Pytanie', 'CZY NA PEWNO chcesz utrwalić zmiany ?', mtConfirmation, [mbYes, mbNo],0) <> mrYes then exit;

  form2.ProgressBar1.Min:=0;
  form2.ProgressBar1.Max:=lv1.Items.Count;
  form2.ProgressBar1.Position:=0;
  form2.ListView1.Clear;
  form2.ListView1.Visible:=false;
  form2.Label1.Visible:=false;
  form2.Show;

  for i:=0 to lv1.Items.Count-1 do if lv1.Items[i].Checked then
  begin
    if trim(lv1.Items[i].SubItems[1]) = '' then
    begin
      l:=form2.ListView1.Items.Add;
      l.Caption:=lv1.items[i].Caption;
      l.SubItems.Add(lv1.Items[i].SubItems[0]);
      form2.ListView1.Visible:=true;
      form2.Label1.Visible:=true;
    end
    else
    try
      sqlq.SQL.Clear;
      sqlq.SQL.Add('update towar set nazwa = :a where towid = :b');
      sqlt.StartTransaction;
      dbg:=UTF8ToCP1250(lv1.Items[i].SubItems[1]);
      sqlq.ParamByName('a').AsString:=UTF8ToCP1250(lv1.Items[i].SubItems[1]);
      sqlq.ParamByName('b').AsInteger:=StrToInt(lv1.Items[i].Caption);
      sqlq.ExecSQL;
      sqlt.Commit;

      form2.ProgressBar1.Position:=i;
    except
      sqlt.Rollback;
      l:=form2.ListView1.Items.Add;
      l.Caption:=lv1.items[i].Caption;
      l.SubItems.Add(lv1.Items[i].SubItems[0]);
      form2.ListView1.Visible:=true;
      form2.Label1.Visible:=true;
    end;

    application.ProcessMessages;
  end;

  if form2.ListView1.Items.Count = 0 then form2.Hide else ShowMessage('Operacja zakonczona sukcesem');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  sl  : TStringList;
  l   : TListItem;
  buf : string;
  idx : integer;
  cena: Double;
  promo : string;
begin
  lv1.BeginUpdate;
  lv1.Clear;
  lv1.EndUpdate;

  lv_ety_asort.BeginUpdate;
  lv_ety_asort.Clear;
  lv_ety_asort.EndUpdate;

  lv_ety_sel.Clear;

  if odbc1.Connected then odbc1.Connected:=false;

  odbc_file:=ExtractFilePath(ParamStr(0));
  if odbc_file[length(odbc_file)] <> '\' then odbc_file:=odbc_file+'\';
  odbc_file:=odbc_file+'pcm.dsn';

  if not FileExistsUTF8(odbc_file) then
    if not od1.Execute then exit else odbc_file:=od1.FileName;

  odbc1.FileDSN:=odbc_file;

  sl:=TStringList.Create;
  sl.LoadFromFile(odbc_file);

  try
    odbc1.Connected:=true;
  except
    ShowMessage('(1) Nie udalo sie podlaczyc do bazy');
    exit;
  end;

  while (sl.Count > 0) and (UpperCase(copy(sl[0],1,9)) <> 'DATABASE=') do sl.Delete(0);

  if sl.Count <> 0 then buf:=copy(sl[0],10,length(sl[0]))
  else
    if not InputQuery('','Podaj nazwe bazy',buf) then
    begin
      odbc1.Connected:=false;
      exit;
    end;

  try
    if sqlt.Active then sqlt.Rollback;
    sqlq.SQL.Clear;
    sqlq.SQL.Add('use '+buf+';');
    sqlt.StartTransaction;
    sqlq.ExecSQL;
    sqlt.Commit;
  except
    sqlt.Rollback;
    ShowMessage('(2) Nie udalo sie polaczyc do bazy: '+buf);
    odbc1.Connected:=false;
    exit;
  end;

  try
    sqlq.SQL.Clear;

    sqlq.SQL.Add('select * from (');
    sqlq.SQL.Add('select a.TowID,');
    sqlq.SQL.Add('       a.Nazwa "naztowar",');
    sqlq.SQL.Add('       ROUND(a.CenaDet*(1+(CAST( a.Stawka AS DECIMAL))/10000),2) as CenaDet,');
    sqlq.SQL.Add('       a.Kod,');
    sqlq.SQL.Add('       b.Nazwa "nazjm",');
    sqlq.SQL.Add('       a.IleWCalosci,');
    sqlq.SQL.Add('       ROUND(hc.CenaDet*(1+(CAST( a.Stawka AS DECIMAL))/10000),2) as CENA_HARM');
    sqlq.SQL.Add('from Towar a');
    sqlq.SQL.Add('inner join JM b on b.JMId = a.JMId');
    sqlq.SQL.Add('inner join HarmCeny hc on hc.TowId = a.TowId');
    sqlq.SQL.Add('inner join HarmWpis hw on hw.HarmId = hc.HarmId and hw.WaznyOd <= CURRENT_TIMESTAMP and CURRENT_TIMESTAMP <= hw.WaznyDo and hw.Aktywny = 1');
    sqlq.SQL.Add('union all');
    sqlq.SQL.Add('select a.TowID,');
    sqlq.SQL.Add('       a.Nazwa "naztowar",');
    sqlq.SQL.Add('	   ROUND(a.CenaDet*(1+(CAST( a.Stawka AS DECIMAL))/10000),2) as CenaDet,');
    sqlq.SQL.Add('	   a.Kod,');
    sqlq.SQL.Add('	   b.Nazwa "nazjm",');
    sqlq.SQL.Add('	   a.IleWCalosci,');
    sqlq.SQL.Add('	   ROUND(a.CenaDet*(1+(CAST( a.Stawka AS DECIMAL))/10000),2) as CENA_HARM');
    sqlq.SQL.Add('from Towar a');
    sqlq.SQL.Add('inner join JM b on b.JMId = a.JMId');
    sqlq.SQL.Add('where (a.TowId not in');
    sqlq.SQL.Add('(');
    sqlq.SQL.Add('select a.TowID');
    sqlq.SQL.Add('from Towar a');
    sqlq.SQL.Add('inner join JM b on b.JMId = a.JMId');
    sqlq.SQL.Add('inner join HarmCeny hc on hc.TowId = a.TowId');
    sqlq.SQL.Add('inner join HarmWpis hw on hw.HarmId = hc.HarmId and hw.WaznyOd <= CURRENT_TIMESTAMP and CURRENT_TIMESTAMP <= hw.WaznyDo and hw.Aktywny = 1');
    sqlq.SQL.Add('))) as bbb');
    sqlq.SQL.Add('order by Upper(bbb.naztowar)');

    sqlt.StartTransaction;
    sqlq.Open;
    sqlq.First;
    while not sqlq.EOF do
    begin
      l:=lv1.Items.Add;
      l.Caption:=IntToStr(sqlq.FieldByName('TowID').AsInteger);
      l.SubItems.Add(CP1250ToUTF8(sqlq.FieldByName('naztowar').AsString));
      l.SubItems.Add('');

      if sqlq.FieldByName('cena_harm').IsNull then
      begin
        cena:=sqlq.FieldByName('CenaDet').AsFloat;
        promo:='';
      end
      else
        begin
          cena:=sqlq.FieldByName('CENA_HARM').AsFloat;
          promo:='TAK';
        end;
      l:=lv_ety_asort.Items.Add;
      l.Caption:=CP1250ToUTF8(sqlq.FieldByName('naztowar').AsString);
      l.SubItems.Add(sqlq.FieldByName('nazjm').AsString);                  // 0
      l.SubItems.Add(FloatToStr(cena));     // 1
      l.SubItems.Add(sqlq.FieldByName('Kod').AsString);                    // 2
      l.SubItems.Add(FloatToStr(sqlq.FieldByName('ilewcalosci').AsFloat)); // 3
      l.SubItems.Add(IntToStr(sqlq.FieldByName('TowID').AsInteger));       // 4
      l.SubItems.Add(promo);                                               // 5

      sqlq.Next;
    end;
    sqlt.Commit;
  except
    sqlt.Rollback;
    ShowMessage('Nie udalo sie pobrac zawartosci tabeli TOWARY, nastąpi zamkniecie aplikacji');
    odbc1.Connected:=false;
    application.Terminate;
    exit;
  end;

  lab_selected_printer.Caption:=Printer.Printers[Printer.PrinterIndex];
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  PairSplitter1.Position:= PairSplitter1.Width div 2;
end;

procedure TForm1.lv1DblClick(Sender: TObject);
begin
  Button10Click(nil);
end;

procedure TForm1.lv_ety_asortChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  a,x : integer;
begin
  a:=0;
  for x:=0 to lv_ety_asort.Items.Count-1 do if lv_ety_asort.Items[x].Checked then inc(a);
  labEtyAsort.Caption:='Wszystkich: '+IntToStr(lv_ety_asort.Items.Count)+'    Zaznaczontch: '+IntToStr(a);
end;

procedure TForm1.lv_ety_selChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  a,x : integer;
begin
  a:=0;
  for x:=0 to lv_ety_sel.Items.Count-1 do if lv_ety_sel.Items[x].Checked then inc(a);
  labEtySel.Caption:='Wszystkich: '+IntToStr(lv_ety_sel.Items.Count)+'    Zaznaczonych: '+IntToStr(a);
end;

// etykiety - dodaj zaznaczone
procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  i     : integer;
  l,ln  : TListItem;
begin
  for i:=0 to lv_ety_asort.Items.Count-1 do
  begin
    l:=lv_ety_asort.Items[i];
    if l.Checked then
    begin
      ln:=lv_ety_sel.Items.Add;
      ln.Checked:=l.Checked;
      ln.Caption:=l.Caption;
      ln.SubItems.Add(l.SubItems[0]);
      ln.SubItems.Add(l.SubItems[1]);
      ln.SubItems.Add(l.SubItems[2]);
      ln.SubItems.Add(l.SubItems[3]);
    end;
  end;
end;

// etykiety - kasuj zaznaczone
procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  i : integer;
  l : TListItem;
begin
  i:=0;
  while i < lv_ety_sel.Items.Count do
  begin
    l:=lv_ety_sel.Items[i];
    if l.Checked then
    begin
      lv_ety_sel.Items.Delete(i);
      i:=0;
    end
    else
      inc(i);
  end;
end;

// dodaj wszystkie
procedure TForm1.SpeedButton3Click(Sender: TObject);
var
  i     : integer;
  l,ln  : TListItem;
begin
  lv_ety_sel.BeginUpdate;
  lv_ety_sel.Clear;
  for i:=0 to lv_ety_asort.Items.Count-1 do
  begin
    l:=lv_ety_asort.Items[i];
    ln:=lv_ety_sel.Items.Add;
    ln.Checked:=l.Checked;
    ln.Caption:=l.Caption;
    ln.SubItems.Add(l.SubItems[0]);
    ln.SubItems.Add(l.SubItems[1]);
    ln.SubItems.Add(l.SubItems[2]);
    ln.SubItems.Add(l.SubItems[3]);
  end;
  lv_ety_sel.EndUpdate;
end;

// czyszczenie wszytkich etykiet
procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  lv_ety_sel.BeginUpdate;
  lv_ety_sel.Items.Clear;
  lv_ety_sel.EndUpdate;
end;

// zaznacz wszystko - etykiety
procedure TForm1.sb_ZaznaczWszystkoLClick(Sender: TObject);
var
  i : integer;
  l : TListView;
  b : string;
begin
  b:=TSpeedButton(Sender).Name;
  if b = 'sb_ZaznaczWszystkoL'
  then
    l:=lv_ety_asort
  else
    l:=lv_ety_sel;
  for i:=0 to l.Items.Count-1 do l.Items[i].Checked:=true;
end;

// odznacz wszystkie - etykiety
procedure TForm1.sb_OdznaczWszystkoLClick(Sender: TObject);
var
  i : integer;
  l : TListView;
  b : string;
begin
  b:=TSpeedButton(Sender).Name;
  if b = 'sb_OdznaczWszystkoL'
  then
    l:=lv_ety_asort
  else
    l:=lv_ety_sel;

  for i:=0 to l.Items.Count-1 do l.Items[i].Checked:=false;
end;

// odwróc zaznaczenie - etykiety
procedure TForm1.sb_OdwrocZaznaczenieLClick(Sender: TObject);
var
  i : integer;
  l : TListView;
  b : string;
begin
  b:=TSpeedButton(Sender).Name;
  if b = 'sb_OdwrocZaznaczenieL'
  then
    l:=lv_ety_asort
  else
    l:=lv_ety_sel;

  for i:=0 to l.Items.Count-1 do l.Items[i].Checked:=not l.Items[i].Checked;
end;

procedure TForm1.FillDataSet;
var
  dbg, i,j : integer;
  l        : TListItem;
begin
  if not memDS.Active then memDS.Active:=true;

  dbg:=memDS.DataSize;
  if memDS.DataSize <> 0 then memDS.Clear(false);
  dbg:=memDS.DataSize;

  for i:=0 to lv_ety_sel.Items.Count - 1 do
  begin
    l:=lv_ety_sel.Items[i];
    for j:=1 to se_ety_count.Value do
    begin
      memDS.Append;
      memDS.FieldByName('Nazwa').AsString:=l.Caption;
      memDS.FieldByName('JM').AsString:=l.SubItems[0];
      memDS.FieldByName('cena').AsFloat:=StrToFloat(l.SubItems[1]);
      memDS.FieldByName('ean').AsString:=l.SubItems[2];
      memDS.FieldByName('kg_L').AsFloat:=StrToFloat(l.SubItems[3]);
      memDS.Post;
    end;
  end;

  dbg:=memDS.DataSize;
end;

// zaznacz wszystko - nazwy
procedure TForm1.Button2Click(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to lv1.Items.Count-1 do lv1.Items[i].Checked:=true;
end;


procedure TForm1.Button10Click(Sender: TObject);
var
  buf:string;
begin
  if lv1.ItemIndex < 0 then exit;

  buf:=lv1.Items[lv1.ItemIndex].SubItems[1];
  if not InputQuery('Edycja nazwy "po"','Podaj nazwe',buf) then exit;
  lv1.Items[lv1.ItemIndex].SubItems[1]:=buf;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  if not  od2.Execute then exit;
  try
    lab_selected_ety.Caption:=ExtractFileName(od2.FileName);
    frReport1.LoadFromFile(od2.FileName);
  except
    ShowMessage('Nie udalo sie wczytac definicji etykiety: '+od2.FileName);
  end;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  FillDataSet;
  try
    frReport1.DesignReport;
  finally
  end;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  FillDataSet;
  try
    frReport1.ShowReport;
  finally
  end;
end;

// szukaj frazy w asortymencie
procedure TForm1.Button14Click(Sender: TObject);
var
  idx : integer;
  itm : TListItem;
  buf : string;
begin
  ed_ety_fraza.Text:=UTF8UpperCase(ed_ety_fraza.Text);
  buf:=ed_ety_fraza.Text;

  itm:=nil;
  for idx:=0 to lv_ety_asort.Items.Count - 1 do
  begin
    if (buf = UTF8UpperCase(lv_ety_asort.Items[idx].Caption)) or
       (pos(buf, UTF8UpperCase(lv_ety_asort.Items[idx].Caption)) <> 0)
       then
         begin
           itm:=lv_ety_asort.Items[idx];
           lv_ety_asort.ItemFocused:=itm;
           lv_ety_asort.ItemIndex:=itm.Index;
           lv_ety_asort.Selected:=itm;
           itm.MakeVisible(false);
           exit;
        end;
  end;
end;

procedure TForm1.Button15Click(Sender: TObject);
var
  sl : TStringList;
  i,j: integer;
  x  : string;
begin
  if Form3.ShowModal <> mrOK then exit;
  sl:=form3.GetAsortList;
  lv_ety_asort.BeginUpdate;

  for i:=0 to sl.Count - 1 do
  begin
    x:=IntToStr(Integer(sl.Objects[i]));
    for j:=0 to lv_ety_asort.Items.Count - 1 do
      if x = lv_ety_asort.Items[j].SubItems[4] then lv_ety_asort.Items[j].Checked:=true;
  end;
  lv_ety_asort.EndUpdate;
end;

// szukaj dalej
procedure TForm1.Button16Click(Sender: TObject);
var
  idx,x : integer;
  itm   : TListItem;
  buf   : string;
begin
  ed_ety_fraza.Text:=UpperCase(ed_ety_fraza.Text);
  buf:=ed_ety_fraza.Text;

  x:=lv_ety_asort.ItemIndex+1;
  if x > lv_ety_asort.Items.Count-1 then x:=0;
  itm:=nil;
  for idx:=x to lv_ety_asort.Items.Count - 1 do
    if pos(buf, UTF8UpperCase(lv_ety_asort.Items[idx].Caption)) <> 0
    then
      begin
        itm:=lv_ety_asort.Items[idx];
        lv_ety_asort.ItemFocused:=itm;
        lv_ety_asort.ItemIndex:=itm.Index;
        lv_ety_asort.Selected:=itm;
        itm.MakeVisible(false);
        exit;
      end;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
  if not PrinterSetupDialog1.Execute then exit;
  lab_selected_printer.Caption:=Printer.Printers[Printer.PrinterIndex];
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i,j : integer;
  sl: TStringList;
begin
  if form4.ShowModal <> mrOK then exit;
  sl:=form4.GetAsortList;

  lv_ety_asort.BeginUpdate;

  for i:=0 to sl.Count - 1 do
  begin
    for j:=0 to lv_ety_asort.Items.Count - 1 do
      if sl[i] = lv_ety_asort.Items[j].SubItems[4] then lv_ety_asort.Items[j].Checked:=true;
  end;
  lv_ety_asort.EndUpdate;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to lv1.Items.Count-1 do lv1.Items[i].Checked:=not lv1.Items[i].Checked;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to lv1.Items.Count-1 do lv1.Items[i].Checked:=false;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to lv1.Items.Count-1 do
    if lv1.Items[i].Checked then lv1.Items[i].SubItems[1]:=LowerCase(lv1.Items[i].SubItems[0]);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to lv1.Items.Count-1 do
    if lv1.Items[i].Checked then  lv1.Items[i].SubItems[1]:=UpperCase(lv1.Items[i].SubItems[0]);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  i   : integer;
  a,b : string;
  u   : boolean;
begin
  for i:=0 to lv1.Items.Count-1 do
    if lv1.Items[i].Checked then
    begin
      a:=LowerCase(lv1.Items[i].SubItems[0]);
      b:='';
      u:=true;
      while a <> '' do
      begin
        if u and (a[1] <> ' ') then
        begin
          b:=b+UpperCase(a[1]);
          u:=false;
        end
          else
            b:=b+a[1];

        delete(a,1,1);
        if (a <> '') and (a[1] = ' ') then u:=true;
      end;
      lv1.Items[i].SubItems[1]:=b;
    end;
end;

end.

