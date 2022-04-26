-- Andy Le
-- Q3
CLEAR SCREEN;
SET SERVEROUTPUT ON;
SET VERIFY OFF;

DECLARE
    v_nursing_unit_id nursing_units.nursing_unit_id%TYPE := '&sv_nursing_unit_id';
    CURSOR c_current_patients (
        i_nursing_unit_id IN admissions.nursing_unit_id%TYPE
    ) IS
    SELECT
        room,
        bed,
        patient_id
    FROM
        admissions
    WHERE
        nursing_unit_id = i_nursing_unit_id
        AND discharge_date IS NULL;

    CURSOR c_med (
        i_patient_id IN patients.patient_id%TYPE
    ) IS
    SELECT
        m.medication_description,
        u.dosage
    FROM
        unit_dose_orders u
        INNER JOIN medications m ON m.medication_id = u.medication_id
    WHERE
        u.patient_id = i_patient_id;

BEGIN
    dbms_output.put_line('Medication Report for: '
                         || v_nursing_unit_id
                         || chr(10));
    FOR r_patient IN c_current_patients(v_nursing_unit_id) LOOP
        dbms_output.put_line('Patient ID: '
                             || r_patient.patient_id
                             || ' Room: '
                             || r_patient.room
                             || ' Bed: '
                             || r_patient.bed);

        FOR r_med IN c_med(r_patient.patient_id) LOOP
            dbms_output.put_line('  Medication: '
                                 || r_med.medication_description
                                 || ': '
                                 || r_med.dosage);
        END LOOP;
    END LOOP;
END;