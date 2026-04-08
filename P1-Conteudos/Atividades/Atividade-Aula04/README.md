# Atividade Aula 04 – BDR

Implementação do schema de banco de dados para um sistema de eventos com alertas.

## Tabelas
- **CategoriaUsuario**: idCategoria, nome, nivel_acesso, descricao
- **Usuario**: idUsuario, nome, email, senhaHash, idCategoria (FK)
- **Localizacao**: idLocalizacao, latitude, longitude, cidade, estado
- **TipoEvento**: idTipoEvento, nome, descricao
- **Evento**: idEvento, titulo, descricao, dataHora, status, idTipoEvento (FK), idLocalizacao (FK)
- **Relato**: idRelato, texto, dataHora, idEvento (FK), idUsuario (FK)
- **Alerta**: idAlerta, mensagem, dataHora, nivel, idEvento (FK)

## Ferramenta utilizada
pgAdmin 4
