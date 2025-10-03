<div align="center">
<img width="188" height="200" alt="image" src="https://github.com/user-attachments/assets/60d8a531-d1b0-4282-a91c-0d24467ffd8b" /></div><p>

# <div align="center"><strong>uKAFSMongo</strong></div> 

<div align="center">
Biblioteca Delphi/FireMonkey que fornece operações de CRUD para MongoDB.<br> 
Possui opção de cooldown para regular a frequência das operações, permanecendo dentro dos limites dos planos do MongoDB Atlas.
</p>

[![Delphi](https://img.shields.io/badge/Delphi-12.3+-B22222?logo=delphi)](https://www.embarcadero.com/products/delphi)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb)](https://www.mongodb.com/atlas)
[![Multiplatform](https://img.shields.io/badge/Multiplatform-Windows/Linux-8250DF)]([https://www.embarcadero.com/products/delphi/cross-platform](https://docwiki.embarcadero.com/RADStudio/Athens/en/Developing_Multi-Device_Applications))
[![License](https://img.shields.io/badge/License-GPLv3-blue)](LICENSE)
</div><br>

## ⚠️ Dependências externas

Esta biblioteca utiliza a seguinte unit externa que deve ser adicionada ao projeto:
- 🧩 [TKAFSConexaoMongo](https://github.com/ViniciusdoAmaralReis/TKAFSConexaoMongo)

*Pode ser usado FDConnection manualmente configurado no lugar de [TKAFSConexaoMongo](https://github.com/ViniciusdoAmaralReis/TKAFSConexaoMongo), necessitando apenas de algumas modificações simples no código.
<div></div><br><br>


## ⚡ Chamada - Inserir dados
```pascal
procedure InserirDados(const _resfriamento: Integer; const _base, _colecao: String; const _dados: TJSONArray);
```
🏛️ Exemplo de chamada:
```pascal
var _dadosinserir := TJSONArray.Create;
var _novousuario: TJSONObject;
try
  // Primeiro documento
  _novousuario := TJSONObject.Create;
  _novousuario.AddPair('nome', 'João Silva');
  _novousuario.AddPair('email', 'joao@empresa.com');
  _novousuario.AddPair('data_nascimento', TJSONNumber.Create(831456000)); // Unix: 01/05/1996
  _novousuario.AddPair('departamento', 'TI');
  _novousuario.AddPair('salario', TJSONNumber.Create(4500.00));
  _novousuario.AddPair('ativo', TJSONBool.Create(True));
  _dadosinserir.AddElement(_novousuario);

  // Segundo documento
  _novousuario := TJSONObject.Create;
  _novousuario.AddPair('nome', 'Maria Santos');
  _novousuario.AddPair('email', 'maria@empresa.com');
  _novousuario.AddPair('data_nascimento', TJSONNumber.Create(713808000)); // Unix: 15/08/1992
  _novousuario.AddPair('departamento', 'TI');
  _novousuario.AddPair('salario', TJSONNumber.Create(5200.00));
  _novousuario.AddPair('ativo', TJSONBool.Create(True));
  _dadosinserir.AddElement(_novousuario);

  // Adicione quantos documentos forem necessários...

  // Executa inserção
  InserirDados(QUALQUER_VALOR_EM_MILISEGUNDOS, 'nome_base', 'nome_coleção', _dadosinserir);
  // Resfriamento 0 = Sem fila nem cooldown, executa em tempo real
  // Resfriamento QUALQUER_VALOR_EM_MILISEGUNDOS = Entra na fila e respeita-se o tempo de cooldown 

  ShowMessage('Dados inseridos com sucesso!');
finally
  FreeAndNil(_dadosinserir);
end;
```
<div></div><br><br>


## ⚡ Chamada - Editar dados
```pascal
procedure EditarDados(const _resfriamento: Integer; const _base, _colecao, _filtros: String; const _dados: TJSONArray);
```
🏛️ Exemplo de chamada:
```pascal
var _filtros := '{"$and": [{"departamento": "TI"}, {"data_nascimento": {"$lte": 788918400}}]}'; // Nascidos antes de 1995
var _dadosatualizar := TJSONArray.Create;
var _camposatualizar: TJSONObject;
try
  _camposAtualizar := TJSONObject.Create;
  _camposAtualizar.AddPair('salario', TJSONNumber.Create(5500.00));
  _camposAtualizar.AddPair('nivel', 'Sênior');
  _camposAtualizar.AddPair('ultima_promocao', FormatDateTime('yyyy-mm-dd', Now));
  _dadosatualizar.AddElement(_camposatualizar);

  // Adicione quantos documentos forem necessários...

  // Executa edição
  EditarDados(QUALQUER_VALOR_EM_MILISEGUNDOS, 'nome_base', 'nome_coleção', _filtros, _dadosatualizar);
  // Resfriamento 0 = Sem fila nem cooldown, executa em tempo real
  // Resfriamento QUALQUER_VALOR_EM_MILISEGUNDOS = Entra na fila e respeita-se o tempo de cooldown 

  ShowMessage('Dados editados com sucesso!');
finally
  FreeAndNil(_dadosatualizar);
end;
```
<div></div><br><br>


## ⚡ Chamada - Buscar dados
```pascal
function BuscarDados(const _resfriamento: Integer; const _base, _colecao, _filtros, _projecoes: String): TJSONArray;
```
🏛️ Exemplo de chamada:
```pascal
var _resultados: TJSONArray;
var _filtros := '{"departamento": "TI"}';
var _projecoes := '{"nome": 1, "email": 1, "data_nascimento": 1, "salario": 1, "nivel": 1, "_id": 0}';
var _dadosusuario: TJSONObject;
var _dataNasc: TDateTime;
try
  // Executa busca
  var _resultados := BuscarDados(QUALQUER_VALOR_EM_MILISEGUNDOS, 'nome_base', 'nome_coleção', _filtros, _projecoes);
  // Resfriamento 0 = Sem fila nem cooldown, executa em tempo real
  // Resfriamento QUALQUER_VALOR_EM_MILISEGUNDOS = Entra na fila e respeita-se o tempo de cooldown
    
  // Varre o resultado
  for var I := 0 to _resultados.Count - 1 do
  begin
    _dadosusuario := _resultados.Items[I] as TJSONObject;
      
    ShowMessage(Format('%s (%s) - Nascimento: %s - Salário: R$ %.2f - Nível: %s', 
      [_dadosusuario.GetValue('nome').Value,
       _dadosusuario.GetValue('email').Value,
       FormatDateTime('dd/mm/yyyy', UnixToDateTime(_dadosusuario.GetValue('data_nascimento').Value.ToInteger)),
       _dadosusuario.GetValue('salario').Value.ToDouble,
       _dadosusuario.GetValue('nivel', 'Não definido')]));
  end;
    
  ShowMessage(Format('Encontrados %d funcionários de TI', [_resultados.Count]));
finally
  FreeAndNil(_resultados);
end;
```
📜 Exemplo de resposta:
```json
[
  {
    "nome": "João Silva",
    "email": "joao@empresa.com",
    "data_nascimento": 831456000,
    "salario": 4500.00
  },
  {
    "nome": "Maria Santos",
    "email": "maria@empresa.com", 
    "data_nascimento": 713808000,
    "salario": 5500.00,
    "nivel": "Sênior"
  }
]
```
<div></div><br><br>

## ⚡ Método - Excluir dados
```pascal
procedure ExcluirDados(const _resfriamento: Integer; const _base, _colecao, _filtros: String);
```
🏛️ Exemplo de consumo no cliente:
```pascal
// Excluir usuários inativos OU com salário muito baixo
var _filtros := '{"$or": [{"ativo": false}, {"salario": {"$lt": 2000}}]}';
ExcluirDados(QUALQUER_VALOR_EM_MILISEGUNDOS,'nome_base', 'nome_coleção', _filtros);
// Resfriamento 0 = Sem fila nem cooldown, executa em tempo real
// Resfriamento QUALQUER_VALOR_EM_MILISEGUNDOS = Entra na fila e respeita-se o tempo de cooldown
```
*A exclusão é PERMANENTE. Sempre teste os filtros com BuscarDados antes de executar ExcluirDados!
<div></div><br><br>


---
**Nota**: Este componente é parte do ecossistema KAFS para integração com MongoDB. Requer configuração prévia do MongoDB Atlas através do componente [TKAFSConexaoMongo](https://github.com/ViniciusdoAmaralReis/TKAFSConexaoMongo) ou da configuração manual de um FDConnection e das credenciais apropriadas para funcionamento completo. Todos os filtros e projeções seguem o padrão do MongoDB. 
