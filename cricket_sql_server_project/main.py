from src.cricket_repository import CricketAnalyticsRepository

def run_live_match_simulation():
    repo = CricketAnalyticsRepository()

    print("=== Starting Real-Time Cricket SQL Server Analytics Engine ===")
    
    # 1. Simulate logging an over of deliveries (MatchID=1, Virat=1, Hardik=2, Pant=3, Cummins=4, Starc=5)
    sample_deliveries = [
        (1, 1, 1, 1, 4, 4, 0, 0, None),        # 1.1: Kohli hits Cummins for 4
        (1, 1, 2, 1, 4, 1, 0, 0, None),        # 1.2: Kohli takes a single
        (1, 1, 3, 2, 4, 6, 0, 0, None),        # 1.3: Hardik hits Cummins for 6
        (1, 1, 4, 2, 4, 0, 0, 0, None),        # 1.4: Dot ball
        (1, 1, 5, 2, 4, 4, 0, 0, None),        # 1.5: Hardik hits 4
        (1, 1, 6, 2, 4, 0, 0, 1, "Bowled"),    # 1.6: WICKET! Hardik bowled by Cummins
        (1, 2, 1, 1, 5, 4, 0, 0, None),        # 2.1: Kohli hits Starc for 4
        (1, 2, 2, 1, 5, 2, 0, 0, None),        # 2.2: Kohli takes 2 runs
    ]

    for delivery in sample_deliveries:
        repo.log_ball(*delivery)

    # 2. Display Real-Time Scorecards & Chase Summary
    repo.get_batting_scorecard(match_id=1)
    repo.get_bowling_figures(match_id=1)
    repo.get_match_chase_status(match_id=1)

    # 3. Demonstrate SQL Injection Prevention
    print("--- Testing SQL Injection Prevention ---")
    malicious_input = "Kohli'; DROP TABLE dbo.Players; --"
    results = repo.search_player_safely(malicious_input)
    print(f"Malicious query executed safely via '?' parameter binding. Rows returned: {len(results)}")

if __name__ == "__main__":
    run_live_match_simulation()
