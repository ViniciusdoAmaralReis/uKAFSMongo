# 🧩 uKAFSMongoDB

Biblioteca Delphi/FireMonkey de operações CRUD com MongoDB Atlas através de interface JSON simplificada.

## ⚠️ Dependências externas

Esta biblioteca utiliza a seguinte unit externa que deve ser adicionada ao projeto:

- 🧩 [uKAFSConexaoMongoDBAtlas](https://github.com/ViniciusdoAmaralReis/uKAFSConexaoMongoDBAtlas)

## 💡 Chamada - Inserir dados
```pascal
function InserirDados(const _banco, _colecao: String;
  const _dados: TJSONObject): TJSONObject;
```

- Exemplo de resposta com sucesso:
```json
{"sucesso": true}
```

- Exemplo de resposta com erro:
```json
{"sucesso": false, "erro": "Mensagem do erro aqui"}
```

- Exemplo de chamada:
```pascal
var _dados := TJSONObject.Create;
var _resultado := TJSONObject.Create;
try
  // Preparar dados para inserção
  with _dados do
  begin
    AddPair('nome', TJSONString.Create('João'));
    AddPair('email', TJSONString.Create('joao@email.com'));
    AddPair('nivel', TJSONNumber.Create(1));
  end;

  // Executar inserção
  _resultado := InserirDados('meu_banco', 'minha_coleção', _dados);

  // Verificar resultado
  if not _resultado.GetValue<Boolean>('sucesso') then
    raise Exception.Create(_resultado.GetValue<string>('erro'));

  ShowMessage('Usuário inserido com sucesso!');
finally
  FreeAndNil(_resultado);
  FreeAndNil(_dados);
end;
```

## 💡 Chamada - Editar dados
```pascal
function EditarDados(const _banco, _colecao: String;
  const _filtros, _atualizacoes: TJSONObject): TJSONObject;
```

- Exemplo de resposta com sucesso:
```json
{"sucesso": true}
```

- Exemplo de resposta com erro:
```json
{"sucesso": false, "erro": "Mensagem do erro aqui"}
```

- Exemplo de chamada:
```pascal
var _filtros := TJSONObject.Create;
var _atualizacoes := TJSONObject.Create;
var _resultado := TJSONObject.Create;
try
  // Preparar filtros para edição
  with _filtros do
  begin
    AddPair('email', TJSONString.Create('joao@email.com'));
  end;

  // Preparar dados para atualização
  with _atualizacoes do
  begin
    AddPair('nivel', TJSONNumber.Create(2));
    AddPair('ultima_atualizacao', TJSONString.Create(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)));
  end;

  // Executar edição
  _resultado := EditarDados('meu_banco', 'minha_coleção', _filtros, _atualizacoes);

  // Verificar resultado
  if not _resultado.GetValue<Boolean>('sucesso') then
    raise Exception.Create(_resultado.GetValue<string>('erro'));

  ShowMessage('Usuário atualizado com sucesso!');
finally
  FreeAndNil(_resultado);
  FreeAndNil(_atualizacoes);
  FreeAndNil(_filtros);
end;
```

## 💡 Chamada - Buscar dados
```pascal
function BuscarDados(const _banco, _colecao: String;
  const _filtros: TJSONObject): TJSONObject;
```

- Exemplo de resposta com sucesso e com resultados:
```json
{
  "sucesso": true,
  "quantidade": 2,
  "resultados": [
    {
      "_id": "65a1b2c3d4e5f67890123456",
      "nome": "João",
      "email": "joao@email.com",
      "nivel": 1
    },
    {
      "_id": "65a1b2c3d4e5f67890123457",
      "nome": "Maria",
      "email": "maria@email.com",
      "nivel": 2
    }
  ]
}
```

- Exemplo de resposta com sucesso e sem resultado:
```json
{
  "sucesso": true,
  "quantidade": 0,
  "resultados": []
}
```

- Exemplo de resposta com erro:
```json
{"sucesso": false, "erro": "Mensagem do erro aqui"}
```

- Exemplo de chamada:
```pascal
var _filtros := TJSONObject.Create;
var _resultado := TJSONObject.Create;
try
  // Preparar filtro para busca
  _filtros := TJSONObject.Create;
  with _filtros do
  begin
    AddPair('email', TJSONString.Create('joao@email.com'));
  end;

  // Executar busca
  _resultado := BuscarDados('meu_banco', 'minha_coleção', _filtros);

  // Verificar resultado
  if not _resultado.GetValue<Boolean>('sucesso') then
    raise Exception.Create(_resultado.GetValue<string>('erro'));

  // Processar resultados
  var _quantidade := _resultado.GetValue<Integer>('quantidade');
  var _usuarios := _resultado.GetValue<TJSONArray>('resultados');

  ShowMessage(Format('%d usuário(s) encontrado(s)', [_quantidade]));
finally
  FreeAndNil(_resultado);
  FreeAndNil(_filtros);
end;
```

## 🏛️ Status de compatibilidade

| Sistema operacional | Status FireDAC MongoDB | Observações |
|---------------------|------------------------|-------------|
| **Windows** | ✅ **Totalmente Compatível** | Funcionamento completo com todos os recursos |
| **Linux** | ❌ **Não Suportado** | Limitação técnica do driver FireDAC |

| IDE | Versão mínima | Observações |
|---------------------|------------------------|-------------|
| **Delphi** | ✅ **10.4+** | Suporte a FireDAC e JSON nativo |

---

**Nota**: Este componente é parte do ecossistema KAFS para integração com MongoDB. Requer configuração prévia do MongoDB Atlas através do componente `uKAFSConexaoMongoDBAtlas` e das credenciais apropriadas para funcionamento completo. Todas as operações retornam respostas em formato JSON padronizado para fácil integração com interfaces de usuário.
