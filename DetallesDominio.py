import requests
import pyodbc
import json
import logging
from datetime import datetime

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('similarweb_importer.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Configuración
API_KEY = "45298fb874msh64f601aeecf7c3fp1cf97ajsn3306fd43459c"
API_HOST = "similarweb-api6.p.rapidapi.com"
DB_SERVER = 'DESKTOP-QFC2KRH'
DB_NAME = 'BD_AUNA'
DB_TRUSTED_CONNECTION = 'yes'
MAX_RETRIES = 3
REQUEST_TIMEOUT = 10

# Funciones de ayuda
def safe_get(data, keys, default=None):
    """Obtiene valores anidados de forma segura"""
    for key in keys.split('.'):
        if isinstance(data, dict):
            data = data.get(key, default)
        else:
            return default
    return data if data is not None else default

def safe_json(value):
    """Convierte valores a JSON de forma segura"""
    return json.dumps(value) if value is not None else None

# Funciones de procesamiento de datos
def process_subsidiaries(subsidiaries_data):
    """Procesa la información de subsidiarias/sucursales"""
    processed = []
    
    if not subsidiaries_data or not isinstance(subsidiaries_data, list):
        return processed
    
    for sub in subsidiaries_data:
        if not isinstance(sub, dict):
            continue
            
        processed.append({
            'domain': sub.get('domain'),
            'icon': sub.get('icon'),
            'is_ga_data': sub.get('isGaData', False),
            'processed_at': datetime.now()
        })
    
    return processed

def process_visits_history(visits_data):
    """Procesa el historial de visitas"""
    processed = []
    
    if not visits_data or not isinstance(visits_data, dict):
        return processed
    
    for domain, dates in visits_data.items():
        if not isinstance(dates, dict):
            continue
            
        for date_str, visits in dates.items():
            try:
                processed.append({
                    'domain': domain,
                    'date': datetime.fromisoformat(date_str.replace('T', ' ')).date(),
                    'visits': int(visits),
                    'processed_at': datetime.now()
                })
            except (ValueError, TypeError):
                continue
                
    return processed

def process_average_duration(duration_data):
    """Procesa los datos de duración promedio"""
    processed = []
    
    if not duration_data or not isinstance(duration_data, dict):
        return processed
    
    for domain, dates in duration_data.items():
        if not isinstance(dates, dict):
            continue
            
        for date_str, duration in dates.items():
            try:
                h, m, s = map(int, duration.split(':'))
                total_seconds = h * 3600 + m * 60 + s
                
                processed.append({
                    'domain': domain,
                    'date': datetime.fromisoformat(date_str.replace('T', ' ')).date(),
                    'duration_str': duration,
                    'duration_seconds': total_seconds,
                    'processed_at': datetime.now()
                })
            except (ValueError, AttributeError):
                continue
                
    return processed

def process_pages_per_visit(pages_data):
    """Procesa el historial de páginas por visita"""
    processed = []
    
    if not pages_data or not isinstance(pages_data, dict):
        return processed
    
    for domain, dates in pages_data.items():
        if not isinstance(dates, dict):
            continue
            
        for date_str, pages in dates.items():
            try:
                processed.append({
                    'domain': domain,
                    'date': datetime.fromisoformat(date_str.replace('T', ' ')).date(),
                    'pages_per_visit': float(pages),
                    'processed_at': datetime.now()
                })
            except (ValueError, TypeError):
                continue
                
    return processed

def process_competitors(competitors_data):
    """Procesa la información de competidores"""
    processed = []
    
    if not competitors_data or not isinstance(competitors_data, dict):
        return processed
    
    for main_domain, competitors in competitors_data.items():
        if not isinstance(competitors, list):
            continue
            
        for comp in competitors:
            if not isinstance(comp, dict):
                continue
                
            processed.append({
                'main_domain': main_domain,
                'competitor_domain': comp.get('domain'),
                'competitor_name': comp.get('name'),
                'category': comp.get('categoryId'),
                'employees_min': comp.get('employeesMin'),
                'employees_max': comp.get('employeesMax'),
                'total_visits': comp.get('totalVisits'),
                'processed_at': datetime.now()
            })
    
    return processed

def process_technologies(tech_data):
    """Procesa la información de tecnologías utilizadas"""
    processed = []
    
    if not tech_data or not isinstance(tech_data, dict):
        return processed
    
    for domain, tech_info in tech_data.items():
        if not isinstance(tech_info, dict):
            continue
            
        categories = tech_info.get('categories', [])
        if not isinstance(categories, list):
            continue
            
        for cat in categories:
            if not isinstance(cat, dict):
                continue
                
            processed.append({
                'domain': domain,
                'category': cat.get('categoryId'),
                'top_tech': cat.get('topTechName'),
                'tech_count': cat.get('technologiesTotalCount'),
                'processed_at': datetime.now()
            })
    
    return processed

# Funciones de conexión y manejo de base de datos
def get_similarweb_data(domain):
    """Obtiene datos de la API de SimilarWeb"""
    url = f"https://{API_HOST}/v2/company-details"
    headers = {
        "X-RapidAPI-Key": API_KEY,
        "X-RapidAPI-Host": API_HOST
    }
    
    try:
        response = requests.get(
            url,
            headers=headers,
            params={"company_domain": domain},
            timeout=REQUEST_TIMEOUT
        )
        
        if response.status_code == 200:
            return response.json()
        
        logger.error(f"API respondió con código {response.status_code}: {response.text}")
        return None

    except requests.exceptions.RequestException as e:
        logger.error(f"Error de conexión: {str(e)}")
        return None
    except json.JSONDecodeError as e:
        logger.error(f"Error al decodificar JSON: {str(e)}")
        return None

def get_db_connection():
    """Establece conexión con SQL Server"""
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_NAME};"
        f"Trusted_Connection={DB_TRUSTED_CONNECTION}"
    )
    
    for attempt in range(MAX_RETRIES):
        try:
            logger.info(f"Intentando conexión a SQL Server (intento {attempt + 1})")
            return pyodbc.connect(conn_str)
        except pyodbc.Error as e:
            logger.warning(f"Error de conexión: {str(e)}")
            if attempt == MAX_RETRIES - 1:
                raise
            time.sleep(2)

def create_tables(conn):
    """Crea todas las tablas necesarias si no existen"""
    cursor = conn.cursor()
    
    # Tabla principal DetalleDominio
    cursor.execute("""
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='DetalleDominio' AND xtype='U')
    CREATE TABLE DetalleDominio (
        id INT IDENTITY(1,1) PRIMARY KEY,
        fecha_consulta DATETIME DEFAULT GETDATE(),
        status NVARCHAR(50),
        domain NVARCHAR(255),
        categoryId NVARCHAR(255),
        icon NVARCHAR(MAX),
        company_name NVARCHAR(255),
        company_type NVARCHAR(100),
        snapshotDate NVARCHAR(50),
        feedbackRecaptcha NVARCHAR(255),
        description NVARCHAR(MAX),
        twitter NVARCHAR(255),
        facebook NVARCHAR(255),
        linkedin NVARCHAR(255),
        email NVARCHAR(255),
        phone NVARCHAR(100),
        yearFounded INT,
        headquarterCountryCode NVARCHAR(10),
        headquarterCity NVARCHAR(100),
        headquarterStateCode NVARCHAR(50),
        employeesMin INT,
        employeesMax INT,
        revenueMin BIGINT,
        revenueMax BIGINT,
        revenueCurrency NVARCHAR(10),
        stocks_tickers NVARCHAR(MAX),
        subsidiaries NVARCHAR(MAX),
        revenue NVARCHAR(MAX),
        visitsHistory NVARCHAR(MAX),
        averageDurationHistory NVARCHAR(MAX),
        pagesPerVisitHistory NVARCHAR(MAX),
        competitors NVARCHAR(MAX),
        signals NVARCHAR(MAX),
        technologies NVARCHAR(MAX),
        revenueRanges NVARCHAR(MAX),
        categoryTotalVisits FLOAT,
        categoryPagesPerVisit FLOAT,
        topCompaniesInCategory NVARCHAR(MAX)
    )
    """)
    
    # Tablas para datos procesados
    tables = [
        """
        CREATE TABLE DD_Subsidiaries (
            id INT IDENTITY(1,1) PRIMARY KEY,
            domain NVARCHAR(255),
            icon NVARCHAR(MAX),
            is_ga_data BIT,
            processed_at DATETIME,
            main_domain NVARCHAR(255)
        )
        """,
        """
        CREATE TABLE DD_VisitsHistory (
            id INT IDENTITY(1,1) PRIMARY KEY,
            domain NVARCHAR(255),
            date DATE,
            visits INT,
            processed_at DATETIME
        )
        """,
        """
        CREATE TABLE DD_AverageDuration (
            id INT IDENTITY(1,1) PRIMARY KEY,
            domain NVARCHAR(255),
            date DATE,
            duration_str NVARCHAR(20),
            duration_seconds INT,
            processed_at DATETIME
        )
        """,
        """
        CREATE TABLE DD_PagesPerVisit (
            id INT IDENTITY(1,1) PRIMARY KEY,
            domain NVARCHAR(255),
            date DATE,
            pages_per_visit FLOAT,
            processed_at DATETIME
        )
        """,
        """
        CREATE TABLE DD_Competitors (
            id INT IDENTITY(1,1) PRIMARY KEY,
            main_domain NVARCHAR(255),
            competitor_domain NVARCHAR(255),
            competitor_name NVARCHAR(255),
            category NVARCHAR(255),
            employees_min INT,
            employees_max INT,
            total_visits FLOAT,
            processed_at DATETIME
        )
        """,
        """
        CREATE TABLE DD_Technologies (
            id INT IDENTITY(1,1) PRIMARY KEY,
            domain NVARCHAR(255),
            category NVARCHAR(255),
            top_tech NVARCHAR(255),
            tech_count INT,
            processed_at DATETIME
        )
        """
    ]
    
    for table_query in tables:
        try:
            cursor.execute(f"IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='{table_query.split()[2]}' AND xtype='U') {table_query}")
        except pyodbc.Error as e:
            logger.error(f"Error al crear tabla: {str(e)}")
    
    conn.commit()

def insert_main_data(conn, data):
    """Inserta los datos principales en DetalleDominio"""
    cursor = conn.cursor()
    
    overview = data.get('overview', {})

    insert_query = """
    INSERT INTO DetalleDominio (
        status, domain, categoryId, icon, company_name, company_type, snapshotDate,
        feedbackRecaptcha, description, twitter, facebook, linkedin, email, phone,
        yearFounded, headquarterCountryCode, headquarterCity, headquarterStateCode,
        employeesMin, employeesMax, revenueMin, revenueMax, revenueCurrency,
        stocks_tickers, subsidiaries, revenue, visitsHistory, averageDurationHistory,
        pagesPerVisitHistory, competitors, signals, technologies, revenueRanges,
        categoryTotalVisits, categoryPagesPerVisit, topCompaniesInCategory
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """

    try:
        cursor.execute(insert_query,
            data.get('status'),
            data.get('domain'),
            data.get('categoryId'),
            data.get('icon'),
            data.get('name'),
            data.get('type'),
            data.get('snapshotDate'),
            overview.get('feedbackRecaptcha'),
            overview.get('description'),
            overview.get('twitter'),
            overview.get('facebook'),
            overview.get('linkedin'),
            overview.get('email'),
            overview.get('phone'),
            overview.get('yearFounded'),
            overview.get('headquarterCountryCode'),
            overview.get('headquarterCity'),
            overview.get('headquarterStateCode'),
            overview.get('employeesMin'),
            overview.get('employeesMax'),
            overview.get('revenueMin'),
            overview.get('revenueMax'),
            overview.get('revenueCurrency'),
            safe_json(data.get('stocks', {}).get('tickers')),
            safe_json(data.get('subsidiaries')),
            safe_json(data.get('revenue')),
            safe_json(data.get('visitsHistory')),
            safe_json(data.get('averageDurationHistory')),
            safe_json(data.get('pagesPerVisitHistory')),
            safe_json(data.get('competitors')),
            safe_json(data.get('signals')),
            safe_json(data.get('technologies')),
            safe_json(data.get('revenueRanges')),
            data.get('categoryTotalVisits'),
            data.get('categoryPagesPerVisit'),
            safe_json(data.get('topCompaniesInCategory'))
        )
        conn.commit()
        return True
    except pyodbc.Error as e:
        conn.rollback()
        logger.error(f"Error al insertar datos principales: {str(e)}")
        return False

def insert_processed_data(conn, processed_data, table_name):
    """Inserta datos procesados en tablas específicas"""
    if not processed_data or not table_name:
        return False
        
    cursor = conn.cursor()
    
    try:
        columns = ', '.join(processed_data[0].keys())
        placeholders = ', '.join(['?'] * len(processed_data[0]))
        
        insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        
        for record in processed_data:
            cursor.execute(insert_query, *record.values())
        
        conn.commit()
        return True
        
    except pyodbc.Error as e:
        conn.rollback()
        logger.error(f"Error al insertar en {table_name}: {str(e)}")
        return False

# Función principal
def main():
    domain = "auna.org"
    logger.info(f"Iniciando proceso para dominio: {domain}")
    
    # Obtener datos de la API
    raw_data = get_similarweb_data(domain)
    if not raw_data:
        logger.error("No se obtuvieron datos válidos de la API")
        return
    
    try:
        conn = get_db_connection()
        
        # Crear tablas si no existen
        logger.info("Verificando estructura de tablas...")
        create_tables(conn)
        
        # Insertar datos principales
        logger.info("Insertando datos principales...")
        main_data_success = insert_main_data(conn, raw_data)
        
        if main_data_success:
            logger.info("Datos principales insertados correctamente")
            
            # Procesar e insertar datos detallados
            processors = [
                ('subsidiaries', 'DD_Subsidiaries', process_subsidiaries),
                ('visitsHistory', 'DD_VisitsHistory', process_visits_history),
                ('averageDurationHistory', 'DD_AverageDuration', process_average_duration),
                ('pagesPerVisitHistory', 'DD_PagesPerVisit', process_pages_per_visit),
                ('competitors', 'DD_Competitors', process_competitors),
                ('technologies', 'DD_Technologies', process_technologies)
            ]
            
            for field, table_name, processor in processors:
                data_to_process = raw_data.get(field)
                processed_data = processor(data_to_process)
                
                if processed_data:
                    success = insert_processed_data(conn, processed_data, table_name)
                    logger.info(f"Datos de {field} procesados: {'éxito' if success else 'fallo'}")
                else:
                    logger.warning(f"No se encontraron datos para procesar en {field}")
            
            logger.info("Proceso completado exitosamente")
        else:
            logger.error("No se pudieron insertar los datos principales")
        
    except Exception as e:
        logger.error(f"Error en el proceso principal: {str(e)}")
    finally:
        if 'conn' in locals():
            conn.close()
            logger.info("Conexión a BD cerrada")

if __name__ == "__main__":
    import time
    main()