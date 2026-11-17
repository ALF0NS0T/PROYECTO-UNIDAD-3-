; PARTICIPANTES DEL PROYECTO FINAL
; 23170344 - SOTO NIETO JESUS ALFONSO
; 23170341 - SERRANO SALOMON ALEXIS
; 23170161 - GASTELUM VERDUSZCO FERNANDO

; DOCENTE: ING. MEDINA (mAIstro)

; VERSION UNIDAD 3: mismo sistema de la Unidad 2 con procedimientos
; reutilizables, macros y USES. Funciones, validaciones y regla de
; negocio (10% desde 10 unidades) sin cambios.

INCLUDE Irvine32.inc

; ---- constantes del sistema ----
MAX_PROD     = 10
REG_SIZE     = 44
PRECIO_MAX   = 999999
MAX_EXIST    = 100
MAX_NOMBRE   = 25
UMBRAL_DESC  = 10
LONG_CODIGO  = 7
SIN_LIMITE   = 0FFFFFFFFh
TAM_ENTRADA  = 81
TAM_ARCHIVO  = 450
TAM_CABECERA = 8

; ---- desplazamientos dentro de un registro de 44 bytes ----
; 0..7 codigo | 8..35 nombre | 36..39 precio (centavos) | 40..43 existencia
OFF_NOMBRE   = 8
OFF_PRECIO   = 36
OFF_EXIST    = 40
OFF_CANT     = 4

; ---- macros ----

; Imprimir texto: muestra la cadena terminada en cero. Modifica EDX.
Imprimir MACRO texto
    mov  edx, OFFSET texto
    call WriteString
ENDM

; Preguntar texto: muestra la peticion y lee en bufEntrada (EAX = longitud).
; Modifica EDX y los registros que usa PedirTexto (ninguno mas que EAX).
Preguntar MACRO texto
    mov  edx, OFFSET texto
    call PedirTexto
ENDM

; Campo etiqueta, direccion: muestra una etiqueta y la cadena que esta en
; la direccion indicada (por ejemplo <[esi + OFF_NOMBRE]>). Modifica EDX.
Campo MACRO etiqueta, direccion
    mov  edx, OFFSET etiqueta
    call WriteString
    lea  edx, direccion
    call WriteString
ENDM

; Valor etiqueta, origen, rutina: muestra una etiqueta y un numero.
; rutina es MostrarNumero o MostrarPrecio. Modifica EAX y EDX.
Valor MACRO etiqueta, origen, rutina
    mov  edx, OFFSET etiqueta
    call WriteString
    mov  eax, origen
    call rutina
ENDM

; ValorLn: igual que Valor y agrega salto de linea.
ValorLn MACRO etiqueta, origen, rutina
    mov  edx, OFFSET etiqueta
    call WriteString
    mov  eax, origen
    call rutina
    call Crlf
ENDM

; FueraDeRango registro, minimo, maximo, destino: salta a destino si el
; valor del registro es menor que minimo o mayor que maximo (sin signo).
FueraDeRango MACRO registro, minimo, maximo, destino
    cmp  registro, minimo
    jb   destino
    cmp  registro, maximo
    ja   destino
ENDM

; DigitoAEBX: convierte el caracter '0'..'9' de BL en su valor en EBX.
DigitoAEBX MACRO
    sub  bl, '0'
    movzx ebx, bl
ENDM

; Dividir divisor: EDX:EAX / divisor. Deja cociente en EAX y resto en EDX.
; Modifica EBX.
Dividir MACRO divisor
    mov  edx, 0
    mov  ebx, divisor
    div  ebx
ENDM

; RevisarGrupo minimo, maximo, destino: revisa que los 3 caracteres que
; empiezan en ESI esten entre minimo y maximo; si alguno falla salta a
; destino. Avanza ESI 3 posiciones y usa ECX y BL. Lleva etiqueta interna.
RevisarGrupo MACRO minimo, maximo, destino
    LOCAL ciclo
    mov  ecx, 3
ciclo:
    mov  bl, [esi]
    FueraDeRango bl, minimo, maximo, destino
    inc  esi
    loop ciclo
ENDM

; Opcion caracter, destino: salta a destino si AL es el caracter dado.
Opcion MACRO caracter, destino
    cmp  al, caracter
    je   destino
ENDM

; Accion etiqueta, rutina: bloque del menu que llama a la rutina y vuelve
; al menu.
Accion MACRO etiqueta, rutina
etiqueta:
    call rutina
    jmp  menu_loop
ENDM

.data
catMagic        BYTE "INV1"
cantidad        DWORD 0
registros       BYTE (MAX_PROD * REG_SIZE) DUP(0)

cambios         BYTE 0
ingresos        DWORD 0

nombreArchivo   BYTE "inventario.dat",0
hArchivo        DWORD 0
bytesPedidos    DWORD 0
bytesEscritos   DWORD 0
bytesLeidos     DWORD 0
bufArchivo      BYTE TAM_ARCHIVO DUP(0)

bufEntrada      BYTE TAM_ENTRADA DUP(0)
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

; main
;   Menu principal. Despacha cada opcion con las macros Opcion y Accion.
main PROC
menu_loop:
    Imprimir menuTxt
    Preguntar msgOpcion
    cmp  eax, 1
    jne  opcion_mal
    mov  al, bufEntrada

    Opcion '1', op1
    Opcion '2', op2
    Opcion '3', op3
    Opcion '4', op4
    Opcion '5', op5
    Opcion '6', op6
    Opcion '7', op7
    Opcion '8', op8
    Opcion '9', op9
    Opcion '0', op0
opcion_mal:
    Imprimir msgOpcionMal
    jmp  menu_loop

    Accion op1, Alta
    Accion op2, MostrarInventario
    Accion op3, BuscarProducto
    Accion op4, Recibir
    Accion op5, Vender
    Accion op6, Resumen
    Accion op7, Guardar
    Accion op8, Cargar
    Accion op9, VerArchivo

op0:
    cmp  cambios, 0
    je   salir
    Preguntar msgSinGuardar
    cmp  eax, 1
    jne  menu_loop
    mov  al, bufEntrada
    Opcion 'S', salir
    Opcion 's', salir
    jmp  menu_loop

salir:
    Imprimir msgAdios
    exit
main ENDP

; PedirTexto
;   Recibe   : EDX = direccion de la peticion (cadena terminada en cero)
;   Devuelve : bufEntrada con lo escrito; EAX = numero de caracteres
;   Conserva : ECX, EDX (USES)
PedirTexto PROC USES ecx edx
    call WriteString
    mov  edx, OFFSET bufEntrada
    mov  ecx, TAM_ENTRADA
    call ReadString
    ret
PedirTexto ENDP

; AcumularDigito (nuevo)
;   Recibe   : EAX = acumulador; BL = caracter '0'..'9' ya validado
;   Devuelve : EAX = EAX * 10 + digito; CF = 1 si el resultado no cabe en 32 bits
;   Conserva : EBX, EDX (USES). Los registros de USES se recuperan con POP,
;              que no altera CF, por eso CF llega intacta a quien llama.
AcumularDigito PROC USES ebx edx
    DigitoAEBX
    mov  edx, 10
    mul  edx
    jc   ad_fin
    add  eax, ebx
ad_fin:
    ret
AcumularDigito ENDP

; LeerEntero
;   Recibe   : ESI = cadena terminada en cero
;   Devuelve : EAX = 1 y valorLeido = numero si es un entero sin signo valido;
;              EAX = 0 si esta vacia, tiene otro caracter o no cabe en 32 bits
;   Conserva : EBX, ESI (USES); EDX lo conserva AcumularDigito
LeerEntero PROC USES ebx esi
    mov  eax, 0
    cmp  BYTE PTR [esi], 0
    je   le_mal
le_ciclo:
    mov  bl, [esi]
    cmp  bl, 0
    je   le_ok
    FueraDeRango bl, '0', '9', le_mal
    call AcumularDigito
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
    ret
LeerEntero ENDP

; PedirEnteroRango (nuevo: reemplaza a PedirEntero)
;   Recibe   : EDX = peticion; EBX = minimo; ECX = maximo
;   Devuelve : EAX = 1 y valorLeido si es entero y esta entre EBX y ECX;
;              EAX = 0 en cualquier otro caso
;   Conserva : EBX, ECX, EDX, ESI
PedirEnteroRango PROC USES esi
    call PedirTexto
    mov  esi, OFFSET bufEntrada
    call LeerEntero
    cmp  eax, 0
    je   per_fin
    mov  eax, 0
    cmp  valorLeido, ebx
    jb   per_fin
    cmp  valorLeido, ecx
    ja   per_fin
    mov  eax, 1
per_fin:
    ret
PedirEnteroRango ENDP

; PedirCantidad (nuevo: lo usan Recibir y Vender)
;   Recibe   : EDX = peticion
;   Devuelve : EAX = cantidad (mayor que 0) o 0 si la entrada fue invalida
;   Conserva : EBX, ECX, EDX
PedirCantidad PROC USES ebx ecx
    mov  ebx, 1
    mov  ecx, SIN_LIMITE
    call PedirEnteroRango
    cmp  eax, 0
    je   pc_fin
    mov  eax, valorLeido
pc_fin:
    ret
PedirCantidad ENDP

; LeerPrecio
;   Recibe   : ESI = cadena con el precio (ej. 12.50, 45, 8.5)
;   Devuelve : EAX = 1 y tmpPrecio en centavos si es valido (0.01 a 9999.99);
;              EAX = 0 si no
;   Conserva : EBX, ECX, EDX, ESI (USES)
LeerPrecio PROC USES ebx ecx edx esi
    mov  eax, 0
    mov  ecx, 0
lp_pesos:
    mov  bl, [esi]
    cmp  bl, 0
    je   lp_centavos
    cmp  bl, '.'
    je   lp_centavos
    FueraDeRango bl, '0', '9', lp_mal
    call AcumularDigito
    cmp  eax, 9999
    ja   lp_mal
    inc  ecx
    inc  esi
    jmp  lp_pesos

lp_centavos:
    cmp  ecx, 0
    je   lp_mal
    mov  edx, 100
    mul  edx
    cmp  bl, 0
    je   lp_listo
    inc  esi

    mov  bl, [esi]
    FueraDeRango bl, '0', '9', lp_mal
    DigitoAEBX
    imul ebx, ebx, 10
    add  eax, ebx
    inc  esi

    mov  bl, [esi]
    cmp  bl, 0
    je   lp_listo
    FueraDeRango bl, '0', '9', lp_mal
    DigitoAEBX
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
    ret
LeerPrecio ENDP

; ValidarCodigo
;   Recibe   : ESI = cadena a revisar
;   Devuelve : EAX = 1 si tiene el formato ABC-123 (3 mayusculas, guion,
;              3 digitos); EAX = 0 si no
;   Conserva : EBX, ECX, ESI (USES)
ValidarCodigo PROC USES ebx ecx esi
    mov  eax, 0
    RevisarGrupo 'A', 'Z', vc_fin
    cmp  BYTE PTR [esi], '-'
    jne  vc_fin
    inc  esi
    RevisarGrupo '0', '9', vc_fin
    cmp  BYTE PTR [esi], 0
    jne  vc_fin
    mov  eax, 1
vc_fin:
    ret
ValidarCodigo ENDP

; CompararCodigos (nuevo: lo usan BuscarCodigo y ValidarArchivo)
;   Recibe   : ESI = un codigo; EDI = otro codigo (LONG_CODIGO caracteres)
;   Devuelve : EAX = 1 si son iguales; EAX = 0 si difieren
;   Conserva : EBX, ECX (USES); ESI y EDI no se mueven
CompararCodigos PROC USES ebx ecx
    mov  ecx, 0
cd_letra:
    mov  bl, [esi + ecx]
    cmp  bl, [edi + ecx]
    jne  cd_distinto
    inc  ecx
    cmp  ecx, LONG_CODIGO
    jb   cd_letra
    mov  eax, 1
    jmp  cd_fin
cd_distinto:
    mov  eax, 0
cd_fin:
    ret
CompararCodigos ENDP

; BuscarCodigo
;   Recibe   : bufEntrada con un codigo ya validado
;   Devuelve : EAX = 1 y ESI = registro encontrado; EAX = 0 si no existe
;              (ESI queda sin valor util en ese caso)
;   Conserva : ECX, EDI (USES). ESI es salida y por eso no esta en USES
BuscarCodigo PROC USES ecx edi
    mov  eax, 0
    mov  esi, OFFSET registros
    mov  ecx, cantidad
    mov  edi, OFFSET bufEntrada
    cmp  ecx, 0
    je   bc_fin
bc_registro:
    call CompararCodigos
    cmp  eax, 1
    je   bc_fin
    add  esi, REG_SIZE
    loop bc_registro
bc_fin:
    ret
BuscarCodigo ENDP

; PedirCodigoValido (nuevo: lo usan Alta y PedirYBuscar)
;   Recibe   : nada
;   Devuelve : EAX = 1 si el codigo capturado tiene formato valido
;              (queda en bufEntrada); EAX = 0 si no, tras mostrar el motivo
;              ESI = bufEntrada (salida)
;   Conserva : EDX (USES)
PedirCodigoValido PROC USES edx
    Preguntar msgCodigo
    mov  esi, OFFSET bufEntrada
    call ValidarCodigo
    cmp  eax, 0
    jne  pcv_fin
    Imprimir msgCodigoMal
    mov  eax, 0
pcv_fin:
    ret
PedirCodigoValido ENDP

; PedirYBuscar
;   Recibe   : nada
;   Devuelve : EAX = 1 y ESI = registro del producto si el codigo es valido
;              y existe; EAX = 0 si no (ya se mostro el motivo)
;   Conserva : EDX (USES)
PedirYBuscar PROC USES edx
    call PedirCodigoValido
    cmp  eax, 0
    je   pb_fin
    call BuscarCodigo
    cmp  eax, 1
    je   pb_fin
    Imprimir msgNoExiste
    mov  eax, 0
pb_fin:
    ret
PedirYBuscar ENDP

; CopiarCadena
;   Recibe   : ESI = origen; EDI = destino (copia hasta el terminador nulo)
;   Devuelve : nada
;   Conserva : EAX, ESI, EDI (USES)
CopiarCadena PROC USES eax esi edi
cc_loop:
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    cmp  al, 0
    jne  cc_loop
    ret
CopiarCadena ENDP

; EnteroACadena
;   Recibe   : EAX = numero sin signo; EDI = donde escribir los digitos
;   Devuelve : cadena terminada en cero; EDI queda en el terminador (salida)
;   Conserva : EAX, EBX, ECX, EDX (USES)
EnteroACadena PROC USES eax ebx ecx edx
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
    ret
EnteroACadena ENDP

; MostrarNumero
;   Recibe   : EAX = numero sin signo
;   Devuelve : escribe el numero en pantalla
;   Conserva : EAX, EDX, EDI (USES y EnteroACadena)
MostrarNumero PROC USES edx edi
    mov  edi, OFFSET bufNum
    call EnteroACadena
    Imprimir bufNum
    ret
MostrarNumero ENDP

; MostrarPrecio
;   Recibe   : EAX = precio en centavos
;   Devuelve : escribe $pesos.centavos MXN en pantalla
;   Conserva : EAX, EBX, EDX, EDI (USES)
MostrarPrecio PROC USES eax ebx edx edi
    mov  edi, OFFSET bufNum
    mov  BYTE PTR [edi], '$'
    inc  edi
    Dividir 100
    push edx
    call EnteroACadena
    pop  eax
    mov  BYTE PTR [edi], '.'
    inc  edi
    Dividir 10
    add  al, '0'
    mov  [edi], al
    inc  edi
    add  dl, '0'
    mov  [edi], dl
    inc  edi
    mov  BYTE PTR [edi], 0
    Imprimir bufNum
    Imprimir txtMXN
    ret
MostrarPrecio ENDP

; ImprimirProducto
;   Recibe   : ESI = registro del producto
;   Devuelve : escribe una linea con codigo, nombre, precio y existencia
;   Conserva : EAX, EDX (USES); ESI no se mueve
ImprimirProducto PROC USES eax edx
    Campo txtCodigo, <[esi]>
    Campo txtNombre, <[esi + OFF_NOMBRE]>
    Valor txtPrecio, <[esi + OFF_PRECIO]>, MostrarPrecio
    Valor txtExist, <[esi + OFF_EXIST]>, MostrarNumero
    call Crlf
    ret
ImprimirProducto ENDP

; CapturarProducto (nuevo: sale de Alta)
;   Recibe   : nada
;   Devuelve : EAX = 1 si todos los datos fueron validos (quedan en
;              tmpCodigo, tmpNombre, tmpPrecio y tmpExist); EAX = 0 si
;              algo se rechazo (ya se mostro el motivo)
;   Conserva : EBX, ECX, EDX, ESI, EDI (USES)
CapturarProducto PROC USES ebx ecx edx esi edi
    call PedirCodigoValido
    cmp  eax, 0
    je   cp_fin
    call BuscarCodigo
    cmp  eax, 1
    je   cp_duplicado
    mov  esi, OFFSET bufEntrada
    mov  edi, OFFSET tmpCodigo
    call CopiarCadena

    Preguntar msgNombre
    cmp  eax, 1
    jb   cp_nombre_mal
    cmp  eax, MAX_NOMBRE
    ja   cp_nombre_mal
    mov  esi, OFFSET bufEntrada
    mov  edi, OFFSET tmpNombre
    call CopiarCadena

    Preguntar msgPrecio
    mov  esi, OFFSET bufEntrada
    call LeerPrecio
    cmp  eax, 0
    je   cp_precio_mal

    mov  edx, OFFSET msgExistencia
    mov  ebx, 0
    mov  ecx, MAX_EXIST
    call PedirEnteroRango
    cmp  eax, 0
    je   cp_exist_mal
    mov  eax, valorLeido
    mov  tmpExist, eax
    mov  eax, 1
    jmp  cp_fin

cp_duplicado:
    Imprimir msgDuplicado
    jmp  cp_rechazo
cp_nombre_mal:
    Imprimir msgNombreMal
    jmp  cp_rechazo
cp_precio_mal:
    Imprimir msgPrecioMal
    jmp  cp_rechazo
cp_exist_mal:
    Imprimir msgExistMal
cp_rechazo:
    mov  eax, 0
cp_fin:
    ret
CapturarProducto ENDP

; GuardarRegistro (nuevo: sale de Alta)
;   Recibe   : tmpCodigo, tmpNombre, tmpPrecio y tmpExist ya validados
;   Devuelve : nada; escribe el registro nuevo, suma 1 a cantidad y marca
;              cambios sin guardar
;   Conserva : EAX, EBX, ECX, EDX, ESI, EDI (USES)
GuardarRegistro PROC USES eax ebx ecx edx esi edi
    mov  eax, cantidad
    mov  ebx, REG_SIZE
    mul  ebx
    mov  edi, OFFSET registros
    add  edi, eax

    push edi
    mov  ecx, REG_SIZE
gr_limpiar:
    mov  BYTE PTR [edi], 0
    inc  edi
    loop gr_limpiar
    pop  edi

    mov  esi, OFFSET tmpCodigo
    call CopiarCadena
    push edi
    add  edi, OFF_NOMBRE
    mov  esi, OFFSET tmpNombre
    call CopiarCadena
    pop  edi
    mov  eax, tmpPrecio
    mov  [edi + OFF_PRECIO], eax
    mov  eax, tmpExist
    mov  [edi + OFF_EXIST], eax

    inc  cantidad
    mov  cambios, 1
    ret
GuardarRegistro ENDP

; Alta
;   Recibe   : nada
;   Devuelve : registra un producto si hay lugar y los datos son validos
;   Conserva : EAX, EDX (USES)
Alta PROC USES eax edx
    cmp  cantidad, MAX_PROD
    jae  al_lleno
    call CapturarProducto
    cmp  eax, 0
    je   al_fin
    call GuardarRegistro
    Imprimir msgAltaOk
    jmp  al_fin
al_lleno:
    Imprimir msgLleno
al_fin:
    ret
Alta ENDP

; MostrarInventario
;   Recibe   : nada
;   Devuelve : escribe todos los productos (recorrido con ESI)
;   Conserva : ECX, EDX, ESI (USES)
MostrarInventario PROC USES ecx edx esi
    mov  ecx, cantidad
    cmp  ecx, 0
    jne  mi_hay
    Imprimir msgNoHay
    jmp  mi_fin
mi_hay:
    Imprimir msgEncabezado
    mov  esi, OFFSET registros
mi_loop:
    call ImprimirProducto
    add  esi, REG_SIZE
    loop mi_loop
mi_fin:
    ret
MostrarInventario ENDP

; BuscarProducto
;   Recibe   : nada
;   Devuelve : escribe el producto cuyo codigo se capture
;   Conserva : EAX, ESI (USES)
BuscarProducto PROC USES eax esi
    call PedirYBuscar
    cmp  eax, 1
    jne  bp_fin
    call ImprimirProducto
bp_fin:
    ret
BuscarProducto ENDP

; Recibir
;   Recibe   : nada
;   Devuelve : suma unidades a la existencia sin pasar de MAX_EXIST
;   Conserva : EAX, EDX, ESI (USES)
Recibir PROC USES eax edx esi
    call PedirYBuscar
    cmp  eax, 1
    jne  rc_fin

    mov  edx, OFFSET msgCantRecibir
    call PedirCantidad
    cmp  eax, 0
    je   rc_cant_mal

    add  eax, [esi + OFF_EXIST]
    jc   rc_excede
    cmp  eax, MAX_EXIST
    ja   rc_excede

    mov  [esi + OFF_EXIST], eax
    mov  cambios, 1
    ValorLn msgRecibidoOk, <[esi + OFF_EXIST]>, MostrarNumero
    jmp  rc_fin

rc_cant_mal:
    Imprimir msgCantMal
    jmp  rc_fin
rc_excede:
    Imprimir msgExcede
rc_fin:
    ret
Recibir ENDP

; CalcularVenta (nuevo: sale de Vender)
;   Recibe   : ESI = registro del producto; cantVenta = unidades (mayor que 0)
;   Devuelve : EAX = 1 y ventaBase, ventaDesc, ventaFinal y nuevosIngresos
;              calculados; EAX = 0 si hubo desbordamiento
;              (descuento = base / 10 con division entera: la fraccion de
;              centavo se descarta)
;   Conserva : EBX, EDX (USES); no modifica el registro del producto
CalcularVenta PROC USES ebx edx
    mov  eax, [esi + OFF_PRECIO]
    mul  cantVenta
    jc   cv_desborda
    mov  ventaBase, eax

    mov  ventaDesc, 0
    cmp  cantVenta, UMBRAL_DESC
    jb   cv_total
    Dividir 10
    mov  ventaDesc, eax

cv_total:
    mov  eax, ventaBase
    sub  eax, ventaDesc
    mov  ventaFinal, eax
    add  eax, ingresos
    jc   cv_desborda
    mov  nuevosIngresos, eax
    mov  eax, 1
    jmp  cv_fin
cv_desborda:
    mov  eax, 0
cv_fin:
    ret
CalcularVenta ENDP

; MostrarVenta (nuevo: sale de Vender)
;   Recibe   : ventaBase, ventaDesc, ventaFinal y cantVenta ya calculados
;   Devuelve : escribe el detalle de la venta
;   Conserva : EAX, EDX (USES)
MostrarVenta PROC USES eax edx
    Imprimir msgVentaOk
    ValorLn msgBase, ventaBase, MostrarPrecio
    cmp  cantVenta, UMBRAL_DESC
    jb   mv_sin_desc
    ValorLn msgDesc, ventaDesc, MostrarPrecio
    jmp  mv_total
mv_sin_desc:
    Imprimir msgSinDesc
mv_total:
    ValorLn msgTotal, ventaFinal, MostrarPrecio
    ret
MostrarVenta ENDP

; Vender
;   Recibe   : nada
;   Devuelve : registra la venta, descuenta existencia y suma ingresos
;   Conserva : EAX, EDX, ESI (USES)
Vender PROC USES eax edx esi
    call PedirYBuscar
    cmp  eax, 1
    jne  ve_fin

    mov  edx, OFFSET msgCantVender
    call PedirCantidad
    cmp  eax, 0
    je   ve_cant_mal
    mov  cantVenta, eax
    cmp  eax, [esi + OFF_EXIST]
    ja   ve_sin_stock

    call CalcularVenta
    cmp  eax, 0
    je   ve_desborda

    mov  eax, nuevosIngresos
    mov  ingresos, eax
    mov  eax, [esi + OFF_EXIST]
    sub  eax, cantVenta
    mov  [esi + OFF_EXIST], eax
    mov  cambios, 1
    call MostrarVenta
    jmp  ve_fin

ve_cant_mal:
    Imprimir msgCantMal
    jmp  ve_fin
ve_sin_stock:
    Imprimir msgSinStock
    jmp  ve_fin
ve_desborda:
    Imprimir msgDesborde
ve_fin:
    ret
Vender ENDP

; Resumen
;   Recibe   : nada
;   Devuelve : escribe unidades, valor del inventario e ingresos
;   Conserva : EAX, EBX, ECX, EDX, ESI, EDI (USES)
Resumen PROC USES eax ebx ecx edx esi edi
    mov  ebx, 0
    mov  edi, 0
    mov  ecx, cantidad
    cmp  ecx, 0
    je   rs_mostrar
    mov  esi, OFFSET registros
rs_loop:
    mov  eax, [esi + OFF_EXIST]
    add  ebx, eax
    mul  DWORD PTR [esi + OFF_PRECIO]
    jc   rs_desborda
    add  edi, eax
    jc   rs_desborda
    add  esi, REG_SIZE
    loop rs_loop
rs_mostrar:
    ValorLn msgResUnid, ebx, MostrarNumero
    ValorLn msgResValor, edi, MostrarPrecio
    ValorLn msgResIngr, ingresos, MostrarPrecio
    jmp  rs_fin
rs_desborda:
    Imprimir msgDesborde
rs_fin:
    ret
Resumen ENDP

; Guardar
;   Recibe   : nada
;   Devuelve : escribe inventario.dat (INV1 + cantidad + registros)
;   Conserva : EAX, EBX, ECX, EDX (USES)
Guardar PROC USES eax ebx ecx edx
    mov  edx, OFFSET nombreArchivo
    call CreateOutputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   gu_err_crear
    mov  hArchivo, eax

    mov  eax, cantidad
    mov  ebx, REG_SIZE
    mul  ebx
    add  eax, TAM_CABECERA
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
    Imprimir msgGuardado
    jmp  gu_fin
gu_err_crear:
    Imprimir msgErrCrear
    jmp  gu_fin
gu_err_escribir:
    Imprimir msgErrEscribir
gu_fin:
    ret
Guardar ENDP

; ValidarArchivo
;   Recibe   : ESI = primer registro leido; ECX = cantidad de registros
;   Devuelve : EAX = 1 si todos los registros son validos (codigo, nombre,
;              precio, existencia y sin codigos repetidos); EAX = 0 si no
;   Conserva : EBX, ECX, ESI, EDI (USES)
ValidarArchivo PROC USES ebx ecx esi edi
    mov  inicioRegs, esi
    mov  numRevisados, 0
    cmp  ecx, 0
    je   vaa_ok
vaa_registro:
    call ValidarCodigo
    cmp  eax, 0
    je   vaa_mal
    cmp  BYTE PTR [esi + OFF_NOMBRE], 0
    je   vaa_mal
    mov  ebx, 0
vaa_nombre:
    cmp  BYTE PTR [esi + OFF_NOMBRE + ebx], 0
    je   vaa_nombre_ok
    inc  ebx
    cmp  ebx, MAX_NOMBRE + 1
    jb   vaa_nombre
    jmp  vaa_mal
vaa_nombre_ok:
    mov  eax, [esi + OFF_PRECIO]
    cmp  eax, 1
    jb   vaa_mal
    cmp  eax, PRECIO_MAX
    ja   vaa_mal
    cmp  DWORD PTR [esi + OFF_EXIST], MAX_EXIST
    ja   vaa_mal

    mov  edi, inicioRegs
    mov  ebx, numRevisados
vaa_dup:
    cmp  ebx, 0
    je   vaa_dup_ok
    call CompararCodigos
    cmp  eax, 1
    je   vaa_mal
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
    ret
ValidarArchivo ENDP

; LeerArchivo
;   Recibe   : nada
;   Devuelve : EAX = 1 si inventario.dat se leyo a bufArchivo y paso todas
;              las validaciones; EAX = 0 si no (ya se mostro el motivo)
;   Conserva : EBX, ECX, EDX, ESI (USES)
LeerArchivo PROC USES ebx ecx edx esi
    mov  edx, OFFSET nombreArchivo
    call OpenInputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   la_no_abre
    mov  hArchivo, eax

    mov  edx, OFFSET bufArchivo
    mov  ecx, TAM_ARCHIVO - 1
    call ReadFromFile
    jc   la_err_leer
    mov  bytesLeidos, eax
    mov  eax, hArchivo
    call CloseFile

    mov  ebx, bytesLeidos
    mov  bufArchivo[ebx], 0

    cmp  bytesLeidos, TAM_CABECERA
    jb   la_malo
    mov  eax, DWORD PTR bufArchivo
    cmp  eax, DWORD PTR catMagic
    jne  la_malo
    mov  eax, DWORD PTR [bufArchivo + OFF_CANT]
    cmp  eax, MAX_PROD
    ja   la_malo
    mov  ebx, REG_SIZE
    mul  ebx
    add  eax, TAM_CABECERA
    cmp  eax, bytesLeidos
    jne  la_malo

    mov  esi, OFFSET bufArchivo
    add  esi, TAM_CABECERA
    mov  ecx, DWORD PTR [bufArchivo + OFF_CANT]
    call ValidarArchivo
    cmp  eax, 0
    je   la_malo
    mov  eax, 1
    jmp  la_fin

la_err_leer:
    mov  eax, hArchivo
    call CloseFile
    Imprimir msgErrLeer
    jmp  la_error
la_no_abre:
    Imprimir msgNoArchivo
    jmp  la_error
la_malo:
    Imprimir msgArchivoMal
la_error:
    mov  eax, 0
la_fin:
    ret
LeerArchivo ENDP

; Cargar
;   Recibe   : nada
;   Devuelve : copia los registros del archivo al catalogo si el archivo es
;              valido; si no, el catalogo queda sin cambios
;   Conserva : EAX, EBX, ECX, EDX, ESI, EDI (USES)
Cargar PROC USES eax ebx ecx edx esi edi
    call LeerArchivo
    cmp  eax, 0
    je   ca_fin

    mov  eax, DWORD PTR [bufArchivo + OFF_CANT]
    mov  cantidad, eax
    mov  ebx, REG_SIZE
    mul  ebx
    mov  ecx, eax
    cmp  ecx, 0
    je   ca_listo
    mov  esi, OFFSET bufArchivo
    add  esi, TAM_CABECERA
    mov  edi, OFFSET registros
ca_copia:
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    loop ca_copia
ca_listo:
    mov  cambios, 0
    ValorLn msgCargado, cantidad, MostrarNumero
ca_fin:
    ret
Cargar ENDP

; VerArchivo
;   Recibe   : nada
;   Devuelve : muestra el contenido de inventario.dat sin cargarlo
;   Conserva : EAX, ECX, EDX, ESI (USES)
VerArchivo PROC USES eax ecx edx esi
    call LeerArchivo
    cmp  eax, 0
    je   va_fin

    Imprimir msgVerTitulo
    ValorLn msgVerCant, <DWORD PTR [bufArchivo + OFF_CANT]>, MostrarNumero

    mov  ecx, DWORD PTR [bufArchivo + OFF_CANT]
    cmp  ecx, 0
    jne  va_hay
    Imprimir msgVerVacio
    jmp  va_cierre

va_hay:
    mov  esi, OFFSET bufArchivo
    add  esi, TAM_CABECERA
    mov  numProd, 1
va_loop:
    call Crlf
    ValorLn msgVerProd, numProd, MostrarNumero
    Campo msgVerCodigo, <[esi]>
    call Crlf
    Campo msgVerNombre, <[esi + OFF_NOMBRE]>
    call Crlf
    ValorLn msgVerPrecio, <[esi + OFF_PRECIO]>, MostrarPrecio
    Valor msgVerExist, <[esi + OFF_EXIST]>, MostrarNumero
    Imprimir msgVerUnid
    call Crlf
    add  esi, REG_SIZE
    inc  numProd
    dec  ecx
    jnz  va_loop
va_cierre:
    Imprimir msgVerFin
va_fin:
    ret
VerArchivo ENDP

END main
