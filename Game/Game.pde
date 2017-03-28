// --- CONSTANTS ---
final float INCREMENT = 0.01;
final float SPEED_START = 0.045;
final float MAX_SPEED = 0.15;
final float MIN_SPEED = 0.005;
final float MAX_ANGLE = PI/3;
final float PLATE_SIZE_X = 500;
final float PLATE_SIZE_Y = 20;
final float PLATE_SIZE_Z = 500;
final int OBJECT_COLOR = 0xFF008080;
final int COLOR_RED = 0xFFFF0000;
final int COLOR_GREEN = 0xFF008000;
final int PLATE_COLOR  = 0xFF40E0D0;

// --- Variables ---
boolean shiftDown = false;
float depth = 200;
float angleX = 0;
float angleZ = 0;
float speed = SPEED_START;
ArrayList<PVector> obstaclePositions = new ArrayList<PVector>();
Mover ball;

// --- Surfaces ---
PGraphics data_background;
PGraphics top_view;
PGraphics objects;
PGraphics ball_trace;
PGraphics scoreboard;

int data_background_height = 200;
int top_view_size = 160;
int margin = (data_background_height - top_view_size)/ 2;

void settings() {
  fullScreen(P3D);
}
void setup() {
  noStroke();
  loadCylinder();

  //TODO : Add method for modularity
  data_background = createGraphics(width, data_background_height, P2D);
  top_view = createGraphics(top_view_size, top_view_size, P2D);
  objects = createGraphics(top_view_size, top_view_size, P2D);
  ball_trace = createGraphics(top_view_size, top_view_size, P2D);
  ball = new Mover(new PVector(0, 0, 0));
}
void draw() {
  background(240);
  drawScoreBoard();

  //TODO : Add method for modularity
  image(data_background, 0, height - data_background_height);
  image(top_view, margin, height - (top_view_size + margin));
  image(ball_trace, margin, height - (top_view_size + margin));
  image(objects, margin, height - (top_view_size + margin));
  // --- Camera & Light settings ---
  directionalLight(255, 255, 255, 0.3, 0.7, 0);
  ambientLight(102, 102, 102);

  if (!shiftDown) {
    // --- Display control info ---
    String s = String.format("RotationX: %.7g  RotationZ = %.7g  Speed = %.2g", degrees(angleX), degrees(angleZ), speed/SPEED_START);
    text(s, 10, 20);

    //-- Drawing the plate (angle and speed given by user) ---
    translate(width/2, height/2, 0); 
    rotateX(angleX);
    rotateZ(angleZ);
    fill(PLATE_COLOR);
    box(PLATE_SIZE_X, PLATE_SIZE_Y, PLATE_SIZE_Z); 

    // --- Updating and drawing the ball ---
    translate(0, -PLATE_SIZE_Y/2, 0);
    ball.update(angleZ, angleX, obstaclePositions, cylinderBaseSize);
    ball.checkEdges(PLATE_SIZE_X, PLATE_SIZE_Z);
    ball.display();

    // --- Drawing obstacles added by user ---
    drawObstacles();
  } else {
    // --- Object adding mode ---
    translate(width/2, height/2, 0);
    rotateX(-PI/2);
    fill(PLATE_COLOR);
    box(PLATE_SIZE_X, PLATE_SIZE_Y, PLATE_SIZE_Z);
    ball.display();
    drawObstacles();
    drawObstacleUnderMouse();
  }
}

void drawScoreBoard() {
  data_background.beginDraw();
  data_background.background(239, 236, 202);
  data_background.endDraw();

  objects.beginDraw();
  objects.pushMatrix();
  objects.clear();
  objects.translate(top_view_size/2, top_view_size/2); 
  objects.scale(top_view_size / PLATE_SIZE_X);
  objects.fill(239, 236, 202);
  for (PVector obstacle : obstaclePositions) {
    objects.ellipse(obstacle.x, obstacle.z, cylinderBaseSize * 2, cylinderBaseSize *2);
  }
  objects.fill(COLOR_RED);
  objects.ellipse(ball.location.x, ball.location.z, RADIUS * 2, RADIUS * 2);
  objects.popMatrix();
  objects.endDraw();
  
  top_view.beginDraw();
  top_view.background(5, 100, 129);
  top_view.endDraw();
  

  ball_trace.beginDraw();
  ball_trace.pushMatrix();
  ball_trace.translate(top_view_size/2, top_view_size/2); 
  ball_trace.scale(top_view_size / PLATE_SIZE_X);
  ball_trace.noStroke();
  ball_trace.fill(25, 120, 149);
  ball_trace.ellipse(ball.location.x, ball.location.z, RADIUS / 2, RADIUS / 2);
  ball_trace.popMatrix();
  ball_trace.endDraw();
}


void mouseDragged() 
{
  if (mouseY > pmouseY && angleX > -MAX_ANGLE) {
    angleX -= speed;
    angleX = Math.max(angleX, -MAX_ANGLE);
  } else if (mouseY < pmouseY && angleX < MAX_ANGLE) {
    angleX += speed;
    angleX = Math.min(angleX, MAX_ANGLE);
  }
  if (mouseX > pmouseX && angleZ < MAX_ANGLE) {
    angleZ += speed;
    angleZ = Math.max(angleZ, -MAX_ANGLE);
  } else if (mouseX < pmouseX && angleZ > -MAX_ANGLE) {
    angleZ -= speed;
    angleZ = Math.min(angleZ, MAX_ANGLE);
  }
}

void mouseClicked() {
  if (shiftDown) addObstacle();
}
void mouseWheel(MouseEvent event) {
  float count = event.getCount();
  if (count > 0 && speed < MAX_SPEED) {
    speed += INCREMENT;
    speed = Math.min(MAX_SPEED, speed);
  } else if (count < 0 && speed > MIN_SPEED) {
    speed -= INCREMENT;
    speed = Math.max(MIN_SPEED, speed);
  }
}
void keyPressed() {
  if (keyCode == SHIFT) {
    shiftDown = true;
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shiftDown = false;
  }
}

void addObstacle() {
  PVector position = new PVector(mouseX - width/2, 0, mouseY - height/2);
  if (isObstaclePositionAuthorized(position)) obstaclePositions.add(position);
}

boolean isObstaclePositionAuthorized(PVector position) {
  for (PVector obstacle : obstaclePositions) {
    if (PVector.dist(obstacle, position) < 2 * cylinderBaseSize) return false;
  }
  if (PVector.dist(ball.location, position) < cylinderBaseSize + RADIUS) return false;
  else if (!positionInsidePlate(position)) return false;
  return true;
}

void drawObstacles() {
  for (PVector p : obstaclePositions) {
    cylinderAt(p);
  }
}

void drawObstacleUnderMouse() {
  PVector position = new PVector(mouseX - width/2, 0, mouseY - height/2);
  if (!isObstaclePositionAuthorized(position)) {
    setCylinderColor(COLOR_RED);
  } else {
    setCylinderColor(COLOR_GREEN);
  }
  cylinderAt(position);
  setCylinderColor(OBJECT_COLOR);
}

boolean positionInsidePlate(PVector position) {
  return ( position.x <= PLATE_SIZE_X/2 && 
    position.x >= - PLATE_SIZE_X/2 &&
    position.z <= PLATE_SIZE_Z/2 && 
    position.z >= -PLATE_SIZE_Z/2 );
}