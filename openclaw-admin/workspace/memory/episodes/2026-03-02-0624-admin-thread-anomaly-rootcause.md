# Episode: Slack threading anomaly – root cause
- When: 2026-03-02 06:24 UTC
- Finding: replyToMode was correct; follow-up messages lacked replyTo so became top-level.
- Action: posted fix guidance in thread.
- Lesson: Always preserve thread starter ts and pass replyTo for every subsequent post.
