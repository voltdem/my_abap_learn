*&---------------------------------------------------------------------*
*& Report  ZNVM_Z01
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZNVM_Z01.


PARAMETERS:
  pa_int1 TYPE i,
  pa_int2 TYPE i,
  pa_op(1) TYPE c.

IF NOT ( ( pa_op = '+' ) OR
         ( pa_op = '-' ) OR
         ( pa_op = '*' ) ).

  WRITE 'Несуществующая или неподдерживаемая операция'(iop).

ELSE.

  CASE pa_op.
    WHEN '+'.
      pa_int1 = pa_int1 + pa_int2.
    WHEN '-'.
      pa_int1 = pa_int1 - pa_int2.
    WHEN '*'.
      pa_int1 = pa_int1 * pa_int2.
  ENDCASE.

  WRITE: 'Result:'(res), pa_int1.

ENDIF.