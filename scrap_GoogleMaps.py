from playwright.sync_api import sync_playwright
import pyodbc
import time
from datetime import datetime, timedelta

# Función de conexión
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

def crear_tabla():
    try:
        conn = crear_conexion()
        if conn:
            cursor = conn.cursor()
            cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Resenas_GoogleMaps')
            CREATE TABLE Resenas_GoogleMaps (
                ID_Registro INT IDENTITY(1,1) PRIMARY KEY,
                Usuario NVARCHAR(255) NOT NULL,
                Puntuacion INT NOT NULL,
                Fecha_Resena NVARCHAR(100),  -- Cambiado a texto para fechas relativas
                Comentario NVARCHAR(MAX),
                Fecha_Registro DATETIME DEFAULT GETDATE()
            )
            """)
            conn.commit()
            print("✔ Tabla 'Resenas_GoogleMaps' verificada/creada")
            return True
    except Exception as e:
        print(f"❌ Error al crear tabla: {str(e)}")
        return False

def guardar_calificaciones(datos):
    try:
        conn = crear_conexion()
        if not conn:
            return False
           
        cursor = conn.cursor()
        query = """
        INSERT INTO Resenas_GoogleMaps (Usuario, Puntuacion, Fecha_Resena, Comentario)
        VALUES (?, ?, ?, ?)
        """
       
        for usuario, puntuacion, fecha, comentario in datos:
            cursor.execute(query, (usuario, puntuacion, fecha, comentario))
       
        conn.commit()
        print(f"💾 {len(datos)} calificaciones guardadas")
        return True
    except Exception as e:
        print(f"🚨 Error al guardar: {str(e)}")
        return False

# Función para convertir fecha relativa a formato YYYY-MM-DD (opcional)
def convertir_fecha(fecha_texto):
    try:
        hoy = datetime.now()
        fecha_texto = fecha_texto.lower()
        
        if 'hace' in fecha_texto:
            num = int(''.join(filter(str.isdigit, fecha_texto)))
            
            if 'minuto' in fecha_texto or 'hora' in fecha_texto:
                return hoy.strftime('%Y-%m-%d')
            elif 'día' in fecha_texto or 'días' in fecha_texto:
                return (hoy - timedelta(days=num)).strftime('%Y-%m-%d')
            elif 'semana' in fecha_texto or 'semanas' in fecha_texto:
                return (hoy - timedelta(weeks=num)).strftime('%Y-%m-%d')
            elif 'mes' in fecha_texto or 'meses' in fecha_texto:
                return (hoy - timedelta(days=num*30)).strftime('%Y-%m-%d')
            elif 'año' in fecha_texto or 'años' in fecha_texto:
                return (hoy - timedelta(days=num*365)).strftime('%Y-%m-%d')
        
        # Si ya es una fecha completa o no se puede convertir
        return fecha_texto
    except:
        return fecha_texto  # Devuelve el texto original si falla

# Función principal de scraping
def scrape_all_reviews(url):
    reviews_data = []
   
    with sync_playwright() as p:
        try:
            browser = p.chromium.launch(headless=False, slow_mo=2000)
            context = browser.new_context(
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
                viewport={"width": 1366, "height": 768}
            )
            page = context.new_page()
           
            print(f"🌐 Cargando reseñas...")
            page.goto(url, timeout=60000)
            time.sleep(3)
           
            # Scroll automático
            print("\n🔍 Cargando todas las reseñas...")
            last_count = 0
            same_count = 0
           
            while same_count < 5:
                page.evaluate("""() => {
                    const reviewsSection = document.querySelector('div.m6QErb.DxyBCb.kA9KIf.dS8AEf') ||
                                         document.querySelector('div.eppRr');
                    if (reviewsSection) {
                        reviewsSection.scrollTop = reviewsSection.scrollHeight;
                    }
                }""")
                time.sleep(3)
               
                current_reviews = page.query_selector_all('div.jftiEf')
                print(f"🔄 Reseñas encontradas: {len(current_reviews)}")
               
                if len(current_reviews) == last_count:
                    same_count += 1
                else:
                    same_count = 0
                    last_count = len(current_reviews)
           
            reviews = page.query_selector_all('div.jftiEf')
            print(f"\n📝 Total de reseñas cargadas: {len(reviews)}")
           
            # Procesar cada reseña
            for review in reviews:
                try:
                    # Extraer usuario
                    user = review.query_selector('div.d4r55').inner_text().strip()
                    
                    # Extraer puntuación
                    rating_element = review.query_selector('span.kvMYJc')
                    rating = int(rating_element.get_attribute('aria-label').split()[0]) if rating_element else None
                    
                    # Extraer fecha de la reseña
                    fecha_element = review.query_selector('span.rsqaWe')
                    fecha_texto = fecha_element.inner_text().strip() if fecha_element else "Fecha no disponible"
                    
                    # Extraer comentario
                    comentario_element = review.query_selector('div.MyEned')
                    comentario = comentario_element.inner_text().strip() if comentario_element else ""
                    
                    if user and rating:
                        reviews_data.append((user, rating, fecha_texto, comentario))
                except Exception as e:
                    print(f"⚠ Error procesando reseña: {str(e)}")
                    continue
           
            # Guardar en SQL Server
            if reviews_data:
                if crear_tabla():
                    guardar_calificaciones(reviews_data)
            else:
                print("⚠ No se encontraron reseñas para guardar")
           
        except Exception as e:
            print(f"❌ Error durante el scraping: {str(e)}")
        finally:
            browser.close()

# URL de reseñas
URL_RESENAS = "https://www.google.com/maps/place/Cl%C3%ADnicas+Auna+sede+Camino+Real/@-8.1140746,-79.0313458,17z/data=!4m18!1m9!3m8!1s0x91ad3d82ef387841:0xdbd0eaead09e2870!2sCl%C3%ADnicas+Auna+sede+Camino+Real!8m2!3d-8.1140746!4d-79.0287709!9m1!1b1!16s%2Fg%2F1tdvfn0q!3m7!1s0x91ad3d82ef387841:0xdbd0eaead09e2870!8m2!3d-8.1140746!4d-79.0287709!9m1!1b1!16s%2Fg%2F1tdvfn0q?entry=ttu&g_ep=EgoyMDI1MDQyMi4wIKXMDSoASAFQAw%3D%3D"
if __name__ == "__main__":
    scrape_all_reviews(URL_RESENAS)