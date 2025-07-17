# scraping_linkedin.py
from playwright.sync_api import sync_playwright
import pyodbc
import time
import os
import re
from dotenv import load_dotenv


# Cargar variables de entorno
load_dotenv()
LINKEDIN_USER = os.getenv('LINKEDIN_USER')
LINKEDIN_PASS = os.getenv('LINKEDIN_PASS')


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


# Crear tabla si no existe
def crear_tabla_empresa_linkedin():
    try:
        conn = crear_conexion()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='scrap_Linkedin')
            CREATE TABLE scrap_Linkedin (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                Fecha_Extraccion DATETIME DEFAULT GETDATE(),
                Descripcion NVARCHAR(MAX),
                Sector NVARCHAR(255),
                Ubicacion NVARCHAR(255),
                Seguidores NVARCHAR(100),
                Empleados NVARCHAR(100)
            )
            """)
            conn.commit()
            print("✔ Tabla 'Metricas_Empresa_LinkedIn' creada/verificada")
            return True
    except Exception as e:
        print(f"❌ Error al crear tabla: {str(e)}")
        return False


# Guardar datos en SQL
def guardar_datos_empresa(datos):
    try:
        conn = crear_conexion()
        if not conn:
            return False


        cursor = conn.cursor()
        query = """
        INSERT INTO scrap_Linkedin
            (Descripcion, Sector, Ubicacion, Seguidores, Empleados)
        VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(query, (
            datos.get("descripcion", ""),
            datos.get("sector", ""),
            datos.get("ubicacion", ""),
            datos.get("seguidores", ""),
            datos.get("empleados", "")
        ))
        conn.commit()
        print("💾 Datos de empresa guardados en base de datos")
        return True
    except Exception as e:
        print(f"🚨 Error al guardar en BD: {str(e)}")
        return False


# Iniciar sesión en LinkedIn
def login_linkedin(page):
    try:
        print("🔐 Intentando iniciar sesión en LinkedIn...")
        page.goto("https://www.linkedin.com/login", timeout=60000)
        time.sleep(5)

        # Rellenar credenciales
        page.fill('input[id="username"]', LINKEDIN_USER)
        time.sleep(1)
        page.fill('input[id="password"]', LINKEDIN_PASS)
        time.sleep(1)
        page.click('button[type="submit"]')
        
        # Espera extendida para posible desafío
        timeout = 120  # 2 minutos máximo de espera
        start_time = time.time()
        
        while True:
            if "feed" in page.url or "mynetwork" in page.url:
                print("✅ Sesión iniciada correctamente")
                return True
            elif "checkpoint/challenge" in page.url:
                print("⚠ LinkedIn requiere verificación manual")
                print("Por favor completa el CAPTCHA en la ventana del navegador...")
                
                # Espera hasta que el usuario complete el desafío
                while "checkpoint/challenge" in page.url:
                    if time.time() - start_time > timeout:
                        print("❌ Tiempo de espera agotado")
                        return False
                    time.sleep(5)
                    
                # Verificar si se redirigió al feed después del CAPTCHA
                if "feed" in page.url or "mynetwork" in page.url:
                    print("✅ Verificación completada - Sesión iniciada")
                    return True
            
            # Control de timeout
            if time.time() - start_time > timeout:
                print("❌ Tiempo de espera agotado para el inicio de sesión")
                return False
            
            time.sleep(5)

    except Exception as e:
        print(f"❌ Error en inicio de sesión: {str(e)}")
        return False


# Scraping de perfil de empresa
def scrape_datos_empresa(url):
    datos = {
        "descripcion": "",
        "sector": "",
        "ubicacion": "",
        "seguidores": "",
        "empleados": ""
    }


    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()


        try:
            # Login
            if not login_linkedin(page):
                print("❌ Falló el inicio de sesión")
                return datos


            print(f"🌐 Navegando al perfil de empresa: {url}")
            page.goto(url, timeout=60000)
            time.sleep(6)


            # Descripción
            desc = page.query_selector('p.org-top-card-summary__tagline')
            if desc:
                datos["descripcion"] = desc.inner_text().strip()


            # Info general
            info_items = page.query_selector_all('div.org-top-card-summary-info-list__info-item')
            if info_items:
                if len(info_items) > 0:
                    datos["sector"] = info_items[0].inner_text().strip()
                if len(info_items) > 1:
                    datos["ubicacion"] = info_items[1].inner_text().strip()
                if len(info_items) > 2:
                    datos["seguidores"] = info_items[2].inner_text().strip()


            # Empleados
            empleados = page.query_selector('a.org-top-card-summary-info-list__info-item-link span')
            if empleados:
                datos["empleados"] = empleados.inner_text().strip()


            print("✅ Datos de la empresa extraídos con éxito")


        except Exception as e:
            print(f"❌ Error durante el scraping: {str(e)}")
        finally:
            browser.close()


    return datos


# Main
if __name__ == "__main__":
    if not LINKEDIN_USER or not LINKEDIN_PASS:
        print("❌ Credenciales no configuradas en .env")
        exit(1)


    LINKEDIN_URL = "https://www.linkedin.com/company/auna/"


    print("\n" + "="*50)
    print("INICIANDO SCRAPING DE LINKEDIN")
    print("="*50)


    # Crear tabla si no existe
    crear_tabla_empresa_linkedin()


    # Scraping
    datos_empresa = scrape_datos_empresa(LINKEDIN_URL)


    # Mostrar en consola
    print("\nResultados LinkedIn:")
    print(f"Descripción: {datos_empresa['descripcion']}")
    print(f"Sector: {datos_empresa['sector']}")
    print(f"Seguidores: {datos_empresa['seguidores']}")
    print(f"Empleados: {datos_empresa['empleados']}")


    # Guardar en base de datos
    guardar_datos_empresa(datos_empresa)


    print("\n✅ Proceso completo finalizado")
