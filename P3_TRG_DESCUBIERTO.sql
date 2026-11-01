-- Trigger que evita que se realicen descubiertos > 10%
-- del saldo de la cuenta

-- el trigger será antes de la actualización por filas

CREATE OR REPLACE  TRIGGER trg_descubierto
    BEFORE  UPDATE OF BALANCE  ON ACCOUNT -- dentro de la tabla cuentas
    FOR EACH ROW
    BEGIN
        IF :OLD.BALANCE >0 THEN -- balance positivo
            IF :NEW.BALANCE < ((:OLD.BALANCE*0.10)*-1)  THEN
                RAISE_APPLICATION_ERROR(-20000, 'No es posible hacer una extracción mayor que el 110% del saldo');
            end if;
        ELSE  --balance negativo
            IF :NEW.BALANCE < :OLD.BALANCE THEN
                RAISE_APPLICATION_ERROR(-20000, 'No es posible hacer extracciones con saldo negativo o nulo');
            END IF;
        end if;
    end;
/

-- LA SIG HACE QUE SALTE EL TRIGGER CON LOS DATOS ACTUALES DE LA TABLA
UPDATE ACCOUNT
SET BALANCE = -1100
WHERE ID = 1;
SELECT * FROM ACCOUNT WHERE ID=1;


