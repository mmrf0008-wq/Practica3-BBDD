-- crear objeto de tipo secuencia
-- un disparador que incrementa automaticamente el id de la tabla OPERATION

--creamos la secuencia
DROP SEQUENCE op_id_seq;
CREATE  SEQUENCE op_id_seq
INCREMENT BY 1 START WITH 1014;

-- creamos el trigger
CREATE OR REPLACE TRIGGER op_trigger
    BEFORE INSERT ON OPERATION
    FOR EACH ROW
    BEGIN
            :NEW.COD_OP := op_id_seq.nextval;

    end;
/
-- comprobamos  insertando
savepoint prueba;

INSERT INTO OPERATION("date", "Cli-Acc_id") VALUES (SYSDATE, 14);
INSERT INTO OPERATION("date", "Cli-Acc_id") VALUES (SYSDATE, 14);
SELECT * FROM OPERATION;

ROLLBACK TO prueba;