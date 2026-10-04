*&---------------------------------------------------------------------*
*& Modulpool SAPMZEMP_CRUD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
PROGRAM SAPMZEMP_CRUD.

* Table interface to bind fields directly between Screen Painter & ABAP
TABLES: ztb_emp, ztb_dept.

* Variable to store user actions (OK_CODE)
DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.

* Flag to control field readiness/editability
DATA: gv_mode TYPE c LENGTH 1 VALUE 'C'. " C = Create/Change, D = Display

*----------------------------------------------------------------------*
* Module STATUS_0100 OUTPUT (PBO)
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_100'.
  SET TITLEBAR 'TITLE_100'.
ENDMODULE.

*----------------------------------------------------------------------*
* Module USER_COMMAND_0100 INPUT (PAI)
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.

    WHEN 'DISPLAY'.
      IF ztb_emp-emp_id IS INITIAL.
        MESSAGE 'Please provide an Employee ID to search.' TYPE 'E'.
      ELSE.
        SELECT SINGLE *
          FROM ztb_emp
          INTO CORRESPONDING FIELDS OF ztb_emp
         WHERE emp_id = ztb_emp-emp_id.

        IF sy-subrc = 0.
          " Clear department work area before fetching
          CLEAR: ztb_dept-dept_name, ztb_dept-dept_head.

          " Fetch both Department Name and Department Head
          SELECT SINGLE dept_name, dept_head
            FROM ztb_dept
            INTO ( @ztb_dept-dept_name, @ztb_dept-dept_head )
           WHERE dept_id = @ztb_emp-dept_id.

          " Fallback check with leading zeros if department ID was padded
          IF sy-subrc <> 0.
            DATA(lv_disp_dept) = |{ ztb_emp-dept_id ALPHA = IN }|.
            SELECT SINGLE dept_name, dept_head
              FROM ztb_dept
              INTO ( @ztb_dept-dept_name, @ztb_dept-dept_head )
             WHERE dept_id = @lv_disp_dept.
          ENDIF.

          MESSAGE 'Employee details retrieved.' TYPE 'S'.
        ELSE.
          MESSAGE 'Employee ID not found. Enter data to create.' TYPE 'I'.
        ENDIF.
      ENDIF.

    WHEN 'SAVE'.
      IF ztb_emp-emp_id IS INITIAL.
        MESSAGE 'Employee ID is required.' TYPE 'E'.
      ELSE.
        " Ensure mandatory currency is populated
        IF ztb_emp-waers IS INITIAL.
          ztb_emp-waers = 'INR'.
        ENDIF.

        " Validate department exists
        SELECT SINGLE dept_id FROM ztb_dept
          INTO @DATA(lv_dept_check)
         WHERE dept_id = @ztb_emp-dept_id.
        IF sy-subrc <> 0.
          MESSAGE 'Invalid Department ID. Check ZTB_DEPT.' TYPE 'E'.
        ENDIF.

        MODIFY ztb_emp.
        IF sy-subrc = 0.
          COMMIT WORK.
          MESSAGE 'Employee record saved successfully.' TYPE 'S'.
        ELSE.
          ROLLBACK WORK.
          MESSAGE 'Error saving employee record.' TYPE 'E'.
        ENDIF.
      ENDIF.

    WHEN 'DELETE'.
      IF ztb_emp-emp_id IS INITIAL.
        MESSAGE 'Please specify an Employee ID to delete.' TYPE 'E'.
      ELSE.
        DELETE FROM ztb_emp WHERE emp_id = ztb_emp-emp_id.
        IF sy-subrc = 0.
          COMMIT WORK.
          CLEAR: ztb_emp, ztb_dept.
          MESSAGE 'Employee deleted successfully.' TYPE 'S'.
        ELSE.
          MESSAGE 'Record could not be deleted or does not exist.' TYPE 'E'.
        ENDIF.
      ENDIF.

    WHEN 'CLEAR'.
      CLEAR: ztb_emp, ztb_dept.
      MESSAGE 'Screen fields cleared.' TYPE 'S'.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
