// --- CONSTANTS ---
final float SPEED_START = 0.045;
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
HScrollbar hs;

void settings() {
  fullScreen(P3D);
}
void setup() {
  noStroke();
  //Load the Cylinder Shape and setup de surfaces
  loadCylinder();
  setupSurfaces();

  //Create new mover and scrollbar
  ball = new Mover(new PVector(0, 0, 0));
  hs = new HScrollbar(S_HEIGHT_SMALL + S_WIDTH + 4 * MARGIN, height - 3 * MARGIN , 300, 20);
}

void draw() {
  background(240);
  drawScoreBoardSurfaces();
  displayScoreBoardSurfaces();
  
  // --- Scroll bar ---
  hs.update();
  hs.display();

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


// TODO: add these methods to an Tab called obstacle?
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