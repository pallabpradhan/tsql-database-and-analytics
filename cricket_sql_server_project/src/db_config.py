import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

class DatabaseConfig:
    """Manages Microsoft SQL Server connections securely using environment variables."""
    def __init__(self):
        self.driver = os.getenv("MSSQL_DRIVER", "ODBC Driver 18 for SQL Server")
        self.server = os.getenv("MSSQL_SERVER", "localhost\\SQLEXPRESS")
        self.database = os.getenv("MSSQL_DATABASE", "CricketAnalyticsDB")
        self.trusted_connection = os.getenv("MSSQL_TRUSTED_CONNECTION", "yes")
        self.username = os.getenv("MSSQL_USER", "")
        self.password = os.getenv("MSSQL_PASSWORD", "")

    def get_connection_string(self) -> str:
        if self.trusted_connection.lower() == "yes":
            return (
                f"DRIVER={{{self.driver}}};"
                f"SERVER={self.server};"
                f"DATABASE={self.database};"
                f"Trusted_Connection=yes;"
                f"TrustServerCertificate=yes;"
            )
        return (
            f"DRIVER={{{self.driver}}};"
            f"SERVER={self.server};"
            f"DATABASE={self.database};"
            f"UID={self.username};"
            f"PWD={self.password};"
            f"TrustServerCertificate=yes;"
        )

    def connect(self):
        return pyodbc.connect(self.get_connection_string())
