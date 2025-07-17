# scraping_tiktok.py
from playwright.sync_api import sync_playwright
import pyodbc
import time
import os
import re
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()
TIKTOK_USER = os.getenv('TIKTOK_USER')
TIKTOK_PASS = os.getenv('TIKTOK_PASS')

# Función para conectarse a SQL Server
def crear_conexion():
    try:
        conn = pyodbc.connect(
            Driver='{ODBC Driver 17 for SQL Server}',
            Server='DESKTOP-QFC2KRH',
            Database='BD_AUNA',
            Trusted_Connection='yes'
        )
        print("✅ Conexión exitosa a SQL Server")
        return conn
    except Exception as e:
        print(f"❌ Error de conexión: {str(e)}")
        return None

# Crear tabla para métricas de TikTok
def crear_tabla_tiktok():
    try:
        conn = crear_conexion()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='scrap_TikTok')
            CREATE TABLE scrap_TikTok (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                Fecha_Extraccion DATETIME DEFAULT GETDATE(),
                Usuario NVARCHAR(255),
                Seguidores NVARCHAR(100),
                Siguiendo NVARCHAR(100),
                MeGustas NVARCHAR(100),
                Descripcion NVARCHAR(MAX),
                Enlace NVARCHAR(500)
            )
            """)
            conn.commit()
            print("✔ Tabla 'scrap_TikTok' creada/verificada")
            return True
    except Exception as e:
        print(f"❌ Error al crear tabla: {str(e)}")
        return False

# Guardar datos en SQL
def guardar_datos_tiktok(datos):
    try:
        conn = crear_conexion()
        if not conn:
            return False

        cursor = conn.cursor()
        query = """
        INSERT INTO scrap_TikTok 
            (Usuario, Seguidores, Siguiendo, MeGustas, Descripcion, Enlace)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, (
            datos.get("usuario", ""),
            datos.get("seguidores", ""),
            datos.get("siguiendo", ""),
            datos.get("me_gustas", ""),
            datos.get("descripcion", ""),
            datos.get("enlace", "")
        ))
        conn.commit()
        print("💾 Datos de TikTok guardados en base de datos")
        return True
    except Exception as e:
        print(f"🚨 Error al guardar en BD: {str(e)}")
        return False

import random
import time
from playwright.sync_api import sync_playwright


# Scraping de perfil de TikTok
def scrape_perfil_tiktok(url):
    datos = {
        "usuario": "",
        "seguidores": "",
        "siguiendo": "",
        "me_gustas": "",
        "descripcion": "",
        "enlace": url
    }

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
            viewport={"width": 1280, "height": 1024}
        )
        page = context.new_page()

        try:

            print(f"🌐 Navegando al perfil: {url}")
            page.goto(url, timeout=60000)
            
            # Esperar a que cargue el perfil
            page.wait_for_selector('h1[data-e2e="user-title"]', timeout=15000)
            time.sleep(5)

            # Extraer nombre de usuario
            username = page.query_selector('h1[data-e2e="user-title"]')
            if username:
                datos["usuario"] = username.inner_text().strip()

            # Extraer estadísticas - usando los selectores específicos
            stats_selectors = [
                'strong[data-e2e="followers-count"]',
                'strong[data-e2e="following-count"]',
                'strong[data-e2e="likes-count"]'
            ]
            
            for i, selector in enumerate(stats_selectors):
                element = page.query_selector(selector)
                if element:
                    if i == 0:
                        datos["seguidores"] = element.inner_text().strip()
                    elif i == 1:
                        datos["siguiendo"] = element.inner_text().strip()
                    elif i == 2:
                        datos["me_gustas"] = element.inner_text().strip()

            # Extraer descripción
            desc = page.query_selector('h2[data-e2e="user-bio"]')
            if desc:
                datos["descripcion"] = desc.inner_text().strip()

            print("✅ Datos extraídos exitosamente")
            print(f"👤 Usuario: {datos['usuario']}")
            print(f"📊 Seguidores: {datos['seguidores']}")

        except Exception as e:
            print(f"❌ Error durante scraping: {str(e)}")
            # Capturar screenshot para diagnóstico
            page.screenshot(path='tiktok_error.png')
        finally:
            browser.close()

    return datos

# Main
if __name__ == "__main__":
    if not TIKTOK_USER or not TIKTOK_PASS:
        print("❌ Credenciales de TikTok no configuradas en .env")
        exit(1)

    TIKTOK_URL = "https://www.tiktok.com/@consultordesaludauna"  # Cambiar por perfil deseado

    print("\n" + "="*50)
    print("INICIANDO SCRAPING DE TIKTOK CON CREDENCIALES DIRECTAS")
    print("="*50)

    # Crear tabla si no existe
    crear_tabla_tiktok()

    # Scraping
    datos_perfil = scrape_perfil_tiktok(TIKTOK_URL)

    # Mostrar resultados en consola
    print("\nResultados TikTok:")
    print(f"Usuario: {datos_perfil['usuario']}")
    print(f"Seguidores: {datos_perfil['seguidores']}")
    print(f"Siguiendo: {datos_perfil['siguiendo']}")
    print(f"Me gustas: {datos_perfil['me_gustas']}")
    print(f"Descripción: {datos_perfil['descripcion'][:100]}" + ("" if len(datos_perfil['descripcion']) <= 100 else "..."))

    # Guardar en base de datos
    guardar_datos_tiktok(datos_perfil)

    print("\n✅ Proceso completo finalizado")