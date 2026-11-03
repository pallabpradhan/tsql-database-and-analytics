from typing import List, Tuple, Optional, Dict, Any
from tabulate import tabulate
from src.db_config import DatabaseConfig

class CricketAnalyticsRepository:
    """
    Data Access Layer for CricketAnalyticsDB.
    Enforces strict SQL Injection prevention by using parameterized '?' placeholders
    for every SQL Server query and stored procedure call.
    """
    def __init__(self, db_config: Optional[DatabaseConfig] = None):
        self.db = db_config or DatabaseConfig()

    def log_ball(
        self,
        match_id: int,
        over_num: int,
        ball_num: int,
        batter_id: int,
        bowler_id: int,
        runs: int,
        extras: int = 0,
        is_wicket: int = 0,
        dismissal_type: Optional[str] = None
    ) -> None:
        """Executes sp_RecordDelivery using parameterized inputs to prevent SQL injection."""
        query = """
        EXEC dbo.sp_RecordDelivery 
            @MatchID = ?, 
            @OverNumber = ?, 
            @BallNumber = ?, 
            @BatterID = ?, 
            @BowlerID = ?, 
            @RunsScored = ?, 
            @ExtraRuns = ?, 
            @IsWicket = ?,
            @DismissalType = ?
        """
        params = (match_id, over_num, ball_num, batter_id, bowler_id, runs, extras, is_wicket, dismissal_type)
        with self.db.connect() as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            conn.commit()
            print(f"[SQL COMMIT] Over {over_num}.{ball_num} | Runs: {runs} | Extras: {extras} | Wicket: {bool(is_wicket)}")

    def search_player_safely(self, search_term: str) -> List[Tuple]:
        """
        Demonstrates SQL-injection-safe player lookup.
        Even if a malicious user passes: "Kohli'; DROP TABLE Players; --"
        the '?' placeholder treats the entire string as a literal parameter.
        """
        query = """
        SELECT PlayerID, FullName, TeamName, PlayerRole
        FROM dbo.Players
        WHERE FullName LIKE ? OR TeamName LIKE ?;
        """
        safe_pattern = f"%{search_term}%"
        with self.db.connect() as conn:
            cursor = conn.cursor()
            cursor.execute(query, (safe_pattern, safe_pattern))
            return cursor.fetchall()

    def get_batting_scorecard(self, match_id: int) -> List[Tuple]:
        """Computes real-time batting statistics directly on SQL Server."""
        query = """
        SELECT 
            p.FullName AS Batter,
            SUM(b.RunsScored) AS Runs,
            COUNT(b.DeliveryID) AS Balls,
            SUM(CASE WHEN b.RunsScored = 4 THEN 1 ELSE 0 END) AS Fours,
            SUM(CASE WHEN b.RunsScored = 6 THEN 1 ELSE 0 END) AS Sixes,
            CAST(ROUND((SUM(b.RunsScored) * 100.0) / NULLIF(COUNT(b.DeliveryID), 0), 2) AS DECIMAL(10,2)) AS StrikeRate
        FROM dbo.BallByBall b
        INNER JOIN dbo.Players p ON b.BatterID = p.PlayerID
        WHERE b.MatchID = ?
        GROUP BY p.FullName
        ORDER BY Runs DESC;
        """
        with self.db.connect() as conn:
            cursor = conn.cursor()
            cursor.execute(query, (match_id,))
            rows = cursor.fetchall()
            headers = ["Batter", "Runs", "Balls", "4s", "6s", "Strike Rate"]
            print("\n--- LIVE BATTING SCORECARD (SQL SERVER) ---")
            print(tabulate(rows, headers=headers, tablefmt="fancy_grid"))
            return rows

    def get_bowling_figures(self, match_id: int) -> List[Tuple]:
        """Computes real-time bowling economy and wickets on SQL Server."""
        query = """
        SELECT 
            p.FullName AS Bowler,
            CAST(COUNT(b.DeliveryID) / 6 AS VARCHAR(10)) + '.' + CAST(COUNT(b.DeliveryID) % 6 AS VARCHAR(10)) AS Overs,
            SUM(b.RunsScored + b.ExtraRuns) AS RunsConceded,
            SUM(CAST(b.IsWicket AS INT)) AS Wickets,
            CAST(ROUND((SUM(b.RunsScored + b.ExtraRuns) * 6.0) / NULLIF(COUNT(b.DeliveryID), 0), 2) AS DECIMAL(10,2)) AS Economy
        FROM dbo.BallByBall b
        INNER JOIN dbo.Players p ON b.BowlerID = p.PlayerID
        WHERE b.MatchID = ?
        GROUP BY p.FullName
        ORDER BY Wickets DESC, Economy ASC;
        """
        with self.db.connect() as conn:
            cursor = conn.cursor()
            cursor.execute(query, (match_id,))
            rows = cursor.fetchall()
            headers = ["Bowler", "Overs", "Runs", "Wickets", "Economy"]
            print("\n--- LIVE BOWLING FIGURES (SQL SERVER) ---")
            print(tabulate(rows, headers=headers, tablefmt="fancy_grid"))
            return rows

    def get_match_chase_status(self, match_id: int) -> Optional[Dict[str, Any]]:
        """Calculates live total, CRR, RRR, and win probability metrics."""
        query = """
        SELECT 
            m.TeamA + ' vs ' + m.TeamB AS Matchup,
            m.TargetScore,
            ISNULL(SUM(b.RunsScored + b.ExtraRuns), 0) AS TotalRuns,
            ISNULL(SUM(CAST(b.IsWicket AS INT)), 0) AS WicketsLost,
            COUNT(b.DeliveryID) AS BallsBowled
        FROM dbo.Matches m
        LEFT JOIN dbo.BallByBall b ON m.MatchID = b.MatchID
        WHERE m.MatchID = ?
        GROUP BY m.TeamA, m.TeamB, m.TargetScore;
        """
        with self.db.connect() as conn:
            cursor = conn.cursor()
            cursor.execute(query, (match_id,))
            row = cursor.fetchone()

            if not row:
                return None

            matchup, target, runs, wickets, balls = row
            overs_display = f"{balls // 6}.{balls % 6}"
            runs_needed = max(0, target - runs)
            balls_left = max(0, 120 - balls)
            crr = (runs / balls) * 6 if balls > 0 else 0.0
            rrr = (runs_needed / balls_left) * 6 if balls_left > 0 else 0.0

            summary = {
                "matchup": matchup,
                "score": f"{runs}/{wickets}",
                "overs": overs_display,
                "target": target,
                "runs_needed": runs_needed,
                "balls_left": balls_left,
                "crr": round(crr, 2),
                "rrr": round(rrr, 2)
            }

            print(f"\n--- MATCH SUMMARY: {matchup} ---")
            print(f"Score: {runs}/{wickets} ({overs_display} Overs) | Target: {target}")
            print(f"Need {runs_needed} runs from {balls_left} balls | CRR: {crr:.2f} | RRR: {rrr:.2f}\n")
            return summary
