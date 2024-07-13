# Importando as bibliotecas necessárias
import psycopg2
import pandas as pd
from datetime import datetime
import time

# Lendo o arquivo com as credenciais de acesso
credentials = pd.read_csv('C:/Projetos/Seed/credentials.csv')

# Testando conexão com o Banco de Dados
try:
    conn = psycopg2.connect(
        host=credentials['host'][0],
        port=credentials['port'][0],
        dbname=credentials['dbname'][0],
        user=credentials['user'][0],
        password=credentials['password'][0]
    )
    print("Conexão bem-sucedida!")
    
except Exception as e:
    print("Erro ao conectar:", e)
    conn = None

# Criando consulta para tabela a ser lida
if conn:

    cur = conn.cursor()

try:
        try:
            cur.execute('CALL dw.atualiza_cliente()')
            print("Procedure 'atualiza_cliente' executada com sucesso!")
            time.sleep(10)
        except Exception as e:
            print("Erro ao executar 'atualiza_cliente':", e)

        try:
            cur.execute('CALL dw.atualiza_produto()')
            print("Procedure 'atualiza_produto' executada com sucesso!")
            time.sleep(10)
        except Exception as e:
            print("Erro ao executar 'atualiza_produto':", e)

        try:
            cur.execute('CALL dw.atualiza_faturamento()')
            print("Procedure 'atualiza_faturamento' executada com sucesso!")
            time.sleep(10)
        except Exception as e:
            print("Erro ao executar 'atualiza_faturamento':", e)

        try:
            cur.execute('CALL dw.atualiza_faturamento_item()')
            print("Procedure 'atualiza_faturamento_item' executada com sucesso!")
            time.sleep(10)
        except Exception as e:
            print("Erro ao executar 'atualiza_faturamento_item':", e)

        try:
            cur.execute('CALL dw.atualiza_estoque()')
            print("Procedure 'atualiza_estoque' executada com sucesso!")
            time.sleep(10)
        except Exception as e:
            print("Erro ao executar 'atualiza_estoque':", e)

        conn.commit()
        time.sleep(10)
        print("Stored procedures executadas com sucesso!")
except Exception as e:
    print("Erro ao executar stored procedures:", e)
            
    cur.close()

print('DW Seed Atualizado!')
