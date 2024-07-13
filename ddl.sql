/* Projeto DW SEED */

/* DDL */
--database
create database seed

--schema
create schema dw

--table
-- Criação da tabela faturamento
CREATE TABLE seed.dw.faturamento (
    cnpjOrigemDados VARCHAR(20),
    id INT PRIMARY KEY,  -- Chave primária
    dataAtualizacao TIMESTAMP,
    idCliente VARCHAR(20),
    documentoCliente VARCHAR(20),
    numeroNotaFiscalFaturamento VARCHAR(20),
    serieNotaFiscalFaturamento VARCHAR(20),
    cfopFaturamento VARCHAR(10),
    dataEmissaoFaturamento DATE,
    statusNotaFiscalFaturamento VARCHAR(20),
    valorTotalProdutosFaturamento DOUBLE PRECISION,
    valorTotalNfFaturamento DOUBLE PRECISION,
    tipoFaturamento VARCHAR(20),
    FOREIGN KEY (idCliente) REFERENCES seed.dw.cliente(id)
);

-- Criação da tabela faturamento_item
CREATE TABLE seed.dw.faturamento_item (
    cnpjOrigemDados VARCHAR(20),
    id INT,  -- Este campo será a chave estrangeira
    dataAtualizacao TIMESTAMP,
    numero VARCHAR(20),
    serie VARCHAR(20),
    dataEmissao DATE,
    tipo INT,
    idNotaFiscalOrigem INT,
    notaFiscalOrigem VARCHAR(20),
    idItem VARCHAR(20),
    descricaoItem VARCHAR(100),
    skuItem VARCHAR(50),
    unidadeMedidaItem VARCHAR(20),
    loteItem VARCHAR(50),
    quantidadeItem DOUBLE PRECISION,
    valorUnitarioItem DOUBLE PRECISION,
    valorTotalItem DOUBLE PRECISION,
    cfopItem VARCHAR(10),
    cpfVendedor VARCHAR(20),
    valorUnidadeMedida VARCHAR(20),
    FOREIGN KEY (id) REFERENCES seed.dw.faturamento(id),
    FOREIGN KEY (idItem) REFERENCES seed.dw.produto(id)-- Chave estrangeira
);

-- Criação da tabela cliente
CREATE TABLE seed.dw.cliente (
    cnpjOrigemDados VARCHAR(254),
    dataAtualizacao TIMESTAMP,
    id VARCHAR PRIMARY KEY,
    nomeFantasia VARCHAR(254),
    documento VARCHAR(254),
    celular VARCHAR(254),
    telefoneFixo VARCHAR(254),
    email VARCHAR(254)
);

-- Criação da tabela produto
CREATE TABLE seed.dw.produto (
    cnpjOrigemDados VARCHAR(254),
    id VARCHAR PRIMARY KEY,
    dataAtualizacao TIMESTAMP,
    sku VARCHAR(254),
    descricao VARCHAR(254),
    branding VARCHAR(254),
    um VARCHAR(254),
    segmento VARCHAR(254),
    valorUnidadeMedida VARCHAR(254),
    fatorConversaoQuantidade VARCHAR(254)
);

-- Criação da tabela estoque
CREATE TABLE seed.dw.estoque (
    cnpjOrigemDados VARCHAR(254),
    id INT PRIMARY KEY,
    dataCadastro DATE,
    dataAtualizacao TIMESTAMP,
    idItem VARCHAR(254),
    descricao VARCHAR(254),
    quantidadeDisponivel DOUBLE precision,
    FOREIGN KEY (idItem) REFERENCES seed.dw.produto(id)
);
