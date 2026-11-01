DROP TABLE SALDO_FI;
CREATE TABLE SALDO_FI(
    cod_fi varchar(10) PRIMARY KEY,
    saldo NUMBER(15,2)
);

--EL PROCEDIMIENTO UTILIZA LAS TABLAS FUND, DONDE ESTA LA INFO DE LOS FONDOS
-- Y LA TABAL OP_OSRFI DONDE ESTA LA INFO DE LAS OPERAICONE S

-- PROCEDIMIENTO PARA CARGA INICIAL DE TABAL
CREATE OR REPLACE PROCEDURE saldo_fi_proced IS -- dado que la tabla estará vacia, no tendrá parametros de entrada
    CURSOR saldo_fi_cursor IS
        SELECT f.id,
               NVL((SELECT SUM(CASE op.OPERATION
                                   WHEN 'subscription' THEN op.AMOUNT
                                   WHEN 'refund' THEN -op.AMOUNT
                                   ELSE 0
                   END)
                    FROM OP_OSRFI op
                    WHERE op.FUND_ID = f.id), 0) AS saldo_total
        FROM FUND f;

    -- var para almacenar dtos extraidos de cada fila
    id_fondo FUND.ID%type; -- var para almacenar los id
    cant     OP_OSRFI.AMOUNT%type; -- var para almacenar los montos

BEGIN

    OPEN saldo_fi_cursor; --abrimos el cursor

    LOOP
        FETCH saldo_fi_cursor INTO id_fondo, cant; -- sacamos la fila actual y la almacenamos en las variables
        EXIT WHEN saldo_fi_cursor%NOTFOUND; -- salimos cuando no quedan filas

        INSERT INTO SALDO_FI(cod_fi, saldo) VALUES (id_fondo, cant); -- insertamos en la tabla creada los valores

    end loop;
    CLOSE saldo_fi_cursor; -- al terminar cerramos el curso
    COMMIT;
END saldo_fi_proced;
/

BEGIN
    saldo_fi_proced;
END;
SELECT * FROM SALDO_FI order by cod_fi;