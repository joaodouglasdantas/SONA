# Comecei o Projeto

```diff
+rails new SONA
# Poderia ter usado rails new SONA --database=postgresql mas queria fazer manualmente
```

---

## Adicionando gem do PostgreSQL

```diff
+gem 'pg'
# Adicionando no Gemfile
+bundle install
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
+ALTER ROLE sona CREATEDB;
# Dando permissões ao usuário

---

+GRANT ALL PRIVILEGES ON SCHEMA public TO sona;
# Esse comando dá ao usuário sona acesso total ao schema public, que é onde o Rails cria as tabelas por padrão
+ALTER USER sona WITH SUPERUSER;
# Um superuser é um usuário que tem todas as permissões dentro do PostgreSQL

---

- Conferir se funcionou

+\l
# Lista todos os bancos
+\du
# Lista todos os usuários
+\dn+
# Lista os schemas e mostra quem tem privilégios
+\q
# Sair
+psql -U sona -d sona_development
# Acessar bd com user sona
+\dt
# Isso lista as tabelas ( deve aparecer schema_migrations e ar_internal_metadata )

---

+rails db:create
+rails db:migrate
```

---

## Criando User

```diff
+rails g model User name email
+rails db:migrate
# Meu model ja cria a migration seguindo o padrao -> User / Users / CreateUsers

---

- Testando

+rails console
+User.create(name: "João", email: "joao@example.com")
+User.all

# O rails tem uma medida de segurança para evitar que dados sensíveis apareçam sem querer em logs ou saídas do console, rode pra ver os dados
+User.pluck(:name, :email)
```

---

## Gerando CRUD

```diff
+rails g scaffold User name email
+rails db:migrate
+rails server

---

- Vamos fazer da forma manual

+rails g controller Users
+resources :users
# Definir rota com CRUD completo em config/routes.rb

- Criar as views index, show, new e edit em app/views/users/

- Implementar as ações no UsersController

# index → lista todos os usuários.
# show → mostra um usuário específico.
# new → exibe o formulário para criar.
# create → salva o novo usuário no banco.
# edit → exibe o formulário para editar.
# update → aplica as alterações.
# destroy → apaga o usuário.

- Adicionar validações e regras de negócio no model User (app/models/user.rb)
```