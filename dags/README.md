# DAGs

# Tabela de Conteúdo

- [Tabela de Conteúdo](#tabela-de-conteúdo)
- [Sobre](#sobre)
- [Como usar](#como-usar)
- [Executando teste das DAGs](#executando-teste-das-dags)
- [Estrutura da pasta](#estrutura-da-pasta)

# Sobre

Este diretório contém os arquivos de DAGs utilizados para executar processos deste repositório. Esta pasta não possui arquivos ou diretórios que compõem DAGs específicos, em vez disso, ela serve como um diretório para adicionar DAGs personalizados, se necessário, para a aplicação.

# Como usar

Para adicionar um DAG personalizado, crie um novo arquivo Python na pasta dags com o código da sua DAG.

Certifique-se de que a sua DAG siga as boas práticas de programação e design do Apache Airflow.

Este repositório não contém dados de exemplo para serem utilizados no processo de ETL. É necessário fornecer seus próprios dados e ajustar o código-fonte de acordo com suas necessidades.

# Executando teste das DAGs

Para executar os testes das DAGs, basta adicionar os arquivos ao diretório **[tests](/dags/tests/)** do projeto e iniciar o teste. As DAGs serão testadas e um relatorio será exibido, mostrando as informações do teste.

# Estrutura da pasta

```bash
.
├── conftest.py
├── dags
├── .flake8
├── mypy.ini
├── pytest.ini
├── README.md
├── requirements.txt
├── setup.py
└── tests

2 directories, 7 files
```

- **[dags:](/dags/dags/)** Pasta com os arquivos de DAGs utilizados no projeto.
- **[conftest.py:](/dags/conftest.py)** Arquivo de configuração do Pytest.
- **[.flake8:](/dags/.flake8)** Arquivo de configuração do flake8.
- **[mypy.ini:](/dags/mypy.ini)** Arquivo de configuração do MyPy.
- **[pytest.ini:](/dags/pytest.ini)** Arquivo de configuração do Pytest.
- **[README.md:](/dags/README.md)** Este arquivo README com informações sobre o diretorio **[dags](/dags/)**.
- **[requirements.txt:](/dags/requirements.txt)** Arquivo com as dependências necessárias para executar os testes das DAGs.
- **[setup.py:](/dags/setup.py)** Arquivo de configuração para empacotar o projeto de testes em um pacote Python.
- **[tests:](/dags/tests/)** Pasta com os arquivos de testes das DAGs.