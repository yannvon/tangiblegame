float depth = 200;
float angleX = 0;
float angleY = 0;
float lastMouseX = 0;
float lastMouseY = 0;
float increment = 0.1;
void settings() {
  size(500, 500, P3D);
}
void setup() {
  noStroke();
}
void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);

  rotateX(angleY);
  rotateZ(angleX);
  box(100, 10, 100);
}
void mouseDragged() 
{
  if (mouseY > lastMouseY && angleY > -PI/6) {
    angleY -= increment;
  } else if(mouseY < lastMouseY && angleY < PI/6){
    angleY += increment;
  }
  if (mouseX > lastMouseX && angleX < PI/6) {
    angleX += increment;
  } else if(mouseX < lastMouseX && angleX > -PI/6) {
    angleX -= increment;
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseWheel(MouseEvent event) {
  float count = event.getCount();
  if(count>0 && increment < 1){
    increment += 0.01;
  }
  else if(count<0 && increment > 0.02){
    increment -= 0.01;
  }
}