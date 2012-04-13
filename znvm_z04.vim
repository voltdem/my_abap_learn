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

*Объявляем пользовательский тип данных
TYPES: BEGIN OF fli_type,
  carr_f TYPE s_carr_id,
  conn_f TYPE s_conn_id,
  carr_t TYPE s_carr_id,
  conn_t TYPE s_conn_id,
  city_p(20) TYPE c,
  END OF fli_type.

*Определяем переменные
DATA: res TYPE i,"результат выборки прямых рейсов

      itab_flight TYPE TABLE OF fli_type,"Таблица результатов
      wa_flight LIKE LINE OF itab_flight."Рабочая область для таблицы результатов

*Выборка прямых рейсов
SELECT DISTINCT spfli~carrid AS carr_f spfli~connid AS conn_f
       FROM spfli
       INTO CORRESPONDING FIELDS OF TABLE itab_flight
       WHERE cityfrom = c_fr_fli AND cityto = c_to_fli.

res = sy-subrc.

*Выборка рейсов с 1 пересадкой
SELECT DISTINCT p~carrid p~connid t~carrid t~connid  p~cityto
       FROM spfli AS p INNER JOIN spfli AS t ON p~cityto = t~cityfrom
       APPENDING TABLE itab_flight
       WHERE p~cityfrom = c_fr_fli AND t~cityto = c_to_fli.


IF ( res = 0 ) OR ( sy-subrc = 0 ) .
  LOOP AT itab_flight INTO wa_flight.
    IF wa_flight-conn_t <> 0."Если второй индентификатор рейса есть, выводим все столбцы
      WRITE: / wa_flight-carr_f,
               wa_flight-conn_f,
               wa_flight-carr_t,
               wa_flight-conn_t,
               wa_flight-city_p.
    ELSE."Иначе выводим данные только прямого рейса
      WRITE: / wa_flight-carr_f,
               wa_flight-conn_f.
    ENDIF.
  ENDLOOP.
ELSE.
  WRITE: 'Нет прямых авиарейсов и авиарейсов с одной пересадкой из ', c_fr_fli, ' в ',  c_to_fli.
ENDIF.