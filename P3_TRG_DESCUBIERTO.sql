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

----------------------
-- Punto 2

COMMIT; -- Iniciamos la transacción

savepoint prueba;
-- transferimos el doble del saldo disponible en la cuenta x a la cuenta y
        -- cuenta x: 2      -- cuenta y: 4

--insertamos la operacion en las tablas operation y op_d
INSERT INTO Operation("date","Cli-Acc_id") VALUES (SYSDATE, 4);
SELECT * FROM OPERATION;
INSERT INTO OP_D(COD_OP, AMOUNT, PERIODICITY, "OwnerAsAc-AsAc_id") VALUES (1040, (SELECT 2*Account.balance FROM Account WHERE ID= 2)
                                                                          , 'once', 2);
--actualizamos el balance de la cuenta y
UPDATE ACCOUNT SET BALANCE = (SELECT 2*Account.balance FROM Account WHERE ID= 2)
WHERE ID= 4;

-- vemos que la actualización se realizo con exito
SELECT * FROM ACCOUNT WHERE ID IN (2,4);

--decrementamos el saldo de la cuenta x con el doble del saldo que habia en el momento
UPDATE ACCOUNT SET BALANCE = BALANCE - 2*BALANCE WHERE ID= 2;
SELECT * FROM ACCOUNT WHERE ID=2;

rollback to prueba;

-- i. ¿que ha ocurrido con X,Y y la operacion d ?
/** Luego de la transferencia (punto b), la transferencia se inserta dentro de las tablas OP_D y Operation, la cuenta X permanece con
  el mismo saldo y la cuenta Y con el saldo que ya tenía mas el doble del saldo disponible en la cuenta X
  **/


-- ii.

savepoint pruebaii;
INSERT INTO OP_D(COD_OP, AMOUNT, PERIODICITY, "OwnerAsAc-AsAc_id") VALUES (1040, (SELECT 2*Account.balance FROM Account WHERE ID= 2)
                                                                          , 'once', 2);
--actualizamos el balance de la cuenta y
UPDATE ACCOUNT SET BALANCE = (SELECT 2*Account.balance FROM Account WHERE ID= 2)
WHERE ID= 4;
-- vemos que la actualización se realizo con exito
SELECT * FROM ACCOUNT WHERE ID IN (2,4);
COMMIT;
--decrementamos el saldo de la cuenta x con el doble del saldo que habia en el momento
UPDATE ACCOUNT SET BALANCE = BALANCE - 2*BALANCE WHERE ID= 2;
SELECT * FROM ACCOUNT WHERE ID=2;
rollback to pruebaii;

/**
  Al hacer el commit antes del paso f se confirma de manera permanente e irreversible la inserción y el aumento del saldo de la cuenta Y
  aun teniendo un rollback no vuelve a su estado anterior. No se obtiene el mismo resultado porque la suma del saldo de la cuenta Y debería
  de cancelarse al intentar sacar el saldo de la cuenta X, al poner el commit la extracción del saldo X no se realiza pero el aumento
  de la cuenta Y si, rompiendo asi el principio de atomicidad
 */

 --iii.
BEGIN
    SAVEPOINT P1;
    INSERT INTO OP_D(COD_OP, AMOUNT, PERIODICITY, "OwnerAsAc-AsAc_id") VALUES (1040, (SELECT 2*Account.balance FROM Account WHERE ID= 2)
                                                                              , 'once', 2);
--actualizamos el balance de la cuenta y
    UPDATE ACCOUNT SET BALANCE = (SELECT 2*Account.balance FROM Account WHERE ID= 2)
    WHERE ID= 4;

--decrementamos el saldo de la cuenta x con el doble del saldo que habia en el momento
    UPDATE ACCOUNT SET BALANCE = BALANCE - 2*BALANCE WHERE ID= 2;


EXCEPTION
    WHEN OTHERS THEN ROLLBACK TO P1;

end;

/**
  Al ejecutarlo dentro de un bloque PL/SQL, que cuenta con manejo de excepciones, podemos garantizar la atomicidad

 */

 -- iv. Considero que no es necesario ya que se pueden hacer comprobaciones simples dentro de la propia consulta
-- aunque en caso de necesitar comprobar mas campos se podría optar por un disparador para mantener legibilidad del codigo