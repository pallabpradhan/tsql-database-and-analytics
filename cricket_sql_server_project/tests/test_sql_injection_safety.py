import unittest
from unittest.mock import MagicMock, patch
from src.cricket_repository import CricketAnalyticsRepository

class TestSQLInjectionPrevention(unittest.TestCase):
    """
    Verifies that every database call strictly uses parameterized '?' placeholders
    and passes user inputs as a separate tuple rather than formatting SQL strings.
    """

    @patch("src.cricket_repository.DatabaseConfig")
    def test_search_player_prevents_sql_injection(self, MockDBConfig):
        mock_db = MockDBConfig.return_value
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_db.connect.return_value.__enter__.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor

        repo = CricketAnalyticsRepository(db_config=mock_db)

        # Simulated SQL Injection Payload
        injection_attempt = "Virat'; DROP TABLE dbo.Players; --"
        repo.search_player_safely(injection_attempt)

        # Verify cursor.execute was called with '?' placeholders and a separate parameter tuple
        self.assertTrue(mock_cursor.execute.called)
        executed_sql, passed_params = mock_cursor.execute.call_args[0]

        self.assertIn("WHERE FullName LIKE ? OR TeamName LIKE ?", executed_sql)
        self.assertNotIn("DROP TABLE", executed_sql)
        self.assertEqual(passed_params, (f"%{injection_attempt}%", f"%{injection_attempt}%"))

    @patch("src.cricket_repository.DatabaseConfig")
    def test_log_ball_uses_parameterized_stored_procedure(self, MockDBConfig):
        mock_db = MockDBConfig.return_value
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_db.connect.return_value.__enter__.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor

        repo = CricketAnalyticsRepository(db_config=mock_db)
        repo.log_ball(1, 1, 1, 1, 4, 6, 0, 0, None)

        executed_sql, passed_params = mock_cursor.execute.call_args[0]
        self.assertIn("EXEC dbo.sp_RecordDelivery", executed_sql)
        self.assertEqual(executed_sql.count("?"), 9)
        self.assertEqual(passed_params, (1, 1, 1, 1, 4, 6, 0, 0, None))

if __name__ == "__main__":
    unittest.main()
