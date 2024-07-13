/* Projeto DW seed */

/* Procs */

call seed.dw.atualiza_cliente();

call seed.dw.atualiza_produto();

call seed.dw.atualiza_faturamento();

call seed.dw.atualiza_faturamento_item();

call seed.dw.atualiza_estoque();

--cliente
CREATE OR REPLACE PROCEDURE seed.dw.atualiza_cliente()
	LANGUAGE plpgsql
AS $$



declare



begin
	
	delete from seed.dw.cliente where 1=1;

	insert into seed.dw.cliente
	with tb_cliente_init as (
	select	cargatimestamp as dataAtualizacao,
		clientecodigo as id,
		clientedescricao as nomeFantasia,
		clientecpfcnpj as documento,
		clientecelular as celular,
		clientetelefone as telefoneFixo,
		clienteemail as email
	from data_raw."1250".cliente
	where clientecodigo is not null
	), tb_cnpj as (
		select cnpj as cnpjOrigemDados
		from standard.dist
		where cod = '1250'
	)
	select
		tc.cnpjOrigemDados,
		tci.dataAtualizacao,
		tci.id,
		tci.nomeFantasia,
		tci.documento,
		tci.celular,
		tci.telefoneFixo,
		tci.email
	from tb_cliente_init tci
	cross join tb_cnpj tc;


end;






$$
;
	
--produto
CREATE OR REPLACE PROCEDURE seed.dw.atualiza_produto()
	LANGUAGE plpgsql
AS $$



declare



begin
	
	delete from seed.dw.produto where 1=1;

	insert into seed.dw.produto
	with tb_produto_init as (
	select  produtocodigo as id,
		p.cargatimestamp as dataAtualizacao,
		cast(null as varchar(254)) as sku,
		produtodescricao as descricao,
		fabricantedescricao as branding,
		case 
			when produtodescricao like '%LT%'
				then 'LT'
			when produtodescricao like '%KG%'
				then 'KG'
			when produtodescricao like '% L%'
				then 'LT'
			else produtounidademedida
		end as um,
		produtosubgrupo as segmento,
		REGEXP_SUBSTR(REGEXP_SUBSTR(produtodescricao, '[(](.*)[)]'), '[0-9]+') as valorUnidadeMedida,
		produtofatorconversao as fatorConversaoQuantidade
	from data_raw."1250".produto as p
	inner join data_raw."1250".fabricante as ff
	on
		ff.fabricantecodigo = p.produtofabricante
	where   (fabricantedescricao like '%manufacturer1%' or
		fabricantedescricao like '%manufacturer2%' or
	    	fabricantedescricao like '%manufacturer3%') and
	    	produtocodigo is not null
	), tb_cnpj as (
		select cnpj as cnpjOrigemDados
		from standard.dist
		where cod = '1250'
	)
	select
		tc.cnpjOrigemDados,
		tpi.id,
		tpi.dataAtualizacao,
		tpi.sku,
		tpi.descricao,
		tpi.branding,
		tpi.um,
		tpi.segmento,
		tpi.valorUnidadeMedida,
		tpi.fatorConversaoQuantidade
	from tb_produto_init tpi
	cross join tb_cnpj tc;


end;






$$
;

--faturamento
CREATE OR REPLACE PROCEDURE seed.dw.atualiza_faturamento()
	LANGUAGE plpgsql
AS $$



declare



begin
	
	delete from seed.dw.faturamento where 1=1;

	insert into seed.dw.faturamento
	with tb_faturamento_init as (
	select	row_number() over (order by faturamentonumeronf) as id,
		f.cargatimestamp as dataAtualizacao,
		faturamentocliente as idCliente,
		--documento do cliente tem que fazer relacionamento
		faturamentonumeronf as numeroNotaFiscalFaturamento,
		faturamentoserienf as serieNotaFiscalFaturamento,
		faturamentocfop as cfopFaturamento,
		cast(faturamentodata as date) as dataEmissaoFaturamento,
		faturamentocancelado as statusNotaFiscalFaturamento,
		cast(faturamentovalorbrutoitem as double precision) as valorTotalProdutosFaturamento,
		cast(faturamentovaloritem as double precision) as valorTotalNfFaturamento,
		faturamentosituacao as tipoFaturamento
	from data_raw."1250".faturamento as f
	inner join data_raw."1250".fabricante as ff
	on
		ff.fabricantecodigo = f.faturamentofabricante
	where   (fabricantedescricao like '%manufacturer1%' or
		fabricantedescricao like '%manufacturer2%' or
	    	fabricantedescricao like '%manufacturer3%') and
	    	faturamentoano in ('2024')
	), tb_faturamento_final as (
		select 	fi.id,
			fi.dataAtualizacao,
			fi.idCliente,
			fi.numeroNotaFiscalFaturamento,
			fi.serieNotaFiscalFaturamento,
			fi.cfopFaturamento,
			fi.dataEmissaoFaturamento,
			fi.statusNotaFiscalFaturamento,
			fi.valorTotalProdutosFaturamento,
			fi.valorTotalNfFaturamento,
			fi.tipoFaturamento,
			c.documento as documentoCliente,
			f.filialcnpj as cnpjOrigemDados,
			p.valorUnidadeMedida
		from tb_faturamento_init as fi
		left join seed.dw.cliente as c
		on
			fi.idCliente = c.id
		left join seed.dw.produto as p
		on
			fi.idItem = p.id
		left join data_raw."1250".vendedor as v
		on
			fi.faturamentovendedor = v.vendedorcodigo
		left join data_raw."1250".filial as f
		on
			fi.faturamentofilial = f.filialcodigo
	), tb_select_faturamento as (
		select 
			cnpjOrigemDados,
			id,
			dataAtualizacao,
			idCliente,
			documentoCliente,
			numeroNotaFiscalFaturamento,
			serieNotaFiscalFaturamento,
			cfopFaturamento,
			dataEmissaoFaturamento,
			statusNotaFiscalFaturamento,
			valorTotalProdutosFaturamento,
			valorTotalNfFaturamento,
			tipoFaturamento
		from tb_faturamento_final tfi
	)	
	select *
	from tb_select_faturamento;


end;






$$
;

--faturamento_item
CREATE OR REPLACE PROCEDURE seed.dw.atualiza_faturamento_item()
	LANGUAGE plpgsql
AS $$



declare



begin
	
	delete from seed.dw.faturamento_item where 1=1;

	insert into seed.dw.faturamento_item
	with tb_faturamento_init as (
	select	row_number() over (order by faturamentonumeronf) as id,
		f.cargatimestamp as dataAtualizacao,
		faturamentonumeronf as numero,
		faturamentoserienf as serie,
		cast(faturamentodata as date) as dataEmissao,
		case 
			when faturamentocfop > 5000
				then 1
			else 0
		end as tipo,
		null ::varchar idNotaFiscalOrigem,
		null ::varchar notaFiscalOrigem,
		faturamentoproduto as idItem,
		-- descricao do produto tem que fazer relacionamento
		null ::varchar as sku,
		-- unidade de medida tem que fazer relacionamento
		null ::varchar loteItem,
		cast(faturamentovolumeitem as double precision) as quantidadeItem,
		cast(faturamentovalorbrutoitem as double precision) as faturamentovalorbrutoitem,
		cast(faturamentovolumeitem as double precision) as faturamentovolumeitem,
		cast(faturamentovalorbrutoitem as double precision) as valorTotalItem,
		faturamentocfop as cfopItem,
		-- cpf fo vendedor tem que fazer relacionamento
		faturamentovendedor,
		faturamentofilial
	from data_raw."1250".faturamento as f
	inner join data_raw."1250".fabricante as ff
	on
		ff.fabricantecodigo = f.faturamentofabricante
	where   (fabricantedescricao like '%manufacturer1%' or
		fabricantedescricao like '%manufacturer2%' or
	    	fabricantedescricao like '%manufacturer3%') and
	    	faturamentoano in ('2024')
	), tb_faturamento_final as (
		select 	fi.id,
			fi.dataAtualizacao,
			fi.numero,
			fi.serie,
			fi.dataEmissao,
			fi.tipo,
			case
				when tipo = 0
					then fi.id
				else null
			end as idNotaFiscalOrigem,
			case
				when tipo = 0
					then fi.numeroNotaFiscalFaturamento
				else null
			end as notaFiscalOrigem,
			fi.idItem,
			p.descricao as descricaoItem,
			fi.sku,
			fi.loteItem,
			fi.quantidadeItem,
			(fi.faturamentovalorbrutoitem)/(fi.faturamentovolumeitem) as valorUnitarioItem,
			fi.valorTotalItem,
			fi.cfopItem,
			v.vendedorcpf as cpfVendedor,
			p.um as unidadeMedidaItem,
			p.sku as skuItem
		from tb_faturamento_init as fi
		left join seed.dw.cliente as c
		on
			fi.idCliente = c.id
		left join seed.dw.produto as p
		on
			fi.idItem = p.id
		left join data_raw."1250".vendedor as v
		on
			fi.faturamentovendedor = v.vendedorcodigo
		left join data_raw."1250".filial as f
		on
			fi.faturamentofilial = f.filialcodigo
	), tb_select_faturamento_item as (
		select
			cnpjOrigemDados,
			id,
			dataAtualizacao,
			numero,
			serie,
			dataEmissao,
			tipo,
			idNotaFiscalOrigem,
			notaFiscalOrigem,
			idItem,
			descricaoItem,
			skuItem,
			unidadeMedidaItem,
			loteItem,
			quantidadeItem,
			valorUnitarioItem,
			valorTotalItem,
			cfopItem,
			cpfVendedor,
			valorUnidadeMedida
		from tb_faturamento_final tfi
	)	
	select *
	from tb_select_faturamento_item;


end;






$$
;

--estoque
CREATE OR REPLACE PROCEDURE seed.dw.atualiza_estoque()
	LANGUAGE plpgsql
AS $$



declare



begin
	
	delete from seed.dw.estoque where 1=1;

	insert into seed.dw.estoque
	with tb_estoque_init as (
	select  row_number() over (order by estoquedata) as id,
		cast(estoquedata as date) as dataCadastro,
		e.cargatimestamp as dataAtualizacao,
		estoqueproduto as idItem,
		--relacionar com produto
		cast(estoquesaldo as double precision) as quantidadeDisponivel,
		estoquefilial
	from data_raw."1250".estoque as e
	inner join data_raw."1250".fabricante as ff
	on
		ff.fabricantecodigo = e.estoquefabricante
	where   (fabricantedescricao like '%manufacturer1%' or
		fabricantedescricao like '%manufacturer2%' or
	    	fabricantedescricao like '%manufacturer3%') and
	    	estoqueano in ('2024')
	), tb_estoque_final as (
		select	f.filialcnpj as cnpjOrigemDados,
			ei.id,
			ei.dataCadastro,
			ei.dataAtualizacao,
			ei.idItem,
			ei.quantidadeDisponivel,
			p.descricao
		from tb_estoque_init as ei
		left join seed.dw.produto as p
		on
			ei.idItem = p.id
		left join data_raw."1250".filial as f
		on
			ei.estoquefilial = f.filialcodigo
	)
	select
		ef.cnpjOrigemDados,
		ef.id,
		ef.dataCadastro,
		ef.dataAtualizacao,
		ef.idItem,
		ef.descricao,
		ef.quantidadeDisponivel
	from tb_estoque_final as ef;


end;






$$
;

/* valid */
select dataatualizacao, count(*) as qtd
from seed.dw.cliente c
group by 1

select dataatualizacao, count(*) as qtd
from seed.dw.produto
group by 1

select dataatualizacao, count(*) as qtd
from seed.dw.faturamento f
group by 1

select dataatualizacao, count(*) as qtd
from seed.dw.faturamento_item fi 
group by 1

select dataatualizacao, count(*) as qtd
from seed.dw.estoque e 
group by 1
