// --- Score Variables ---
float totalScore;
float lastScore;



// --- method to change score ---
void changeScore(boolean objectHit) {
  float currentVelocity = ball.velocity.mag();
  
  if (objectHit) {
    totalScore += currentVelocity;
    lastScore = currentVelocity;
  } else {
    totalScore -= currentVelocity;
    lastScore = -currentVelocity;
  }
}