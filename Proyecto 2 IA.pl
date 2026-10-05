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
% REGLAS DE INFERENCIA LÓGICA
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