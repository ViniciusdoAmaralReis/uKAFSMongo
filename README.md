# 🧩 uKAFSMongoDB

Componente Delphi/FireMonkey para operações CRUD com MongoDB Atlas através de interface JSON simplificada.

## ⚠️ Dependências externas

Este componente utiliza a seguinte unit externa que deve ser adicionada ao projeto:

- 🧩 [uKAFSConexaoMongoDBAtlas](https://github.com/ViniciusdoAmaralReis/uKAFSConexaoMongoDBAtlas)

## 💡 Instanciação básica

```pascal
// Inserir documento
var dados := TJSONObject.Create;
dados.AddPair('nome', TJSONString.Create('João Silva'));
dados.AddPair('email', TJSONString.Create('joao@email.com'));
dados.AddPair('idade', TJSONNumber.Create(30));

var resultado := InserirDados('meubanco', 'usuarios', dados);
```

```pascal
// Buscar documentos
var filtro := TJSONObject.Create;
filtro.AddPair('idade', TJSONNumber.Create(30));

var resultado := BuscarDados('meubanco', 'usuarios', filtro);
```

```pascal
// Editar documento
var filtro := TJSONObject.Create;
filtro.AddPair('email', TJSONString.Create('joao@email.com'));

var atualizacao := TJSONObject.Create;
atualizacao.AddPair('idade', TJSONNumber.Create(31));

var resultado := EditarDados('meubanco', 'usuarios', filtro, atualizacao);
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
