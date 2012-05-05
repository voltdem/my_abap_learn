*&---------------------------------------------------------------------*
*& Report  ZNVM_RC1758_01_24122008
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZNVM_RC1758_01_24122008.

TABLES: bseg.

*Тип данных описывающий эмитента
TYPES: BEGIN OF type_issuer,
     anred TYPE kna1-anred, "Обращение
     name1 TYPE kna1-name1, "Имя 1
     name2 TYPE kna1-name2, "Имя 2
  END OF type_issuer.

*Тип данных для результирующей формы
TYPES: BEGIN OF type_forma,
    butxt     TYPE t001-butxt,  "Организация
    paval     TYPE t001z-paval, "Код по ОКПО
    okved(10) TYPE c,           "Код по ОКВЭД
    dtype(13) TYPE c,           "Основание для проведения инвентаризации
    num(20)   TYPE c,           "№ документа основания
    budat     TYPE dats,        "Дата документа основания
    augdt     TYPE dats,        "Дата инвентаризации
  END OF type_forma.

*Тип данных для результирующей таблицы
TYPES: BEGIN OF type_line,
    butxt       TYPE t001-butxt,  "Организация
    paval       TYPE t001z-paval, "Код по ОКПО
    dtype(13)   TYPE c,           "Основание для проведения инвентаризации
    num(20)     TYPE c,           "№ документа основания
    budat       TYPE dats,         "Дата документа основания
    hkont       TYPE bseg-hkont,  "Номер счета бухгалтеского учета
    augdt       TYPE dats,        "Дата инвентаризации
    issuer(40)  TYPE c,           "Эмитент
    xref3       TYPE bseg-xref3,  "серия, номер
    zfbdt       TYPE bseg-zfbdt,  "Срок гашения
    quantity    TYPE i,           "Количество
    dmbtr       TYPE bseg-dmbtr,  "Номинал
    n_paper(30) TYPE c,           "Наименование ценной бумаги
  END OF type_line.

*Тип данных для выборки данных из таблицы BSEG
TYPES: BEGIN OF type_bs,
    bukrs       TYPE bseg-bukrs,  "Балансовая единица
    belnr       TYPE bseg-belnr,  "№ бухгалтерского документа
    gjahr       TYPE bseg-gjahr,  "Финансовый год
    buzei       TYPE bseg-buzei,  "№ строки проводки в рамках бухгалтерского документа
    kunnr       TYPE bseg-kunnr,  "№ дебитора 1
    xref3       TYPE bseg-xref3,  "Cерия, номер
    zfbdt       TYPE bseg-zfbdt,  "Срок гашения
    augdt       TYPE bseg-augdt,  "Дата выравнивания
    hkont       TYPE bseg-hkont,  "Основной счет главной бухгалтерии
    dmbtr       TYPE bseg-dmbtr,  "Сумма во внутренней валюте
  END OF type_bs.


DATA lform      TYPE          type_forma.         "Переменная, описывающая текущую форму
DATA itab_bs    TYPE TABLE OF type_bs.            "Таблица для хранения результата из таблицы bseg
DATA itab_line  TYPE TABLE OF type_line.          "Таблица для хранения таблицы акта
DATA lwa_line   TYPE          type_line.          "Рабочая область для работы с таблицей акта
DATA issuer     TYPE          type_issuer.        "Описание эмитента

FIELD-SYMBOLS <fs_bs> TYPE type_bs.



PARAMETERS bukrs TYPE bseg-bukrs OBLIGATORY. "Балансовая единица

*Тип документа основания
PARAMETERS: p_dtype1  TYPE c RADIOBUTTON GROUP 1 DEFAULT 'X',
            p_dtype2  TYPE c RADIOBUTTON GROUP 1,
            p_dtype3  TYPE c RADIOBUTTON GROUP 1.

PARAMETERS     num(20)    TYPE c.           "№ документа основания
PARAMETERS     budat      TYPE dats.        "Дата документа основания
SELECT-OPTIONS hkont      FOR  bseg-hkont.  "Номер счета бухгалтеского учета
PARAMETERS     augdt      TYPE dats.        "Дата инвентаризации

AT SELECTION-SCREEN.

  AUTHORITY-CHECK OBJECT 'Z_BKPF_BUK'
           ID 'BUKRS' FIELD bukrs
           ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    MESSAGE 'У вас недостаточно прав доступа' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

lform-okved = '74.15.2'.

IF p_dtype1 = 'X'.
  lform-dtype = 'приказ'.
ENDIF.

IF p_dtype2 = 'X'.
  lform-dtype = 'постановление'.
ENDIF.

IF p_dtype3 = 'X'.
  lform-dtype = 'разпоряжение'.
ENDIF.

lform-num = num.
lform-budat = budat.
*lform-hkont = hkont.
lform-augdt = augdt.


*Поиск Организации согласно п.1 доп. алгоритма
**************************************************************
SELECT SINGLE t001~butxt
  FROM t001
  INTO CORRESPONDING FIELDS OF lform
  WHERE t001~bukrs = bukrs.
**************************************************************


*Поиск кода по ОКПО согласно п.2 доп. алгоритма
**************************************************************
SELECT SINGLE t001z~paval
  FROM t001z
*  INTO CORRESPONDING FIELDS OF lform
  INTO lform-paval
  WHERE ( t001z~bukrs = bukrs ) and ( t001z~party = 'SAPZ03' ).
**************************************************************


*Выборка данных согласно п.3 алгоритма
**************************************************************
*Выборка данных из таблиц bsis и bsas
SELECT bukrs belnr gjahr buzei hkont
  FROM bsis
  INTO CORRESPONDING FIELDS OF TABLE itab_bs
  WHERE ( bsis~bukrs = bukrs ) and ( bsis~hkont in hkont )
        and ( bsis~budat < augdt ).

SELECT bukrs belnr gjahr buzei hkont
  FROM bsas
  APPENDING CORRESPONDING FIELDS OF TABLE itab_bs
  WHERE ( bsas~bukrs = bukrs ) and ( bsas~hkont in hkont )
        and ( bsas~budat < augdt ) and ( bsas~augdt >= augdt ).

*Подтягивание дополнительных данных из таблицы bseg
LOOP AT itab_bs ASSIGNING <fs_bs>.
  SELECT SINGLE kunnr xref3 zfbdt augdt dmbtr
    FROM bseg
    INTO CORRESPONDING FIELDS OF <fs_bs>
    WHERE ( bseg~bukrs = <fs_bs>-bukrs ) and ( bseg~belnr = <fs_bs>-belnr )
          and ( bseg~gjahr = <fs_bs>-gjahr ) and ( bseg~buzei = <fs_bs>-buzei ).
ENDLOOP.

**************************************************************

*Формирование строки таблицы АКТА
**************************************************************
FREE itab_line.
LOOP AT itab_bs ASSIGNING <fs_bs>.
  CLEAR lwa_line.
  MOVE-CORRESPONDING <fs_bs> TO lwa_line.

  "Формирование ЭМИТЕНТА
  IF <fs_bs>-kunnr is INITIAL.

      lwa_line-issuer = '------'.

    ELSE.

      SELECT SINGLE anred name1 name2
        FROM kna1
        INTO CORRESPONDING FIELDS OF issuer
        WHERE kna1~kunnr = <fs_bs>-kunnr.

      CONCATENATE issuer-anred  issuer-name1  issuer-name2 INTO lwa_line-issuer.

  ENDIF.

  "Назначение НАИМЕНОВАНИЯ ЦЕННОЙ БУМАГИ
  IF <fs_bs>-hkont CP '0000113*'.
          lwa_line-n_paper = 'простой вексель'.
        ELSE.
          lwa_line-n_paper = '------'.
  ENDIF.
  lwa_line-quantity = 1.
  MOVE-CORRESPONDING lform TO lwa_line.
  APPEND lwa_line TO itab_line.
ENDLOOP.
**************************************************************

SORT itab_line.

DATA: lo_alv TYPE REF TO cl_salv_table.

TRY.
CALL METHOD cl_salv_table=>factory
*  EXPORTING
*    list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*    r_container    =
*    container_name =
  IMPORTING
    r_salv_table   = lo_alv
  CHANGING
    t_table        = itab_line
    .
 CATCH cx_salv_msg .
ENDTRY.

lo_alv->display( ).