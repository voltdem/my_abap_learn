*&---------------------------------------------------------------------*
*& Report  ZNVM_Z05
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  znvm_z05.

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

TYPES it_fli TYPE STANDARD TABLE OF fli_type WITH NON-UNIQUE KEY carrid connid.

DATA dat_car TYPE net200_tt_scarr.
DATA wa_car LIKE LINE OF dat_car.

DATA itab_flight TYPE it_fli.
DATA wa_flight LIKE LINE OF itab_flight.

SELECT sflight~carrid sflight~connid fldate seatsmax seatsocc cityfrom cityto arrtime deptime
       FROM spfli INNER JOIN sflight
       ON sflight~carrid = spfli~carrid AND sflight~connid = spfli~connid
       INTO CORRESPONDING FIELDS OF TABLE itab_flight
       WHERE fldate = da_car.

IF sy-subrc = 0.

  PERFORM procc_data
              CHANGING
                  itab_flight.

  PERFORM write_res
              USING
                  itab_flight
              CHANGING wa_flight.

ELSE.
  WRITE: 'No ', da_car, 'flights found !'.
ENDIF.


AT LINE-SELECTION.
  IF sy-lsind = 1.

    SELECT *
      FROM scarr
      INTO CORRESPONDING FIELDS OF TABLE dat_car
      WHERE carrid = wa_flight-carrid.

    WRITE text-001.
    ULINE.

    LOOP AT dat_car INTO wa_car.
      WRITE: /   wa_car-carrid,
                 wa_car-carrname,
                 wa_car-currcode,
                 wa_car-url.
    ENDLOOP.

  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  procc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(ITAB_FLIGHT)  text
*----------------------------------------------------------------------*
FORM procc_data
      CHANGING value(lt_flight) TYPE it_fli.

  FIELD-SYMBOLS <fs_flight> TYPE fli_type.

  LOOP AT lt_flight ASSIGNING <fs_flight>.
    <fs_flight>-time = <fs_flight>-arrtime - <fs_flight>-deptime.
    <fs_flight>-percentage = ( <fs_flight>-seatsocc / <fs_flight>-seatsmax ) * 100.
  ENDLOOP.

  SORT lt_flight BY percentage.

ENDFORM.                    "procc_data

*&---------------------------------------------------------------------*
*&      Form  write_res
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(LT_FLIGHT)  text
*----------------------------------------------------------------------*
FORM write_res
      USING value(lt_flight) TYPE it_fli
      CHANGING lwa TYPE fli_type.


  LOOP AT lt_flight INTO lwa.
    WRITE: /   lwa-carrid COLOR = 5,
               lwa-connid,
               lwa-time,
               lwa-seatsmax,
               lwa-seatsocc,
               lwa-percentage, '%'.
    HIDE lwa-carrid.
  ENDLOOP.

ENDFORM.                    "write_res