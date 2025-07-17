# scraping_Instagram.py
from playwright.sync_api import sync_playwright
import pyodbc
import time
import json
import os
from dotenv import load_dotenv
import re

# Cargar variables de entorno
load_dotenv()

# Credenciales desde variables de entorno
IG_USER = os.getenv('INSTAGRAM_USER')
IG_PASS = os.getenv('INSTAGRAM_PASS')

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

# Función para crear la tabla actualizada
def crear_tabla_scrap_Instagram():
    try:
        conn = crear_conexion()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='scrap_Instagram')
            CREATE TABLE scrap_Instagram (
                ID_Metrica INT IDENTITY(1,1) PRIMARY KEY,
                Fecha_Extraccion DATETIME DEFAULT GETDATE(),
                cant_Seguidores NVARCHAR(100),
                cant_Publicaciones NVARCHAR(100),
                cant_Seguidos NVARCHAR(100)
            )
            """)
            conn.commit()
            print("✔ Tabla 'scrap_Instagram' creada/verificada")
            return True
    except Exception as e:
        print(f"❌ Error al crear tabla: {str(e)}")
        return False

# Función para guardar métricas actualizada
def guardar_metricas_redes(metricas):
    try:
        conn = crear_conexion()
        if not conn:
            return False
            
        cursor = conn.cursor()
        # Consulta actualizada con nuevas columnas
        query = """
        INSERT INTO scrap_Instagram 
            (cant_Seguidores, cant_Publicaciones, cant_Seguidos)
        VALUES (?, ?, ?)
        """
        
        # Obtener valores de las métricas
        cant_Seguidores = metricas.get("seguidores", "")
        cant_Publicaciones = metricas.get("publicaciones", "")  
        cant_Seguidos = metricas.get("seguidos", "")  
        
        cursor.execute(query, (
            cant_Seguidores,
            cant_Publicaciones,
            cant_Seguidos
        ))
        
        conn.commit()
        print(f"💾 Métricas guardadas")
        return True
    except Exception as e:
        print(f"🚨 Error al guardar métricas: {str(e)}")
        return False
    
# Función para iniciar sesión en Instagram con mejor manejo
def login_instagram(page):
    try:
        print("🔐 Intentando iniciar sesión en Instagram...")
        page.goto("https://www.instagram.com/accounts/login/", timeout=60000)
        time.sleep(4)
        
        # Aceptar cookies si es necesario
        try:
            page.click('button:has-text("Permitir solo cookies esenciales")', timeout=3000)
            time.sleep(1)
        except:
            pass
        
        # Rellenar credenciales
        page.fill('input[name="username"]', IG_USER)
        page.fill('input[name="password"]', IG_PASS)
        time.sleep(2)
        
        # Hacer clic en el botón de inicio de sesión
        page.click('button[type="submit"]')
        time.sleep(5)
        
        # Manejar "Guardar información de inicio de sesión"
        try:
            page.click('button:has-text("Ahora no")', timeout=3000)
            time.sleep(1)
        except:
            pass
        
        # Manejar notificaciones
        try:
            page.click('button:has-text("Ahora no")', timeout=3000)
            time.sleep(1)
        except:
            pass
        
        # Verificar inicio de sesión
        if page.query_selector('svg[aria-label="Instagram"]'):
            print("✅ Sesión de Instagram iniciada correctamente")
            return True
        else:
            print("❌ No se pudo iniciar sesión en Instagram")
            return False
    except Exception as e:
        print(f"❌ Error al iniciar sesión en Instagram: {str(e)}")
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
    
    # Manejar formato "246 mil"
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

def scrape_instagram(url):
    data = {
        "seguidores": "0",
        "publicaciones": "0",
        "seguidos": "0"
    }
    
    with sync_playwright() as p:
        # Configuración con persistencia de sesión
        context = p.chromium.launch_persistent_context(
            user_data_dir="instagram_session",
            headless=False,
            slow_mo=2000,
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            viewport={"width": 800, "height": 1000}
        )
        page = context.new_page()
        
        try:
            # Verificar si ya estamos logueados
            page.goto("https://www.instagram.com/", timeout=60000)
            time.sleep(3)
            
            if not page.query_selector('svg[aria-label="Instagram"]'):
                if not login_instagram(page):
                    print("❌ No se pudo iniciar sesión, no se puede continuar")
                    return data
            
            print(f"📸 Scrapeando Instagram: {url}")
            page.goto(url, timeout=60000)
            time.sleep(5)
            
            # Extraer estadísticas principales con nuevos selectores
            try:
                # 1. Número de publicaciones
                publicaciones_element = page.query_selector('span:has-text("publicaciones")')
                if publicaciones_element:
                    pub_span = publicaciones_element.query_selector('span > span')
                    if pub_span:
                        data["publicaciones"] = parse_social_number(pub_span.inner_text())
                        print(f"📊 Publicaciones: {data['publicaciones']}")
                
                # 2. Número de seguidores
                followers_element = page.query_selector('a[href*="followers"] span[title]')
                if followers_element:
                    # Usar el atributo title si está disponible (más confiable)
                    data["seguidores"] = parse_social_number(followers_element.get_attribute('title'))
                else:
                    # Fallback: buscar el texto del span
                    followers_fallback = page.query_selector('a[href*="followers"] span > span')
                    if followers_fallback:
                        data["seguidores"] = parse_social_number(followers_fallback.inner_text())
                
                print(f"👥 Seguidores: {data['seguidores']}")
                
                # 3. Número de cuentas seguidas
                following_element = page.query_selector('a[href*="following"] span > span')
                if following_element:
                    data["seguidos"] = parse_social_number(following_element.inner_text())
                    print(f"🔄 Seguidos: {data['seguidos']}")
                    
            except Exception as e:
                print(f"⚠ Error extrayendo estadísticas principales: {str(e)}")
            
        except Exception as e:
            print(f"❌ Error en Instagram: {str(e)}")
        finally:
            # Mantener la sesión para futuras ejecuciones
            context.close()
    
    return data

# URLs específicas para scraping
INSTAGRAM_URL = "https://www.instagram.com/auna_peru/"

if __name__ == "__main__":
    # Verificar credenciales
    if not IG_USER or not IG_PASS:
        print("❌ Error: Credenciales no configuradas en el archivo .env")
        exit(1)
    
    # Crear tabla si no existe
    crear_tabla_scrap_Instagram()
    
    # Scrapear Instagram
    # Scrapear Instagram
    print("\n" + "="*50)
    print("INICIANDO SCRAPING DE INSTAGRAM")
    print("="*50)
    metricas_ig = scrape_instagram(INSTAGRAM_URL)
    print("\nResultados Instagram:")
    print(f"Publicaciones: {metricas_ig['publicaciones']}")
    print(f"Seguidores: {metricas_ig['seguidores']}")
    print(f"Seguidos: {metricas_ig['seguidos']}")
    guardar_metricas_redes(metricas_ig)
    
    print("\n✅ Proceso de redes sociales completado")