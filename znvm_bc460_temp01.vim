*&---------------------------------------------------------------------*
*& Report  ZNVM_BC460_TEMP01
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  znvm_bc460_temp01.

TABLES spfli.

SELECT-OPTIONS c_from FOR spfli-cityfrom NO INTERVALS.
SELECT-OPTIONS c_to  FOR spfli-cityto NO INTERVALS.

*
TYPES: BEGIN OF data_fli,
    cityfrom TYPE spfli-cityfrom,"Город отправления
    airpfrom TYPE spfli-airpfrom,"Аэропорт отправления
    cityto  TYPE spfli-cityto,"Город прибытия
    airpto TYPE spfli-airpto,"Аэропорт прибытия
    distance TYPE spfli-distance,"расстояние
    fltime  TYPE spfli-fltime,"Продолжительность полета
  END OF data_fli.

DATA itab_data TYPE STANDARD TABLE OF data_fli. "Таблица с выбранными данными
DATA lwa_data LIKE LINE OF itab_data."Рабочая область

DATA counter TYPE i VALUE 0." Счетчик выведенных записей

*Выборка данных в соответствии с заданными данными
SELECT *
  FROM spfli
  INTO CORRESPONDING FIELDS OF TABLE itab_data
  WHERE ( spfli~cityfrom IN c_from ) AND ( spfli~cityto IN c_to ).

*Открытие формы
CALL FUNCTION 'OPEN_FORM'
 EXPORTING
*   APPLICATION                       = 'TX'
*   ARCHIVE_INDEX                     =
*   ARCHIVE_PARAMS                    =
    device                            = 'PRINTER'
*   DIALOG                            = 'X'
    form                              = 'ZNVM_BC460_T01'
*    language                          = sy-langu
*    OPTIONS                           = ITCP0
*   MAIL_SENDER                       =
*   MAIL_RECIPIENT                    =
*   MAIL_APPL_OBJECT                  =
*   RAW_DATA_INTERFACE                = '*'
*   SPONUMIV                          =
* IMPORTING
*   LANGUAGE                          =
*   NEW_ARCHIVE_PARAMS                =
*   RESULT                            =
 EXCEPTIONS
    canceled                          = 1
*   DEVICE                            = 2
    form                              = 3
*   OPTIONS                           = 4
    unclosed                          = 5
*   MAIL_OPTIONS                      = 6
*   ARCHIVE_ERROR                     = 7
*   INVALID_FAX_NUMBER                = 8
*   MORE_PARAMS_NEEDED_IN_BATCH       = 9
*   SPOOL_ERROR                       = 10
*   CODEPAGE                          = 11
*   OTHERS                            = 12
          .
IF sy-subrc <> 0.
  MESSAGE 'Error is open_form' TYPE 'E'.
ENDIF.

*Запуск формы
CALL FUNCTION 'START_FORM'
 EXPORTING
*   ARCHIVE_INDEX          =
    form                   = 'ZNVM_BC460_T01'
    language               = sy-langu
*   STARTPAGE              = ' '
*   PROGRAM                = ' '
*   MAIL_APPL_OBJECT       =
* IMPORTING
*   LANGUAGE               =
 EXCEPTIONS
    form                   = 1
    format                 = 2
*   UNENDED                = 3
*   UNOPENED               = 4
*   UNUSED                 = 5
*   SPOOL_ERROR            = 6
*   CODEPAGE               = 7
*   OTHERS                 = 8
          .
IF sy-subrc <> 0.
  MESSAGE 'Error is start_form' TYPE 'E'.
ENDIF.

*Устанавливаем ("SET") верхнюю часть ("TOP") окна MAIN
CALL FUNCTION 'WRITE_FORM'
  EXPORTING
    element                        = 'ITEM_HEADER'
    function                       = 'SET'
    type                           = 'TOP'
    window                         = 'MAIN'
* IMPORTING
*   PENDING_LINES                  =
 EXCEPTIONS
*   ELEMENT                        = 1
*   FUNCTION                       = 2
*   TYPE                           = 3
*   UNOPENED                       = 4
*   UNSTARTED                      = 5
*   WINDOW                         = 6
*   BAD_PAGEFORMAT_FOR_PRINT       = 7
*   SPOOL_ERROR                    = 8
*   CODEPAGE                       = 9
   OTHERS                         = 10
          .
IF sy-subrc <> 0.
  MESSAGE 'Error is write_form item_header' TYPE 'E'.
ENDIF.

*Выводим результат в тело окна MAIN
LOOP AT itab_data INTO lwa_data."Построчно идем по внутренней таблице
  counter = counter + 1.
  "Выводим каждую строку в теле окна MAIN
  CALL FUNCTION 'WRITE_FORM'
   EXPORTING
     element                        = 'ITEM_LINE'
*      FUNCTION                       = 'SET'
      type                           = 'BODY'
      window                         = 'MAIN'
*   IMPORTING
*     PENDING_LINES                  =
   EXCEPTIONS
*     ELEMENT                        = 1
*     FUNCTION                       = 2
*     TYPE                           = 3
*     UNOPENED                       = 4
*     UNSTARTED                      = 5
*     WINDOW                         = 6
*     BAD_PAGEFORMAT_FOR_PRINT       = 7
*     SPOOL_ERROR                    = 8
*     CODEPAGE                       = 9
     OTHERS                         = 10
            .
  IF sy-subrc <> 0.
    MESSAGE 'Error is write_form item_header' TYPE 'E'.
  ENDIF.


ENDLOOP.
*Выводим в одтельном окне по окончанию вывода списка итоговую запись
*Можно вывести итоговую запись внутри таблицы вывода
CALL FUNCTION 'WRITE_FORM'
 EXPORTING
   ELEMENT                        = 'ITEM_FOOTER'
   FUNCTION                       = 'APPEND'
*   TYPE                           = 'BODY'
   WINDOW                         = 'FOOT_M'
* IMPORTING
*   PENDING_LINES                  =
 EXCEPTIONS
   ELEMENT                        = 1
   FUNCTION                       = 2
   TYPE                           = 3
   UNOPENED                       = 4
   UNSTARTED                      = 5
   WINDOW                         = 6
   BAD_PAGEFORMAT_FOR_PRINT       = 7
   SPOOL_ERROR                    = 8
   CODEPAGE                       = 9
   OTHERS                         = 10
          .
IF sy-subrc <> 0.
    MESSAGE 'Error is write_form item_footer' TYPE 'E'.
ENDIF.

*Закрываем форму
CALL FUNCTION 'CLOSE_FORM'
* IMPORTING
*   RESULT                         =
*   RDI_RESULT                     =
* TABLES
*   OTFDATA                        =
 EXCEPTIONS
*   UNOPENED                       = 1
*   BAD_PAGEFORMAT_FOR_PRINT       = 2
*   SEND_ERROR                     = 3
*   SPOOL_ERROR                    = 4
*   CODEPAGE                       = 5
   OTHERS                         = 6
          .
IF sy-subrc <> 0.
  MESSAGE 'Error is close_form' TYPE 'E'.
ENDIF.