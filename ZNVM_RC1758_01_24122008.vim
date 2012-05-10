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
TYPES: BEGIN OF ts_issuer,
        anred TYPE kna1-anred, "Обращение
        name1 TYPE kna1-name1, "Имя 1
        name2 TYPE kna1-name2, "Имя 2
       END OF ts_issuer.

*Тип данных для результирующей формы
TYPES: BEGIN OF ts_forma,
        butxt     TYPE t001-butxt,  "Организация
        paval     TYPE t001z-paval, "Код по ОКПО
        okved(10) TYPE c,           "Код по ОКВЭД
        dtype(13) TYPE c,           "Основание для проведения инвентаризации
        num(20)   TYPE c,           "№ документа основания
        budat     TYPE dats,        "Дата документа основания
        augdt     TYPE dats,        "Дата инвентаризации
       END OF ts_forma.

*Тип данных для результирующей таблицы
TYPES: BEGIN OF ts_line,
        butxt       TYPE t001-butxt,  "Организация
        paval       TYPE t001z-paval, "Код по ОКПО
        dtype(13)   TYPE c,           "Основание для проведения инвентаризации
        num(20)     TYPE c,           "№ документа основания
        budat       TYPE dats,        "Дата документа основания
        hkont       TYPE bseg-hkont,  "Номер счета бухгалтеского учета
        augdt       TYPE dats,        "Дата инвентаризации
        issuer(40)  TYPE c,           "Эмитент
        xref3       TYPE bseg-xref3,  "серия, номер
        zfbdt       TYPE bseg-zfbdt,  "Срок гашения
        quantity    TYPE i,           "Количество
        dmbtr       TYPE bseg-dmbtr,  "Номинал
        n_paper(30) TYPE c,           "Наименование ценной бумаги
       END OF ts_line.

*Тип данных для выборки данных из таблицы BSEG
TYPES: BEGIN OF ts_bs,
        bukrs TYPE bseg-bukrs,  "Балансовая единица
        belnr TYPE bseg-belnr,  "№ бухгалтерского документа
        gjahr TYPE bseg-gjahr,  "Финансовый год
        buzei TYPE bseg-buzei,  "№ строки проводки в рамках бухгалтерского документа
        kunnr TYPE bseg-kunnr,  "№ дебитора 1
        xref3 TYPE bseg-xref3,  "Cерия, номер
        zfbdt TYPE bseg-zfbdt,  "Срок гашения
        augdt TYPE bseg-augdt,  "Дата выравнивания
        hkont TYPE bseg-hkont,  "Основной счет главной бухгалтерии
        dmbtr TYPE bseg-dmbtr,  "Сумма во внутренней валюте
       END OF ts_bs.

DATA:
  g_form   TYPE          ts_forma,         "Переменная, описывающая текущую форму
  gt_bs    TYPE TABLE OF ts_bs,            "Таблица для хранения результата из таблицы bseg
  gt_line  TYPE TABLE OF ts_line,          "Таблица для хранения таблицы акта
  g_line   TYPE          ts_line,          "Рабочая область для работы с таблицей акта
  g_issuer TYPE          ts_issuer.        "Описание эмитента

FIELD-SYMBOLS <ts_bs> TYPE ts_bs.

PARAMETERS:
  p_bukrs   TYPE bseg-bukrs OBLIGATORY, "Балансовая единица (OBLIGATORY - обязательное поле)
  "Тип документа основания
  p_dtype1  TYPE c RADIOBUTTON GROUP 1 DEFAULT 'X',
  p_dtype2  TYPE c RADIOBUTTON GROUP 1,
  p_dtype3  TYPE c RADIOBUTTON GROUP 1,
  "
  p_num(20) TYPE c,             "№ документа основания
  p_budat   TYPE dats.          "Дата документа основания
SELECT-OPTIONS:
  so_hkont  FOR  bseg-hkont. "Номер счета бухгалтеского учета
PARAMETERS:
  p_augdt   TYPE dats.          "Дата инвентаризации

AT SELECTION-SCREEN.

  AUTHORITY-CHECK OBJECT 'Z_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs
           ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    MESSAGE 'У вас недостаточно прав доступа' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

g_form-okved = '74.15.2'.

IF p_dtype1 = 'X'.
  g_form-dtype = 'приказ'.
ENDIF.

IF p_dtype2 = 'X'.
  g_form-dtype = 'постановление'.
ENDIF.

IF p_dtype3 = 'X'.
  g_form-dtype = 'разпоряжение'.
ENDIF.

g_form-num = p_num.
g_form-budat = p_budat.
g_form-augdt = p_augdt.


*Поиск Организации согласно п.1 доп. алгоритма
**************************************************************
SELECT SINGLE t001~butxt
  FROM t001
  INTO CORRESPONDING FIELDS OF g_form
  WHERE t001~bukrs = p_bukrs.
**************************************************************


*Поиск кода по ОКПО согласно п.2 доп. алгоритма
**************************************************************
SELECT SINGLE t001z~paval
  FROM t001z
  INTO g_form-paval
  WHERE t001z~bukrs = p_bukrs
    AND t001z~party = 'SAPZ03'.
**************************************************************


*Выборка данных согласно п.3 алгоритма
**************************************************************
*Выборка данных из таблиц bsis и bsas
SELECT bukrs belnr gjahr buzei hkont
  FROM bsis
  INTO CORRESPONDING FIELDS OF TABLE gt_bs
  WHERE bsis~bukrs = p_bukrs
    AND bsis~hkont IN so_hkont
    AND bsis~budat < p_augdt.

SELECT bukrs belnr gjahr buzei hkont
  FROM bsas
  APPENDING CORRESPONDING FIELDS OF TABLE gt_bs
  WHERE bsas~bukrs = p_bukrs
    AND bsas~hkont IN so_hkont
    AND bsas~budat < p_augdt
    AND bsas~augdt >= p_augdt.

*Подтягивание дополнительных данных из таблицы bseg
LOOP AT gt_bs ASSIGNING <ts_bs>.
  SELECT SINGLE kunnr xref3 zfbdt augdt dmbtr
    FROM bseg
    INTO CORRESPONDING FIELDS OF <ts_bs>
    WHERE bseg~bukrs = <ts_bs>-bukrs
      AND bseg~belnr = <ts_bs>-belnr
      AND bseg~gjahr = <ts_bs>-gjahr
      AND bseg~buzei = <ts_bs>-buzei.
ENDLOOP.

**************************************************************

*Формирование строки таблицы АКТА
**************************************************************
FREE gt_line.
LOOP AT gt_bs ASSIGNING <ts_bs>.
  CLEAR g_line.
  MOVE-CORRESPONDING <ts_bs> TO g_line.

  "Формирование ЭМИТЕНТА
  SELECT SINGLE anred name1 name2
    FROM kna1
    INTO CORRESPONDING FIELDS OF g_issuer
    WHERE kna1~kunnr = <ts_bs>-kunnr.

  IF sy-subrc <> 0.
     g_line-issuer = '------'.
  ELSE.
     CONCATENATE g_issuer-anred  g_issuer-name1  g_issuer-name2 INTO g_line-issuer SEPARATED BY space.
     SHIFT g_line-issuer LEFT DELETING LEADING ' '.
  ENDIF.
  "Назначение НАИМЕНОВАНИЯ ЦЕННОЙ БУМАГИ
  IF <ts_bs>-hkont CP '0000113*'.
          g_line-n_paper = 'простой вексель'.
        ELSE.
          g_line-n_paper = '------'.
  ENDIF.
  g_line-quantity = 1.
  MOVE-CORRESPONDING g_form TO g_line.
  APPEND g_line TO gt_line.
ENDLOOP.
**************************************************************

SORT gt_line BY issuer ASCENDING.

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
    t_table        = gt_line
    .
 CATCH cx_salv_msg .
ENDTRY.

lo_alv->display( ).