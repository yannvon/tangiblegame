// --- Score Board Constants ---
int S_HEIGHT_LARGE;
int S_HEIGHT_SMALL;
int MARGIN;
int S_WIDTH;
final int DATA_BACKGROUND_COLOR  = 0xFFE0E0C0;  //FIXME better Color
final int DATA_BACKGROUND_COLOR_LIGHT  = 0xFFEFECCA;
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

final float tiny_rect_size = 5;
float tiny_rect_size_y = 5;
final float tiny_margin = 1;
final int intervall = 30;
final float scorePerRect = 30;


// --- Initialiser Methods ---
void setupSurfaces() {
  // --- Initialize size constants ---
  S_HEIGHT_LARGE = height/5;
  S_HEIGHT_SMALL = height/6;
  MARGIN = (S_HEIGHT_LARGE - S_HEIGHT_SMALL)/ 2;
  S_WIDTH = width/12;

  // --- Create Graphics for Surfaces ---
  data_background = createGraphics(width, S_HEIGHT_LARGE, P2D);
  top_view = createGraphics(S_HEIGHT_SMALL, S_HEIGHT_SMALL, P2D);
  objects = createGraphics(S_HEIGHT_SMALL, S_HEIGHT_SMALL, P2D);
  ball_trace = createGraphics(S_HEIGHT_SMALL, S_HEIGHT_SMALL, P2D);
  scoreboard = createGraphics(S_WIDTH, S_HEIGHT_SMALL, P2D);
  barChart = createGraphics(width - S_HEIGHT_SMALL - S_WIDTH - 5 * MARGIN, S_HEIGHT_SMALL - 3 * MARGIN, P2D);
}

// --- Drawing Methods ---
void drawScoreBoardSurfaces() {
  // --- Draw large Data Background ---
  data_background.beginDraw();
  data_background.background(DATA_BACKGROUND_COLOR);
  data_background.endDraw();

  // --- Draw objects (mover & cylinders) ---
  objects.beginDraw();
  objects.pushMatrix();
  objects.clear();
  objects.translate(S_HEIGHT_SMALL/2, S_HEIGHT_SMALL/2); 
  objects.scale(S_HEIGHT_SMALL / PLATE_SIZE_X);
  objects.fill(DATA_BACKGROUND_COLOR);
  for (PVector obstacle : obstaclePositions) {
    objects.ellipse(obstacle.x, obstacle.z, CYLINDER_BASE_SIZE * 2, CYLINDER_BASE_SIZE *2);
  }
  objects.fill(COLOR_RED);
  objects.ellipse(ball.location.x, ball.location.z, RADIUS * 2, RADIUS * 2);
  objects.popMatrix();
  objects.endDraw();

  // --- Draw top view of plate --
  top_view.beginDraw();
  top_view.background(TOPVIEW_COLOR);
  top_view.endDraw();

  //FIXME ball trace and topview can be merged!
  //FIXME make ball trace disappear, I already tried, I think I see how its done
  ball_trace.beginDraw();
  ball_trace.pushMatrix();
  //ball_trace.fill(TOPVIEW_COLOR, 10);
  //ball_trace.rect(0, 0, ball_trace.width, ball_trace.height);
  ball_trace.translate(S_HEIGHT_SMALL/2, S_HEIGHT_SMALL/2); 
  ball_trace.scale(S_HEIGHT_SMALL / PLATE_SIZE_X);
  ball_trace.noStroke();
  ball_trace.fill(BALLTRACE_COLOR);
  ball_trace.ellipse(ball.location.x, ball.location.z, RADIUS / 2, RADIUS / 2);
  ball_trace.popMatrix();
  ball_trace.endDraw();

  scoreboard.beginDraw();
  scoreboard.background(DATA_BACKGROUND_COLOR);
  //FIXME add border to image, tried but no good solution found yet
  String s = String.format(
    "Your score\n %.3f\n\n" +
    "Velocity\n%.3f\n\n" +
    "Last Score\n%.3f", 
    totalScore, ball.velocity.mag(), lastScore);
  scoreboard.fill(SCOREBOARD_TEXT_COLOR);
  scoreboard.text(s, MARGIN, MARGIN, scoreboard.width-MARGIN, scoreboard.height - MARGIN);  //FIXME better values :)
  scoreboard.endDraw();

  // --- Draw BarChart ---
  float newPos = hs.getPos();
  if (++count == intervall) {
    count = 0;
    if (!scores.isEmpty() || totalScore > scorePerRect) scores.add(totalScore);
  }
  if (count == intervall  || oldPos != newPos) {
    barChart.beginDraw();
    barChart.background(DATA_BACKGROUND_COLOR_LIGHT);
    barChart.noStroke();
    float xPos = 0;
    float scale_factor = Math.max(newPos*2, 0.3);
    for (float score : scores) {
      barChart.fill(TOPVIEW_COLOR);
      int vertical_limit = (int)(score/scorePerRect);
      if (vertical_limit*(tiny_rect_size_y+tiny_margin) > barChart.height)tiny_rect_size_y = barChart.height/((1.0)*vertical_limit) - tiny_margin;
      for (int y = 0; y <= vertical_limit; y++) {
        barChart.rect(xPos, barChart.height - y * (tiny_rect_size_y + tiny_margin), tiny_rect_size * scale_factor, tiny_rect_size_y);
      }
      xPos += (tiny_rect_size + tiny_margin)*scale_factor;
    }
    barChart.endDraw();
  }
}

//TODO put inside method above?
void displayScoreBoardSurfaces() {
  int yCordinate = height - (S_HEIGHT_SMALL + MARGIN);
  image(data_background, 0, height - data_background.height);
  image(top_view, MARGIN, yCordinate);
  image(ball_trace, MARGIN, yCordinate);
  image(objects, MARGIN, yCordinate);
  image(scoreboard, S_HEIGHT_SMALL + 2 * MARGIN, yCordinate);
  image(barChart, S_HEIGHT_SMALL + S_WIDTH + 4 * MARGIN, yCordinate);
}