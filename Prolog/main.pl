:- module(main, [ejecutar/0]).

/* =========================================================================
   PRACTICA I: DEL PÍXEL A LA INTEGRAL (PROLOG)
   ========================================================================= */

ejecutar :-
    Ruta = 'curva_binaria_P4.pbm',
    (   cargar_pbm_p4(Ruta, Ancho, Alto, DatosBytes)
    ->  AnchoBytes is div(Ancho + 7, 8),
        writeln('======================================================'),
        format('Imagen cargada: ~w x ~w pixeles~n', [Ancho, Alto]),
        
        MaxX is Ancho - 1,
        findall(Altura,
                (between(0, MaxX, X),
                 f_x(X, DatosBytes, Alto, AnchoBytes, Altura)),
                M),
        
        sum_list(M, Area),
        format('Area calculada = ~w pixeles cuadrados~n', [Area]),
        writeln('======================================================'),
        
        writeln('\nREPRESENTACION EN CONSOLA DE LA CURVA (REESCALADA):'),
        dibujar_curva_consola(M, Alto, 80),
        
        writeln('\nALGUNOS VALORES x_i -> f(x_i):'),
        mostrar_muestras(M, Ancho, 10),
        writeln('======================================================')
    ;   writeln('ERROR: No se pudo leer el archivo curva_binaria_P4.pbm.')
    ).

/* -------------------------------------------------------------------------
   1. LECTURA DEL ENCABEZADO Y BINARIO PBM P4
   ------------------------------------------------------------------------- */
cargar_pbm_p4(Ruta, Ancho, Alto, DatosBytes) :-
    open(Ruta, read, Stream, [type(binary)]),
    read_stream_to_codes(Stream, TodosBytes),
    close(Stream),
    extraer_encabezado_y_datos(TodosBytes, Ancho, Alto, DatosBytes).

extraer_encabezado_y_datos(Bytes, Ancho, Alto, Datos) :-
    obtener_tokens_ascii(Bytes, Tokens, RestoBytes),
    Tokens = [Magic, AnchoCode, AltoCode | _],
    atom_codes(MagicAtom, Magic),
    ( MagicAtom == 'P4' ; MagicAtom == 'p4' ),
    atom_codes(AnchoAtom, AnchoCode),
    atom_codes(AltoAtom, AltoCode),
    atom_number(AnchoAtom, Ancho),
    atom_number(AltoAtom, Alto),
    Datos = RestoBytes.

obtener_tokens_ascii([B | Resto], Tokens, RestoBytes) :-
    is_whitespace(B), !,
    obtener_tokens_ascii(Resto, Tokens, RestoBytes).
obtener_tokens_ascii([0'# | Resto], Tokens, RestoBytes) :- !,
    saltar_linea(Resto, TrasLinea),
    obtener_tokens_ascii(TrasLinea, Tokens, RestoBytes).
obtener_tokens_ascii(Bytes, [Token1, Token2, Token3], RestoBytes) :-
    leer_token(Bytes, Token1, R1),
    obtener_siguiente_token(R1, Token2, R2),
    obtener_siguiente_token(R2, Token3, R3),
    saltar_separador_final(R3, RestoBytes).

obtener_siguiente_token([0'# | Resto], Token, RestoBytes) :- !,
    saltar_linea(Resto, TrasLinea),
    obtener_siguiente_token(TrasLinea, Token, RestoBytes).
obtener_siguiente_token([B | Resto], Token, RestoBytes) :-
    is_whitespace(B), !,
    obtener_siguiente_token(Resto, Token, RestoBytes).
obtener_siguiente_token(Bytes, Token, RestoBytes) :-
    leer_token(Bytes, Token, RestoBytes).

leer_token([B | Resto], [B | TokenResto], RestoBytes) :-
    \+ is_whitespace(B),
    B \== 0'#, !,
    leer_token(Resto, TokenResto, RestoBytes).
leer_token(RestoBytes, [], RestoBytes).

saltar_separador_final([B | Resto], Resto) :- is_whitespace(B), !.
saltar_separador_final(Bytes, Bytes).

saltar_linea([10 | Resto], Resto) :- !.
saltar_linea([13, 10 | Resto], Resto) :- !.
saltar_linea([_ | Resto], TrasLinea) :- saltar_linea(Resto, TrasLinea).
saltar_linea([], []).

is_whitespace(32).
is_whitespace(9).
is_whitespace(10).
is_whitespace(13).

/* -------------------------------------------------------------------------
   2. CONSULTA DE PÍXEL Y FUNCIÓN DE ALTURA f(x)
   ------------------------------------------------------------------------- */
% En PBM P4: bit 1 = negro (1), bit 0 = blanco (0)
pixel_negro(X, Y, DatosBytes, AnchoBytes) :-
    ByteIdx is Y * AnchoBytes + (X // 8),
    BitOffset is 7 - (X mod 8),
    nth0(ByteIdx, DatosBytes, ByteVal),
    (ByteVal /\ (1 << BitOffset)) =\= 0.

f_x(X, DatosBytes, Alto, AnchoBytes, Altura) :-
    YInicio is Alto - 1,
    contar_negros_columna(X, YInicio, DatosBytes, AnchoBytes, 0, Altura).

contar_negros_columna(X, Y, DatosBytes, AnchoBytes, Acc, Altura) :-
    Y >= 0,
    pixel_negro(X, Y, DatosBytes, AnchoBytes), !,
    NextY is Y - 1,
    NewAcc is Acc + 1,
    contar_negros_columna(X, NextY, DatosBytes, AnchoBytes, NewAcc, Altura).
contar_negros_columna(_, _, _, _, Altura, Altura).

/* -------------------------------------------------------------------------
   3. VISUALIZACIÓN EN CONSOLA
   ------------------------------------------------------------------------- */
dibujar_curva_consola(M, Alto, AnchoConsola) :-
    length(M, AnchoOriginal),
    FactorX is AnchoOriginal / AnchoConsola,
    findall(Alt,
            (between(0, 79, I),
             XIdx is round(I * FactorX),
             nth0(XIdx, M, Alt)),
            MuestrasM),
    
    FilasConsola = 20,
    between(1, FilasConsola, FilaRev),
    Fila is FilasConsola - FilaRev + 1,
    Nivel is (Fila / FilasConsola) * Alto,
    
    findall(Char,
            (member(Alt, MuestrasM),
             (Alt >= Nivel -> Char = '█' ; Char = ' ')),
            LineaChars),
    atomic_list_concat(LineaChars, LineaTexto),
    format('~w~n', [LineaTexto]),
    fail.
dibujar_curva_consola(_, _, _).

/* -------------------------------------------------------------------------
   4. MUESTRA DE VALORES EN EL DOMINIO
   ------------------------------------------------------------------------- */
mostrar_muestras(M, Ancho, NumMuestras) :-
    Paso is (Ancho - 1) / (NumMuestras - 1),
    between(0, 9, I),
    X is round(I * Paso),
    nth0(X, M, Altura),
    format('x_~w = ~w -> f(x_~w) = ~w pixeles~n', [I, X, I, Altura]),
    fail.
mostrar_muestras(_, _, _).
