*&---------------------------------------------------------------------*
*& Report  ZNVM_Z03
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  znvm_z03.

PARAMETERS da_car TYPE s_date.

TYPES: BEGIN OF fli_type,
  carrid TYPE s_carr_id,
  connid TYPE s_conn_id,
  cityfrom TYPE s_from_cit,
  cityto  TYPE s_to_city,
  seatsmax TYPE s_seatsmax,
  seatsocc TYPE s_seatsocc,
  deptime TYPE s_dep_time,
  arrtime TYPE s_arr_time,
  time TYPE tims,
  percentage TYPE p DECIMALS 2,
END OF fli_type.

*Использование указателя, используется обычно в loop  endloop для обращения непосредственно к строке таблицы
FIELD-SYMBOLS <fs_flight> TYPE fli_type.

DATA wa_flight TYPE fli_type.

*Определение таблицы с собсвенным типом данных
DATA itab_flight TYPE STANDARD TABLE OF fli_type WITH NON-UNIQUE KEY carrid connid.

SELECT sflight~carrid sflight~connid fldate seatsmax seatsocc cityfrom cityto arrtime deptime
       FROM spfli INNER JOIN sflight
       ON sflight~carrid = spfli~carrid AND sflight~connid = spfli~connid
       INTO CORRESPONDING FIELDS OF TABLE itab_flight
       WHERE fldate = da_car.

IF sy-subrc = 0.

  LOOP AT itab_flight ASSIGNING <fs_flight>.
*Вычисление производятся непосредственно со строками таблицы
    <fs_flight>-time = <fs_flight>-arrtime - <fs_flight>-deptime.
    <fs_flight>-percentage = ( <fs_flight>-seatsocc / <fs_flight>-seatsmax ) * 100.
  ENDLOOP.

*Сортировка по полю percentage
  SORT itab_flight BY percentage.

  LOOP AT itab_flight INTO wa_flight.
    WRITE: / wa_flight-carrid,
               wa_flight-connid,
               wa_flight-time,
               wa_flight-seatsmax,
               wa_flight-seatsocc,
               wa_flight-percentage, '%'.
  ENDLOOP.
ELSE.
  WRITE: 'No ', da_car, 'flights found !'.
ENDIF.