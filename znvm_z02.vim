*&---------------------------------------------------------------------*
*& Report  ZNVM_Z02
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  znvm_z02.

*Определение переменных из глобального словаря Abap

DATA it_spfli TYPE sbc400_t_spfli. "Определяем таблицу. Выбираем структуру из словаря и просматриваем журнал использования по "типу таблицы"
DATA wa_spfli LIKE LINE OF it_spfli. "Определяем рабочую область (структуру) подобно строке таблицы it_spfli
DATA time_spfli TYPE tims. "Определяем переменную для задания даты 

PARAMETERS pa_car TYPE s_carr_id DEFAULT 'LH'.

SELECT * FROM spfli INTO TABLE it_spfli.
*После выполнения любого действия возвращается код возврата Abap-операторов в переменной sy-subrc (все нормально sy-subrc = 0)
*Посмотреть полный список кодом можно в Abap-словаре по ключевому слову "syst"
IF sy-subrc = 0.
  LOOP AT it_spfli INTO wa_spfli.
    time_spfli = wa_spfli-arrtime - wa_spfli-deptime.
*Если выполняется условие, то выделяем строки цветом
    IF wa_spfli-carrid = pa_car.
      FORMAT COLOR = 5.
    ELSE.
      FORMAT COLOR OFF.

    ENDIF.
    WRITE: / wa_spfli-carrid,
           wa_spfli-connid,
           wa_spfli-countryfr,
           wa_spfli-cityfrom,
           wa_spfli-airpfrom,
           wa_spfli-countryto,
           wa_spfli-cityto,
           wa_spfli-airpto,
           wa_spfli-fltime,
           wa_spfli-deptime,
           wa_spfli-arrtime,
           wa_spfli-distance,
           wa_spfli-distid,
           wa_spfli-fltype,
           wa_spfli-period,
           'Время полета:',
           time_spfli.

  ENDLOOP.
ELSE.
  WRITE 'Data not found'.
ENDIF.