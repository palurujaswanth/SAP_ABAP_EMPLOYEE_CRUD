*&---------------------------------------------------------------------*
*& Report ZJAS_BASIC_PROGRAMMING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZJAS_BASIC_PROGRAMMING.
*PARAMETERS p_marks TYPE i.
*DATA lv_grade TYPE C LENGTH 1.
*if p_marks > 100 or p_marks < 0.
*  write 'Invalid Marks' .
*ELSE.
*if p_marks >= 75.
*  lv_grade = 'A'.
*elseif p_marks >= 50.
*  lv_grade = 'B'.
*elseif p_marks >= 35.
*  lv_grade = 'C'.
*else.
*  lv_grade = 'F'.
*WRITE: / 'Marks :' , p_marks , 'Grade :' , lv_grade.
*endif.
*ENDIF.

*PARAMETERS Age TYPE i.
*IF Age >= 18.
*  write 'You Are Eligible to Vote'.
*else.
*  write 'You Are Not Eligible to Vote'.
*ENDIF.

*PARAMETERS p_day TYPE i.
*CASE p_day.
*  WHEN 1.
*    WRITE / 'Monday'.
*  WHEN 2.
*    WRITE / 'Tuesday'.
*  WHEN 3.
*    WRITE / 'Wednesday'.
*  WHEN 4.
*    WRITE / 'Thursday'.
*  WHEN 5.
*    WRITE / 'Friday'.
*  WHEN 6.
*    WRITE / 'Saturday'.
*  WHEN OTHERS.
*    WRITE / 'Invalid Day Or Sunday'.
*ENDCASE.

data: lv_i type i value 1,
      lv_sum type i value 0.
while lv_i <= 3.
  lv_sum = lv_sum + lv_i.
  lv_i = lv_i + 1.
ENDWHILE.
WRITE: / 'Sum OF 1 to 3 = ', lv_sum.
