create or replace
procedure  acertar_css_cliente is
			
/*FonteTitulo - 6 - 132
FonteNormal - 1 -134
FonteNegrito - 3 -133
FonteTituloPequeno - 7 -135
FonteCabecalho - 4-136
tr.CabecalhoTabela -77 -141
FonteRodape -5 - 137
tr.ComCor - 138 -8
tr.SemCor - 139 -9
tr.CorTituloLab - 131 - 140*/
			
ds_valor_cliente_w	varchar2(50);
nr_sequencia_w		number(10);

begin

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 28;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  455;

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 16;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  449;

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 10;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  443;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 36;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  461;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 244;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  467;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 4;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  474;

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 22;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  481;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 41;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  487;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 42;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  488;

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 442;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  490;

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 258;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  489;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 70;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  491;

select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 71;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  492;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 72;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  493;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 73;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  494;



select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 74;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  495;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 75;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  496;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 76;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  497;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 77;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  498;



select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 67;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  499;


select 	ds_valor_cliente
into	ds_valor_cliente_w
from 	WEB_CSS_ELEMENTO_ATRIB
where 	nr_sequencia 	= 68;

update 	WEB_CSS_ELEMENTO_ATRIB
set	ds_valor_cliente =  ds_valor_cliente_w,
	dt_atualizacao	 = sysdate,
	nm_usuario	 = 'TASY'
where 	nr_sequencia 	 =  500;
commit;

end  acertar_css_cliente;
/