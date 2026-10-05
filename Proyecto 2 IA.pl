% ==========================================
% HECHOS: PLANTAS Y SUS ATRIBUTOS
% ==========================================
planta(girasol). planta(lanzaguisantes). planta(nuez). planta(nuez_cascara_rabias).
planta(petacereza). planta(hielaguisantes). planta(plantorcha). planta(carnivora).
planta(magnetoseta). planta(cactus). planta(bipetidora). planta(trebolador).

costo(girasol, 50). costo(lanzaguisantes, 100). costo(nuez, 50). costo(nuez_cascara_rabias, 125).
costo(petacereza, 150). costo(hielaguisantes, 175). costo(plantorcha, 175). costo(carnivora, 150).
costo(magnetoseta, 100). costo(cactus, 125). costo(bipetidora, 125). costo(trebolador, 100).

funcion(girasol, produccion). funcion(lanzaguisantes, ofensiva_basica).
funcion(nuez, defensa_basica). funcion(nuez_cascara_rabias, defensa_alta).
funcion(petacereza, explosiva). funcion(hielaguisantes, ralentizacion).
funcion(plantorcha, potenciador). funcion(carnivora, instakill_cuerpo).
funcion(magnetoseta, utilidad_magnetica). funcion(cactus, antiaereo).
funcion(bipetidora, ataque_trasero). funcion(trebolador, despeje_aereo).

% ==========================================
% HECHOS: ZOMBIS Y SUS ATRIBUTOS
% ==========================================
zombi(comun). zombi(caracono). zombi(caracubo). zombi(saltador_pertiga).
zombi(minero). zombi(globo). zombi(all_star).

dureza(comun, 200). dureza(caracono, 570). dureza(caracubo, 1300).
dureza(saltador_pertiga, 500). dureza(minero, 300). dureza(globo, 290). dureza(all_star, 1600).

rasgo_especial(comun, ninguno). rasgo_especial(caracono, proteccion_ligera).
rasgo_especial(caracubo, objeto_metalico). rasgo_especial(saltador_pertiga, salta_obstaculo).
rasgo_especial(minero, ataca_por_detras). rasgo_especial(globo, vuela).
rasgo_especial(all_star, embestida).

% ==========================================
% REGLAS DE INFERENCIA LOGICA
% ==========================================
comprable(Planta, SolesActuales) :- planta(Planta), costo(Planta, Precio), Precio =< SolesActuales.

counter_directo(magnetoseta, Z) :- rasgo_especial(Z, objeto_metalico).
counter_directo(nuez_cascara_rabias, Z) :- rasgo_especial(Z, salta_obstaculo).
counter_directo(bipetidora, Z) :- rasgo_especial(Z, ataca_por_detras).
counter_directo(cactus, Z) :- rasgo_especial(Z, vuela).
counter_directo(trebolador, Z) :- rasgo_especial(Z, vuela).
counter_directo(petacereza, Z) :- dureza(Z, HP), HP >= 1300.

mala_combinacion(hielaguisantes, plantorcha).
mala_combinacion(plantorcha, hielaguisantes).

peligro_critico(Zombi) :- zombi(Zombi), dureza(Zombi, HP), HP > 1000.
peligro_critico(Zombi) :- zombi(Zombi), rasgo_especial(Zombi, embestida).

estrategia_segura(Zombi, PlantaDefensa, PlantaApoyo) :-
    zombi(Zombi),
    (funcion(PlantaDefensa, defensa_basica) ; funcion(PlantaDefensa, defensa_alta)),
    (counter_directo(PlantaApoyo, Zombi) -> true ; funcion(PlantaApoyo, ofensiva_basica)),
    \+ mala_combinacion(PlantaDefensa, PlantaApoyo).

% ==========================================
% INTERFAZ DEL CHATBOT Y NLP
% ==========================================
chatbot :-
    write('======================================================'), nl,
    write(' ALMANAQUE TACTICO: PLANTS VS ZOMBIES (PROLOG) '), nl,
    write('======================================================'), nl,
    write('Haz tus preguntas libremente. Escribe "salir" para terminar.'), nl,
    loop_chat.

loop_chat :-
    write('\n> '),
    flush_output,
    read_line_to_string(user_input, StringInput),
    string_lower(StringInput, LowerString),
    split_string(LowerString, " ,.?!", " ,.?!", Palabras),
    procesar_frase(Palabras).

% 1. Salir del programa
procesar_frase(Palabras) :- member("salir", Palabras), write('Cerrando Almanaque...'), nl, !.

% 2. Preguntar costo de una planta ("cuanto cuesta la nuez")
procesar_frase(Palabras) :-
    (member("cuesta", Palabras) ; member("vale", Palabras) ; member("precio", Palabras)),
    extraer_planta(Palabras, Planta),
    costo(Planta, Costo),
    format('La planta ~w cuesta ~w soles.', [Planta, Costo]), nl, !, loop_chat.

% 3. Preguntar funcion de una planta ("que hace el girasol")
procesar_frase(Palabras) :-
    (member("hace", Palabras) ; member("funcion", Palabras)),
    extraer_planta(Palabras, Planta),
    funcion(Planta, Funcion),
    format('La funcion principal de ~w es: ~w.', [Planta, Funcion]), nl, !, loop_chat.

% 4. Preguntar vida de un zombi ("cuanta vida tiene el caracubo")
procesar_frase(Palabras) :-
    (member("vida", Palabras) ; member("resistencia", Palabras) ; member("dureza", Palabras)),
    extraer_zombi(Palabras, Zombi),
    dureza(Zombi, HP),
    format('El zombi ~w tiene ~w puntos de vida.', [Zombi, HP]), nl, !, loop_chat.

% 5. Preguntar habilidad de un zombi ("cual es la habilidad del minero")
procesar_frase(Palabras) :-
    (member("habilidad", Palabras) ; member("especial", Palabras) ; member("rasgo", Palabras)),
    extraer_zombi(Palabras, Zombi),
    rasgo_especial(Zombi, Rasgo),
    format('El rasgo especial del zombi ~w es: ~w.', [Zombi, Rasgo]), nl, !, loop_chat.

% 6. Comprobar combinaciones malas ("puedo juntar hielaguisantes y plantorcha")
procesar_frase(Palabras) :-
    (member("juntar", Palabras) ; member("combinar", Palabras) ; member("mezclar", Palabras)),
    extraer_planta(Palabras, P1),
    extraer_planta(Palabras, P2),
    P1 \= P2,
    (mala_combinacion(P1, P2) ->
        write('No hagas eso. Es una mala combinacion estrategica y se anulan.')
    ;
        write('Esa combinacion es valida, no hay conflictos conocidos.')
    ), nl, !, loop_chat.

% 7. Estrategia y Defensa ("como matar al minero" / "que planta sirve contra el all star")
procesar_frase(Palabras) :-
    (member("matar", Palabras) ; member("contra", Palabras) ; member("sirve", Palabras) ; member("defender", Palabras)),
    extraer_zombi(Palabras, Zombi),
    estrategia_segura(Zombi, Defensa, Apoyo),
    format('Para enfrentar al zombi ~w, usa ~w como defensa y ~w como apoyo.', [Zombi, Defensa, Apoyo]), nl,
    !, loop_chat.

% 8. Counter directo ("cual es el counter del globo")
procesar_frase(Palabras) :-
    member("counter", Palabras),
    extraer_zombi(Palabras, Zombi),
    (counter_directo(Planta, Zombi) ->
        format('El counter directo para el zombi ~w es la planta ~w.', [Zombi, Planta])
    ;
        write('Ese zombi no requiere un counter especifico. Usa dano puro.')
    ), nl, !, loop_chat.

% 9. Comprar con soles ("que compro con 100 soles")
procesar_frase(Palabras) :-
    (member("comprar", Palabras) ; member("soles", Palabras) ; member("alcanza", Palabras)),
    extraer_numero(Palabras, Soles),
    findall(P, comprable(P, Soles), Plantas),
    (Plantas \= [] ->
        format('Con ~w soles puedes plantar: ~w', [Soles, Plantas])
    ;
        write('No tienes soles suficientes para el catalogo.')
    ), nl, !, loop_chat.

% 10. Analizar amenaza ("es peligroso el caracono")
procesar_frase(Palabras) :-
    (member("peligroso", Palabras) ; member("amenaza", Palabras) ; member("riesgo", Palabras)),
    extraer_zombi(Palabras, Zombi),
    (peligro_critico(Zombi) ->
        write('ALERTA: Ese zombi es una amenaza critica. Cuidado.')
    ;
        write('Amenaza estandar. Las defensas normales seran suficientes.')
    ), nl, !, loop_chat.

% Fallback
procesar_frase(_) :-
    write('No entendi la consulta. Intenta mencionar un zombi, una planta o una cantidad de soles.'), nl,
    loop_chat.

% ==========================================
% DICCIONARIO: EXTRACCION DE ENTIDADES
% ==========================================
extraer_zombi(Palabras, caracubo) :- (member("caracubo", Palabras) ; (member("cara", Palabras), member("cubo", Palabras))), !.
extraer_zombi(Palabras, caracono) :- (member("caracono", Palabras) ; (member("cara", Palabras), member("cono", Palabras))), !.
extraer_zombi(Palabras, saltador_pertiga) :- (member("saltador", Palabras) ; member("pertiga", Palabras)), !.
extraer_zombi(Palabras, all_star) :- (member("all", Palabras) ; member("star", Palabras) ; member("deportista", Palabras)), !.
extraer_zombi(Palabras, minero) :- member("minero", Palabras), !.
extraer_zombi(Palabras, globo) :- member("globo", Palabras), !.
extraer_zombi(Palabras, comun) :- member("comun", Palabras), !.

% AQUI SE QUITARON LOS CORTES (!) PARA PERMITIR ENCONTRAR 2 PLANTAS EN LA MISMA FRASE
extraer_planta(Palabras, girasol) :- member("girasol", Palabras).
extraer_planta(Palabras, lanzaguisantes) :- member("lanzaguisantes", Palabras).
extraer_planta(Palabras, nuez_cascara_rabias) :- (member("rabias", Palabras) ; member("alta", Palabras)).
extraer_planta(Palabras, nuez) :- member("nuez", Palabras).
extraer_planta(Palabras, petacereza) :- member("petacereza", Palabras).
extraer_planta(Palabras, hielaguisantes) :- (member("hielaguisantes", Palabras) ; member("hielo", Palabras)).
extraer_planta(Palabras, plantorcha) :- member("plantorcha", Palabras).
extraer_planta(Palabras, carnivora) :- member("carnivora", Palabras).
extraer_planta(Palabras, magnetoseta) :- (member("magnetoseta", Palabras) ; member("iman", Palabras)).
extraer_planta(Palabras, cactus) :- member("cactus", Palabras).
extraer_planta(Palabras, bipetidora) :- member("bipetidora", Palabras).
extraer_planta(Palabras, trebolador) :- member("trebolador", Palabras).

extraer_numero([H|_], Numero) :- number_string(Numero, H), !.
extraer_numero([_|T], Numero) :- extraer_numero(T, Numero).