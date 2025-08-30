unit uKAFSMongoDB;

interface

uses
  System.Classes, System.Generics.Collections, System.JSON, System.SysUtils,
  System.Variants,
  FireDAC.Phys.MongoDBWrapper;

  function InserirDados(const _banco, _colecao: String; const _dados: TJSONObject): TJSONObject;
  function EditarDados(const _banco, _colecao: String; const _filtro, _atualizacao: TJSONObject): TJSONObject;
  function BuscarDados(const _banco, _colecao: String; const _filtro: TJSONObject): TJSONObject;

implementation

uses
  uKAFSConexaoMongoDBAtlas;

function CriarRespostaSucesso: TJSONObject; overload;
begin
  Result := TJSONObject.Create;
  Result.AddPair('sucesso', TJSONBool.Create(True));
end;
function CriarRespostaSucesso(const _resultados: TJSONArray; const _count: Integer): TJSONObject; overload;
begin
  Result := TJSONObject.Create;
  with Result do
  begin
    AddPair('sucesso', TJSONBool.Create(True));
    AddPair('quantidade', TJSONNumber.Create(_count));
    AddPair('resultados', _resultados);
  end;
end;
function CriarRespostaErro(const _mensagem: String): TJSONObject;
begin
  Result := TJSONObject.Create;
  with Result do
  begin
    AddPair('sucesso', TJSONBool.Create(False));
    AddPair('erro', TJSONString.Create(_mensagem));
  end;
end;

function ValidarOperacao(const _banco, _colecao: String; const _json: TJSONObject): TJSONObject; overload;
begin
  // Validação de banco e coleção
  if Trim(_banco) = '' then
    Exit(CriarRespostaErro('Nome do banco não pode ser vazio'));

  if Trim(_colecao) = '' then
    Exit(CriarRespostaErro('Nome da coleção não pode ser vazio'));

  // Validação do JSON
  if not Assigned(_json) then
    Exit(CriarRespostaErro('JSON não pode ser nulo'));

  if _json.Count = 0 then
    Exit(CriarRespostaErro('Nenhum campo foi informado'));

  Result := CriarRespostaSucesso;
end;
function ValidarOperacao(const _banco, _colecao: String; const _filtro, _atualizacao: TJSONObject): TJSONObject; overload;
begin
  // Validação de banco e coleção
  if Trim(_banco) = '' then
    Exit(CriarRespostaErro('Nome do banco não pode ser vazio'));

  if Trim(_colecao) = '' then
    Exit(CriarRespostaErro('Nome da coleção não pode ser vazio'));

  // Validação do filtro
  if not Assigned(_filtro) then
    Exit(CriarRespostaErro('Filtro não pode ser nulo'));

  if _filtro.Count = 0 then
    Exit(CriarRespostaErro('Nenhum critério de filtro foi informado'));

  // Validação da atualização
  if not Assigned(_atualizacao) then
    Exit(CriarRespostaErro('Atualização não pode ser nula'));

  if _atualizacao.Count = 0 then
    Exit(CriarRespostaErro('Nenhum campo para atualização foi informado'));

  Result := CriarRespostaSucesso;
end;

function JSONValueToVariant(_valor: TJSONValue): Variant;
begin
  if _valor is TJSONNumber then
    Result := (_valor as TJSONNumber).AsDouble
  else if _valor is TJSONBool then
    Result := (_valor as TJSONBool).AsBoolean
  else if _valor is TJSONNull then
    Result := Null
  else if _valor is TJSONString then
    Result := _valor.Value
  else
    Result := _valor.Value; // Fallback para string
end;

function InserirDados(const _banco, _colecao: String; const _dados: TJSONObject): TJSONObject;
begin
  // Validação
  var validacao := ValidarOperacao(_banco, _colecao, _dados);
  try
    if not validacao.GetValue<Boolean>('sucesso') then
      Exit(validacao.Clone as TJSONObject);
  finally
    FreeAndNil(validacao);
  end;

  // Cria uma conexao
  var _conexao := TKAFSConexaoMongoDBAtlas.Create(nil);
  var _mongo := _conexao.MongoConnection;
  try
    try
      // Executa a inserção
      var _inserir := _mongo[_banco][_colecao].Insert();
      with _inserir.Values() do
      begin
        for var I := 0 to _dados.Count - 1 do
        begin
          var _par := _dados.Pairs[I];
          var _campo := _par.JsonString.Value;
          var _valor := JSONValueToVariant(_par.JsonValue);

          if Trim(_campo) = '' then
            Exit(CriarRespostaErro('Nome do campo não pode ser vazio'));

          Add(_campo, _valor);
        end;

        &End.Exec;
      end;

      Result := CriarRespostaSucesso;

    except
      on E: Exception do
        Result := CriarRespostaErro(E.Message);
    end;
  finally
    FreeAndNil(_conexao);
  end;
end;
function EditarDados(const _banco, _colecao: String; const _filtro, _atualizacao: TJSONObject): TJSONObject;
begin
  // Validação
  var validacao := ValidarOperacao(_banco, _colecao, _filtro, _atualizacao);
  try
    if not validacao.GetValue<Boolean>('sucesso') then
      Exit(validacao.Clone as TJSONObject);
  finally
    FreeAndNil(validacao);
  end;

  // Cria uma conexao
  var _conexao := TKAFSConexaoMongoDBAtlas.Create(nil);
  var _mongo := _conexao.MongoConnection;
  try
    try
      // Executa a busca
      var _editar := _mongo[_banco][_colecao].Update();
      with _editar.Match() do
      begin
        for var I := 0 to _filtro.Count - 1 do
        begin
          var _par := _filtro.Pairs[I];
          var _campo := _par.JsonString.Value;
          var _valor := JSONValueToVariant(_par.JsonValue);

          if Trim(_campo) = '' then
            Exit(CriarRespostaErro('Nome do campo de filtro não pode ser vazio'));

          Add(_campo, _valor);
        end;
        &End;
      end;

      // Executa a edição
      with _editar.Modify().&Set() do
      begin
        for var I := 0 to _atualizacao.Count - 1 do
        begin
          var _par := _atualizacao.Pairs[I];
          var _campo := _par.JsonString.Value;
          var _valor := JSONValueToVariant(_par.JsonValue);

          if Trim(_campo) = '' then
            Exit(CriarRespostaErro('Nome do campo de atualização não pode ser vazio'));

          Field(_campo, _valor);
        end;
        &End;
      end;

      // Executa ação
      _editar.Exec;

      Result := CriarRespostaSucesso;

    except
      on E: Exception do
        Result := CriarRespostaErro(E.Message);
    end;
  finally
    FreeAndNil(_conexao);
  end;
end;
function BuscarDados(const _banco, _colecao: String; const _filtro: TJSONObject): TJSONObject;
begin
  // Validação
  var validacao := ValidarOperacao(_banco, _colecao, _filtro);
  try
    if not validacao.GetValue<Boolean>('sucesso') then
      Exit(validacao.Clone as TJSONObject);
  finally
    FreeAndNil(validacao);
  end;

  var _conexao := TKAFSConexaoMongoDBAtlas.Create(nil);
  var _mongo := _conexao.MongoConnection;
  try
    try
      // Adiciona os critérios de filtro
      var _buscar := _mongo[_banco][_colecao].Find();
      with _buscar.Match() do
      begin
        for var I := 0 to _filtro.Count - 1 do
        begin
          var _par := _filtro.Pairs[I];
          var _campo := _par.JsonString.Value;
          var _valor := JSONValueToVariant(_par.JsonValue);
          Add(_campo, _valor);
        end;
        &End;
      end;

      // Processa os resultados
      var _cursor: IMongoCursor;
      var _resultadosArray := TJSONArray.Create;
      var count := 0;

      _cursor := _buscar;
      while _cursor.Next do
      begin
        var _doc := TJSONObject.ParseJSONValue(_cursor.Doc.AsJSON) as TJSONObject;
        if Assigned(_doc) then
        begin
          _resultadosArray.AddElement(_doc);
          Inc(count);
        end;
      end;

      Result := CriarRespostaSucesso(_resultadosArray, count);

    except
      on E: Exception do
        Result := CriarRespostaErro(E.Message);
    end;
  finally
    FreeAndNil(_conexao);
  end;
end;

end.
