--Asociado tabla OSRFI
-- mantiene la tabla actualizada, cada vez que se recibe una OSRFIA
-- el disparador se ejecuta y realiza la modificacion de SALDO_FI

CREATE OR REPLACE TRIGGER trg_saldo_fi
    AFTER INSERT ON OP_OSRFI
    FOR EACH ROW
    DECLARE -- declaramos variables auxiliarss
        saldo_actual SALDO_FI.SALDO%type;
        nuevo_saldo SALDO_FI.SALDO%type;

    BEGIN
        SELECT saldo INTO saldo_actual FROM SALDO_FI WHERE COD_FI = :NEW.FUND_ID;

        IF :new.OPERATION = 'subscription' THEN -- se suma el nuevo amoinr
            nuevo_saldo := saldo_actual + :new.AMOUNT;

        ELSIF :new.OPERATION = 'refund' THEN  -- se resta el nuevo amount
            nuevo_saldo := saldo_actual - :new.AMOUNT;
        ELSE
            nuevo_saldo := saldo_actual;
        end if;

        UPDATE SALDO_FI
        SET saldo = nuevo_saldo
        WHERE COD_FI = :new.FUND_ID;

    end trg_saldo_fi;
/
SELECT COD_FI, SALDO FROM SALDO_FI WHERE COD_FI=1;
SELECT COD_OP FROM OPERATION WHERE COD_OP IN (1001, 1005);
SELECT  CONTRACT_NUMBER FROM OP_OSRFI WHERE CONTRACT_NUMBER IN (1021, 1030);


-- probamos
SELECT * FROM SALDO_FI;
--comprobamos que se sume
INSERT INTO OPERATION(cod_op, "date", "Cli-Acc_id") values (1001, SYSDATE,1 );
INSERT INTO OP_OSRFI(cod_op, contract_number, amount, operation, fund_id) VALUES (1001, 1021, 45,'subscription', 1);

SELECT * FROM SALDO_FI;

INSERT INTO OPERATION(cod_op, "date", "Cli-Acc_id") values (1002, SYSDATE,1 );
INSERT INTO OP_OSRFI(cod_op, contract_number, amount, operation, fund_id) VALUES (1002, 1022, -45,'subscription', 1);

SELECT * FROM SALDO_FI;
-- ahora comprobamos la resta