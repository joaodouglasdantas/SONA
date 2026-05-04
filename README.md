# Comecei o projeto

```
rails new SONA
```

---

## Adicionando gem do PostgreSQL

```
gem 'pg' # Adicionando no Gemfile
bundle install
```

---

## Criando BD

```
psql -U postgres # Aqui eu entro como usuário postgres padrão

CREATE DATABASE sona_development; # Esses nomes precisam bater com o que está no database.yml
CREATE DATABASE sona_test;

CREATE USER sona WITH PASSWORD 'minhasenha'; # Criando um usuário específico para o projeto
ALTER ROLE sona CREATEDB; # Dando permissões ao usuário

# Conferir se funcionou

\l   -- lista todos os bancos
\du  -- lista todos os usuários
\q   -- sair

rails db:create
rails db:migrate
```

---