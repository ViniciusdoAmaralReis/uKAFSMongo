unit uKAFSMongoDB;

interface

uses
  System.Classes, System.Generics.Collections, System.JSON, System.SysUtils,
  FireDAC.Phys.MongoDBWrapper;

type
  TResultado = record
    Ok: Boolean;
    Erro: string;

    class function Sucesso: TResultado; static;
    class function Falha(const _erro: String): TResultado; static;
  end;

  function ValidarOperacao(const _banco, _colecao: String; const _campos1, _valores1, _campos2, _valores2: array of String): TResultado;

  function InserirDados(const _banco, _colecao: String; const _campos, _valores: array of String): TResultado;
  function EditarDados(const _banco, _colecao: String; const _camposfiltro, _valoresfiltro, _camposatualizar, _valoresatualizar: array of String): TResultado;
  function BuscarDados(const _banco, _colecao: String; const _campos, _valores: array of String): TJSONArray;

implementation

uses
  uKAFSConexaoMongoDBAtlas;

class function TResultado.Sucesso: TResultado;
begin
  with Result do
  begin
    Ok := True;
    Erro := '';
  end;
end;
class function TResultado.Falha(const _erro: String): TResultado;
begin
  with Result do
  begin
    Ok := False;
    Erro := _erro;
  end;
end;

function ValidarOperacao(const _banco, _colecao: String; const _campos1, _valores1, _campos2, _valores2: array of String): TResultado;
begin
  // Validação de banco e coleção
  if Trim(_banco) = '' then
    Exit(TResultado.Falha('Nome do banco não pode ser vazio'));

  if Trim(_colecao) = '' then
    Exit(TResultado.Falha('Nome da coleção não pode ser vazio'));

  // Validação do primeiro array (obrigatório)
  if Length(_campos1) <> Length(_valores1) then
    Exit(TResultado.Falha('Quantidade de campos e valores não corresponde'));

  if Length(_campos1) = 0 then
    Exit(TResultado.Falha('Nenhum campo foi informado'));

  // Validação do segundo array (opcional - apenas se não estiver vazio)
  if (Length(_campos2) > 0) or (Length(_valores2) > 0) then
  begin
    if Length(_campos2) <> Length(_valores2) then
      Exit(TResultado.Falha('Quantidade de campos e valores não corresponde'));

    if Length(_campos2) = 0 then
      Exit(TResultado.Falha('Nenhum campo foi informado'));
  end;

  Result := TResultado.Sucesso;
end;

function InserirDados(const _banco, _colecao: String; const _campos, _valores: array of String): TResultado;
begin
  // Validação
  Result := ValidarOperacao(_banco, _colecao, _campos, _valores, [], []);
  if not Result.Ok then
    Exit;

  // Cria uma conexao
  var _conexao := TKAFSConexaoMongoDBAtlas.Create(nil);
  var _mongo := _conexao.MongoConnection;
  try
    try
      // Executa a inserção
      with _mongo[_banco][_colecao].Insert().Values() do
      begin
        for var I := Low(_campos) to High(_campos) do
        begin
          // Validação de campo vazio
          if Trim(_campos[I]) = '' then
            Exit(TResultado.Falha('Nome do campo não pode ser vazio'));

          Add(_campos[I], _valores[I]);
        end;

        &End.Exec;
      end;

      // Retorno de sucesso
      Result := TResultado.Sucesso;

    except
      on E: Exception do
        // Retorno de erro com mensagem da exceção
        Result := TResultado.Falha('Erro ao inserir dados: ' + E.Message);
    end;
  finally
    FreeAndNil(_conexao);
  end;
end;
function EditarDados(const _banco, _colecao: String; const _camposfiltro, _valoresfiltro, _camposatualizar, _valoresatualizar: array of String): TResultado;
begin
  // Validação
  Result := ValidarOperacao(_banco, _colecao, _camposfiltro, _valoresfiltro, _camposatualizar, _valoresatualizar);
  if not Result.Ok then
    Exit;

  // Cria uma conexao
  var _conexao := TKAFSConexaoMongoDBAtlas.Create(nil);
  var _mongo := _conexao.MongoConnection;
  try
    try
      // Cria o comando de atualização
      var _comando := _mongo[_banco][_colecao].Update();

      // Adiciona os critérios de filtro (Match)
      with _comando.Match() do
      begin
        for var I := Low(_camposfiltro) to High(_camposfiltro) do
        begin
          // Validação de campo de filtro vazio
          if Trim(_camposfiltro[I]) = '' then
            Exit(TResultado.Falha('Nome do campo de filtro não pode ser vazio'));

          Add(_camposfiltro[I], _valoresfiltro[I]);
        end;
        &End;
      end;

      // Adiciona os campos para atualização (Modify/Set)
      with _comando.Modify().&Set() do
      begin
        for var I := Low(_camposatualizar) to High(_camposatualizar) do
        begin
          // Validação de campo de atualização vazio
          if Trim(_camposatualizar[I]) = '' then
            Exit(TResultado.Falha('Nome do campo de atualização não pode ser vazio'));

          Field(_camposatualizar[I], _valoresatualizar[I]);
        end;
        &End;
      end;

      // Executa o comando
      _comando.Exec;

      // Retorno de sucesso
      Result := TResultado.Sucesso;

    except
      on E: Exception do
        // Retorno de erro com mensagem da exceção
        Result := TResultado.Falha('Erro ao editar dados: ' + E.Message);
    end;
  finally
    FreeAndNil(_conexao);
  end;
end;
function BuscarDados(const _banco, _colecao: String; const _campos, _valores: array of String): TJSONArray;
begin
  // Validação
  var _validacao := ValidarOperacao(_banco, _colecao, _campos, _valores, [], []);
  if not _validacao.Ok then
    raise Exception.Create(_validacao.Erro);

  var _conexao := TKAFSConexaoMongoDBAtlas.Create(nil);
  var _mongo := _conexao.MongoConnection;
  Result := TJSONArray.Create;
  try
    try
      //cria o comando de atualização
      var _comando := _mongo[_banco][_colecao].Find();

      with _comando.Match() do
      begin
        for var I := Low(_campos) to High(_campos) do
          Add(_campos[I], _valores[I]);

        &End;
      end;

      // Processa os resultados
      var _cursor: IMongoCursor; // Necessário especificar
      var _doc: TJSONObject;

      _cursor := _comando;
      while _cursor.Next do
      begin
        _doc := TJSONObject.ParseJSONValue(_cursor.Doc.AsJSON) as TJSONObject;
        if Assigned(_doc) then
          Result.AddElement(_doc);
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    FreeAndNil(_conexao);
  end;
end;

end.
