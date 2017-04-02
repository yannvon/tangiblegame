// --- Score Variables ---
float totalScore;
float lastScore;



// --- method to change score ---
void changeScore(boolean obstacleHit, boolean edgeHit) {
  float currentVelocity = ball.velocity.mag();

  if (obstacleHit) {
    totalScore += currentVelocity;
    lastScore = currentVelocity;
  }
  if (edgeHit) {
    totalScore -= currentVelocity;
    lastScore = -currentVelocity;
    if(totalScore < 0)totalScore = 0;
  }
}