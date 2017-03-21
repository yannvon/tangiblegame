// --- CONSTANTS ---
final float INCREMENT = 0.01;
final float SPEED_START = 0.025;
final float MAX_SPEED = 0.15;
final float MIN_SPEED = 0.005;
final float MAX_ANGLE = PI/3;
final float PLATE_SIZE_X = 500;
final float PLATE_SIZE_Y = 20;
final float PLATE_SIZE_Z = 500;

// --- Shapes ---
float cylinderBaseSize = 50;
float cylinderHeight = 50;
int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape side = new PShape();

// --- Variables ---
boolean shiftDown = false;
float depth = 200;
float angleX = 0;
float angleZ = 0;
float speed = SPEED_START;
ArrayList<PVector> obstaclePositions = new ArrayList<PVector>();
Mover ball;


void settings() {
  fullScreen(P3D);
}
void setup() {
  noStroke();
  loadShapes();
  ball = new Mover(new PVector(0, 0, 0));
}
void draw() {
  background(240);
  if (!shiftDown) {
    // --- Camera & Light settings ---
    //FIXME: Is standard camera good enough?
    directionalLight(50, 100, 125, 0.3, 0.7, 0);  //Light from left/above
    ambientLight(102, 102, 102);


    // --- Display control info ---
    String s = String.format("RotationX: %.7g  RotationZ = %.7g  Speed = %.2g", degrees(angleX), degrees(angleZ), speed/SPEED_START);
    text(s, 10, 20);

    //-- Drawing the plate (angle and speed given by user) --
    translate(width/2, height/2, 0); 
    rotateX(angleX);
    rotateZ(angleZ);
    box(500, PLATE_SIZE_Y, 500);
    translate(0, -PLATE_SIZE_Y/2, 0);
    ball.update(angleZ, angleX);
    ball.checkEdges(PLATE_SIZE_X, PLATE_SIZE_Z);
    ball.display();
  } else {
    translate(width/2, height/2, 0);
    rotateX(-PI/2);
    directionalLight(50, 100, 125, 0.3, 0.7, 0);  //Light from left/above
    ambientLight(102, 102, 102);
    box(500, PLATE_SIZE_Y, 500);
    ball.display();
  }
  drawObstacles();
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
  if (shiftDown)addObstacle();
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
void loadShapes() {
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();
  side = createShape();
  side.beginShape(TRIANGLE);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    side.vertex(x[i], y[i], 0);
    side.vertex(0, 0, 0);
    if (i!=x.length-1)side.vertex(x[i+1], y[i+1], 0);
    else side.vertex(x[0], y[0], 0);
  }
  side.endShape();
}

void addObstacle() {
  obstaclePositions.add(new PVector(mouseX, mouseY, 0));
}
void drawObstacles() {
  for (PVector p : obstaclePositions) {
    cylinderAt(p);
  }
}
void cylinderAt(PVector position) {
  pushMatrix();
  translate(-width/2, 0, -height/2); 
  translate(position.x, 0, position.y);
  rotateX(PI/2);
  shape(openCylinder);
  shape(side);
  translate(0, 0, cylinderHeight);
  shape(side);
  popMatrix();
}