create table mensaje(
    id SERIAL PRIMARY KEY,
    remitente VARCHAR(50) NOT NULL,
    contenido TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
   
    commit;

    exception
      when others then
      rollback;

      raise notice 'Ocurrio un error se aplico rollback: %', sqlerrm;
      raise exception 'El error que impidio llevar a cabo la transaccion: %', sqlerrm;
end;
$$;

-- drop procedure sp_insertar_mensaje(); esto sirve si el SP no tiene parametros de entrada

drop procedure sp_insertar_mensaje(varchar, text, timestamp); -- para eliminar un SP en postrgres hay que poner el tipo de dato de los parametros de entrada

select *
from mensaje;