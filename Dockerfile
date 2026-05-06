FROM ruby:3.2

# Instalando minhas dependências básicas
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Criando diretório da app
WORKDIR /app

# Copiar meu gemfile e instalar gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copiar todo o código
COPY . .

# Expor na porta padrão do Rails
EXPOSE 3000

# Comando padrão pelo visto
CMD ["bin/rails", "server", "-b", "0.0.0.0"]