unit uKAFSMongoDB;

interface

uses
  System.Generics.Collections, System.JSON, System.SyncObjs, System.SysUtils,
  System.Variants,
  FireDAC.Phys.MongoDBWrapper;

  procedure InserirDados(const _resfriamento: Integer; const _base, _colecao: String; const _dados: TJSONArray);
  procedure EditarDados(const _resfriamento: Integer; const _base, _colecao, _filtros: String; const _dados: TJSONArray);
  function BuscarDados(const _resfriamento: Integer; const _base, _colecao, _filtros, _projecoes: String): TJSONArray;
  procedure ExcluirDados(const _resfriamento: Integer; const _base, _colecao, _filtros: String);

var
  _fila: TCriticalSection = nil;

implementation

uses
  uKAFSConexaoMongo;

function Fila: TCriticalSection;
begin
  if not Assigned(_fila) then
    _fila := TCriticalSection.Create;
  Result := _fila;
end;

function JSONValueParaVariant(const _valor: TJSONValue): Variant;
begin
  if _valor is TJSONNumber then
  begin
    var _int64: Int64;
    var _integer: Integer;
    var _double: Double;
    var _numero := TJSONNumber(_valor);

    if TryStrToInt64(_numero.Value, _int64) then
    begin
      if (_int64 >= Low(Integer)) and (_int64 <= High(Integer)) then
        Result := Integer(_int64)
      else
        Result := _int64;
    end
    else if TryStrToFloat(_numero.Value, _double, TFormatSettings.Invariant) then
      Result := _double
    else
      Result := _numero.Value;
  end
  else if _valor is TJSONBool then
    Result := TJSONBool(_valor).AsBoolean
  else if _valor is TJSONString then
    Result := TJSONString(_valor).Value
  else if _valor is TJSONNull then
    Result := Null
  else
    Result := _valor.ToJSON;
end;

procedure InserirDados(const _resfriamento: Integer; const _base, _colecao: String; const _dados: TJSONArray);
  procedure Executar(const _base, _colecao: String; const _dados: TJSONArray);
  begin
    var _conexao := TKAFSConexaoMongo.Create(nil);
    var _mongo := _conexao.MongoConnection;
    try
      // Varre array
      for var I := 0 to _dados.Count - 1 do
      begin
        var _docdados := _dados.Items[I] as TJSONObject;

        // Cria a insert
        var _inserir := _mongo[_base][_colecao].Insert();

        // Varre object
        for var J := 0 to _docdados.Count - 1 do
        begin
          var _campo := _docdados.Pairs[J].JsonString.Value;
          var _valor := _docdados.Pairs[J].JsonValue;

          // Adiciona cada valor
          _inserir.Values().Add(_campo, JSONValueParaVariant(_valor));
        end;

        // Executa
        _inserir.Values().&End.Exec;
      end;
    finally
      FreeAndNil(_conexao);
    end;
  end;
begin
  if _resfriamento < 1 then
    Executar(_base, _colecao, _dados)
  else
  begin
    Fila.Enter;
    try
      Sleep(_resfriamento);
      Executar(_base, _colecao, _dados);
    finally
      Fila.Leave;
    end;
  end;
end;
procedure EditarDados(const _resfriamento: Integer; const _base, _colecao, _filtros: String; const _dados: TJSONArray);
  procedure Executar(const _base, _colecao, _filtros: String; const _dados: TJSONArray);
  begin
    var _conexao := TKAFSConexaoMongo.Create(nil);
    var _mongo := _conexao.MongoConnection;
    // Monta o documento de atualização
    var _setDoc := TJSONObject.Create;
    try
      // Varre o array
      for var I := 0 to _dados.Count - 1 do
      begin
        var _docdados := _dados.Items[I] as TJSONObject;

        // Varre object
        for var J := 0 to _docdados.Count - 1 do
        begin
          var _campo := _docdados.Pairs[J].JsonString.Value;
          var _valor := _docdados.Pairs[J].JsonValue.Clone as TJSONValue;

          // Adiciona cada valor
          _setDoc.AddPair(_campo, _valor);
        end;
      end;

      // Cria o doc
      var _updateDoc := TJSONObject.Create;
      try
        _updateDoc.AddPair('$set', _setDoc);

        // Cria o update
        var upd := _mongo[_base][_colecao].Update([TMongoCollection.TUpdateFlag.MultiUpdate]);

        // Define filtro e modificador
        upd.Match(_filtros);
        upd.Modify(_updateDoc.ToJSON);

        // Executa
        upd.Exec;
      finally
        FreeAndNil(_updateDoc);
      end;
    finally
      FreeAndNil(_conexao);
    end;
  end;
begin
  if _resfriamento < 1 then
    Executar(_base, _colecao, _filtros, _dados)
  else
  begin
    Fila.Enter;
    try
      Sleep(_resfriamento);
      Executar(_base, _colecao, _filtros, _dados);
    finally
      Fila.Leave;
    end;
  end;
end;
function BuscarDados(const _resfriamento: Integer; const _base, _colecao, _filtros, _projecoes: String): TJSONArray;
  function Executar(const _base, _colecao, _filtros, _projecoes: String): TJSONArray;
  begin
    Result := TJSONArray.Create;

    var _conexao := TKAFSConexaoMongo.Create(nil);
    var _mongo := _conexao.MongoConnection;
    try
      // Cria a consulta
      var _qry := _mongo[_base][_colecao].Find;

      // Aplica o filtro
      if _filtros <> '' then
        _qry.Match(_filtros);

      // Aplica a projeção
      if _projecoes <> '' then
        _qry.Project(_projecoes);

      // Executa
      var cursor := _qry.Open;

      // Itera sobre os resultados
      while cursor.Next do
      begin
        var _JsonStr := cursor.Doc.AsJSON;
        var _json := TJSONObject.ParseJSONValue(_JsonStr, False) as TJSONObject;

        if Assigned(_json) then
          Result.AddElement(_json);
      end;

    finally
      FreeAndNil(_conexao);
    end;
  end;
begin
  if _resfriamento < 1 then
    Result := Executar(_base, _colecao, _filtros, _projecoes)
  else
  begin
    Fila.Enter;
    try
      Sleep(_resfriamento);
      Result := Executar(_base, _colecao, _filtros, _projecoes);
    finally
      Fila.Leave;
    end;
  end;
end;
procedure ExcluirDados(const _resfriamento: Integer; const _base, _colecao, _filtros: String);
  procedure Executar(const _base, _colecao, _filtros: String);
  begin
    var _conexao := TKAFSConexaoMongo.Create(nil);
    var _mongo := _conexao.MongoConnection;
    try
      // Obtém o seletor de remoção já vinculado à coleção
      var sel := _mongo[_base][_colecao].Remove([]);

      // Aplica o filtro
      sel.Match(_filtros);

      // Executa a remoção
      sel.Exec;
    finally
      FreeAndNil(_conexao);
    end;
  end;
begin
  if _resfriamento < 1 then
    Executar(_base, _colecao, _filtros)
  else
  begin
    Fila.Enter;
    try
      Sleep(_resfriamento);
      Executar(_base, _colecao, _filtros);
    finally
      Fila.Leave;
    end;
  end;
end;

initialization
  _fila := TCriticalSection.Create;
finalization
  FreeAndNil(_fila);

end.
