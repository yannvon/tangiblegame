float depth = 200;
float angleX = 0;
float angleZ = 0;
float lastMouseX = 0;
float lastMouseY = 0;
float increment = 0.02;

void settings() {
  //size(500, 500, P3D);
  fullScreen(P3D);
}
void setup() {
  noStroke();
}
void draw() {
  //camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0); //FIXME standard enough?
  directionalLight(50, 100, 125, 0.3, 0.7, 0);  //Light from left/above
  ambientLight(102, 102, 102);
  background(240);
  
  //-- Display control info top left --
  //TODO: convert angle to Degrees
  //TODO: speed fine tuning
  String s = String.format("RotationX: %.7g  RotationZ = %.7g  Speed = %.2g", angleX, angleZ, increment*100);
  text(s, 10, 20);
  
  //-- Drawing the plate (angle and speed given by user) --
  pushMatrix();  //Probably useless..
  translate(width/2, height/2, 0);
  rotateX(angleX);
  rotateZ(angleZ);
  box(500, 20, 500);
  popMatrix();
}

void mouseDragged() 
{
  if (mouseY > lastMouseY && angleX > -PI/6) {
    angleX -= increment;
  } else if(mouseY < lastMouseY && angleX < PI/6){
    angleX += increment;
  }
  if (mouseX > lastMouseX && angleZ < PI/6) {
    angleZ += increment;
  } else if(mouseX < lastMouseX && angleZ > -PI/6) {
    angleZ -= increment;
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseWheel(MouseEvent event) {
  float count = event.getCount();
  if(count > 0 && increment < 1){
    increment += 0.01;
  }
  else if(count < 0 && increment > 0.02){
    increment -= 0.01;
  }
}