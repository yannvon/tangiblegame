// --- CONSTANTS ---
final float GRAVITY_CONSTANT = 0.2;
final float normalForce = 1;
final float mu = 0.01;
final float RADIUS = 50;
final float BOUNCING_FACTOR = 0.98;  //FIXME remove!

class Mover {
  // --- Attributes ---
  PVector location;
  PVector velocity;
  PVector gravityForce = new PVector(0, 0);
  
  // --- Consturctor ---
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
    velocity.add(friction);
    location.add(velocity);
  }
  
  void display() {
    pushMatrix();
    translate(location.x, location.y, location.z);
    translate(0, -RADIUS, 0);
    sphere(RADIUS);
    popMatrix();
  }
  
  void checkEdges(float boundary_x, float boundary_z) {
    if (location.x > boundary_x/2) {
      location.x = boundary_x/2;
      velocity.x = velocity.x * -1 * BOUNCING_FACTOR;
    }
    else if(location.x < - boundary_x/2){
      location.x = - boundary_x/2;
      velocity.x = velocity.x * -1 * BOUNCING_FACTOR;
    }
    if (location.z > boundary_z/2) {
      location.z = boundary_z/2;
      velocity.z = velocity.z * -1 * BOUNCING_FACTOR;
    }
    else if (location.z < -boundary_z/2){
      location.z = - boundary_x/2;
      velocity.z = velocity.z * -1 * BOUNCING_FACTOR;
    }
  }
}