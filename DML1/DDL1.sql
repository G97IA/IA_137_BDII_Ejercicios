/*
Practica I - Clase.
*/

conn hr/hr

create user kzguniga // crear usuario
identified by kgzuniga; // contraseña

desc all_users; // ver usuarios

desc hr.employees; // ver empleados

select * from all_users; // vista de diccionario de datos

grant create session, connect to kgzuniga; // privilegio de crear session y conectar con el usuario kgzuniga

create role estudiante; // crear rol 

desc user_role_privs // ver roles creados privados

select username, granted_role from user_role_privs; // ver roles creados privados con permiso adm a un usuario

conn rh/rh // conexion

conn kgzuniga1/kgzuniga1 // conexion 

select * from cat; // mostrar tablas de catalago de datos

show user // ver usuario 

grant select, insert, update, delete on hr.employees to estudiante; // otorgar privilegios en la tabla empleados a el rol estudiante

grant estudiante to kgzuniga1; // otorgar rol con privilegios a usuario 

select employee_id, first_name, last_name, salary
* from hr.employees // vista de la tabla empleados, primer y segundo nombre + salario 

delete hr.employees // borrar tabla 

delete hr.regions where region_id = 8; // borrar registro especifico de una tabla

update hr.employees
set salary = salary + 1000; // aumentar el salario a todos los empleados en 1000

update hr. regions
set region_name = 'XYZ'
where region_id = 7; // agregar registro especifico a una tabla

grant connect, create any table, dba 
to estudiante; // privilegios de crear tabla y asignar rol dba a estudiante

grant connect, create any table, create procedure
to estudiante; // privilegios de crear tabla y procedimiento a estudiante

desc user role_sys_privs verificar privilegios otorgados a usuario

desc role_sys_privs // verificar privilegios otorgados a un rol 

select * from role_sys_privs
where role = 'estudiante'

select owner, table_name, privilege 
from role_tab_privs
where role = 'estudiante' 
order by 1 

desc user_tab_privs_made // privilegios hechos en tablas
desc user_col_privs_made // privilegios hechos sobre columnas
desc user_tab_privs_recd // privilegios recibidos
desc user_col_privs_recd // privilegios recibidos sobre columnas

revoke estudiante
from kgzuniga; // rebocacion de privilegios

drop role estudiante; // eliminar rol

drop user estudiante; // eliminar usuario 

/* 
Practica I - Parcial
*/

/*
1. Crear una función que reciba como parámetro de entrada el nombre del departamento (Ejemplo “Sales”) y calcule el salario promedio del departamento. 
La función deberá devolver un mensaje como el siguiente: “El departamento Sales tiene un salario promedio de 8955” 
*/

create or replace function department_avg(p_department_name hr.departments department_name%type) return varchar is
v_avg number;
v_mess varchar(250);
begin
  select round(avg(salary),2)
	into v_avg
   from hr.employees e, hr.departments d
   where e.department_id = d.department_id
   and d.department_name = p_department_name; 
   v_mess := ('El departamento ' ||p_department_name||' tiene un salario de: '||to_char(v_avg));
   return (v_mess);
end;

/

declare
v_texto varchar(500);
begin 
    v_texto := department_avg('Sales');
    dbms_output.put_line(v_texto);
end;

/

set serveroutput on 
l

/

/*     
2.Crear una función que recibirá como parámetro el Código del empleado y retornara un valor Boolean deberá comprobar, la existencia de historia de un empleado en la tabla Job_History. 
La función devolverá TRUE si encuentra registros en la tabla y FALSE si no encuentra registros.
*/

create or replace function empleado_tiene_historia(p_employee_id hr. employees.employee_id%type) return boolean is
v_contador number;
begin
    select count (*)
      into v_contador
      from hr.job_history j
    where j.employee_id = p_employee_id;
  if v_contador = 0 then 
    return False;
  else 
   return True;
  end if;
end;

/	

declare
v_resultado boolean;
begin 
    v_resultado := empleado_tiene_historia(101);
 if v_resultado then 
    dbms_output.put_line('Empleado tiene historial');
 else
    dbms_output.put_line('Empleado no tiene historial');
 end if;
end;

/

/*
3. Crear una función que reciba como parámetro el Employee_id, y retorne la cantidad de subordinados o personal a cargo que este tiene (El campo manager_id indica el jefe de cada empleado)
*/

create or replace function personal_acargo(p_employee_id hr.employees.employee_id%type) return number is 
v_cantidad number;
 begin 
   select count (*)
    into v_cantidad
   from hr.employees e 
    where e.manager_id = p_employee_id;
   return (v_cantidad);
 end;

/

declare
v_resultado number;
begin
 v_resultado := personal_acargo(101);
 dbms_output.put_line('Empleados a cargo: ' ||to_char(v_resultado));
end;

/

/*
4. Crear un procedimiento para insertar registros en la tabla  Employees,  recibirá como parámetros todos los campos existentes. 
Deberá controlar por medio de excepción si el Employee_id ya existe en la tabla de empleados y desplegar mensaje indicándolo. 
*/

create or replace procedure ins_employees(
  p_emplyee_id     hr.employees.employee_id%type,
  p_first_name     hr.employees.first_name%type,  
  p_last_name      hr.employees.last_name%type,
  p_email          hr.employees.email%type,
  p_phone_number   hr.employees.phone_number%type,
  p_hire_date      hr.employees.hire_date%type,                       
  p_job_id         hr.employees.job_id%type,
  p_salary         hr.employees.salary%type,
  p_commission_pc  hr.employees.commission_pc%type,
  p_manager_id     hr.employees.manager_id%type,
  p_department_id  hr.employees.department_id%type) is
  begin
  insert into employees (employee_id, first_name, last_name, email, phone_number, hire_date,
   			  job_id, salary, commission_pct, manager_id, department_id)
  values (p_employee_id, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date,
   	   p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
  exception
	when dup_val_on_index then
	dbms_output.put_line('Error codigo de empleado ya existe');
end;

/

Declare
  v_emplyee_id       hr.employees.employee_id%type := 100;
  v_first_name       hr.employees.first_name%type := 'Kevin';
  v_last_name        hr.employees.last_name%type := 'Zuniga';
  v_email            hr.employees.email%type := 'kgzuniga@unah.hn';
  v_phone_number     hr.employees.phone_number%type := '99989796';
  v_hire_date        hr.employees.hire_date%type := '16-JUL-1997';                    
  v_job_id           hr.employees.job_id%type := 'KZ_MAN';
  v_salary           hr.employees.salary%type := 100000;
  v_commission_pc    hr.employees.commission_pc%type := 0;
  v_manager_id       hr.employees.manager_id%type := 100;
  v_department_id    hr.employees.department_id%type := 60;
begin
  ins_employees(v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, v_hire_date,
   	        v_job_id, v_salary, v_commission_pct, v_manager_id, v_department_id);
end;

/