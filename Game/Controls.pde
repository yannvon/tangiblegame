//--Controls Constants
final float INCREMENT = 0.01;
final float MAX_SPEED = 0.15;
final float MIN_SPEED = 0.005;
final float MAX_ANGLE = PI/3;


void mouseDragged() 
{
  if (!hs.locked) {
    if (mouseY > pmouseY) {
      angleX -= speed;
      angleX = Math.max(angleX, -MAX_ANGLE);
    } else if (mouseY < pmouseY) {
      angleX += speed;
      angleX = Math.min(angleX, MAX_ANGLE);
    }
    if (mouseX > pmouseX) {
      angleZ += speed;
      angleZ = Math.min(angleZ, MAX_ANGLE);
    } else if (mouseX < pmouseX) {
      angleZ -= speed;
      angleZ = Math.max(angleZ, -MAX_ANGLE);
    }
  }
}

void mouseClicked() {
  if (shiftDown) addObstacle();
}
void mouseWheel(MouseEvent event) {
  float count = event.getCount();
  speed += count * INCREMENT;
  speed = Math.min(MAX_SPEED, speed);
  speed = Math.max(MIN_SPEED, speed);
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