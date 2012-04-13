*&---------------------------------------------------------------------*
*& Report  ZNVM_Z07
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  znvm_z07.

TYPES: BEGIN OF tcity,
       city TYPE sgeocity-city,
  END OF tcity.

DATA gcity TYPE TABLE OF tcity.

TABLES: scarr, spfli, sflight.

SELECT-OPTIONS da_car FOR sflight-fldate.
PARAMETERS cifrom TYPE spfli-cityfrom.

TYPES: BEGIN OF fli_type,
  carrid TYPE s_carr_id,
  connid TYPE s_conn_id,
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

AT SELECTION-SCREEN.

  SELECT city
    FROM sgeocity
    INTO CORRESPONDING FIELDS OF TABLE gcity
    WHERE city = cifrom.

  FREE gcity.

  IF sy-subrc <> 0.
    MESSAGE 'Такого города нет в списке аэропортов' TYPE 'E'.
  ENDIF.



START-OF-SELECTION.

  SELECT sflight~carrid sflight~connid fldate seatsmax seatsocc cityfrom cityto arrtime deptime
         FROM spfli INNER JOIN sflight
         ON sflight~carrid = spfli~carrid AND sflight~connid = spfli~connid
         INTO CORRESPONDING FIELDS OF TABLE itab_flight
         WHERE fldate IN da_car.

  IF sy-subrc = 0.

    PERFORM procc_data
                CHANGING
                    itab_flight.

    PERFORM write_res
                USING
                    itab_flight
                CHANGING wa_flight.

  ELSE.
    WRITE: 'No flights found !'.
  ENDIF.


AT LINE-SELECTION.
  IF sy-lsind = 1.

    SELECT SINGLE *
      FROM scarr
      WHERE carrid = wa_flight-carrid.
    SELECT SINGLE *
      FROM spfli
      WHERE carrid = wa_flight-carrid AND deptime = wa_flight-deptime
        AND arrtime = wa_flight-arrtime.

    CALL SCREEN 100.

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
    HIDE: lwa-carrid,
          lwa-deptime,
          lwa-arrtime.
  ENDLOOP.

ENDFORM.                    "write_res

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR 'TEST100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  IF sy-ucomm = 'BACK'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0100  INPUT