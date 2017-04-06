// --- Score Variables ---
float totalScore;
float lastScore;

// --- method to change score ---
void changeScore(boolean positive) {
  float currentVelocity = ball.velocity.mag();

  if (positive) {
    totalScore += currentVelocity;
    lastScore = currentVelocity;
  }
  else {
    totalScore -= currentVelocity;
    lastScore = -currentVelocity;
    if(totalScore < 0)totalScore = 0;
  }
}