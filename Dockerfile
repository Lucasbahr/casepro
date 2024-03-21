# Use a imagem Python oficial como base
FROM python:3.10

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Instalação do Node.js e npm
RUN apt-get update && apt-get install -y \
    nodejs \
    npm

# Copie o arquivo de dependências do Python para o diretório de trabalho
COPY requirements.txt .

# Instala as dependências de Python
RUN pip install -r requirements.txt

# Instala o Less globalmente
RUN npm install -g less

# Instala o Coffeescript globalmente
RUN npm install -g coffeescript

# Copia todos os arquivos do diretório atual para o diretório de trabalho no contêiner
COPY . .

# Copie o arquivo de configuração do Django para substituir o arquivo de configuração padrão
COPY ./casepro/settings.py.dev ./casepro/settings.py

# Expõe a porta 8000 para acessar a aplicação
EXPOSE 8000

# Comando para iniciar a aplicação
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
