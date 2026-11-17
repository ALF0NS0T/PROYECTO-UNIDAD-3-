; PARTICIPANTES DEL PROYECTO FINAL
; 23170344 - SOTO NIETO JESUS ALFONSO
; 23170341 - SERRANO SALOMON ALEXIS
; 23170161 - GASTELUM VERDUSZCO FERNANDO

; DOCENTE: ING. MEDINA (mAIstro)

INCLUDE Irvine32.inc

MAX_PROD   = 10
REG_SIZE   = 44
PRECIO_MAX = 999999

.data
catMagic        BYTE "INV1"
cantidad        DWORD 0
registros       BYTE 440 DUP(0)

cambios         BYTE 0
ingresos        DWORD 0

nombreArchivo   BYTE "inventario.dat",0
hArchivo        DWORD 0
bytesPedidos    DWORD 0
bytesEscritos   DWORD 0
bytesLeidos     DWORD 0
bufArchivo      BYTE 450 DUP(0)

bufEntrada      BYTE 81 DUP(0)
bufNum          BYTE 20 DUP(0)

tmpCodigo       BYTE 8 DUP(0)
tmpNombre       BYTE 28 DUP(0)
tmpPrecio       DWORD 0
tmpExist        DWORD 0
valorLeido      DWORD 0

cantVenta       DWORD 0
ventaBase       DWORD 0
ventaDesc       DWORD 0
ventaFinal      DWORD 0
nuevosIngresos  DWORD 0

numProd         DWORD 0
inicioRegs      DWORD 0
numRevisados    DWORD 0

menuTxt         BYTE 0Dh,0Ah
                BYTE "=========== PAPELERIA EL LAPIZ ===========",0Dh,0Ah
                BYTE " 1. Registrar producto",0Dh,0Ah
                BYTE " 2. Mostrar inventario",0Dh,0Ah
                BYTE " 3. Buscar producto por codigo",0Dh,0Ah
                BYTE " 4. Recibir mercancia",0Dh,0Ah
                BYTE " 5. Vender",0Dh,0Ah
                BYTE " 6. Resumen",0Dh,0Ah
                BYTE " 7. Guardar inventario",0Dh,0Ah
                BYTE " 8. Cargar inventario",0Dh,0Ah
                BYTE " 9. Ver archivo guardado",0Dh,0Ah
                BYTE " 0. Salir",0Dh,0Ah
                BYTE "==========================================",0Dh,0Ah,0

msgOpcion       BYTE "Opcion: ",0
msgOpcionMal    BYTE "Opcion invalida.",0Dh,0Ah,0
msgCodigo       BYTE "Codigo (formato ABC-123): ",0
msgNombre       BYTE "Nombre (1 a 25 caracteres): ",0
msgPrecio       BYTE "Precio en MXN (ej. 185.50): ",0
msgExistencia   BYTE "Existencia inicial (0 a 100): ",0
msgCantRecibir  BYTE "Unidades a recibir (mayor que 0): ",0
msgCantVender   BYTE "Unidades a vender (mayor que 0): ",0

msgLleno        BYTE "RECHAZADO: el catalogo ya tiene 10 productos.",0Dh,0Ah,0
msgCodigoMal    BYTE "RECHAZADO: codigo incorrecto (3 letras MAYUSCULAS, guion, 3 digitos).",0Dh,0Ah,0
msgDuplicado    BYTE "RECHAZADO: ya existe un producto con ese codigo.",0Dh,0Ah,0
msgNombreMal    BYTE "RECHAZADO: el nombre debe tener de 1 a 25 caracteres.",0Dh,0Ah,0
msgPrecioMal    BYTE "RECHAZADO: precio invalido (de 0.01 a 9999.99, maximo 2 decimales).",0Dh,0Ah,0
msgExistMal     BYTE "RECHAZADO: existencia invalida (entero de 0 a 100).",0Dh,0Ah,0
msgNoExiste     BYTE "RECHAZADO: no existe un producto con ese codigo.",0Dh,0Ah,0
msgCantMal      BYTE "RECHAZADO: cantidad invalida (entero mayor que 0).",0Dh,0Ah,0
msgExcede       BYTE "RECHAZADO: la existencia no puede pasar de 100 unidades.",0Dh,0Ah,0
msgSinStock     BYTE "RECHAZADO: no hay existencias suficientes.",0Dh,0Ah,0
msgDesborde     BYTE "RECHAZADO: desbordamiento en el calculo.",0Dh,0Ah,0

msgAltaOk       BYTE "Producto registrado.",0Dh,0Ah,0
msgNoHay        BYTE "No hay productos registrados.",0Dh,0Ah,0
msgEncabezado   BYTE "--- Inventario ---",0Dh,0Ah,0
msgRecibidoOk   BYTE "Mercancia recibida. Nueva existencia: ",0
msgVentaOk      BYTE "Venta aceptada.",0Dh,0Ah,0
msgBase         BYTE "  Importe base:  ",0
msgDesc         BYTE "  Descuento 10%: ",0
msgSinDesc      BYTE "  Sin descuento (se aplica desde 10 unidades).",0Dh,0Ah,0
msgTotal        BYTE "  TOTAL:         ",0
msgResUnid      BYTE "Unidades disponibles:  ",0
msgResValor     BYTE "Valor del inventario:  ",0
msgResIngr      BYTE "Ingresos de la sesion: ",0

msgGuardado     BYTE "Inventario guardado en inventario.dat",0Dh,0Ah,0
msgErrCrear     BYTE "ERROR: no se pudo crear el archivo.",0Dh,0Ah,0
msgErrEscribir  BYTE "ERROR: no se escribieron todos los datos.",0Dh,0Ah,0
msgCargado      BYTE "Inventario cargado. Productos: ",0
msgNoArchivo    BYTE "ERROR: inventario.dat no existe o no se pudo abrir. Catalogo sin cambios.",0Dh,0Ah,0
msgErrLeer      BYTE "ERROR: no se pudo leer el archivo. Catalogo sin cambios.",0Dh,0Ah,0
msgArchivoMal   BYTE "ERROR: archivo danado o con datos invalidos. Catalogo sin cambios.",0Dh,0Ah,0

msgVerTitulo    BYTE "====== CONTENIDO DE inventario.dat ======",0Dh,0Ah,0
msgVerCant      BYTE "Productos guardados: ",0
msgVerVacio     BYTE "El archivo no tiene productos guardados.",0Dh,0Ah,0
msgVerProd      BYTE "Producto #",0
msgVerCodigo    BYTE "   Codigo:     ",0
msgVerNombre    BYTE "   Nombre:     ",0
msgVerPrecio    BYTE "   Precio:     ",0
msgVerExist     BYTE "   Existencia: ",0
msgVerUnid      BYTE " unidades",0
msgVerFin       BYTE "=========================================",0Dh,0Ah,0

msgSinGuardar   BYTE "Hay cambios sin guardar. Salir de todas formas? (S/N): ",0
msgAdios        BYTE "Hasta luego.",0Dh,0Ah,0

txtCodigo       BYTE "Codigo: ",0
txtNombre       BYTE " | Nombre: ",0
txtPrecio       BYTE " | Precio: ",0
txtExist        BYTE " | Existencia: ",0
txtMXN          BYTE " MXN",0

.code

main PROC
menu_loop:
    mov  edx, OFFSET menuTxt
    call WriteString
    mov  edx, OFFSET msgOpcion
    call PedirTexto
    cmp  eax, 1
    jne  opcion_mal
    mov  al, bufEntrada

    cmp  al, '1'
    je   op1
    cmp  al, '2'
    je   op2
    cmp  al, '3'
    je   op3
    cmp  al, '4'
    je   op4
    cmp  al, '5'
    je   op5
    cmp  al, '6'
    je   op6
    cmp  al, '7'
    je   op7
    cmp  al, '8'
    je   op8
    cmp  al, '9'
    je   op9
    cmp  al, '0'
    je   op0
opcion_mal:
    mov  edx, OFFSET msgOpcionMal
    call WriteString
    jmp  menu_loop

op1:
    call Alta
    jmp  menu_loop
op2:
    call MostrarInventario
    jmp  menu_loop
op3:
    call BuscarProducto
    jmp  menu_loop
op4:
    call Recibir
    jmp  menu_loop
op5:
    call Vender
    jmp  menu_loop
op6:
    call Resumen
    jmp  menu_loop
op7:
    call Guardar
    jmp  menu_loop
op8:
    call Cargar
    jmp  menu_loop
op9:
    call VerArchivo
    jmp  menu_loop

op0:
    cmp  cambios, 0
    je   salir
    mov  edx, OFFSET msgSinGuardar
    call PedirTexto
    cmp  eax, 1
    jne  menu_loop
    mov  al, bufEntrada
    cmp  al, 'S'
    je   salir
    cmp  al, 's'
    je   salir
    jmp  menu_loop

salir:
    mov  edx, OFFSET msgAdios
    call WriteString
    exit
main ENDP

PedirTexto PROC
    push ecx
    push edx
    call WriteString
    mov  edx, OFFSET bufEntrada
    mov  ecx, 81
    call ReadString
    pop  edx
    pop  ecx
    ret
PedirTexto ENDP

LeerEntero PROC
    push ebx
    push edx
    push esi
    mov  eax, 0
    cmp  BYTE PTR [esi], 0
    je   le_mal
le_ciclo:
    mov  bl, [esi]
    cmp  bl, 0
    je   le_ok
    cmp  bl, '0'
    jb   le_mal
    cmp  bl, '9'
    ja   le_mal
    sub  bl, '0'
    movzx ebx, bl
    mov  edx, 10
    mul  edx
    jc   le_mal
    add  eax, ebx
    jc   le_mal
    inc  esi
    jmp  le_ciclo
le_ok:
    mov  valorLeido, eax
    mov  eax, 1
    jmp  le_fin
le_mal:
    mov  eax, 0
le_fin:
    pop  esi
    pop  edx
    pop  ebx
    ret
LeerEntero ENDP

PedirEntero PROC
    push esi
    call PedirTexto
    mov  esi, OFFSET bufEntrada
    call LeerEntero
    pop  esi
    ret
PedirEntero ENDP

LeerPrecio PROC
    push ebx
    push ecx
    push edx
    push esi
    mov  eax, 0
    mov  ecx, 0
lp_pesos:
    mov  bl, [esi]
    cmp  bl, 0
    je   lp_sin_punto
    cmp  bl, '.'
    je   lp_punto
    cmp  bl, '0'
    jb   lp_mal
    cmp  bl, '9'
    ja   lp_mal
    sub  bl, '0'
    movzx ebx, bl
    mov  edx, 10
    mul  edx
    add  eax, ebx
    cmp  eax, 9999
    ja   lp_mal
    inc  ecx
    inc  esi
    jmp  lp_pesos

lp_sin_punto:
    cmp  ecx, 0
    je   lp_mal
    mov  edx, 100
    mul  edx
    jmp  lp_listo

lp_punto:
    cmp  ecx, 0
    je   lp_mal
    mov  edx, 100
    mul  edx
    inc  esi

    mov  bl, [esi]
    cmp  bl, '0'
    jb   lp_mal
    cmp  bl, '9'
    ja   lp_mal
    sub  bl, '0'
    movzx ebx, bl
    imul ebx, ebx, 10
    add  eax, ebx
    inc  esi

    mov  bl, [esi]
    cmp  bl, 0
    je   lp_listo
    cmp  bl, '0'
    jb   lp_mal
    cmp  bl, '9'
    ja   lp_mal
    sub  bl, '0'
    movzx ebx, bl
    add  eax, ebx
    inc  esi
    cmp  BYTE PTR [esi], 0
    jne  lp_mal

lp_listo:
    cmp  eax, 1
    jb   lp_mal
    mov  tmpPrecio, eax
    mov  eax, 1
    jmp  lp_fin
lp_mal:
    mov  eax, 0
lp_fin:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
LeerPrecio ENDP

ValidarCodigo PROC
    push ebx
    push ecx
    push esi
    mov  eax, 0
    mov  ecx, 3
vc_letras:
    mov  bl, [esi]
    cmp  bl, 'A'
    jb   vc_fin
    cmp  bl, 'Z'
    ja   vc_fin
    inc  esi
    loop vc_letras
    cmp  BYTE PTR [esi], '-'
    jne  vc_fin
    inc  esi
    mov  ecx, 3
vc_digitos:
    mov  bl, [esi]
    cmp  bl, '0'
    jb   vc_fin
    cmp  bl, '9'
    ja   vc_fin
    inc  esi
    loop vc_digitos
    cmp  BYTE PTR [esi], 0
    jne  vc_fin
    mov  eax, 1
vc_fin:
    pop  esi
    pop  ecx
    pop  ebx
    ret
ValidarCodigo ENDP

BuscarCodigo PROC
    push ebx
    push ecx
    push edx
    mov  eax, 0
    mov  esi, OFFSET registros
    mov  ecx, cantidad
    cmp  ecx, 0
    je   bc_fin
bc_registro:
    mov  edx, 0
bc_letra:
    mov  bl, [esi + edx]
    cmp  bl, bufEntrada[edx]
    jne  bc_siguiente
    inc  edx
    cmp  edx, 7
    jb   bc_letra
    mov  eax, 1
    jmp  bc_fin
bc_siguiente:
    add  esi, REG_SIZE
    loop bc_registro
bc_fin:
    pop  edx
    pop  ecx
    pop  ebx
    ret
BuscarCodigo ENDP

PedirYBuscar PROC
    push edx
    mov  edx, OFFSET msgCodigo
    call PedirTexto
    mov  esi, OFFSET bufEntrada
    call ValidarCodigo
    cmp  eax, 0
    je   pb_codigo_mal
    call BuscarCodigo
    cmp  eax, 1
    je   pb_fin
    mov  edx, OFFSET msgNoExiste
    call WriteString
    jmp  pb_fin
pb_codigo_mal:
    mov  edx, OFFSET msgCodigoMal
    call WriteString
    mov  eax, 0
pb_fin:
    pop  edx
    ret
PedirYBuscar ENDP

CopiarCadena PROC
    push eax
    push esi
    push edi
cc_loop:
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    cmp  al, 0
    jne  cc_loop
    pop  edi
    pop  esi
    pop  eax
    ret
CopiarCadena ENDP

EnteroACadena PROC
    push eax
    push ebx
    push ecx
    push edx
    mov  ebx, 10
    mov  ecx, 0
ec_dividir:
    mov  edx, 0
    div  ebx
    push edx
    inc  ecx
    cmp  eax, 0
    jne  ec_dividir
ec_sacar:
    pop  edx
    add  dl, '0'
    mov  [edi], dl
    inc  edi
    loop ec_sacar
    mov  BYTE PTR [edi], 0
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
EnteroACadena ENDP

MostrarNumero PROC
    push edx
    push edi
    mov  edi, OFFSET bufNum
    call EnteroACadena
    mov  edx, OFFSET bufNum
    call WriteString
    pop  edi
    pop  edx
    ret
MostrarNumero ENDP

MostrarPrecio PROC
    push eax
    push ebx
    push edx
    push edi
    mov  edi, OFFSET bufNum
    mov  BYTE PTR [edi], '$'
    inc  edi
    mov  edx, 0
    mov  ebx, 100
    div  ebx
    push edx
    call EnteroACadena
    pop  eax
    mov  BYTE PTR [edi], '.'
    inc  edi
    mov  edx, 0
    mov  ebx, 10
    div  ebx
    add  al, '0'
    mov  [edi], al
    inc  edi
    add  dl, '0'
    mov  [edi], dl
    inc  edi
    mov  BYTE PTR [edi], 0
    mov  edx, OFFSET bufNum
    call WriteString
    mov  edx, OFFSET txtMXN
    call WriteString
    pop  edi
    pop  edx
    pop  ebx
    pop  eax
    ret
MostrarPrecio ENDP

ImprimirProducto PROC
    push eax
    push edx
    mov  edx, OFFSET txtCodigo
    call WriteString
    mov  edx, esi
    call WriteString
    mov  edx, OFFSET txtNombre
    call WriteString
    lea  edx, [esi + 8]
    call WriteString
    mov  edx, OFFSET txtPrecio
    call WriteString
    mov  eax, [esi + 36]
    call MostrarPrecio
    mov  edx, OFFSET txtExist
    call WriteString
    mov  eax, [esi + 40]
    call MostrarNumero
    call Crlf
    pop  edx
    pop  eax
    ret
ImprimirProducto ENDP

Alta PROC
    pushad
    cmp  cantidad, MAX_PROD
    jae  al_lleno

    mov  edx, OFFSET msgCodigo
    call PedirTexto
    mov  esi, OFFSET bufEntrada
    call ValidarCodigo
    cmp  eax, 0
    je   al_codigo_mal
    call BuscarCodigo
    cmp  eax, 1
    je   al_duplicado
    mov  esi, OFFSET bufEntrada
    mov  edi, OFFSET tmpCodigo
    call CopiarCadena

    mov  edx, OFFSET msgNombre
    call PedirTexto
    cmp  eax, 1
    jb   al_nombre_mal
    cmp  eax, 25
    ja   al_nombre_mal
    mov  esi, OFFSET bufEntrada
    mov  edi, OFFSET tmpNombre
    call CopiarCadena

    mov  edx, OFFSET msgPrecio
    call PedirTexto
    mov  esi, OFFSET bufEntrada
    call LeerPrecio
    cmp  eax, 0
    je   al_precio_mal

    mov  edx, OFFSET msgExistencia
    call PedirEntero
    cmp  eax, 0
    je   al_exist_mal
    mov  eax, valorLeido
    cmp  eax, 100
    ja   al_exist_mal
    mov  tmpExist, eax

    mov  eax, cantidad
    mov  ebx, REG_SIZE
    mul  ebx
    mov  edi, OFFSET registros
    add  edi, eax

    push edi
    mov  ecx, REG_SIZE
al_limpiar:
    mov  BYTE PTR [edi], 0
    inc  edi
    loop al_limpiar
    pop  edi

    mov  esi, OFFSET tmpCodigo
    call CopiarCadena
    push edi
    add  edi, 8
    mov  esi, OFFSET tmpNombre
    call CopiarCadena
    pop  edi
    mov  eax, tmpPrecio
    mov  [edi + 36], eax
    mov  eax, tmpExist
    mov  [edi + 40], eax

    inc  cantidad
    mov  cambios, 1
    mov  edx, OFFSET msgAltaOk
    jmp  al_msg

al_lleno:
    mov  edx, OFFSET msgLleno
    jmp  al_msg
al_codigo_mal:
    mov  edx, OFFSET msgCodigoMal
    jmp  al_msg
al_duplicado:
    mov  edx, OFFSET msgDuplicado
    jmp  al_msg
al_nombre_mal:
    mov  edx, OFFSET msgNombreMal
    jmp  al_msg
al_precio_mal:
    mov  edx, OFFSET msgPrecioMal
    jmp  al_msg
al_exist_mal:
    mov  edx, OFFSET msgExistMal
al_msg:
    call WriteString
    popad
    ret
Alta ENDP

MostrarInventario PROC
    pushad
    mov  ecx, cantidad
    cmp  ecx, 0
    jne  mi_hay
    mov  edx, OFFSET msgNoHay
    call WriteString
    jmp  mi_fin
mi_hay:
    mov  edx, OFFSET msgEncabezado
    call WriteString
    mov  esi, OFFSET registros
mi_loop:
    call ImprimirProducto
    add  esi, REG_SIZE
    loop mi_loop
mi_fin:
    popad
    ret
MostrarInventario ENDP

BuscarProducto PROC
    pushad
    call PedirYBuscar
    cmp  eax, 1
    jne  bp_fin
    call ImprimirProducto
bp_fin:
    popad
    ret
BuscarProducto ENDP

Recibir PROC
    pushad
    call PedirYBuscar
    cmp  eax, 1
    jne  rc_fin

    mov  edx, OFFSET msgCantRecibir
    call PedirEntero
    cmp  eax, 0
    je   rc_cant_mal
    mov  eax, valorLeido
    cmp  eax, 0
    je   rc_cant_mal

    add  eax, [esi + 40]
    jc   rc_excede
    cmp  eax, 100
    ja   rc_excede

    mov  [esi + 40], eax
    mov  cambios, 1
    mov  edx, OFFSET msgRecibidoOk
    call WriteString
    call MostrarNumero
    call Crlf
    jmp  rc_fin

rc_cant_mal:
    mov  edx, OFFSET msgCantMal
    call WriteString
    jmp  rc_fin
rc_excede:
    mov  edx, OFFSET msgExcede
    call WriteString
rc_fin:
    popad
    ret
Recibir ENDP

Vender PROC
    pushad
    call PedirYBuscar
    cmp  eax, 1
    jne  ve_fin

    mov  edx, OFFSET msgCantVender
    call PedirEntero
    cmp  eax, 0
    je   ve_cant_mal
    mov  eax, valorLeido
    cmp  eax, 0
    je   ve_cant_mal
    mov  cantVenta, eax
    cmp  eax, [esi + 40]
    ja   ve_sin_stock

    mov  eax, [esi + 36]
    mul  cantVenta
    jc   ve_desborda
    mov  ventaBase, eax

    mov  ventaDesc, 0
    cmp  cantVenta, 10
    jb   ve_total
    mov  edx, 0
    mov  ebx, 10
    div  ebx
    mov  ventaDesc, eax

ve_total:
    mov  eax, ventaBase
    sub  eax, ventaDesc
    mov  ventaFinal, eax
    add  eax, ingresos
    jc   ve_desborda
    mov  nuevosIngresos, eax

    mov  eax, nuevosIngresos
    mov  ingresos, eax
    mov  eax, [esi + 40]
    sub  eax, cantVenta
    mov  [esi + 40], eax
    mov  cambios, 1

    mov  edx, OFFSET msgVentaOk
    call WriteString
    mov  edx, OFFSET msgBase
    call WriteString
    mov  eax, ventaBase
    call MostrarPrecio
    call Crlf
    cmp  cantVenta, 10
    jb   ve_sin_desc
    mov  edx, OFFSET msgDesc
    call WriteString
    mov  eax, ventaDesc
    call MostrarPrecio
    call Crlf
    jmp  ve_mostrar_total
ve_sin_desc:
    mov  edx, OFFSET msgSinDesc
    call WriteString
ve_mostrar_total:
    mov  edx, OFFSET msgTotal
    call WriteString
    mov  eax, ventaFinal
    call MostrarPrecio
    call Crlf
    jmp  ve_fin

ve_cant_mal:
    mov  edx, OFFSET msgCantMal
    jmp  ve_msg
ve_sin_stock:
    mov  edx, OFFSET msgSinStock
    jmp  ve_msg
ve_desborda:
    mov  edx, OFFSET msgDesborde
ve_msg:
    call WriteString
ve_fin:
    popad
    ret
Vender ENDP

Resumen PROC
    pushad
    mov  ebx, 0
    mov  edi, 0
    mov  ecx, cantidad
    cmp  ecx, 0
    je   rs_mostrar
    mov  esi, OFFSET registros
rs_loop:
    mov  eax, [esi + 40]
    add  ebx, eax
    mul  DWORD PTR [esi + 36]
    jc   rs_desborda
    add  edi, eax
    jc   rs_desborda
    add  esi, REG_SIZE
    loop rs_loop
rs_mostrar:
    mov  edx, OFFSET msgResUnid
    call WriteString
    mov  eax, ebx
    call MostrarNumero
    call Crlf
    mov  edx, OFFSET msgResValor
    call WriteString
    mov  eax, edi
    call MostrarPrecio
    call Crlf
    mov  edx, OFFSET msgResIngr
    call WriteString
    mov  eax, ingresos
    call MostrarPrecio
    call Crlf
    jmp  rs_fin
rs_desborda:
    mov  edx, OFFSET msgDesborde
    call WriteString
rs_fin:
    popad
    ret
Resumen ENDP

Guardar PROC
    pushad
    mov  edx, OFFSET nombreArchivo
    call CreateOutputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   gu_err_crear
    mov  hArchivo, eax

    mov  eax, cantidad
    mov  ebx, REG_SIZE
    mul  ebx
    add  eax, 8
    mov  bytesPedidos, eax

    mov  eax, hArchivo
    mov  edx, OFFSET catMagic
    mov  ecx, bytesPedidos
    call WriteToFile
    mov  bytesEscritos, eax
    mov  eax, hArchivo
    call CloseFile

    mov  eax, bytesEscritos
    cmp  eax, bytesPedidos
    jne  gu_err_escribir
    mov  cambios, 0
    mov  edx, OFFSET msgGuardado
    jmp  gu_msg
gu_err_crear:
    mov  edx, OFFSET msgErrCrear
    jmp  gu_msg
gu_err_escribir:
    mov  edx, OFFSET msgErrEscribir
gu_msg:
    call WriteString
    popad
    ret
Guardar ENDP

ValidarArchivo PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov  inicioRegs, esi
    mov  numRevisados, 0
    cmp  ecx, 0
    je   vaa_ok
vaa_registro:
    call ValidarCodigo
    cmp  eax, 0
    je   vaa_mal
    cmp  BYTE PTR [esi + 8], 0
    je   vaa_mal
    mov  ebx, 0
vaa_nombre:
    cmp  BYTE PTR [esi + 8 + ebx], 0
    je   vaa_nombre_ok
    inc  ebx
    cmp  ebx, 26
    jb   vaa_nombre
    jmp  vaa_mal
vaa_nombre_ok:
    mov  eax, [esi + 36]
    cmp  eax, 1
    jb   vaa_mal
    cmp  eax, PRECIO_MAX
    ja   vaa_mal
    cmp  DWORD PTR [esi + 40], 100
    ja   vaa_mal

    mov  edi, inicioRegs
    mov  ebx, numRevisados
vaa_dup:
    cmp  ebx, 0
    je   vaa_dup_ok
    mov  edx, 0
vaa_letra:
    mov  al, [esi + edx]
    cmp  al, [edi + edx]
    jne  vaa_dup_sig
    inc  edx
    cmp  edx, 7
    jb   vaa_letra
    jmp  vaa_mal
vaa_dup_sig:
    add  edi, REG_SIZE
    dec  ebx
    jmp  vaa_dup
vaa_dup_ok:
    inc  numRevisados
    add  esi, REG_SIZE
    dec  ecx
    jnz  vaa_registro
vaa_ok:
    mov  eax, 1
    jmp  vaa_fin
vaa_mal:
    mov  eax, 0
vaa_fin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
ValidarArchivo ENDP

LeerArchivo PROC
    push ebx
    push ecx
    push edx
    push esi
    mov  edx, OFFSET nombreArchivo
    call OpenInputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   la_no_abre
    mov  hArchivo, eax

    mov  edx, OFFSET bufArchivo
    mov  ecx, 449
    call ReadFromFile
    jc   la_err_leer
    mov  bytesLeidos, eax
    mov  eax, hArchivo
    call CloseFile

    mov  ebx, bytesLeidos
    mov  bufArchivo[ebx], 0

    cmp  bytesLeidos, 8
    jb   la_malo
    mov  eax, DWORD PTR bufArchivo
    cmp  eax, DWORD PTR catMagic
    jne  la_malo
    mov  eax, DWORD PTR [bufArchivo + 4]
    cmp  eax, MAX_PROD
    ja   la_malo
    mov  ebx, REG_SIZE
    mul  ebx
    add  eax, 8
    cmp  eax, bytesLeidos
    jne  la_malo

    mov  esi, OFFSET bufArchivo
    add  esi, 8
    mov  ecx, DWORD PTR [bufArchivo + 4]
    call ValidarArchivo
    cmp  eax, 0
    je   la_malo
    mov  eax, 1
    jmp  la_fin

la_err_leer:
    mov  eax, hArchivo
    call CloseFile
    mov  edx, OFFSET msgErrLeer
    jmp  la_msg
la_no_abre:
    mov  edx, OFFSET msgNoArchivo
    jmp  la_msg
la_malo:
    mov  edx, OFFSET msgArchivoMal
la_msg:
    call WriteString
    mov  eax, 0
la_fin:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
LeerArchivo ENDP

Cargar PROC
    pushad
    call LeerArchivo
    cmp  eax, 0
    je   ca_fin

    mov  eax, DWORD PTR [bufArchivo + 4]
    mov  cantidad, eax
    mov  ebx, REG_SIZE
    mul  ebx
    mov  ecx, eax
    cmp  ecx, 0
    je   ca_listo
    mov  esi, OFFSET bufArchivo
    add  esi, 8
    mov  edi, OFFSET registros
ca_copia:
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    loop ca_copia
ca_listo:
    mov  cambios, 0
    mov  edx, OFFSET msgCargado
    call WriteString
    mov  eax, cantidad
    call MostrarNumero
    call Crlf
ca_fin:
    popad
    ret
Cargar ENDP

VerArchivo PROC
    pushad
    call LeerArchivo
    cmp  eax, 0
    je   va_fin

    mov  edx, OFFSET msgVerTitulo
    call WriteString
    mov  edx, OFFSET msgVerCant
    call WriteString
    mov  eax, DWORD PTR [bufArchivo + 4]
    call MostrarNumero
    call Crlf

    mov  ecx, DWORD PTR [bufArchivo + 4]
    cmp  ecx, 0
    jne  va_hay
    mov  edx, OFFSET msgVerVacio
    call WriteString
    jmp  va_cierre

va_hay:
    mov  esi, OFFSET bufArchivo
    add  esi, 8
    mov  numProd, 1
va_loop:
    call Crlf
    mov  edx, OFFSET msgVerProd
    call WriteString
    mov  eax, numProd
    call MostrarNumero
    call Crlf
    mov  edx, OFFSET msgVerCodigo
    call WriteString
    mov  edx, esi
    call WriteString
    call Crlf
    mov  edx, OFFSET msgVerNombre
    call WriteString
    lea  edx, [esi + 8]
    call WriteString
    call Crlf
    mov  edx, OFFSET msgVerPrecio
    call WriteString
    mov  eax, [esi + 36]
    call MostrarPrecio
    call Crlf
    mov  edx, OFFSET msgVerExist
    call WriteString
    mov  eax, [esi + 40]
    call MostrarNumero
    mov  edx, OFFSET msgVerUnid
    call WriteString
    call Crlf
    add  esi, REG_SIZE
    inc  numProd
    dec  ecx
    jnz  va_loop
va_cierre:
    mov  edx, OFFSET msgVerFin
    call WriteString
va_fin:
    popad
    ret
VerArchivo ENDP

END main