SET SCHEMA PAL;

-- test data
DROP TABLE SOCIAL_NETWORK;
CREATE COLUMN TABLE SOCIAL_NETWORK (NODE1 VARCHAR(10), NODE2 VARCHAR(10));
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Philip','Bob');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Philip','Jamie');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Bob','Jamie');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Jamie','Joe');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Denys','Philip');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Julie','Joe');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Julie','Bob');
INSERT INTO SOCIAL_NETWORK (NODE1, NODE2) VALUES ('Joe','Bob');

-- cleanup
DROP TYPE PAL_T_LP_DATA;
DROP TYPE PAL_T_LP_PARAMS;
DROP TYPE PAL_T_LP_RESULTS;
DROP TABLE PAL_LP_SIGNATURE;
CALL SYSTEM.AFL_WRAPPER_ERASER ('PAL_LP');
DROP TABLE LP_RESULTS;

-- PAL setup
CREATE TYPE PAL_T_LP_DATA AS TABLE (NODE1 VARCHAR(10), NODE2 VARCHAR(10));
CREATE TYPE PAL_T_LP_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));
CREATE TYPE PAL_T_LP_RESULTS AS TABLE (NODE1 VARCHAR(10), NODE2 VARCHAR(10), SCORE DOUBLE);

CREATE COLUMN TABLE PAL_LP_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_LP_SIGNATURE VALUES (1, 'PAL.PAL_T_LP_DATA', 'in');
INSERT INTO PAL_LP_SIGNATURE VALUES (2, 'PAL.PAL_T_LP_PARAMS', 'in');
INSERT INTO PAL_LP_SIGNATURE VALUES (3, 'PAL.PAL_T_LP_RESULTS', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_LP', 'AFLPAL', 'LINKPREDICTION', PAL_LP_SIGNATURE);

-- app setup

CREATE COLUMN TABLE LP_RESULTS LIKE PAL_T_LP_RESULTS;

-- app runtime

DROP TABLE #LP_PARAMS;
CREATE LOCAL TEMPORARY COLUMN TABLE #LP_PARAMS LIKE PAL_T_LP_PARAMS;
INSERT INTO #LP_PARAMS VALUES ('THREAD_NUMBER', 2, null, null);
INSERT INTO #LP_PARAMS VALUES ('METHOD', 1, null, null); 1:Common Neighbors, 2:Jaccard's, 3:Adamic/Adar, 4:Katz
--INSERT INTO #LP_PARAMS VALUES ('BETA', null, 0.1, null); 0-1 for use with Katz method (4)

TRUNCATE TABLE LP_RESULTS;

CALL _SYS_AFL.PAL_LP (SOCIAL_NETWORK, #LP_PARAMS, LP_RESULTS) WITH OVERVIEW;

SELECT * FROM SOCIAL_NETWORK;
SELECT * FROM LP_RESULTS ORDER BY SCORE DESC;
