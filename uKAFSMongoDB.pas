unit uKAFSMongoDB;

interface

uses
  System.Classes,
  FireDAC.Phys.MongoDBWrapper;

type
  TKAFSMongoDB = class

    constructor Create; reintroduce;
    //procedure InserirDados(const _banco, _colecao: String; const _campos, _valores: array of String);
    //procedure EditarDados(const _banco, _colecao: String; const _camposfiltro, _valoresfiltro, _camposatualizar, _valoresatualizar: array of String);
    //function BuscarDados(const _banco, _colecao: String; const _campos, _valores: array of String): IMongoCursor;
    //function ValorCampo(const _json: String; _campo: String): String;
    //procedure Desconectar;
    destructor Destroy; override;
  end;

implementation

constructor TKAFSMongoDB.Create;
begin
  inherited Create;

end;

destructor TKAFSMongoDB.Destroy;
begin

  inherited Destroy;
end;


end.
