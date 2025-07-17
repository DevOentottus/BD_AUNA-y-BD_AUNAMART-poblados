import requests
import pyodbc
import json

# Consulta a la API
url = "https://similarweb-insights.p.rapidapi.com/all-insights"
querystring = {"domain": "auna.org"}

headers = {
    "X-Rapidapi-Key": "45298fb874msh64f601aeecf7c3fp1cf97ajsn3306fd43459c",
    "X-Rapidapi-Host": "similarweb-insights.p.rapidapi.com"
}

response = requests.get(url, headers=headers, params=querystring)

if response.status_code == 200:
    data = response.json()

    # 🎯 Extracción de campos clave
    snapshot = data.get("SnapshotDate")
    domain = data.get("WebsiteDetails", {}).get("Domain")
    category = data.get("WebsiteDetails", {}).get("Category")
    rank_global = data.get("Rank", {}).get("GlobalRank")
    rank_country = data.get("Rank", {}).get("CountryRank", {}).get("Rank")
    country = data.get("Rank", {}).get("CountryRank", {}).get("Country")
    rank_cat = data.get("Rank", {}).get("CategoryRank", {}).get("Rank")
    keywords = data.get("SEOInsights", {}).get("TopKeywords", [])
    fuentes = data.get("Traffic", {}).get("Sources", {})
    visitas_mayo = data.get("Traffic", {}).get("Visits", {}).get("2025-05-01", 0)
    engagement = data.get("Traffic", {}).get("Engagement", {})
    tiempo = engagement.get("TimeOnSite")
    rebote = engagement.get("BounceRate")
    paginas = engagement.get("PagesPerVisit")

    # 🧠 Formato plano para palabras clave
    palabras = "; ".join([kw.get("Name") for kw in keywords])

    # 🧠 Formato plano para fuentes de tráfico
    fuentes_str = "; ".join([f"{k}: {v}" for k, v in fuentes.items()])

    # 🔗 Conexión SQL Server
    conn = pyodbc.connect(
        Driver='{ODBC Driver 17 for SQL Server}',
        Server='DESKTOP-QFC2KRH',
        Database='BD_AUNA',
        Trusted_Connection='yes'
    )
    cursor = conn.cursor()

    # 🏗️ Crear tabla si no existe
    cursor.execute("""
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Trafico_Web_auna_org'
    )
    BEGIN
        CREATE TABLE Trafico_Web_auna_org (
            Id INT IDENTITY(1,1) PRIMARY KEY,
            FechaSnapshot NVARCHAR(MAX),
            Dominio NVARCHAR(100),
            Categoria NVARCHAR(255),
            RankGlobal INT,
            RankPais INT,
            Pais NVARCHAR(50),
            RankCategoria INT,
            PalabrasClave NVARCHAR(MAX),
            FuentesTráfico NVARCHAR(MAX),
            VisitasMensuales BIGINT,
            TiempoPromedio FLOAT,
            BounceRate FLOAT,
            PagesPorVisita FLOAT
        )
    END
    """)

    # 📥 Inserción
    cursor.execute("""
    INSERT INTO Trafico_Web_auna_org (
        FechaSnapshot, Dominio, Categoria, RankGlobal, RankPais, Pais,
        RankCategoria, PalabrasClave, FuentesTráfico, VisitasMensuales,
        TiempoPromedio, BounceRate, PagesPorVisita
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, snapshot, domain, category, rank_global, rank_country, country, rank_cat,
         palabras, fuentes_str, visitas_mayo, tiempo, rebote, paginas)

    conn.commit()
    conn.close()
    print("✅ Datos insertados correctamente en Trafico_Web_auna_org")

else:
    print(f"❌ Error {response.status_code}: {response.text}")