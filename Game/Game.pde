// --- CONSTANTS ---
final float INCREMENT = 0.01;
final float SPEED_START = 0.025;
final float MAX_SPEED = 0.15;
final float MIN_SPEED = 0.005;
final float MAX_ANGLE = PI/3;
final float PLATE_SIZE_X = 500;
final float PLATE_SIZE_Y = 20;
final float PLATE_SIZE_Z = 500;

// --- Variables ---
float depth = 200;
float angleX = 0;
float angleZ = 0;
float speed = SPEED_START;
Mover ball;


void settings() {
  fullScreen(P3D);
}
void setup() {
  noStroke();
  ball = new Mover(new PVector(0, 0, 0));
}
void draw() {
  // --- Camera & Light settings ---
  //FIXME: Is standard camera good enough?
  directionalLight(50, 100, 125, 0.3, 0.7, 0);  //Light from left/above
  ambientLight(102, 102, 102);
  background(240);

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