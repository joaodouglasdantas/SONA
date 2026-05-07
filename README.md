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
# Meu model ja cria a migration seguindo o padrao → User / Users / CreateUsers

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

# index → lista todos os usuários
# show → mostra um usuário específico
# new → exibe o formulário para criar
# create → salva o novo usuário no banco
# edit → exibe o formulário para editar
# update → aplica as alterações
# destroy → apaga o usuário

- Adicionar validações e regras de negócio no model User (app/models/user.rb)
```

---

## Rodando o Projeto

```diff
+rails server
# Abrir em http://localhost:3000

+rails routes
# Confira as rotas do projeto
+rails routes | findstr users
# Rotas pra user
```

---

## Configurando Tela de Login

```diff
- Iremos deletar o user criado pra implementarmos o devise

+gem 'devise'
+bundle install
# Instalando minha gem pra login

+rails g devise:install
# Instalando devise no projeto

- Deletando o arquivo app/models/user.rb

- Deletando as migrations que criaram a tabela users

- Dropando a tabela com rails db:drop db:create

- Deletando o arquivo app/controllers/users_controller.rb

---

+rails g devise User
# Gerando user com devise
+rails g devise:views
# Gerando views do devise pra edição

- Como estamos recomeçando o sistema podemos apagar o schema do bd pra não dar BO

+rails db:migrate

+devise_scope :user do
+  root to: "devise/sessions#new"
+end
# Definindo minha home no arquivo config/routes.rb
```

---

## Criando Dash pro User Logado

```diff
+rails g controller Dashboard index

- Adicionando rotas com authenticated :user do no lugar do devise_scope

+before_action :authenticate_user!
# Adicionando callback de proteção de rota com autenticação no controller

---

+match "*path", to: "errors#routing", via: :all
# Adicionando rota pra rotas nao existentes, assim consigo exibir o erro de forma controlada

+rails g controller Errors routing
# Adicionando controller de erro de rotas

- Adicionando logica if/else no controller pra redirecionar o user
```

## Configurando Docker

```diff
- Editando meu Dockerfile

- Criando meu compose do Docker

- Alterando o usuario sona criado pelo padrao do pg

- Ajustando o db pra usar automaticamente as credenciais do .env

- Configurando bd pra rodar dentro e fora do docker

- Criando .env

+dotenv-rails
# Instalando a gem para rodar rails s fora do Docker

---

- Configurando o .gitattributes pra conversao dos arquivos windows/linux sem problema

+bundle exec rails app:update:bin
+#!/usr/bin/env ruby
# Alterando as definições ruby.exe do windows

+docker compose run web bundle install
# Rodando as gems no docker

+docker compose up --build
# Construindo o docker
+docker compose run web bin/rails db:create db:migrate
# Criando banco

---

- Isso garante que roda toda vez que o container sobe:

+bundle install
# Adicionando bundle no compose pra sempre subir as gems atualizadas
+bin/rails db:create db:migrate
# Adicionando comando do db no compose pra rodar automatico
```

## Gerando model de emoção

```diff
+rails g model Emotion user:references mood intensity:integer note:text recorded_at:date
+rails db:migrate
```