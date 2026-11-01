--se actualiza el saldo de la cuenta en la que se ingresa un cheque

--
CREATE OR REPLACE TRIGGER trg_op_i
    AFTER INSERT ON OP_I
    FOR EACH ROW

BEGIN
    UPDATE ACCOUNT
    SET BALANCE = BALANCE+ nvl(:new.AMOUNT,0)
    where ID = (SELECT cliente.ING_ACCOUNT_ID FROM "Cli-Acc" cliente
                        WHERE cliente.ID =
                              (SELECT op."Cli-Acc_id" FROM OPERATION op
                               WHERE op.COD_OP = :new.COD_OP)
                        );
end trg_op_i;
/

-- comprobamos que funciones
SELECT COD_OP FROM OPERATION WHERE COD_OP IN (1000, 1020);
SELECT COD_OP FROM OP_I WHERE OFFICE_ID_BANK = 1465 AND OFFICE_NUMBER = 13 AND CHECK_NUMBER IN (2001, 2020);
SELECT ID, BALANCE FROM ACCOUNT WHERE  ID =14;
SAVEPOINT prueba;

INSERT INTO OPERATION(cod_op, "date", "Cli-Acc_id") values (1014, SYSDATE,4 );
INSERT INTO OP_I(cod_op, office_id_bank, office_number, check_number, amount) VALUES
                                                                                  (1014, 1465, 13, 2011, 450);

--SELECT COD_OP, AMOUNT FROM OP_I WHERE COD_OP =1012;
--SELECT * FROM OPERATION WHERE COD_OP=1012;
SELECT ID, BALANCE FROM ACCOUNT WHERE ID=14;
ROLLBACK to prueba;