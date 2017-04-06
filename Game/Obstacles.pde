void addObstacle() {
  PVector position = new PVector(mouseX - width/2, 0, mouseY - height/2);
  if (isObstaclePositionAuthorized(position)) obstaclePositions.add(position);
}

boolean isObstaclePositionAuthorized(PVector position) {
  for (PVector obstacle : obstaclePositions) {
    if (PVector.dist(obstacle, position) < 2 * CYLINDER_BASE_SIZE) return false;
  }
  if (PVector.dist(ball.location, position) < CYLINDER_BASE_SIZE + RADIUS) return false;
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