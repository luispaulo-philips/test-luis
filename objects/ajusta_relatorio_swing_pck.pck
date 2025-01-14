create or replace package ajusta_relatorio_swing_pck authid CURRENT_USER as
	/*
	ie_opcao_p
		V - Checar campos visuais
		S - Checar SQL
		A - Checar ambos
	*/

	type lista is RECORD (
		nm VARCHAR2(4000),
		vl long );
	type myArray is table of lista index by binary_integer;
	
	procedure	verificar (nr_sequencia_p in number , ie_opcao_p in varchar2, ie_classif_relat_p in varchar2);
	procedure 	verifica_sql(ds_sql_p in varchar2, ds_campos_p out dbms_sql.desc_tab, col_cnt_p out pls_integer);
	procedure	grava_erro(ds_erro_p in varchar2, ie_impeditivo_p in varchar2);
	function 	verifica_caracteres_invalidos(ds_valor_p varchar2) return boolean;
end ajusta_relatorio_swing_pck;
/

create or replace package body ajusta_relatorio_swing_pck as
	/*Variaveis Globais*/
	nr_seq_relatorio_w 		number(10);
	nr_seq_banda_w 			number(10);
	ds_expressao_w			varchar2(255);
	nr_seq_campo_w			number(10);
	nr_seq_parametro_w		number(10);
	ds_erro_w			varchar2(4000);
	ie_classif_relat_w		varchar2(1);
	relatorio_w			relatorio%rowtype;
	banda_relatorio_w		banda_relatorio%rowtype;
	banda_relat_campo_w		banda_relat_campo%rowtype;
	relatorio_parametro_w		relatorio_parametro%rowtype;
	ds_quebra_w			varchar2(30) := chr(13) || chr(10);
	qt_altura_papel_w		number(10);
	qt_altura_bandas_padrao_w	number(10);
	qt_soma_altura_bandas_w		number(10);
	cursor_w 	INTEGER;
	campos_vazio_w      dbms_sql.desc_tab;
	Cursor C01 is
		select	nr_sequencia,
		        ie_tipo_papel,
		        ie_orientacao,
		        qt_altura,
		        qt_margem_sup,
		        qt_margem_inf,
		     --   ds_sql,
				cd_classif_relat
		from (	select 	nr_sequencia,
						ie_tipo_papel,
						ie_orientacao,
						qt_altura,
						qt_margem_sup,
						qt_margem_inf,
						cd_classif_relat
			from		relatorio a
			where		substr(a.cd_classif_relat,1,1) = ie_classif_relat_w
			and			(a.nr_sequencia	= nr_seq_relatorio_w or nr_seq_relatorio_w is null)
		)
		where nr_sequencia in (		select	z.nr_sequencia
									from	(	select	y.nr_sequencia,
														k.cd_classif_relat,
														k.cd_relatorio,
														count(*) qt_geracao
												from	relatorio y,
														LOG_RELATORIO_GERACAO k
												where	k.cd_classif_relat = y.cd_classif_relat
												and		k.cd_relatorio		= y.cd_relatorio
												and		dt_geracao between (trunc(sysdate) - 365) and sysdate --Um ano
												and		nr_seq_relatorio_w is null
												group by k.cd_classif_relat,
														k.cd_relatorio,
														y.nr_sequencia
												having count(*) > 4 --Gerado mais de 4 vez
												union all
												select	nr_seq_relatorio_w,
														'0',
														0,
														0
												from	dual
												where	nr_seq_relatorio_w is not null
												order by qt_geracao desc
											) z
								);
							
	Cursor C02 is
		select	*
		from	banda_relatorio
		where	nr_seq_relatorio = nr_seq_relatorio_w
		order by nr_seq_apresentacao;

	Cursor C03 is
		select	*
		from	banda_relat_campo
		where	nr_seq_banda = nr_seq_banda_w
		order by nr_seq_apresentacao;

	Cursor C04 is
		select	*
		from	relatorio_parametro
		where	nr_seq_relatorio = nr_seq_relatorio_w
		order by nr_sequencia;

	procedure 	verifica_sql(ds_sql_p in varchar2, ds_campos_p out dbms_sql.desc_tab, col_cnt_p out pls_integer) as
	ds_sql_w	varchar2(5000);
	begin
		begin
			if (	cursor_w is null ) then
				cursor_w := DBMS_SQL.OPEN_CURSOR;
			end if;
			ds_sql_w := ds_sql_p;
			ds_sql_w := replace(ds_sql_w, '@SQL_WHERE');	
			ds_sql_w := replace(ds_sql_w, '@SQL_WHERE');
			ds_sql_w := replace(ds_sql_w, '@Sql_Where');
			ds_sql_w := replace(ds_sql_w, '@sql_where');
			
			if(ds_sql_w is not null) then
				if (trim(ds_sql_w) is null ) then
					grava_erro('Comando SQL inválido. Somente espaços em branco!', 'S');
				else
					DBMS_SQL.PARSE(cursor_w, ds_sql_w, dbms_sql.native);
					dbms_sql.describe_columns(cursor_w,col_cnt_p,ds_campos_p);
					for i in 1 .. col_cnt_p loop
					if	(verifica_caracteres_invalidos(ds_campos_p(i).col_name) or ds_campos_p(i).col_name = chr(39) || chr(39)) then
						grava_erro('Coluna no SQL sem alias ' || ds_campos_p(i).col_name, 'S');
					end if;
					end loop;
				end if;
				--DBMS_SQL.CLOSE_CURSOR(cursor_w);
			end if;
		exception when others then
			ds_erro_w	:= SQLERRM(SQLCODE);
			ds_campos_p := campos_vazio_w;
			--DBMS_SQL.CLOSE_CURSOR(cursor_w);
			grava_erro('Erro ao analisar a instrução SQL! -> '||chr(13) || chr(10)|| ds_erro_w || ds_sql_w, 'S');
		end;
	end;

	/*
		DS_TIPO_P
		R - tabela Relatório
		B - tabela banda_relatorio
		C - tabela_banda_relat_campo
	*/
	procedure	grava_erro(ds_erro_p in varchar2, ie_impeditivo_p in varchar2) as
	ds_erro_w	varchar2(4000);
	begin
		ds_erro_w := substr(ds_erro_p,1,4000);
		insert into log_erro_relatorio(
			nr_seq_relatorio,
			nr_seq_banda,
			nr_seq_campo,
			nr_seq_parametro,
			ds_erro,
			ie_impeditivo
		) values (
			nr_seq_relatorio_w,
			nr_seq_banda_w,
			nr_seq_campo_w,
			nr_seq_parametro_w,
			ds_erro_w,
			ie_impeditivo_p
		);
		commit;
	end;

	function verifica_caracteres_invalidos(ds_valor_p varchar2) return boolean as
	ds_valor_w 	varchar2(4000);
	ds_caracter_w	varchar2(1);
	contador	number(10);
	achou_caracter  number(10)	:= 0;
	caracteres_validos varchar2(100) :='abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPRQSTUVXYWZ_1234567890';
	begin
	ds_valor_w := '';
	if	(instr(ds_valor_w,'_') = 0) then
		return false;
	end if;
	for contador in reverse 1..length(ds_valor_p) loop
		ds_caracter_w := substr(ds_valor_p,contador,1);
		if	( instr(caracteres_validos,ds_caracter_w) > 0 ) and
			( achou_caracter < 2) then
			ds_valor_w := ds_caracter_w || ds_valor_w;
			achou_caracter := 1;
		else
			if	( achou_caracter = 1 ) then
				achou_caracter := 2;
			end if;
		end if;
	end loop;
	return achou_caracter = 2;
	end;

	function obter_altura_bandas_filhas(nr_seq_relatorio_p		number,
						nr_seq_banda_p		number)
	 		    	return number as
	qt_soma_w		number(10) := 0;
	qt_altura_banda_w	number(10);

	Cursor C15 is
		select	qt_altura
		from	banda_relatorio
		where	nr_seq_relatorio 	= nr_seq_relatorio_p
		and	nr_seq_banda_superior 	= nr_seq_banda_p;
	begin
	open C15;
	loop
	fetch C15 into
		qt_altura_banda_w;
	exit when C15%notfound;
		begin
		qt_soma_w := qt_soma_w + qt_altura_banda_w;
		end;
	end loop;
	close C15;
	return	qt_soma_w;
	end;

	function obter_altura_bandas_padrao(nr_seq_relatorio_p		number)
	 		    	return number as
	qt_soma_w		number(10) := 0;
	qt_altura_banda_w	number(10);
	nr_seq_banda_w		number(10);

	Cursor C16 is
		select	nr_sequencia,
			qt_altura
		from	banda_relatorio
		where	nr_seq_relatorio 	= nr_seq_relatorio_p
		and	ie_tipo_banda		in ('C','R');
	begin
	open C16;
	loop
	fetch C16 into
		nr_seq_banda_w,
		qt_altura_banda_w;
	exit when C16%notfound;
		begin
		qt_soma_w := qt_soma_w + qt_altura_banda_w;
		qt_soma_w := qt_soma_w + obter_altura_bandas_filhas(nr_seq_relatorio_p, nr_seq_banda_w);
		end;
	end loop;
	close C16;
	return	qt_soma_w;
	end;

	function obter_altura_pagina(	ie_tipo_papel_p		varchar2,
					ie_orientacao_p		varchar2,
					qt_altura_p		number) return number as
	qt_altura_papel_w	number(10);
	begin

	if	(ie_orientacao_p = 'R') then
		if	(ie_tipo_papel_p = 'A4') then
			qt_altura_papel_w := 842;
		elsif	(ie_tipo_papel_p = 'A5') then
			qt_altura_papel_w := 595;
		elsif	(ie_tipo_papel_p = 'A6') then
			qt_altura_papel_w := 421;
		elsif	(ie_tipo_papel_p = 'Letter') then
			qt_altura_papel_w := 792;
		elsif	(ie_tipo_papel_p = 'Default') then
			qt_altura_papel_w := 1008;
		elsif	(ie_tipo_papel_p = 'B5') then
			qt_altura_papel_w := 709;
		elsif	(ie_tipo_papel_p = 'Env10') then
			qt_altura_papel_w := 297;
		elsif	(ie_tipo_papel_p = 'A3') then
			qt_altura_papel_w := 1190;
		elsif	(ie_tipo_papel_p = 'Folio') then
			qt_altura_papel_w := 1052;
		elsif	(ie_tipo_papel_p = 'Custom') then
			qt_altura_papel_w := (qt_altura_p / 2.54) * 75;
		else
			qt_altura_papel_w := 842;
		end if;
	else --Paisagem
		if	(ie_tipo_papel_p = 'A4') then
			qt_altura_papel_w := 595;
		elsif	(ie_tipo_papel_p = 'A5') then
			qt_altura_papel_w := 421;
		elsif	(ie_tipo_papel_p = 'A6') then
			qt_altura_papel_w := 297;
		elsif	(ie_tipo_papel_p = 'Letter') then
			qt_altura_papel_w := 612;
		elsif	(ie_tipo_papel_p = 'Default') then
			qt_altura_papel_w := 612;
		elsif	(ie_tipo_papel_p = 'B5') then
			qt_altura_papel_w := 501;
		elsif	(ie_tipo_papel_p = 'Env10') then
			qt_altura_papel_w := 681;
		elsif	(ie_tipo_papel_p = 'A3') then
			qt_altura_papel_w := 842;
		elsif	(ie_tipo_papel_p = 'Folio') then
			qt_altura_papel_w := 612;
		elsif	(ie_tipo_papel_p = 'Custom') then
			qt_altura_papel_w := (qt_altura_p / 2.54) * 75;
		else
			qt_altura_papel_w := 595;
		end if;
	end if;

	return qt_altura_papel_w;
	end;

	/*Percorre o SQL armazenando os parametros
	Ex: :NM_USUARIO */
	procedure armazena_parametros_sql(ds_comando_p in varchar2,ar_nm_parametros_sql_p in out myArray,ie_upper_param_p boolean default true) as
	ds_comando_w 		varchar2(10000);
	nm_param_w		varchar2(4000);
	pos_w			number(10);
	ar_nm_parametros_w	myArray;
	ds_caracter_w		varchar2(1);
	contador_w		number(10) 	:= 1;
	caracteres_validos_w	varchar2(60)  :='abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPRQSTUVXYWZ_';
	ie_valido_w		boolean;
	BEGIN
		ds_comando_w := ds_comando_p;
		pos_w := instr(ds_comando_w,':');
		while	( pos_w > 0 ) and
			( contador_w < 300 ) loop /*Variavel de controle para evitar LOOP*/
			ds_comando_w 	:= substr(ds_comando_w,pos_w+1,length(ds_comando_w));
			nm_param_w 	:= '';
			ie_valido_w	:= true;
			pos_w 		:= 1;
			while	( ie_valido_w ) and
				( pos_w < length(ds_comando_p)) loop  /*Variavel de controle para evitar LOOP*/
				ds_caracter_w := substr(ds_comando_w,pos_w,1);
				if	( instr(caracteres_validos_w,ds_caracter_w) > 0 ) then
					nm_param_w := nm_param_w || ds_caracter_w;
				else
					ie_valido_w := false;
				end if;
				pos_w := pos_w + 1;
			end loop;
			if	( instr(nm_param_w,'_') > 0 ) then
				if	(ie_upper_param_p) then
					ar_nm_parametros_sql_p((ar_nm_parametros_sql_p.count+1)).nm := upper(nm_param_w);
				else
					ar_nm_parametros_sql_p((ar_nm_parametros_sql_p.count+1)).nm := nm_param_w;
				end if;
			end if;

			ds_comando_w := substr(ds_comando_w,pos_w,length(ds_comando_w));
			pos_w := instr(ds_comando_w,':');
			contador_w := contador_w + 1;
		end loop;
	END;

	procedure verificar (nr_sequencia_p in number , ie_opcao_p in varchar2,ie_classif_relat_p in varchar2) as
	qt_var_estilo_w number(10);
	ds_campos_relat_w dbms_sql.desc_tab;
	ds_campos_banda_relat_w dbms_sql.desc_tab;
	ds_campos_banda_relat_campo_w dbms_sql.desc_tab;
	ds_campos_sql_banda_w	 dbms_sql.desc_tab;
	col_cnt_relat_w pls_integer;
	col_cnt_banda_relat_w pls_integer;
	col_cnt_banda_relat_campo_w pls_integer;
	qt_soma_tamanho_campo_w  number(5);
	qt_soma_altura_campo_w   number(5);
	ar_nm_param_sql_w	myArray;
	pos_do_alias_w  	number(5);
	pos_ini_linha_w		number(5);
	ds_linha_do_alias_w	varchar2(2000);
	cursor_sql_banda_w	INTEGER;
	index_coluna_w 		number(10);
	col_cnt_w		number(10);
	ds_erro_w		varchar2(4000);
	ie_executou_sql_banda_w	varchar2(1);
	qt_razao_campo_w	number(10);

	nr_sequencia_w 	relatorio.nr_sequencia%type;
	ie_tipo_papel_w relatorio.ie_tipo_papel%type;
	ie_orientacao_w relatorio.ie_orientacao%type;
	qt_altura_w		relatorio.qt_altura%type;
	qt_margem_sup_w	relatorio.qt_margem_sup%type;
	qt_margem_inf_w	relatorio.qt_margem_inf%type;
	ds_sql_w		relatorio.ds_sql%type;
		cd_classif_relat_w relatorio.cd_classif_relat%type;


	begin
		ie_classif_relat_w := substr(ie_classif_relat_p,1,1);
		exec_sql_dinamico('Tasy','truncate table log_erro_relatorio');
		nr_seq_relatorio_w := nr_sequencia_p;
		if c01%ISOPEN then
      Close c01;
    end if;
    open C01;
		loop
		fetch C01 into
			--relatorio_w
			nr_sequencia_w,
			ie_tipo_papel_w,
			ie_orientacao_w ,
			qt_altura_w		,
			qt_margem_sup_w	,
			qt_margem_inf_w	,
			--ds_sql_w		,
			cd_classif_relat_w;
		exit when C01%notfound;

			if	(length(cd_classif_relat_w) < 4) then
				grava_erro('A junção da classificação do relatório + o código, devem obrigatoriamente totalizar 9 ou mais dígitos', 'S');
			end if;

			nr_seq_relatorio_w 			:= nr_sequencia_w;
			qt_altura_papel_w			:= obter_altura_pagina(ie_tipo_papel_w, ie_orientacao_w, qt_altura_w) - floor((qt_margem_sup_w + qt_margem_inf_w) * 2.83);
			qt_altura_bandas_padrao_w 	:= obter_altura_bandas_padrao(nr_seq_relatorio_w);  --bandas cabeçalho e rodapé + suas respectivas filhas

			ds_campos_relat_w := campos_vazio_w;

		 if	( ie_opcao_p in ('A','S')) then
				verifica_sql(ds_sql_w,ds_campos_relat_w,col_cnt_relat_w);
			end if;

			if	((ie_tipo_papel_w = 'Custom') and (qt_altura_w is null or qt_altura_w is null)) then
				grava_erro('Os relatórios com tipo de papel "Customizado" devem ter altura e largura de papel informados.', 'S');
			end if;

		if c02%ISOPEN then
      Close c02;
    end if;
			open C02;
			loop
			fetch C02 into
				banda_relatorio_w;
			exit when C02%notfound;
				begin
					ie_executou_sql_banda_w	:= 'N';
					nr_seq_banda_w 		:= banda_relatorio_w.nr_sequencia;
					qt_soma_altura_bandas_w := banda_relatorio_w.qt_altura + obter_altura_bandas_filhas(nr_seq_relatorio_w, nr_seq_banda_w) + qt_altura_bandas_padrao_w;
					qt_soma_tamanho_campo_w := 0;
					qt_soma_altura_campo_w  := 0;
					ds_expressao_w		:= banda_relatorio_w.ds_expressao;

					if	(ds_expressao_w is not null) and
						(ds_expressao_w = 'LINK') then
						begin
						grava_erro('A expressão Link não deve ser utilizada! em vez disso colocar todos os campos na mesma banda.', 'N');
						end;
					end if;

					if	(floor(qt_soma_altura_bandas_w * 0.75) > qt_altura_papel_w) then
						grava_erro('A altura da banda ultrapassou a altura do papel', 'S');
					end if;
					ds_campos_banda_relat_w := campos_vazio_w;
					if	( ie_opcao_p in ('A','S')) then
						verifica_sql(REPLACE(banda_relatorio_w.ds_sql, '@SQL_WHERE', ''),ds_campos_banda_relat_w,col_cnt_banda_relat_w);
						armazena_parametros_sql(banda_relatorio_w.ds_sql,ar_nm_param_sql_w);
					end if;
					
          		if c03%ISOPEN then
      Close c03;
    end if;
          open C03;
					loop
					fetch C03 into
						banda_relat_campo_w;
					exit when C03%notfound;
						begin
							nr_seq_campo_w := banda_relat_campo_w.nr_sequencia;

							
							--Barras
							if 	(banda_relat_campo_w.IE_TIPO_CAMPO = 2) then
								if	(nvl(banda_relat_campo_w.QT_TAMANHO, 0) < 20) then
									grava_erro('Verifique as dimensões do campo BARRAS pois a largura deve ser superior a 20 caso contrario o campo não será apresentado', 'S');
								end if;
							end if;
							if	( banda_relatorio_w.ds_sql is not null) and
								( banda_relat_campo_w.DS_MASCARA is null) and
								( ar_nm_param_sql_w.count > 0) then

								pos_do_alias_w  := instr(upper(banda_relatorio_w.ds_sql), banda_relat_campo_w.NM_ATRIBUTO);
								pos_ini_linha_w := instr(substr(upper(banda_relatorio_w.ds_sql), 1, pos_do_alias_w), chr(10), -1);
								ds_linha_do_alias_w := upper(substr(banda_relatorio_w.ds_sql, pos_ini_linha_w, (pos_do_alias_w - pos_ini_linha_w)));

								for i in 1..ar_nm_param_sql_w.count loop
									if	( substr(ar_nm_param_sql_w(i).nm,1,3) = 'DT_') and
										( instr(ds_linha_do_alias_w,':'||ar_nm_param_sql_w(i).nm) > 0 ) and
										( instr(ds_linha_do_alias_w,'TO_CHAR(:'||ar_nm_param_sql_w(i).nm) = 0 )then
											grava_erro('Informar a mascara de data para o campo bind', 'N');
									end if;
								end loop;

							end if;

							if	(banda_relatorio_w.ds_sql is not null) and
								( col_cnt_banda_relat_w > 0) then
								for i in 1 .. col_cnt_banda_relat_w loop

									/*Data*/
									if	( ds_campos_banda_relat_w(i).col_type = 12 ) and
										( ds_campos_banda_relat_w(i).col_name = banda_relat_campo_w.NM_ATRIBUTO) and
										( banda_relat_campo_w.DS_MASCARA is null) then
										grava_erro('Informar a mascara de data para o campo', 'N');
									/*Campo DATA passado como parâmetro sem TO_CHAR ou mascara*/
									elsif	( ds_campos_banda_relat_w(i).col_type = 1) and
											( substr(ds_campos_banda_relat_w(i).col_name,1,3) = 'DT_') and
											( ds_campos_banda_relat_w(i).col_name = banda_relat_campo_w.NM_ATRIBUTO) and
											( banda_relat_campo_w.DS_MASCARA is null) and
											( instr(upper(banda_relatorio_w.ds_sql),':'||banda_relat_campo_w.NM_ATRIBUTO) > 0 ) and
											( instr(upper(banda_relatorio_w.ds_sql),'TO_CHAR(:'||banda_relat_campo_w.NM_ATRIBUTO) = 0 )then
												grava_erro('Informar a mascara de data para o campo', 'N');

									end if;

									if ('S' = banda_relat_campo_w.IE_AJUSTAR_TAMANHO) then
										begin
										if	(nvl(ie_executou_sql_banda_w, 'N') = 'N') then
											verifica_sql(REPLACE(banda_relatorio_w.ds_sql, '@SQL_WHERE', ''), ds_campos_sql_banda_w, col_cnt_w);
											/*Executar o sql da banda somente uma vez, visto que itera sobre todos os campos*/
											ie_executou_sql_banda_w := 'S';
										end if;
										index_coluna_w := 0;
										for i in 1 .. col_cnt_w loop
											index_coluna_w := index_coluna_w + 1;
											exit when upper(ds_campos_sql_banda_w(index_coluna_w).col_name) = upper(banda_relat_campo_w.NM_ATRIBUTO);
										end loop;

										/*8 - razao media em pixels do gerenciador de relatorios para Strings*/
										qt_razao_campo_w	:= 8;
										if	(ds_campos_banda_relat_w(i).col_type = 1) then /*Varchar*/
											qt_razao_campo_w := 8;
										elsif	(ds_campos_banda_relat_w(i).col_type = 2) then /*Number*/
											/*7 - razao media em pixels do gerenciador de relatorios para Numericos*/
											qt_razao_campo_w := 7;
										elsif	(ds_campos_banda_relat_w(i).col_type = 8) then /*Long*/
											if 	('N' = banda_relat_campo_w.IE_ESTENDER) then
												grava_erro('Para evitar problemas com cortes de conteúdo, deve-se definir o campo para estender ', 'D');
											else
												qt_razao_campo_w := 8;
											end if;
										end if;

										select	decode(nvl(qt_razao_campo_w, 0), 0, 8, qt_razao_campo_w)
										into	qt_razao_campo_w
										from	dual;

										if 	(index_coluna_w > 0) then
											if	(ds_campos_sql_banda_w(index_coluna_w).col_max_len > (nvl(banda_relat_campo_w.QT_TAMANHO, 0) / qt_razao_campo_w)) then
												--grava_erro('Para evitar problemas de sobreposição de campos, deve-se definir um tamanho preciso para o campo ' || ds_campos_sql_banda_w(index_coluna_w).col_name, 'D');
												grava_erro('Para evitar problemas de sobreposição de campos, deve-se definir um tamanho preciso para o campo ', 'D');
											end if;
										end if ;
										end;
									end if;

								end loop;
							end if;

							if	(banda_relat_campo_w.ds_estilo_fonte is not null) then
								qt_var_estilo_w := 1;
							else
								qt_var_estilo_w := 0;
							end if;

							if	(banda_relat_campo_w.ds_sql is not null ) and
								(ie_opcao_p in ('A','S')) then

								armazena_parametros_sql(banda_relat_campo_w.ds_sql,ar_nm_param_sql_w);

								if	(banda_relat_campo_w.ds_sql is not null) and
									(ar_nm_param_sql_w.count > 0) and
									(banda_relat_campo_w.DS_MASCARA is null) then

									pos_do_alias_w  := instr(upper(banda_relat_campo_w.ds_sql), banda_relat_campo_w.NM_ATRIBUTO);
									pos_ini_linha_w := instr(substr(banda_relat_campo_w.ds_sql, 1, pos_do_alias_w), chr(10), -1);
									ds_linha_do_alias_w := upper(substr(banda_relat_campo_w.ds_sql, pos_ini_linha_w, (pos_do_alias_w - pos_ini_linha_w)));


									for i in 1..ar_nm_param_sql_w.count loop
										if	( substr(ar_nm_param_sql_w(i).nm,1,3) = 'DT_') and
											( instr(ds_linha_do_alias_w,':'||ar_nm_param_sql_w(i).nm) > 0 ) and
											( instr(ds_linha_do_alias_w,'TO_CHAR(:'||ar_nm_param_sql_w(i).nm) = 0 )then
												grava_erro('Informar a mascara de data para o campo bind', 'N');
										end if;
									end loop;

								end if;


								verifica_sql(banda_relat_campo_w.ds_sql,ds_campos_banda_relat_campo_w,col_cnt_banda_relat_campo_w);
								if(col_cnt_banda_relat_campo_w > 0) then
									for i in 1 .. col_cnt_banda_relat_campo_w loop
										/*DATA*/
										if	( ds_campos_banda_relat_campo_w(i).col_type = 12 ) and
											( ds_campos_banda_relat_campo_w(i).col_name = banda_relat_campo_w.NM_ATRIBUTO) and
											(  banda_relat_campo_w.DS_MASCARA is null) then
											grava_erro('Informar a mascara de data para o campo', 'N');
										/*Campo DATA passado como parâmetro sem TO_CHAR ou mascara*/
										elsif	( ds_campos_banda_relat_campo_w(i).col_type = 1) and
												( substr(ds_campos_banda_relat_campo_w(i).col_name,1,3) = 'DT_') and
												( ds_campos_banda_relat_campo_w(i).col_name = banda_relat_campo_w.NM_ATRIBUTO) and
												( banda_relat_campo_w.DS_MASCARA is null) and
												( instr(upper(banda_relat_campo_w.ds_sql),':'||banda_relat_campo_w.NM_ATRIBUTO) > 0 ) and
												( instr(upper(banda_relat_campo_w.ds_sql),'TO_CHAR(:'||banda_relat_campo_w.NM_ATRIBUTO) = 0 )then
													grava_erro('Informar a mascara de data para o campo', 'N');
										end if;

									end loop;
								end if;
								ds_campos_banda_relat_campo_w := campos_vazio_w;
							end if;

							if	(banda_relat_campo_w.ds_mascara is not null) and
								( instr(banda_relat_campo_w.ds_mascara,';;') > 0)then
								grava_erro('O formato da máscara é inválido', 'S');
							end if;

							if	( ie_opcao_p in ( 'V','A')) then

								if	(banda_relat_campo_w.qt_altura+banda_relat_campo_w.qt_topo > banda_relatorio_w.qt_altura) then
									if	((banda_relatorio_w.qt_altura = 17 and banda_relat_campo_w.qt_altura = 17 and banda_relat_campo_w.qt_topo  = 1)) then
										--A situação acima já foi tratada no gerenciador porque a maioria dos relatórios possui a mesma
										qt_var_estilo_w := qt_var_estilo_w;
									else
										grava_erro('A altura do campo + topo não pode ser superior ao tamanho da banda', 'N');
									end if;
								end if;

								if	(banda_relat_campo_w.qt_tam_fonte+qt_var_estilo_w > floor(banda_relat_campo_w.qt_altura *.75) ) then
									if	(banda_relat_campo_w.ie_estender = 'S') then
										if (floor(banda_relat_campo_w.qt_topo*.75) + (banda_relat_campo_w.qt_tam_fonte+qt_var_estilo_w) > floor(banda_relatorio_w.qt_altura*.75)) then
											if (qt_var_estilo_w > 0 ) then
												grava_erro('O topo do campo + tamanho de fonte + estilo é superior ao tamanho da banda', 'N');
											else
												grava_erro('O topo do campo + tamanho da fonte é superior a altura da banda', 'N');
											end if;
										end if;
									else
										if (banda_relat_campo_w.ds_estilo_fonte is not null) then
											grava_erro('A altura do campo não suporta a configuração de fonte + estilo', 'N');
										else
											grava_erro('A altura do campo não suporta o tamanho da fonte', 'N');
										end if;
									end if;
								end if;

								if  (banda_relat_campo_w.ds_label is not null) and (instr(banda_relat_campo_w.ds_label, chr(38)) > 0)then
									grava_erro('Não é recomendada a utilização do caracter especial "'|| chr(38) ||'" no atributo Label, pois ele pode vir a ocasionar problemas de execução', 'D');
								end if;

								if	(banda_relatorio_w.ie_tipo_banda not in ('S','D')) then
									if	(banda_relatorio_w.ie_tipo_banda = 'F') and
										(banda_relat_campo_w.ds_label is not null) then
										grava_erro('Substituir o label do campo da banda filha, por um campo do tipo conteúdo ', 'N');
									end if;

									if	(qt_soma_tamanho_campo_w > 0 and
										banda_relat_campo_w.qt_esquerda < qt_soma_tamanho_campo_w and
										banda_relat_campo_w.qt_topo < qt_soma_altura_campo_w) then
										grava_erro('Alguns campos podem estar sobrepostos (verificar campos com label)', 'D');
									end if;

									if	(banda_relat_campo_w.ds_label is not null) then
										qt_soma_tamanho_campo_w := banda_relat_campo_w.qt_esquerda + banda_relat_campo_w.qt_tamanho + 10;
										qt_soma_altura_campo_w  := banda_relat_campo_w.qt_topo + banda_relat_campo_w.qt_altura + 1;
									end if;
								end if;

							end if;

							if (banda_relat_campo_w.qt_tam_fonte <= 0) then

								grava_erro('Campo está com o tamanho da fonte menor ou igual a zero.', 'N');

							elsif	((banda_relat_campo_w.qt_altura / banda_relat_campo_w.qt_tam_fonte) <= 1.5) then

								grava_erro('Alguns campos estão com o tamanho da fonte maior que o suportado pela altura do campo(verificar relação altura x tamanho fonte)', 'N');

							end if;
						end;
					end loop;
					close C03;
					nr_seq_campo_w := null;
				end;
			end loop;
			close C02;
			nr_seq_banda_w := null;
			commit;
			
			if c04%ISOPEN then
				Close c04;
			end if;
			open C04;
			loop
			fetch C04 into
				relatorio_parametro_w;
			exit when C04%notfound;
				begin
				nr_seq_parametro_w := relatorio_parametro_w.nr_sequencia;
				if (relatorio_parametro_w.IE_FORMA_PASSAGEM = 'W') then
					begin
					if	(relatorio_parametro_w.cd_parametro = 'CD_ESTABELECIMENTO' or
						relatorio_parametro_w.cd_parametro = 'NM_USUARIO' or
						relatorio_parametro_w.cd_parametro = 'CD_PERFIL' or 
						relatorio_parametro_w.cd_parametro = 'CD_EMPRESA' or 
						relatorio_parametro_w.cd_parametro = 'CD_EMPRESA_COR' or 
						relatorio_parametro_w.cd_parametro = 'ESTABELECIMENTO_LOGO' or 
						relatorio_parametro_w.cd_parametro = 'NM_ESTABELECIMENTO_LOGO') then
					   begin
							grava_erro('Encontrado parâmetro multiseleção de parametro padrão do sistema. '|| chr(13) || chr(10) ||
										'Alterar para o nome no plural, caso contrário o parametro nao será utilizado'|| chr(13) || chr(10) ||
										'Exemplo: CD_ESTABELECIMENTOS, NM_USUARIOS, CD_PERFIS, CD_EMPRESAS, etc.', 'S');
					   end;
					end if;
					end;
				end if;
				if	(length(trim(relatorio_parametro_w.cd_parametro)) is null) then
					grava_erro('Parâmetro com nome vazio ou inválido', 'S');
				end if;

				end;
			end loop;
			close C04;
			nr_seq_parametro_w := null;
		end loop;
		close C01;
		ds_campos_relat_w := campos_vazio_w;
		ds_campos_banda_relat_w := campos_vazio_w;
		ds_campos_banda_relat_campo_w := campos_vazio_w;
		if(cursor_w != null ) then
			DBMS_SQL.CLOSE_CURSOR(cursor_w);
		end if;

	end;
end ajusta_relatorio_swing_pck;
/