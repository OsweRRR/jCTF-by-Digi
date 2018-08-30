# jCTF by Digi (aka Hunter-Digital)
Este mod fue creado por <b>Digi (aka Hunter-Digital)</b> pero hace mucho tiempo le dejo de dar actualizaciones así que yo me tome la molestia de hacerle algunas mejoras a mi parecer.

## Requerimientos
* <b>ReHLDS</b> [click link](https://github.com/dreamstalker/rehlds/)
* <b>ReGameDLL</b> [click link](https://github.com/s1lentq/ReGameDLL_CS)
* <b>Reapi</b> [click link](https://github.com/s1lentq/reapi)
* <b>AmxModX 1.8.3</b> Dev-git5154 ó versiones mayores. [click link](http://amxmodx.org/snapshots.php)

## ¿Qué le hice?
* Removí el buy personalizado (Se incluye la compra del C4).
* El sistema de adrenalina lo quite para hacerlo por separado del mod sin embargo las natives seguiran siendo las mismas.
* Model de la bandera en movimiento (No lo hice yo, el model personalizado es público).
* Le agregue para que la bandera se pueda soltar desde las teclas Z, X ó C.
* Le hice un remake al sistema del respawn y protección de spawn totalmente sobre el que estaba.
* El spawn de armas lo cambié por armas aleatorias.
* Debido al uso de reapi ya no se usaran 2 librerias (Hamsandwich y Fun).
* Remplace algunas funciones como por ejemplo: [clickeame](https://github.com/OsweRRR/jCTF-by-Digi/blob/master/addons/amxmodx/scripting/jctf_base.sma#L297) anteriormente se usaba ham_killed de hamsandwich.
* Personalize los huds y también cuando este sale lo hace por un canal que estee disponible para 'tratar' evitar la desaparición de los huds.
* Cambie el glow cuando recibes protección en el spawn al revivir por un renderizado transparente estilo protección de <b>ReGameDLL</b>.
* Removí <b>Orpheu</b> debido a que se usará ReGameDLL (Orpheu solo funcionaba para hookear la ronda).
* Los estilos de luz que se creaban al tomar la bandera enemiga los removi debido a que provoca lag si no se cuenta con un buen pc.
* Removí el drop de items al azar cuando muere un player.

## Cvars del mod
| Cvar                          | Default | Min | Max | Descripción |
| :---------------------------- | :-: | :-: | :-: | :--------------------------------------------- |
| ctf_flagheal                  | 1   | 0   | 1   | Cura al jugador si esta cerca de su bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_flagreturn                | 200 | -   | -   | Tiempo que durara la bandera en el suelo luego de ser soltada. |
| ctf_respawntime               | 6   | -   | -   | Tiempo al revivir después de haber muerto. |
| ctf_protection                | 5   | -   | -   | Tiempo de protección luego de revivir. Si le dispara a un enemigo esta se removerá |
| ctf_sound_taken               | 1   | 0   | 1   | Sonido que se emite al capturar la bandera:<br/>`0` desactivado <br/>`1` activado  |
| ctf_sound_dropped             | 1   | 0   | 1   | Sonido que se emite al soltar la bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_sound_returned            | 1   | 0   | 1   | Sonido que se emite al ser devuelta la bandera:<br/>`0` desactivado <br/>`1` activado |
| ctf_sound_score               | 1   | 0   | 1   | Sonido que se emite al sumar puntuación después de capturar la bandera:<br/>`0` desactivado <br/>`1` activado |

## Tienda
Uso el plugin de tienda por natives de <b>Sugisaki</b> [link](https://amxmodx-es.com/Thread-Otra-Tienda-por-natives) En su post explica cómo funciona a excepción de que en la native no se deberá especificar el equipo del jugador: `native shop_add_item(const name[], cost, const function[])` el parámetro `name` irá la palabra clave con que se halla identificado en el archivo `jctf.txt`, en el parámetro `cost` irá el costo del item y no debe ser mayor a 100 de adrenalina y por último el parámetro `function`. A demás cómo dije antes se debe agregar las traducciones al archivo `jctf.txt` de los items.
