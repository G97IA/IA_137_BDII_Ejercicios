
--Practica II - Clase.

--Crear un procedimiento para insertar y eliminar registros en la tabla  Employees, recibir� como par�metros todos los campos existentes y actualizar� las columnas con los nuevos valores que se env�en.
--Debera controlar por medio de Excepci�n si el registro no existe, y desplegar un mensaje indic�ndolo.

create or replace procedure gestiona_employees(p_operacion char, 
 p_emplyee_id       hr.employees.employee_id%type,
 p_first_name       hr.employees.first_name%type,  
 p_last_name        hr.employees.last_name%type,
 p_email            hr.employees.email%type,
 p_phone_number     hr.employees.phone_number%type,
 p_hire_date        hr.employees.hire_date%type,                       
 p_job_id           hr.employees.job_id%type,
 p_salary           hr.employees.salary%type,
 p_commission_pc    hr.employees.commission_pc%type,
 p_manager_id       hr.employees.manager_id%type,
 p_department_id    hr.employees.department_id%type) is

 e_operacion_no_valida exception; 
 e_actualizacion_no_valida exception;
 e_eliminacion_no_valida exception;
 dup_val_on_index exception;
 v_cantidad number;

 begin
      select count(*)
	  into v_cantidad
      from employees
      where employee_id = p_employee_id;

      if p_operacion = 'I' then --Insert
	   if v_cantidad = 0 then
	      insert into employees (employee_id, first_name, last_name, email, phone_number, hire_date,
  	      	job_id, salary, commission_pct, manager_id, department_id)
	      values (p_employee_id, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date,
   		p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
	    else
	      raise dup_val_on_index;
  	   end if;

      elsif p_operacion = 'U' then --Update
           if v_cantidad = 0 then
	        update employees
 		set first_name = p_first_name, last_name = p_last_name, email = p_email, phone_number = p_phone_number, hire_date = p_hire_date,
  	      	  job_id = p_job_id, salary = p_salary, commission_pct = p_commission_pct, manager_id = p_manager_id, department_id = p_department_id
		where employee_id = p_employee_id;
	     else 
              raise e_actualizacion_no_valida exception;
	   end if;

      elsif p_operacion = 'D' then --Delete
	    if v_cantidad = 0 then
		delete employees
		where employee_id = p_employee_id;
  	     else
		raise e_eliminacion_no_valida exception;
 	    end if;
 	     else
		e_operacion_no_valida exception; 
      end if;

 exceptions when e_operacion_no_valida then  
		   dbms_output.put_line('Error de operacion no valida');
	      when e_actualizacion_no_valida then 
		    dbms_output.put_line('Error... Registro de actualizacion invalido');
	      when e_eliminacion_no_valida then 
 		    dbms_output.put_line('Error... Registro de eliminacion invalido');
	      when dup_val_on_index then
	             dbms_output.put_line('DUP_VAL_ON_INDEX: '||sqlerrm);
		     dbms_output.put_line('Empleado con ese ID ya existe.');
		     dbms_output.put_line('Solucion: cambie el valor de employe_id para el nuevo empleado insertado.');
 	      when others then 
		     dbms_output.put_line('Error en procedimiento Gestiona employees, contacte a soporte');
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
gestiona_employees(v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, v_hire_date,
   		   v_job_id, v_salary, v_commission_pct, v_manager_id, v_department_id);
end;

/

--Practica II - Parcial

--0. Cursores

declare
   CURSOR cur_emps(p_department_id employees.department_id%type) is
          select employee_id, Last_name, Salary
            from employees
            where department_id = p_department_id;
   v_emps cur_emps%rowtype;
   CURSOR cur_depts is
          select department_id, department_name
          from departments;
 begin
   for i in cur_depts loop
       dbms_output.put_line('Depto: '||i.department_id||' -'||i.department_name);
       for j in cur_emps(i.department_id) loop
             dbms_output.put_line('Codigo: '||j.employee_id||' Apellido: '||j.last_name||' Salario: '||j.salary);
       end loop; 
       DBMS_OUTPUT.PUT_LINE('-----------------');
       DBMS_OUTPUT.PUT_LINE(' ');
   end loop; 
end;

/

--1. Crear un procedimiento que identifique de la tabla de empleados los N (N ser� un par�metro a 
--enviar al procedimiento) mejores empleados pagados y los inserte en una tabla llamada 
--TOP_salary( que deber� de tener la siguiente estructura: Employee_id, First_name, Last_name, 
--Salary, Job_name y Department_name).

create table top_salary
(employee_id Number(6),
 first_name Varchar2(20),
 last_name Varchar2(25),
 salary Number(8,2), 
 job_tittle Varchar2(35)
 departament_name Varchar2(30));

create or replace procedure top_sal(p_N number) is 
      Cursor c_emp is
		select e.employee_id, e.first_name, e.last_name, e.salary, j.job_title, d.department_name
		from employees e, jobs j, departments d
		where e.job_id = j.job_id 
			and e.department_id = d.department_id
			and rownum < =p_n
		order by salary desc;
	
	begin
	 for i in c_emp loop
		insert into top_salary 
		Values(i.employee_id, i.first_name, i.last_name, i.salary, i.job_title, i.department_name);
	 end loop;
end;


--2. Crear un procedimiento que identifique los Jefes de la tabla de empleados, e inserte un registro 
--en una tabla llamada Subordinados(con la siguiente estructura: First_name, Last_name, cantidad 
--de empleados a su cargo)

create  table subordinados
(first_name varchar2(20),
 last_name varchar2(25),
 cantidad number);

create or replace procedure obtener_subordinados is cursor c_emp is
	select e2.first_name, e2.last_name, count(e1.employee_id) cant
	  from employees e1, employees e2
	  where e1.manager id = e2.employee_id
	group by e2.first_name, e2.last_name;
begin
for i in c_emp loop
   insert into subordinados  
   values(i.first_name, i.last_name, i.cant);
end loop;
end;

/


--3. Elaborar una funci�n en la cual dado un c�digo de departamento(Par�metro) que retorne el c�digo 
--de empleado y salario de todos aquellos empleados que tenga un salario menor que el salario 
--m�nimo definido para su puesto o mayor al salario m�ximo definido para su puesto.

create or replace function retornar_empleados(p_deparment_id employees.department_id%type) return 
varchar2 is 
cursor c_emp is select e.employee_id, e.salary, j.min_salary, j.max_salary, e.department_id
	from employees e, jobs j 
	where e.job_id = j.job_id 
	and (e.salary > j.max_salary or
	     e.salary < j.min_salary);

v_empleados varchar2(2500);
begin
for i in c_emp loop
    v_empleados := (v_empleados||''||i.employee_id||':'||i.salary);
end loop;
return v_empleados; 
end;

declare
v_valores varchar2(2500);
begin 
v_valores := retornar_empleados(50);
dbms_output.put_line(v_valores);
end;

--4. Crear una funci�n que al indicar el country_id (P�rametro) retornara los nombres completos de 
--todos los empleados pertenecientes a ese pa�s.


create or replace function listar_empleados(p_country_id countries.country id%type) return varchar is 
cursor c_emp is select e.first_name, e.last_name
	from employees e, departments d, locations l
	where e.deparment_id = d.deparment_id
	and d.locations_id = l.location_id
	and l.country_id = p_country_id;

v_listado varchar2(2500);
begin
for i in c_emp loop
   v_listado := v.listado||'-'||i.first_name||''||i.last_name;
end loop;
return v_listado;
end;

--5. Crear paquete que contenga 3 procedimientos necesarios para realizar las operaciones de 
--Inserci�n, actualizaci�n y borrado de registros de la tabla Countries

create or replace package pkg_countries is
	  procedure insertar   (p_country_id countries.country_id%type,
			       p_country_name countries.country_name%type,
			       p_region_id countries.region_id%type);
	  procedure actualizar (p_country_id countries.country_id%type,
			       p_country_name countries.country_name%type,
			       p_region_id countries.region_id%type);
	  procedure borrar     (p_country_id countries.country_id%type);
end;

create or replace package body pkg_countries is
	procedure insertar (p_country_id countries.country_id$type,
			    p_country_name countries.country_name%type,
			    p_region_id countries.region_id%type) is
	begin
	     insert into countries
	     values(p_country_id, p_country_name, p_region_id);
	end;
	procedure actualizar (p_country_id countries.country_id%type,
			     p_country_name countries.country_name%type,
			     p_region_id countries.region_id%type) is
	begin
	     update countries
		set country_name = p_country_name,
		    region_id = p_region_id,
	     where country_id = p_country_id;
	end;
	procedure borrar (p_country_id countries.country_id%type) is
	begin
	     delete countries
	where country_id = p_country_id;
	end;
end;


