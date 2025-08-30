# 🧩 uKAFSMongoDB

Biblioteca Delphi/FireMonkey de operações CRUD com MongoDB Atlas através de interface JSON simplificada.

## ⚠️ Dependências externas

Esta unit utiliza a seguinte unit externa que deve ser adicionada ao projeto:

- 🧩 [uKAFSConexaoMongoDBAtlas](https://github.com/ViniciusdoAmaralReis/uKAFSConexaoMongoDBAtlas)

## 💡 Inserir dados
```pascal
var _dados := TJSONObject.Create;
with _dados do
begin
  AddPair('nome', TJSONString.Create('João Silva'));
  AddPair('email', TJSONString.Create('joao@email.com'));
  AddPair('idade', TJSONNumber.Create(30));
end;

var resultado := InserirDados('meu_banco', 'minha_coleção', _dados);
```
## 💡 Editar dados
```pascal
var _filtros := TJSONObject.Create;
_filtros.AddPair('email', TJSONString.Create('joao@email.com'));

var _atualizacoes := TJSONObject.Create;
_atualizacoes.AddPair('idade', TJSONNumber.Create(31));

var _resultado := EditarDados('meu_banco', 'minha_coleção', _filtros, _atualizacoes);
```
## 💡 Buscar dados
```pascal
var _filtros := TJSONObject.Create;
_filtros.AddPair('idade', TJSONNumber.Create(30));

var resultado := BuscarDados('meu_banco', 'minha_coleção', _filtros);
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
