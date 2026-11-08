create table mensaje(
    id SERIAL PRIMARY KEY,
    remitente VARCHAR(50) NOT NULL,
    contenido TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table log_operaciones(
    id serial primary key,
    nombre_tabla varchar(100) not null,
    operacion varchar(20) not null,
    usuario varchar(100) default current_user,
    fecha_hora timestamp CURRENT_TIMESTAMP,
    datos_anteriores jsonb,
    datos_nuevos jsonb
);

-- Indice
create index idx_mensaje_remitente on mensaje(remitente, fecha desc);

/*create or replace function validar_fecha()
retruns trigger as $$ 
-- declare fecha_acutal timestamp := current_timestamp; -- el declare siempre va antes del begin, en triggers o SP
begin
	if new.fecha is distinct from current_timestamp then
    raise exception 'La fecha no es correcta';
    end if;

    return new;
end;
$$ language plpgsql;*/

-- Trigger
-- Mensaje
create or replace function validar_fecha()
returns trigger as $$ 
begin
    IF NEW.fecha IS DISTINCT FROM CURRENT_TIMESTAMP THEN
    raise exception 'La fecha no es correcta';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger tg_validador_fecha
after insert on mensaje
for each row
execute function validar_fecha();

-- Mensaje
create or replace function proteger_hitosrial()
returns trigger as $$
begin
	raise exception 'No esta permitido modificar ni eliminar el historial de mesnajes';
end;
$$ language plpgsql; 

create trigger tg_proteger_mensajes
before update or delete on mensajes
for each row
execute function proteger_hitosrial();

-- Log_operaciones
create or replace function fn_log_auditoria()
returns trigger as $$
begin
	  if(tg_op = 'INSERT') then -- tg_op guarda la operacion CRUD realizada
        insert into log_operaciones(nombre_tabla, operacion, usuario, fecha_hora, datos_anteriores, datos_nuevos)
        values(tg_realname, tg_op, to_jsonb(new)); -- tg_realname guarda de forma automatica el nombre d ela tabla
        return new;
      elsif(tg_op = 'UPDATE') then
        insert into log_operaciones(nombre_tabla, operacion, usuario, fecha_hora, datos_anteriores, datos_nuevos)
        values(tg_realname, tg_op, to_jsonb(old), to_jsonb(new)); 
        return new;
      elsif(tg_op = 'DELETE') then
        insert into log_operaciones(nombre_tabla, operacion, usuario, fecha_hora, datos_anteriores, datos_nuevos)
        values(tg_realname, tg_op, to_jsonb(old));
        return old;
      end if,;
      return null;
end;
$$ language plpgsql;

create trigger tg_log_auditoria
after insert on update or delete on mensajes
for each row
execute function fn_log_auditoria();


-- SP
create or replace procedure sp_insertar_mensaje(
    p_remitente varchar, p_contenido text, p_fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
)
language plpgsql
as $$
begin
	if p_remitente is null then
       raise exception 'El remitente no puede ser nulo';
    elsif p_contenido is null then
       raise exception 'El contenido no puede ser nulo';
    end if;

    insert into mensaje(remitente, contenido, fecha)
    values(p_remitente, p_contenido, p_fecha);
   
    exception
      when others then
      raise notice 'Ocurrio un error se aplico rollback: %', sqlerrm;
      raise exception 'El error que impidio llevar a cabo la transaccion: %', sqlerrm;
end;
$$;

-- drop procedure sp_insertar_mensaje(); esto sirve si el SP no tiene parametros de entrada

drop procedure sp_insertar_mensaje(varchar, text, timestamp); -- para eliminar un SP en postrgres hay que poner el tipo de dato de los parametros de entrada

-- Vista
-- mensaje
create view mostrar_ultimo_mensaje as(
     select distinct on (remitente) id, contenido, fecha
     from mensaje
     order by remitente, fecha desc
);

-- log_operaciones
create view vista_auditoria as(
    select id, 
           nombre_tabla as tabla,
           operacion as accion,
           usuario as ejecutado_por,
           to_char(fecha_hora, 'DD/MM/YYYY HH24:MI:SS') as fecha_hora, -- convierte el valor de tipo fecha a caracteres 
           case 
           	   when operacion = 'UPDATE' then 'Modifico registros'
           	   when operacion = 'INSERT' then 'Inserto regitors'
           	   else 'Elimino registros'
           end as descripcion
     from log_operaciones
     order by fecha_hora desc       
);
select *
from mensaje;
