// --- Score Board Constants ---
final int large_surface_height = 200;    //FIXME dont hardcode!!
final int small_surface_height = 160;    //FIXME dont hardcode!!
final int margin = (large_surface_height - small_surface_height)/ 2;
final int scoreboard_width = 120;          //FIXME dont hardcode!!
final int BACKGROUND_COLOR  = 0xFFE0E0C0;  //FIXME better Color
final int BACKGROUND_COLOR_LIGHT  = 0xFFEFECCA;
final int TOPVIEW_COLOR = 0xFF056481;
final int BALLTRACE_COLOR = 0xFF197895;
final int SCOREBOARD_TEXT_COLOR = 60;

// --- BACKGROUND SURFACE ---
PGraphics data_background;

// --- TOP VIEW Surfaces ---
PGraphics top_view;
PGraphics objects;
PGraphics ball_trace;

// --- SCOREBOARD surfaces ---
PGraphics scoreboard;

// --- BAR CHART surface ---
PGraphics barChart;

// --- BAR CHART variable ---
int count;
int oldPos = -1;
ArrayList<Float> scores = new ArrayList<Float>();
int xPos;

final int tiny_rect_size = 5;              //FIXME chose wisely ;)
final int tiny_margin = 2;
final int intervall = 30;
final float scorePerRect = 4;


// --- Initialiser Methods ---
void setupSurfaces() {
  data_background = createGraphics(width, large_surface_height, P2D);
  top_view = createGraphics(small_surface_height, small_surface_height, P2D);
  objects = createGraphics(small_surface_height, small_surface_height, P2D);
  ball_trace = createGraphics(small_surface_height, small_surface_height, P2D);
  scoreboard = createGraphics(scoreboard_width, small_surface_height, P2D); //FIXME less width
  barChart = createGraphics(width - 2 * small_surface_height - 4 * margin, small_surface_height - 3 * margin, P2D);
  barChart.beginDraw();    //FIXME allowed to do this here?
  barChart.background(BACKGROUND_COLOR_LIGHT);
  barChart.endDraw();
}

// --- Drawing Methods ---
void drawScoreBoardSurfaces() {
  data_background.beginDraw();
  data_background.background(BACKGROUND_COLOR);
  data_background.endDraw();

  objects.beginDraw();
  objects.pushMatrix();
  objects.clear();
  objects.translate(small_surface_height/2, small_surface_height/2); 
  objects.scale(small_surface_height / PLATE_SIZE_X);
  objects.fill(BACKGROUND_COLOR);
  for (PVector obstacle : obstaclePositions) {
    objects.ellipse(obstacle.x, obstacle.z, cylinderBaseSize * 2, cylinderBaseSize *2);
  }
  objects.fill(COLOR_RED);
  objects.ellipse(ball.location.x, ball.location.z, RADIUS * 2, RADIUS * 2);
  objects.popMatrix();
  objects.endDraw();

  top_view.beginDraw();
  top_view.background(TOPVIEW_COLOR);
  top_view.endDraw();

  //FIXME ball trace and topview can be merged!
  //FIXME make ball trace disappear, I already tried, I think I see how its done
  ball_trace.beginDraw();
  ball_trace.pushMatrix();
  //ball_trace.fill(TOPVIEW_COLOR, 10);
  //ball_trace.rect(0, 0, ball_trace.width, ball_trace.height);
  ball_trace.translate(small_surface_height/2, small_surface_height/2); 
  ball_trace.scale(small_surface_height / PLATE_SIZE_X);
  ball_trace.noStroke();
  ball_trace.fill(BALLTRACE_COLOR);
  ball_trace.ellipse(ball.location.x, ball.location.z, RADIUS / 2, RADIUS / 2);
  ball_trace.popMatrix();
  ball_trace.endDraw();

  scoreboard.beginDraw();
  scoreboard.background(BACKGROUND_COLOR);
  scoreboard.stroke(255);    //FIXME I tried fixing a white stroke around scoreboard but didn't achieved it
  scoreboard.fill(255, 0);
  scoreboard.rect(0, 0, scoreboard.width, scoreboard.height);
  //FIXME add border to image, tried but no good solution found yet
  String s = String.format(
    "Your score\n %.3f\n\n" +
    "Velocity\n%.3f\n\n" +
    "Last Score\n%.3f", 
    totalScore, ball.velocity.mag(), lastScore);
  scoreboard.fill(SCOREBOARD_TEXT_COLOR);
  scoreboard.text(s, margin, margin, scoreboard.width-margin, scoreboard.height - margin);  //FIXME better values :)
  scoreboard.endDraw();



  float newPos = hs.getPos();
  if (++count == intervall) {
    count = 0;
    if(!scores.isEmpty() || totalScore > scorePerRect * tiny_rect_size) scores.add(totalScore);
  }
  if (count == intervall  || oldPos != newPos) {
    barChart.beginDraw();
    barChart.background(BACKGROUND_COLOR);
    xPos = 0;
    float scale_factor = Math.max(newPos*2, 0.3);
    for (float score : scores) {
      barChart.fill(TOPVIEW_COLOR);
      for (int y = tiny_rect_size; y < barChart.height && y <= (score / scorePerRect); y += tiny_margin + tiny_rect_size) {
        barChart.rect(xPos, barChart.height - y, tiny_rect_size * scale_factor, tiny_rect_size);
      }
      xPos += (tiny_rect_size + tiny_margin)*scale_factor;
    }
    barChart.endDraw();
  }
}

//TODO put inside method above?
void displayScoreBoardSurfaces() {
  int yCordinate = height - (small_surface_height + margin);
  image(data_background, 0, height - data_background.height);
  image(top_view, margin, yCordinate);
  image(ball_trace, margin, yCordinate);
  image(objects, margin, yCordinate);
  stroke(COLOR_RED);
  image(scoreboard, small_surface_height + 2 * margin, yCordinate);
  image(barChart, 2 * small_surface_height + 3 * margin, yCordinate); 
  noStroke();
}