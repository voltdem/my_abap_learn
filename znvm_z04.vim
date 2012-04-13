*&---------------------------------------------------------------------*
*& Report  ZNVM_Z04
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  znvm_z04.

PARAMETERS c_fr_fli TYPE spfli-cityfrom.
PARAMETERS c_to_fli TYPE spfli-cityto.

TYPES: BEGIN OF fli_type,
  carrid TYPE s_carr_id,
  connid TYPE s_conn_id,
END OF fli_type.

TYPES: BEGIN OF fli_typ2,
  carr_f TYPE s_carr_id,
  conn_f TYPE s_conn_id,
  carr_t TYPE s_carr_id,
  conn_t TYPE s_conn_id,
  city_p(20) TYPE c,
  END OF fli_typ2.

DATA wa_flight TYPE fli_type.
DATA wa_fligh2 TYPE fli_typ2.

DATA itab_flight TYPE STANDARD TABLE OF fli_type WITH NON-UNIQUE KEY carrid connid.
DATA itab_flight2 TYPE TABLE OF fli_typ2.

SELECT *
       FROM spfli
       INTO CORRESPONDING FIELDS OF TABLE itab_flight
       WHERE cityfrom = c_fr_fli AND cityto = c_to_fli.

IF sy-subrc = 0.
  LOOP AT itab_flight INTO wa_flight.
    WRITE: / wa_flight-carrid,
             wa_flight-connid.

  ENDLOOP.
ELSE.
  WRITE: 'Нет прямых вылетов из ', c_fr_fli, ' в ',  c_to_fli.
  NEW-LINE.
ENDIF.

SELECT DISTINCT p~carrid p~connid t~carrid t~connid  p~cityto
       FROM spfli as p INNER JOIN spfli as t ON p~cityto = t~cityfrom
       INTO TABLE itab_flight2
       WHERE p~cityfrom = c_fr_fli AND t~cityto = c_to_fli.

IF sy-subrc = 0.
  LOOP AT itab_flight2 INTO wa_fligh2.
    WRITE: / wa_fligh2-carr_f,
             wa_fligh2-conn_f,
             wa_fligh2-carr_t,
             wa_fligh2-conn_t,
             wa_fligh2-city_p.
  ENDLOOP.
ELSE.
  WRITE: 'Нет вылетов с пересадкой из ', c_fr_fli, ' в ',  c_to_fli.
ENDIF.