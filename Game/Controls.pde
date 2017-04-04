void mouseDragged() 
{
  if (mouseY < height-scoreboard.height) {
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