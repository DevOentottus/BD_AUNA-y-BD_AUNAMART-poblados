# scraping_Facebook.py
from playwright.sync_api import sync_playwright
import pyodbc
import time
import os
from dotenv import load_dotenv
import re

# Cargar variables de entorno
load_dotenv()

# Credenciales desde variables de entorno
FB_USER = os.getenv('FACEBOOK_USER')
FB_PASS = os.getenv('FACEBOOK_PASS')

# Función de conexión a SQL
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

# Función para crear la tabla en BD
def crear_tabla_scrap_Facebook():
    try:
        conn = crear_conexion()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='scrap_Facebook')
            CREATE TABLE scrap_Facebook (
                ID_Metrica INT IDENTITY(1,1) PRIMARY KEY,
                Fecha_Extraccion DATETIME DEFAULT GETDATE(),
                cant_Seguidores NVARCHAR(100),
                cant_MeGusta NVARCHAR(100)
            )
            """)
            conn.commit()
            print("✔ Tabla 'scrap_Facebook' creada/verificada")
            return True
    except Exception as e:
        print(f"❌ Error al crear tabla: {str(e)}")
        return False

# Función para guardar métricas actualizada
def guardar_inf_scrap(plataforma, metricas):
    try:
        conn = crear_conexion()
        if not conn:
            return False
            
        cursor = conn.cursor()
        # Consulta actualizada con nuevas columnas
        query = """
        INSERT INTO scrap_Facebook 
            (cant_Seguidores, cant_MeGusta)
        VALUES (?, ?)
        """
        
        # Obtener valores de las métricas
        cant_Seguidores = metricas.get("seguidores", "")
        cant_MeGusta = metricas.get("likes", "")
        
        cursor.execute(query, (
            cant_Seguidores,
            cant_MeGusta
        ))
        
        conn.commit()
        print(f"💾 Métricas guardadas")
        return True
    except Exception as e:
        print(f"🚨 Error al guardar métricas: {str(e)}")
        return False
    
# Función para iniciar sesión en Facebook con manejo de errores mejorado
def login_facebook(page):
    try:
        print("🔐 Intentando iniciar sesión en Facebook...")
        page.goto("https://www.facebook.com/login.php", timeout=60000)
        time.sleep(3)
        
        # Manejar cookies si es necesario
        try:
            page.click('button:has-text("Permitir solo cookies esenciales")', timeout=3000)
            time.sleep(1)
        except:
            pass
        
        # Rellenar credenciales
        page.fill('input[name="email"]', FB_USER)
        page.fill('input[name="pass"]', FB_PASS)
        time.sleep(1)
        
        # Hacer clic en el botón de inicio de sesión
        page.click('button[name="login"]')
        time.sleep(5)
        
        # Verificar si el inicio de sesión fue exitoso
        if "checkpoint" in page.url:
            print("⚠ Se requiere verificación de seguridad. Por favor completa manualmente.")
            print("Pausando por 60 segundos para verificación manual...")
            time.sleep(60)
            print("Reanudando automatización...")
        
        # Verificar si estamos logueados
        if page.query_selector('div[aria-label="Cuenta"]'):
            print("✅ Sesión de Facebook iniciada correctamente")
            return True
        else:
            print("❌ No se pudo iniciar sesión en Facebook")
            return False
    except Exception as e:
        print(f"❌ Error al iniciar sesión en Facebook: {str(e)}")
        return False

# Función para convertir números sociales
def parse_social_number(num_str):
    if not num_str:
        return "0"
    
    # Convertir "mil" a "k"
    if 'mil' in num_str:
        num_str = num_str.replace('mil', 'k')
    
    # Manejar espacios no rompibles (como &nbsp;)
    num_str = num_str.replace('\u00a0', ' ').strip()
    
    # Manejar formato "mil"
    if ' ' in num_str:
        parts = num_str.split()
        if len(parts) == 2 and parts[1] == 'mil':
            num_str = f"{parts[0]}k"
    
    # Convertir k y m a números completos
    if 'k' in num_str:
        num_value = float(num_str.replace('k', '').replace(',', '.')) * 1000
        return str(int(num_value))
    elif 'm' in num_str:
        num_value = float(num_str.replace('m', '').replace(',', '.')) * 1000000
        return str(int(num_value))
    
    # Eliminar caracteres no numéricos excepto puntos y comas
    clean_str = re.sub(r'[^\d.,]', '', num_str)
    
    # Manejar separadores de miles
    if '.' in clean_str and ',' in clean_str:
        # Si ambos están presentes, asumir que la coma es separador decimal
        clean_str = clean_str.replace('.', '')
        clean_str = clean_str.replace(',', '.')
    else:
        # Eliminar todos los separadores de miles
        clean_str = clean_str.replace('.', '').replace(',', '')
    
    return clean_str if clean_str != "" else "0"

# Función para extraer cant_Seguidores y 'me gusta' de Facebook
def extract_social_stats(page):
    stats = {
        "cant_Seguidores": "0",
        "cant_MeGusta": "0"
    }
    
    try:
        # Estrategia 1: Buscar por enlaces específicos
        try:
            # Buscar el enlace de "Me gusta"
            likes_link = page.query_selector('a[href*="/friends_likes/"]')
            if likes_link:
                likes_strong = likes_link.query_selector('strong')
                if likes_strong:
                    likes_text = likes_strong.inner_text()
                    stats["likes"] = parse_social_number(likes_text)
                    print(f"🔍 Encontrado 'Me gusta' en enlace: {likes_text}")
            
            # Buscar el enlace de seguidores
            followers_link = page.query_selector('a[href*="/followers/"]')
            if followers_link:
                followers_strong = followers_link.query_selector('strong')
                if followers_strong:
                    followers_text = followers_strong.inner_text()
                    stats["seguidores"] = parse_social_number(followers_text)
                    print(f"🔍 Encontrados seguidores en enlace: {followers_text}")
        except Exception as e:
            print(f"⚠ Error en estrategia de enlaces: {str(e)}")
        
        # Estrategia 2: Buscar por texto si no se encontró en los enlaces
        if stats["likes"] == "0" or stats["seguidores"] == "0":
            print("⚠ Probando estrategia alternativa de búsqueda por texto...")
            def find_by_pattern(pattern):
                try:
                    elements = page.query_selector_all(f'//*[contains(text(), "{pattern}")]')
                    for element in elements:
                        # Buscar el elemento fuerte más cercano que podría contener el número
                        strong_element = element.query_selector('strong')
                        if strong_element:
                            num_text = strong_element.inner_text()
                            return parse_social_number(num_text)
                        
                        # Si no encuentra strong, buscar en el texto del elemento
                        text = element.inner_text().lower()
                        if pattern in text:
                            match = re.search(r'([\d,.]+[km]?)\s*' + pattern, text, re.IGNORECASE)
                            if match:
                                return parse_social_number(match.group(1))
                except:
                    pass
                return None
            
            # Buscar seguidores
            if stats["seguidores"] == "0":
                followers = find_by_pattern("seguidores") or find_by_pattern("seguir")
                if followers:
                    stats["seguidores"] = followers
            
            # Buscar likes
            if stats["likes"] == "0":
                likes = find_by_pattern("me gusta") or find_by_pattern("likes")
                if likes:
                    stats["likes"] = likes
        
        print(f"🔍 Estadísticas encontradas: Seguidores={stats['seguidores']}, Likes={stats['likes']}")
    
    except Exception as e:
        print(f"⚠ Error extrayendo estadísticas: {str(e)}")
    
    # Tomar captura de pantalla si no se encontraron valores
    if stats["seguidores"] == "0" and stats["likes"] == "0":
        print("⚠ No se encontraron estadísticas. Tomando captura de pantalla...")
        page.screenshot(path="debug_facebook_stats.png", full_page=True)
        print("📸 Captura de pantalla guardada como 'debug_facebook_stats.png'")
    
    return stats

# Función mejorada para scrapear Facebook
def scrape_facebook(url):
    data = {
        "calificacion": "N/A",
        "total_reseñas": 0,
        "tiempo_respuesta": "N/A",
        "comentarios_recientes": [],
        "seguidores": "0",
        "likes": "0"  # Nuevo campo para 'me gusta'
    }
    
    with sync_playwright() as p:
        # Configuración del navegador
        context = p.chromium.launch_persistent_context(
            user_data_dir="facebook_session",
            headless=False,
            slow_mo=3000,
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
            viewport={"width": 1200, "height": 800}
        )
        page = context.new_page()
        
        try:
            # Navegación directa a la página de Auna Perú
            target_url = "https://www.facebook.com/AunaPeru"
            print(f"🌐 Navegando directamente a: {target_url}")
            page.goto(target_url, timeout=60000)
            time.sleep(5)
            
            # Extracción de estadísticas sociales
            print("🔍 Buscando estadísticas de seguidores y 'me gusta'...")
            social_stats = extract_social_stats(page)
            
            # Actualizar datos con los valores encontrados
            data["seguidores"] = social_stats["seguidores"]
            data["likes"] = social_stats["likes"]
            print(f"✅ Estadísticas: Seguidores={data['seguidores']}, Me gusta={data['likes']}")
            
            
        except Exception as e:
            print(f"❌ Error durante el scraping: {str(e)}")
        finally:
            context.close()
    
    return data

# URL para scraping
FACEBOOK_URL = "https://www.facebook.com/AunaPeru"

if __name__ == "__main__":
    # Verificar credenciales
    if not FB_USER or not FB_PASS:
        print("❌ Error: Credenciales no configuradas en el archivo .env")
        exit(1)
    
    # Crear tabla si no existe
    crear_tabla_scrap_Facebook()
    
    # Scrapear Facebook
    print("="*60)
    print("INICIANDO SCRAPING DE FACEBOOK")
    print("="*60)
    metricas_fb = scrape_facebook(FACEBOOK_URL)
    guardar_inf_scrap("Facebook", metricas_fb)
    
    print("\n✅ Proceso Scraping Facebook completado")