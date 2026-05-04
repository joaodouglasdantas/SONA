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

```diff
+psql -U postgres
# Aqui eu entro como usuário postgres padrão

---

+CREATE DATABASE sona_development;
# Esses nomes precisam bater com o que está no database.yml
+CREATE DATABASE sona_test;

---

+CREATE USER sona WITH PASSWORD 'minhasenha';
# Criando um usuário específico para o projeto
+ALTER ROLE sona CREATEDB; # Dando permissões ao usuário

---

+GRANT ALL PRIVILEGES ON SCHEMA public TO sona;
# Esse comando dá ao usuário sona acesso total ao schema public, que é onde o Rails cria as tabelas por padrão
+ALTER USER sona WITH SUPERUSER;
# Um superuser é um usuário que tem todas as permissões dentro do PostgreSQL

- Conferir se funcionou

+\l
# lista todos os bancos
+\du
#lista todos os usuários
+\q
#sair

---

+rails db:create
+rails db:migrate
```

---