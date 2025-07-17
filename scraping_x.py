# scraping_x.py
from playwright.sync_api import sync_playwright
import pyodbc
import time
import os
import re
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()
X_USER = os.getenv('X_USER')
X_PASS = os.getenv('X_PASS')

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

# Crear tabla para métricas de X (Twitter)
def crear_tabla_x():
    try:
        conn = crear_conexion()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='scrap_X')
            CREATE TABLE scrap_X (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                Fecha_Extraccion DATETIME DEFAULT GETDATE(),
                Nombre NVARCHAR(255),
                Usuario NVARCHAR(255),
                Seguidores NVARCHAR(100),
                Siguiendo NVARCHAR(100),
                Biografia NVARCHAR(MAX),
                Enlace NVARCHAR(500)
            )
            """)
            conn.commit()
            print("✔ Tabla 'scrap_X' creada/verificada")
            return True
    except Exception as e:
        print(f"❌ Error al crear tabla: {str(e)}")
        return False

# Guardar datos en SQL
def guardar_datos_x(datos, estado="Éxito"):
    try:
        conn = crear_conexion()
        if not conn:
            return False

        cursor = conn.cursor()
        query = """
        INSERT INTO scrap_X 
            (Nombre, Usuario, Seguidores, Siguiendo, Biografia, Enlace)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        cursor.execute(query, (
            datos.get("nombre", ""),
            datos.get("usuario", ""),
            datos.get("seguidores", ""),
            datos.get("siguiendo", ""),
            datos.get("biografia", ""),
            datos.get("enlace", "")
        ))
        conn.commit()
        print("💾 Datos de X guardados en base de datos")
        return True
    except Exception as e:
        print(f"🚨 Error al guardar en BD: {str(e)}")
        return False

# Iniciar sesión en X con credenciales directas
def login_x(page):
    try:
        print("🔐 Intentando iniciar sesión en X con credenciales directas...")
        # Ir a la página de inicio de sesión de X
        page.goto("https://twitter.com/i/flow/login", timeout=60000)
        time.sleep(5)
        
        # Tomar screenshot inicial
        page.screenshot(path='x_login_step1.png')
        
        # Esperar a que cargue el formulario de login
        try:
            username_field = page.wait_for_selector('input[autocomplete="username"]', timeout=15000)
        except:
            print("❌ Tiempo de espera agotado para el campo de usuario")
            page.screenshot(path='x_login_timeout_username.png')
            return False
        
        # Ingresar usuario/email
        username_field.fill(X_USER)
        time.sleep(2)
        
        # Tomar screenshot después de ingresar usuario
        page.screenshot(path='x_login_step2.png')
        
        # Hacer clic en siguiente usando múltiples estrategias
        next_button_found = False
        next_button_selectors = [
            'button:has-text("Siguiente")',
            'button[type="button"] div:has-text("Siguiente")',
            'xpath=//button//*[contains(text(),"Siguiente")]/ancestor::button'
        ]
        
        for selector in next_button_selectors:
            next_button = page.query_selector(selector)
            if next_button:
                next_button.click()
                next_button_found = True
                break
                
        if not next_button_found:
            print("❌ No se encontró el botón 'Siguiente' después de múltiples intentos")
            page.screenshot(path='x_login_next_button_missing.png')
            return False
            
        time.sleep(3)
        page.screenshot(path='x_login_step3.png')
        
        # Manejar posible verificación adicional
        verification_field = page.query_selector('input[name="text"]')
        if verification_field:
            print("⚠️ Se requiere verificación adicional")
            verification_field.fill(X_USER)
            time.sleep(2)
            
            # Hacer clic en siguiente
            next_button_found = False
            for selector in next_button_selectors:
                next_button = page.query_selector(selector)
                if next_button:
                    next_button.click()
                    next_button_found = True
                    break
            
            if not next_button_found:
                print("❌ No se encontró el botón 'Siguiente' para verificación")
                page.screenshot(path='x_login_verification_next_missing.png')
                return False
                
            time.sleep(3)
            page.screenshot(path='x_login_step4.png')
        
        # Ingresar contraseña
        try:
            password_field = page.wait_for_selector('input[name="password"]', timeout=10000)
        except:
            print("❌ Tiempo de espera agotado para el campo de contraseña")
            page.screenshot(path='x_login_password_missing.png')
            return False
            
        password_field.fill(X_PASS)
        time.sleep(2)
        page.screenshot(path='x_login_step5.png')
        
        # Hacer clic en iniciar sesión
        login_button_found = False
        login_button_selectors = [
            'button:has-text("Iniciar sesión")',
            'button[data-testid="LoginForm_Login_Button"]',
            'xpath=//button//*[contains(text(),"Iniciar sesión")]/ancestor::button'
        ]
        
        for selector in login_button_selectors:
            login_button = page.query_selector(selector)
            if login_button:
                login_button.click()
                login_button_found = True
                break
                
        if not login_button_found:
            print("❌ No se encontró el botón de inicio de sesión")
            page.screenshot(path='x_login_button_missing.png')
            return False
            
        time.sleep(5)
        page.screenshot(path='x_login_step6.png')
        
        # Verificar si el inicio de sesión fue exitoso
        if "home" in page.url or "twitter.com/home" in page.url or "x.com/home" in page.url:
            print("✅ Sesión iniciada correctamente en X")
            return True
        
        # Manejar posibles errores
        error_message = page.query_selector('div[role="alert"]')
        if error_message:
            error_text = error_message.inner_text()
            print(f"❌ Error en inicio de sesión: {error_text}")
            page.screenshot(path='x_login_error_alert.png')
        else:
            print(f"❌ Falló el inicio de sesión. URL actual: {page.url}")
            page.screenshot(path='x_login_failed.png')
        
        return False
        
    except Exception as e:
        print(f"❌ Error crítico en inicio de sesión: {str(e)}")
        page.screenshot(path='x_login_critical_error.png')
        return False
    
# Scraping de perfil de X
def scrape_perfil_x(url):
    datos = {
        "nombre": "",
        "usuario": "",
        "seguidores": "",
        "siguiendo": "",
        "biografia": "",
        "ubicacion": "",
        "sitio_web": "",
        "enlace": url
    }

    estado = "Éxito"
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
            viewport={"width": 1280, "height": 1024}
        )
        page = context.new_page()

        try:
            # Login con credenciales X
            if not login_x(page):
                print("❌ Falló el inicio de sesión en X")
                estado = "Error en inicio de sesión"
                return datos, estado

            print(f"🌐 Navegando al perfil: {url}")
            page.goto(url, timeout=60000)
            
            # Esperar a que cargue el perfil
            try:
                page.wait_for_selector('div[data-testid="UserName"]', timeout=15000)
                time.sleep(3)
            except:
                print("⚠️ Tiempo de espera agotado para cargar el perfil")
                estado = "Tiempo de espera agotado"
                return datos, estado

            # Extraer nombre y usuario
            try:
                name_element = page.query_selector('div[data-testid="UserName"] div span:first-child')
                if name_element:
                    datos["nombre"] = name_element.inner_text().strip()
                
                username_element = page.query_selector('div[data-testid="UserName"] div span:last-child')
                if username_element:
                    datos["usuario"] = username_element.inner_text().strip()
            except Exception as e:
                print(f"⚠️ Error al extraer nombre/usuario: {str(e)}")
                estado = "Error al extraer datos"

            # Extraer biografía
            try:
                bio_element = page.query_selector('div[data-testid="UserDescription"]')
                if bio_element:
                    datos["biografia"] = bio_element.inner_text().strip()
            except:
                pass

            # Extraer ubicación y sitio web
            try:
                location_element = page.query_selector('div[data-testid="UserLocation"] span')
                if location_element:
                    datos["ubicacion"] = location_element.inner_text().strip()
            except:
                pass
            
            try:
                website_element = page.query_selector('div[data-testid="UserUrl"] a')
                if website_element:
                    datos["sitio_web"] = website_element.get_attribute('href') or website_element.inner_text().strip()
            except:
                pass

            # Extraer estadísticas de seguidores y seguidos
            try:
                # Extraer número de following (ya funciona)
                following_element = page.query_selector('a[href*="/following"] span.css-1jxf684')
                if following_element:
                    datos["siguiendo"] = following_element.inner_text().strip()
                
                # Extraer número de seguidores usando el elemento específico proporcionado
                followers_element = page.query_selector('a[href*="/followers"] span.css-1jxf684')
                if followers_element:
                    datos["seguidores"] = followers_element.inner_text().strip()
                
                # Si no se encontró, intentar con el selector específico de tu ejemplo
                if not datos["seguidores"]:
                    verified_followers_element = page.query_selector('a[href*="/verified_followers"] span.css-1jxf684')
                    if verified_followers_element:
                        datos["seguidores"] = verified_followers_element.inner_text().strip()
                
                # Si aún no se encuentra, usar enfoque alternativo
                if not datos["seguidores"]:
                    followers_links = page.query_selector_all('a[href*="/followers"]')
                    for link in followers_links:
                        spans = link.query_selector_all('span')
                        if len(spans) > 0:
                            # El primer span contiene el número (según tu estructura HTML)
                            datos["seguidores"] = spans[0].inner_text().strip()
                            break

            except Exception as e:
                print(f"⚠️ Error al extraer estadísticas: {str(e)}")
                estado = "Error al extraer estadísticas"

            print("✅ Datos extraídos exitosamente")

        except Exception as e:
            print(f"❌ Error crítico durante scraping: {str(e)}")
            estado = "Error crítico"
        finally:
            browser.close()

    return datos, estado

# Main
if __name__ == "__main__":
    if not X_USER or not X_PASS:
        print("❌ Credenciales de X no configuradas en .env")
        exit(1)

    X_URL = "https://x.com/lasamericasauna"  # URL del perfil a analizar

    print("\n" + "="*50)
    print("INICIANDO SCRAPING DE X (TWITTER) CON CREDENCIALES DIRECTAS")
    print("="*50)

    # Crear tabla si no existe
    crear_tabla_x()

    # Scraping
    datos_perfil, estado = scrape_perfil_x(X_URL)

    # Mostrar resultados en consola
    print("\nResultados X:")
    print(f"Nombre: {datos_perfil['nombre']}")
    print(f"Usuario: {datos_perfil['usuario']}")
    print(f"Seguidores: {datos_perfil['seguidores']}")
    print(f"Siguiendo: {datos_perfil['siguiendo']}")
    print(f"Biografía: {datos_perfil['biografia'][:100]}" + ("" if len(datos_perfil['biografia']) <= 100 else "..."))

    # Guardar en base de datos
    guardar_datos_x(datos_perfil, estado)

    print("\n✅ Proceso completo finalizado")