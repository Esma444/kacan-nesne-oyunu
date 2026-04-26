#make_COM#

ORG 100h

JMP BASLA

nesne_x     DW 35
nesne_y     DW 10
nesne_boy   DW 8
nesne_dx    DW 1
nesne_dy    DW 1
skor        DW 0
sure        DW 30
son_san     DW 0
son_har     DW 0
oyun_dur    DB 0
har_hz      DW 3
tohum       DW 0
hiz_say     DW 0
fare_var    DB 0
tik_now     DW 0

msg_bas     DB '                        KACAN NESNE TAKIBI OYUNU', 13, 10
            DB 13, 10, 13, 10
            DB '                     Mouse ile kirmizi nesneyi yakalayiniz.', 13, 10
            DB 13, 10
            DB '                    Nesne her tiklamada kuculur ve hizlanir!', 13, 10
            DB 13, 10, 13, 10, 13, 10
            DB '                               Bir tusa basin...', '$'
msg_sk      DB 'Skor: $'
msg_sr      DB 'Sure: $'
msg_bo      DB '    $'
msg_bt      DB '           *** OYUN BITTI! ***', 13, 10, '$'
msg_tp      DB '         Toplam Yakalama Sayisi: $'
msg_ck      DB 13, 10, 13, 10
            DB '       Cikmak icin bir tusa basin...$'
msg_kaz     DB '*** KAZANDIN! ***$'

BASLA:
    MOV AX, CS
    MOV DS, AX

    MOV AH, 0
    MOV AL, 3
    INT 10h

    MOV AH, 2
    MOV BH, 0
    MOV DH, 7
    MOV DL, 0
    INT 10h

    MOV DX, OFFSET msg_bas
    MOV AH, 9
    INT 21h

    MOV AH, 0
    INT 16h
    MOV [tohum], AX

    MOV AH, 0
    MOV AL, 3
    INT 10h

    MOV AH, 1
    MOV CH, 20h
    MOV CL, 00h
    INT 10h

    MOV AX, 0
    INT 33h
    CMP AX, 0
    JE FARE_YOK
    MOV AL, 1
    MOV [fare_var], AL
    MOV AX, 1
    INT 33h
    JMP FARE_OK
FARE_YOK:
    MOV AL, 0
    MOV [fare_var], AL
FARE_OK:

    MOV AH, 0
    INT 1Ah
    MOV [son_san], DX
    MOV [son_har], DX
    ADD [tohum], DX

    CALL RASTGELE
    MOV DX, 0
    MOV BX, 65
    DIV BX
    ADD DX, 3
    MOV [nesne_x], DX

    CALL RASTGELE
    MOV DX, 0
    MOV BX, 16
    DIV BX
    ADD DX, 2
    MOV [nesne_y], DX

    CALL YON_DEGISTIR
    CALL NESNE_CIZ
    CALL BILGI_GOSTER

DONGU:
    MOV AL, [oyun_dur]
    CMP AL, 1
    JE SONUC_EKRANI

    MOV AH, 0
    INT 1Ah
    MOV [tik_now], DX

    CALL ZAMAN_GUNCELLE
    CALL HAREKET_KONTROL

    MOV AL, [fare_var]
    CMP AL, 1
    JNE DONGU
    CALL FARE_KONTROL

    JMP DONGU

ZAMAN_GUNCELLE:
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AX, [tik_now]
    SUB AX, [son_san]
    CMP AX, 18
    JB ZG_SON

    MOV AX, [tik_now]
    MOV [son_san], AX

    MOV AX, [sure]
    DEC AX
    MOV [sure], AX
    CMP AX, 0
    JG ZG_HIZ

    MOV AL, 1
    MOV [oyun_dur], AL
    JMP ZG_SON

ZG_HIZ:
    MOV AX, [hiz_say]
    INC AX
    MOV [hiz_say], AX
    MOV DX, 0
    MOV BX, 5
    DIV BX
    CMP DX, 0
    JNE ZG_SON
    MOV AX, [har_hz]
    CMP AX, 1
    JBE ZG_SON
    DEC AX
    MOV [har_hz], AX

ZG_SON:
    POP DX
    POP BX
    POP AX
    RET

HAREKET_KONTROL:
    PUSH AX

    MOV AX, [tik_now]
    SUB AX, [son_har]
    CMP AX, [har_hz]
    JB HK_SON

    MOV AX, [tik_now]
    MOV [son_har], AX

    CALL NESNE_SIL
    CALL NESNE_HAREKET
    CALL NESNE_CIZ
    CALL BILGI_GOSTER

HK_SON:
    POP AX
    RET

NESNE_SIL:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, 0
NS_S:
    MOV AX, [nesne_boy]
    CMP SI, AX
    JGE NS_B

    MOV AX, [nesne_y]
    ADD AX, SI
    MOV DH, AL
    MOV AX, [nesne_x]
    MOV DL, AL
    MOV AH, 2
    MOV BH, 0
    INT 10h

    MOV AH, 9
    MOV AL, 32
    MOV BL, 07h
    MOV BH, 0
    MOV CX, [nesne_boy]
    INT 10h

    INC SI
    JMP NS_S

NS_B:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

NESNE_CIZ:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, 0
NC_S:
    MOV AX, [nesne_boy]
    CMP SI, AX
    JGE NC_B

    MOV AX, [nesne_y]
    ADD AX, SI
    MOV DH, AL
    MOV AX, [nesne_x]
    MOV DL, AL
    MOV AH, 2
    MOV BH, 0
    INT 10h

    MOV AH, 9
    MOV AL, 219
    MOV BL, 0Ch
    MOV BH, 0
    MOV CX, [nesne_boy]
    INT 10h

    INC SI
    JMP NC_S

NC_B:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

NESNE_HAREKET:
    PUSH AX
    PUSH BX
    PUSH DX

    CALL RASTGELE
    MOV DX, 0
    MOV BX, 65
    DIV BX
    ADD DX, 3
    MOV [nesne_x], DX

    CALL RASTGELE
    MOV DX, 0
    MOV BX, 16
    DIV BX
    ADD DX, 2
    MOV [nesne_y], DX

    POP DX
    POP BX
    POP AX
    RET

YON_DEGISTIR:
    PUSH AX
    PUSH BX

    MOV AX, [nesne_dx]
    NEG AX
    MOV [nesne_dx], AX

    CALL RASTGELE
    AND AX, 1
    CMP AX, 0
    JE YD_E
    MOV AX, [nesne_dy]
    NEG AX
    MOV [nesne_dy], AX

YD_E:
    POP BX
    POP AX
    RET

RASTGELE:
    PUSH BX
    PUSH DX
    MOV AX, [tohum]
    MOV BX, 25173
    MUL BX
    ADD AX, 13849
    MOV [tohum], AX
    POP DX
    POP BX
    RET

FARE_KONTROL:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, 3
    INT 33h

    AND BX, 1
    CMP BX, 1
    JNE FK_E

    MOV AX, [nesne_x]
    ADD AX, AX
    ADD AX, AX
    ADD AX, AX
    CMP CX, AX
    JL FK_E

    MOV AX, [nesne_x]
    ADD AX, [nesne_boy]
    ADD AX, AX
    ADD AX, AX
    ADD AX, AX
    CMP CX, AX
    JGE FK_E

    MOV AX, [nesne_y]
    ADD AX, AX
    ADD AX, AX
    ADD AX, AX
    CMP DX, AX
    JL FK_E

    MOV AX, [nesne_y]
    ADD AX, [nesne_boy]
    ADD AX, AX
    ADD AX, AX
    ADD AX, AX
    CMP DX, AX
    JGE FK_E

    MOV AX, [skor]
    INC AX
    MOV [skor], AX

    CALL NESNE_SIL

    MOV AX, [nesne_boy]
    MOV BX, 9
    MUL BX
    MOV BX, 10
    MOV DX, 0
    DIV BX
    CMP AX, 1
    JGE FK_BOK
    MOV AX, 1
FK_BOK:
    MOV [nesne_boy], AX

    CALL RASTGELE
    MOV DX, 0
    MOV BX, 65
    DIV BX
    ADD DX, 3
    MOV [nesne_x], DX

    CALL RASTGELE
    MOV DX, 0
    MOV BX, 16
    DIV BX
    ADD DX, 2
    MOV [nesne_y], DX

    CALL YON_DEGISTIR
    CALL NESNE_CIZ
    CALL BILGI_GOSTER

FK_BK:
    MOV AX, 3
    INT 33h
    AND BX, 1
    CMP BX, 1
    JE FK_BK

FK_E:
    POP DX
    POP CX
    POP BX
    POP AX
    RET

BILGI_GOSTER:
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 2
    MOV BH, 0
    MOV DH, 0
    MOV DL, 2
    INT 10h
    MOV DX, OFFSET msg_sk
    MOV AH, 9
    INT 21h
    MOV AX, [skor]
    CALL SAYI_YAZ
    MOV DX, OFFSET msg_bo
    MOV AH, 9
    INT 21h

    MOV AH, 2
    MOV BH, 0
    MOV DH, 0
    MOV DL, 65
    INT 10h
    MOV DX, OFFSET msg_sr
    MOV AH, 9
    INT 21h
    MOV AX, [sure]
    CALL SAYI_YAZ
    MOV DX, OFFSET msg_bo
    MOV AH, 9
    INT 21h

    MOV AX, [nesne_boy]
    CMP AX, 1
    JNE BG_SON
    MOV AH, 2
    MOV BH, 0
    MOV DH, 1
    MOV DL, 31
    INT 10h
    MOV DX, OFFSET msg_kaz
    MOV AH, 9
    INT 21h
BG_SON:
    POP DX
    POP BX
    POP AX
    RET

SONUC_EKRANI:
    MOV AX, 2
    INT 33h

    MOV AH, 0
    MOV AL, 3
    INT 10h

    MOV AH, 1
    MOV CH, 06h
    MOV CL, 07h
    INT 10h

    MOV AH, 2
    MOV BH, 0
    MOV DH, 8
    MOV DL, 0
    INT 10h

    MOV DX, OFFSET msg_bt
    MOV AH, 9
    INT 21h

    MOV AH, 2
    MOV BH, 0
    MOV DH, 12
    MOV DL, 0
    INT 10h

    MOV DX, OFFSET msg_tp
    MOV AH, 9
    INT 21h

    MOV AX, [skor]
    CALL SAYI_YAZ

SE_DEVAM:
    MOV AH, 2
    MOV BH, 0
    MOV DH, 16
    MOV DL, 0
    INT 10h

    MOV DX, OFFSET msg_ck
    MOV AH, 9
    INT 21h

    MOV AH, 0
    INT 16h

    MOV AH, 4Ch
    INT 21h

SAYI_YAZ:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0
    MOV BX, 10
SY_B:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE SY_B

SY_Y:
    POP DX
    ADD DL, 30h
    MOV AH, 2
    INT 21h
    LOOP SY_Y

    POP DX
    POP CX
    POP BX
    POP AX
    RET

