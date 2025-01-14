create or replace
function adic_dias_uteis_horas_data (
		dt_referencia_p		date,
		nr_horas_referencia_p	number,
		nr_horas_adicionar_p	number,
		cd_estabelecimento_p	number)
		return date is

nr_dias_adicionar_w	number(10,0);
nr_ctrl_loop_w		number(5) := 0;
ie_dia_util_w		varchar2(1);
dt_dia_horas_adic_w	date;
		
begin
if	(dt_referencia_p is not null) and
	(nr_horas_referencia_p is not null) and
	(nr_horas_adicionar_p is not null) and
	(cd_estabelecimento_p is not null) then
	begin
	dt_dia_horas_adic_w	:= trunc(dt_referencia_p);
	nr_dias_adicionar_w 	:= round(dividir(nr_horas_adicionar_p, nr_horas_referencia_p));
	
	while 	(nr_dias_adicionar_w > 0) and
		(nr_ctrl_loop_w < 10000) loop
		begin
		dt_dia_horas_adic_w	:= dt_dia_horas_adic_w + 1;
		ie_dia_util_w 		:= obter_se_dia_util(dt_dia_horas_adic_w, cd_estabelecimento_p);
		
		if	(ie_dia_util_w = 'S') then
			begin
			nr_dias_adicionar_w := nr_dias_adicionar_w - 1;
			end;
		end if;
		nr_ctrl_loop_w := nr_ctrl_loop_w + 1;
		end;
	end loop;
	end;
end if;
return dt_dia_horas_adic_w;
end adic_dias_uteis_horas_data;
/