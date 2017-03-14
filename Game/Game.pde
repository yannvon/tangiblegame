float depth = 200;
float angleX = 0;
float angleZ = 0;
float lastMouseX = 0;
float lastMouseY = 0;
float speed = 0.02;

final float INCREMENT = 0.1;
final float SPEED_START = speed;
final float MAX_ANGLE = PI/3;
final float PLATE_SIZE_Z = 20;
Mover ball;
void settings() {
  //size(500, 500, P3D);
  fullScreen(P3D);
}
void setup() {
  noStroke();
  ball = new Mover(new PVector(0, 0, 0));
}
void draw() {
  //camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0); //FIXME standard enough?
  directionalLight(50, 100, 125, 0.3, 0.7, 0);  //Light from left/above
  ambientLight(102, 102, 102);
  background(240);

  //-- Display control info top left --
  //TODO: convert angle to Degrees
  //TODO: speed fine tuning
  String s = String.format("RotationX: %.7g  RotationZ = %.7g  Speed = %.2g", degrees(angleX), degrees(angleZ), speed/SPEED_START);
  text(s, 10, 20);

  //-- Drawing the plate (angle and speed given by user) --
  pushMatrix();  //Probably useless..
  translate(width/2, height/2, 0); 
  rotateX(angleX);
  rotateZ(angleZ);
  box(500, PLATE_SIZE_Z, 500);
  translate(0, PLATE_SIZE_Z/2, 0);
  ball.update(angleZ, angleX);
  ball.display();
  popMatrix();
}

void mouseDragged() 
{
  if (mouseY > lastMouseY && angleX > -MAX_ANGLE) {
    angleX -= speed;
  } else if (mouseY < lastMouseY && angleX < MAX_ANGLE) {
    angleX += speed;
  }
  if (mouseX > lastMouseX && angleZ < MAX_ANGLE) {
    angleZ += speed;
  } else if (mouseX < lastMouseX && angleZ > -MAX_ANGLE) {
    angleZ -= speed;
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseWheel(MouseEvent event) {
  float count = event.getCount();
  if (count > 0 && speed < 1) {
    speed += INCREMENT;
  } else if (count < 0 && speed > 0.02) {
    speed -= INCREMENT;
  }
}