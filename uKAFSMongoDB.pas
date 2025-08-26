unit uKAFSMongoDB;

interface

uses
  System.Classes,
  FireDAC.Comp.Client, FireDAC.Phys.MongoDBWrapper;

  procedure InserirDados(const _conexao: TFDConnection; const _banco, _colecao: String; const _campos, _valores: array of String);
  //procedure EditarDados(const _banco, _colecao: String; const _camposfiltro, _valoresfiltro, _camposatualizar, _valoresatualizar: array of String);
  //function BuscarDados(const _banco, _colecao: String; const _campos, _valores: array of String): IMongoCursor;
  //function ValorCampo(const _json: String; _campo: String): String;
  //procedure Desconectar;

implementation

procedure InserirDados(const _conexao: TFDConnection; const _banco, _colecao: String; const _campos, _valores: array of String);
begin
  //
end;

end.
