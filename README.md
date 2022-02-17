# jCTF by Digi (aka Hunter-Digital)
Este modo fue creado por <b>Digi (aka Hunter-Digital)</b> y al parecer la última actualización fue en 2012 desde su creación por lo que yo en 2018 decidí personalizar su última versión y a demas de eso optimizar el código y remover algunas funciones, también separar otras funciones.

* Versión actual: <b>1.32o</b>
* Versión anterior: <b>1.32c</b>

## Requerimientos
* <b>ReHLDS</b> [click url](https://github.com/dreamstalker/rehlds/)
* <b>ReGameDLL</b> [click url](https://github.com/s1lentq/ReGameDLL_CS)
* <b>AmxModX 1.8.3</b> Dev-git5154 ó versiones mayores. [click url](http://amxmodx.org/snapshots.php)

## ¿Qué le hice?
* Removí el buy personalizado (incluyendo la compra del C4 e items con adrenalina).
* El sistema de adrenalina lo quite para hacerlo por separado del modo sin embargo las natives seguiran siendo las mismas.
* Modelo de la bandera en <b>movimiento</b> (No lo hice yo, el model personalizado es público).
* Le agregue para que la bandera se pueda soltar desde las teclas Z, X ó C.
* Le hice un remake al sistema del respawn y protección de spawn (ya no hay bug de los segundos al revivir/protección).
* El spawn de armas lo cambié por armas aleatorias.
* Personalize los huds y también cuando este sale lo hace por un canal que estee disponible para 'tratar' de evitar la desaparición de los huds o un flood de canales.
* Removí <b>Orpheu</b> debido a que se usará <b>ReGameDLL</b> (<b>Orpheu</b> solo funcionaba para hookear la ronda).
* Los estilos de luz que se creaban al tomar la bandera enemiga los removi debido a que causaba bajos de <b>FPS</b> con pc's de gama baja.
* Removí el hud de la adrenalina. Ahora este se muestra a través de la tienda. `say /adrenaline`
* Removí el hooksay por si quieren implementar un admin-chat-color o algún plugin que hookee el say.

## Cvars del modo
| Cvar                          | Default | Min | Max | Descripción |
| :---------------------------- | :-: | :-: | :-: | :--------------------------------------------- |
| ctf_flagheal                  | 1   | 0   | 1   | Cura al jugador si esta cerca de su bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_flagreturn                | 200 | 0   | -   | Tiempo en segundos que durará la bandera en el suelo luego de ser soltada. |
| ctf_respawntime               | 6   | 0   | -   | Tiempo en segundos al revivir después de haber muerto. |
| ctf_protection                | 5   | 0   | -   | Tiempo en segundos de protección luego de revivir. Si le dispara a un enemigo esta se removerá |
| ctf_sound_taken               | 1   | 0   | 1   | Sonido que se emite al capturar la bandera:<br/>`0` desactivado <br/>`1` activado  |
| ctf_sound_dropped             | 1   | 0   | 1   | Sonido que se emite al soltar la bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_sound_returned            | 1   | 0   | 1   | Sonido que se emite al ser devuelta la bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_sound_score               | 1   | 0   | 1   | Sonido que se emite al sumar puntuación después de capturar la bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_itempercent               | 25  | 1   | 100 | Porcentaje al soltar un item cuando muere un player, el item puede ser adrenalina ó medkit. |
| ctf_itemstay                  | 15  | 1   | -   | Tiempo en segundos que permanecerá un item en el suelo, el item puede ser adrenalina ó medkit. |
| ctf_glows                     | 1   | 0   | 1   | Le añade un glow a la base de la bandera y a los jugadores cuando reciben protección en el spawn:<br/>`0` desactivado <br/>`1` activado |


## Tienda de adrenalina
Uso el plugin de tienda por natives de <b>Sugisaki</b> [click url](https://amxmodx-es.com/Thread-Otra-Tienda-por-natives) En su post explica cómo funciona a excepción de que en la native no se deberá especificar el equipo del jugador: `native shop_add_item(const name[], cost, const function[])` el parámetro `name` irá la palabra clave con que se halla identificado en el archivo `jctf.txt`, en el parámetro `cost` irá el costo del item y no debe ser mayor a 100 de adrenalina y por último el parámetro `function`. A demás cómo dije antes se debe agregar las traducciones al archivo `jctf.txt` de los items.

## Notas
* Debe instalar el modo con los recursos que proporcioné en el repositorio <b>(modelos, sonidos y sprites)</b>.
* Estoy constantemente actualizando los plugins así qué estar atento a los <b>commits</b>. Tal vez halla solucionado algún bug que halla dejado suelto.
