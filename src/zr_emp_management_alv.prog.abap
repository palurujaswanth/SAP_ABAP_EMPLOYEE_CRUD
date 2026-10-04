*&---------------------------------------------------------------------*
*& Report ZR_EMP_MANAGEMENT_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZR_EMP_MANAGEMENT_ALV.

TYPE-POOLS: slis.

*----------------------------------------------------------------------*
* Data Types & Structures
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_emp_out,
         emp_id     TYPE ztb_emp-emp_id,
         first_name TYPE ztb_emp-first_name,
         last_name  TYPE ztb_emp-last_name,
         dept_id    TYPE ztb_emp-dept_id,
         dept_name  TYPE ztb_dept-dept_name,
         join_date  TYPE ztb_emp-join_date,
         salary     TYPE ztb_emp-salary,
         waers      TYPE ztb_emp-waers,
         status     TYPE ztb_emp-status,
       END OF ty_emp_out.

DATA: gt_emp_out  TYPE STANDARD TABLE OF ty_emp_out,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.

* Tables declaration for selection screen dictionary references
TABLES: ztb_emp.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_dept  FOR ztb_emp-dept_id,
                  s_date  FOR ztb_emp-join_date.
  PARAMETERS:     p_stat  TYPE ztb_emp-status DEFAULT 'A'.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Initialization & Text-elements
*----------------------------------------------------------------------*
INITIALIZATION.
  %_s_dept_%_app_%-text = 'Department ID'.
  %_s_date_%_app_%-text = 'Joining Date'.
  %_p_stat_%_app_%-text = 'Status (A/I)'.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data.

END-OF-SELECTION.
  IF gt_emp_out IS INITIAL.
    MESSAGE 'No employees found matching the criteria.' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM build_fieldcatalog.
    PERFORM build_layout.
    PERFORM display_alv.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
FORM fetch_data.
  SELECT e~emp_id,
         e~first_name,
         e~last_name,
         e~dept_id,
         d~dept_name,
         e~join_date,
         e~salary,
         e~waers,
         e~status
    FROM ztb_emp AS e
    LEFT OUTER JOIN ztb_dept AS d
      ON e~dept_id = d~dept_id
    INTO TABLE @gt_emp_out
   WHERE e~dept_id   IN @s_dept
     AND e~join_date IN @s_date
     AND e~status    =  @p_stat.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_fieldcatalog
*&---------------------------------------------------------------------*
FORM build_fieldcatalog.
  DATA: ls_fc TYPE slis_fieldcat_alv.

  CLEAR gt_fieldcat.

  DEFINE add_col.
    CLEAR ls_fc.
    ls_fc-col_pos   = &1.
    ls_fc-fieldname = &2.
    ls_fc-seltext_m = &3.
    ls_fc-hotspot   = &4.
    ls_fc-cfieldname = &5.
    APPEND ls_fc TO gt_fieldcat.
  END-OF-DEFINITION.

  add_col 1 'EMP_ID'     'Employee ID'    'X' ''.
  add_col 2 'FIRST_NAME' 'First Name'     ''  ''.
  add_col 3 'LAST_NAME'  'Last Name'      ''  ''.
  add_col 4 'DEPT_ID'    'Dept ID'        ''  ''.
  add_col 5 'DEPT_NAME'  'Department'     ''  ''.
  add_col 6 'JOIN_DATE'  'Join Date'      ''  ''.
  add_col 7 'SALARY'     'Monthly Salary' ''  'WAERS'.
  add_col 8 'WAERS'      'Currency'       ''  ''.
  add_col 9 'STATUS'     'Status'         ''  ''.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_layout
*&---------------------------------------------------------------------*
FORM build_layout.
  CLEAR gs_layout.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
FORM display_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat
    TABLES
      t_outtab                = gt_emp_out
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error loading ALV Grid' TYPE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form user_command (Interactive Navigation)
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  IF r_ucomm = '&IC1'. " Standard ALV Double Click / Hotspot Click
    IF rs_selfield-fieldname = 'EMP_ID' AND rs_selfield-value IS NOT INITIAL.
      " Display Department info popup for the selected employee
      READ TABLE gt_emp_out INTO DATA(ls_emp) INDEX rs_selfield-tabindex.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM ztb_dept INTO @DATA(ls_dept)
          WHERE dept_id = @ls_emp-dept_id.

        IF sy-subrc = 0.
          DATA(lv_msg) = |Employee: { ls_emp-first_name } { ls_emp-last_name } | &
                         |belongs to { ls_dept-dept_name } (Head: { ls_dept-dept_head }).|.
          MESSAGE lv_msg TYPE 'I'.
        ELSE.
          MESSAGE 'Department details not found' TYPE 'I'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
