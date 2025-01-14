CREATE OR REPLACE VIEW Ano_v AS
select trunc(sysdate, 'year') dt_mes from dual
union
select add_months(trunc(sysdate, 'year'),-12) from dual
union
select add_months(trunc(sysdate, 'year'),-24) from dual
union
select add_months(trunc(sysdate, 'year'),-36) from dual
union
select add_months(trunc(sysdate, 'year'),-48) from dual
union
select add_months(trunc(sysdate, 'year'),-60) from dual
union
select add_months(trunc(sysdate, 'year'),-72) from dual
union
select add_months(trunc(sysdate, 'year'),-84) from dual
union
select add_months(trunc(sysdate, 'year'),-96) from dual
union
select add_months(trunc(sysdate, 'year'),-108) from dual
union
select add_months(trunc(sysdate, 'year'),-120) from dual
union
select add_months(trunc(sysdate, 'year'),-132) from dual
union
select add_months(trunc(sysdate, 'year'),-144) from dual;
/