-- Andy Le
-- Q1  
SET SERVEROUTPUT ON;
SET VERIFY OFF;
CLEAR SCREEN;

CREATE OR REPLACE PACKAGE final_api AS
    FUNCTION get_doc (
        v_specialty physicians.specialty%TYPE
    ) RETURN physicians.physician_id%TYPE;

    PROCEDURE discharge_patients (
        v_nursing_unit_id IN nursing_units.nursing_unit_id%TYPE,
        v_count           OUT NUMBER
    );

END final_api;

CREATE OR REPLACE PACKAGE BODY final_api AS

    FUNCTION get_doc (
        v_specialty physicians.specialty%TYPE
    ) RETURN physicians.physician_id%TYPE AS
        v_physician_id physicians.physician_id%TYPE;
    BEGIN
        SELECT
            physicians_id
        INTO v_physician_id
        FROM
            physicians
        WHERE
            UPPER(specialty) LIKE UPPER('%' + v_specialty + '%')
            and ROWNUM < 2;
        RETURN v_physician_id;
    END get_doc;

    PROCEDURE discharge_patients (
        v_nursing_unit_id IN nursing_units.nursing_unit_id%TYPE,
        v_count           OUT NUMBER
    ) IS
        v_count_encouters NUMBER;
        CURSOR c_patients IS
        SELECT
            patient_id,
            discharge_date
        FROM
            admissions
        WHERE
            discharge_date IS NULL
            AND nursing_unit_id = v_nursing_unit_id
        FOR UPDATE;

    BEGIN
        v_count := 0;
        FOR v_patients IN c_patients LOOP
            v_count_encounters := 0;
            SELECT
                COUNT encounter_date_time
            INTO v_count_encounters
            FROM
                encouters
            WHERE
                v_patients.patient_id = encounters.patient_id;

            IF v_count_encouters > 0 THEN
                UPDATE admissions
                SET
                    discharge_date = sysdate
                WHERE
                    admissions.patient_id = v_patients.patient_id;
                v_count := v_count + 1;
            END IF;

        END LOOP;

    END discharge_patients;

END final_api;