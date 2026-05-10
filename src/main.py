import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from equipos  import listar_equipos, crear_equipo, actualizar_equipo, eliminar_equipo
from jugadores import listar_jugadores, crear_jugador, actualizar_jugador, eliminar_jugador


def menu_equipos():
    opciones = {
        "1": ("Listar equipos",    listar_equipos),
        "2": ("Crear equipo",      crear_equipo),
        "3": ("Actualizar equipo", actualizar_equipo),
        "4": ("Eliminar equipo",   eliminar_equipo),
    }
    while True:
        print("\n========== EQUIPOS ==========")
        for k, (label, _) in opciones.items():
            print(f"  {k}. {label}")
        print("  0. Volver")
        opcion = input("Seleccione: ").strip()
        if opcion == "0":
            break
        elif opcion in opciones:
            opciones[opcion][1]()
        else:
            print("  Opción inválida.")


def menu_jugadores():
    opciones = {
        "1": ("Listar jugadores",    listar_jugadores),
        "2": ("Crear jugador",       crear_jugador),
        "3": ("Actualizar jugador",  actualizar_jugador),
        "4": ("Eliminar jugador",    eliminar_jugador),
    }
    while True:
        print("\n========== JUGADORES ==========")
        for k, (label, _) in opciones.items():
            print(f"  {k}. {label}")
        print("  0. Volver")
        opcion = input("Seleccione: ").strip()
        if opcion == "0":
            break
        elif opcion in opciones:
            opciones[opcion][1]()
        else:
            print("  Opción inválida.")


def main():
    print("=" * 40)
    print("   SISTEMA DE GESTIÓN DE TORNEOS")
    print("=" * 40)
    while True:
        print("\n  1. Gestionar Equipos")
        print("  2. Gestionar Jugadores")
        print("  0. Salir")
        opcion = input("\nSeleccione: ").strip()
        if opcion == "1":
            menu_equipos()
        elif opcion == "2":
            menu_jugadores()
        elif opcion == "0":
            print("\nHasta luego.")
            break
        else:
            print("  Opción inválida.")


if __name__ == "__main__":
    main()
