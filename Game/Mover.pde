final float GRAVITY_CONSTANT = 0.2;
final float normalForce = 1;
final float mu = 0.01;
final float RADIUS = 100;

class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce = new PVector(0,0);
  Mover(PVector location) {
    this.location = location;
    velocity = new PVector(0, 0);
  }
  void update(float rotZ, float rotX) {
    gravityForce.x = sin(rotZ) * GRAVITY_CONSTANT;
    gravityForce.z = -sin(rotX) * GRAVITY_CONSTANT;

    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    velocity.add(gravityForce);
    //velocity.add(friction);
    location.add(velocity);
  }
  void display() {

    pushMatrix();
    stroke(0);
    strokeWeight(2);
    fill(127);
    translate(location.x, location.y, location.z);
    translate(0, RADIUS, 0);
    sphere(RADIUS);
    popMatrix();
  }
  void checkEdges() {
    /*
    if ((location.x > width - radius/2) || (location.x < 0 + radius/2)) {
     velocity.x = velocity.x * -1;
     }
     if ((location.y > height - radius/2) || (location.y < 0 + radius/2)) {
     velocity.y = velocity.y * -1;
     }
     */
  }
}