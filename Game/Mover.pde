// --- CONSTANTS ---
final float GRAVITY_CONSTANT = 0.2;
final float normalForce = 1;
final float mu = 0.01;
final float RADIUS = 20;
final float BOUNCING_FACTOR = 0.98;  //FIXME
final int MOVER_COLOR = 0xFF778899;

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

  void update(float rotZ, float rotX, ArrayList<PVector> obstaclePositions, float obstacleRadius) {
    gravityForce.x = sin(rotZ) * GRAVITY_CONSTANT;
    gravityForce.z = -sin(rotX) * GRAVITY_CONSTANT;

    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    velocity.add(gravityForce);
    velocity.add(friction);
    checkCylinderCollision(obstaclePositions, obstacleRadius);
    location.add(velocity);
  }

  void display() {
    pushMatrix();
    translate(location.x, location.y, location.z);
    translate(0, -RADIUS, 0);
    fill(MOVER_COLOR);
    sphere(RADIUS);
    popMatrix();
  }

  void checkEdges(float boundary_x, float boundary_z) {
    boolean hit = false;  //FIXME better way than this stupid boolean
    
    if (location.x > boundary_x/2) {
      location.x = boundary_x/2;
      velocity.x = velocity.x * -1 * BOUNCING_FACTOR;
      hit = true;
    } else if (location.x < - boundary_x/2) {
      location.x = - boundary_x/2;
      velocity.x = velocity.x * -1 * BOUNCING_FACTOR;
      hit = true;
    }
    if (location.z > boundary_z/2) {
      location.z = boundary_z/2;
      velocity.z = velocity.z * -1 * BOUNCING_FACTOR;
      hit = true;
    } else if (location.z < -boundary_z/2) {
      location.z = - boundary_x/2;
      velocity.z = velocity.z * -1 * BOUNCING_FACTOR;
      hit = true;
    }
    // --- Adjust score if it hit ---
    if (hit) {
      changeScore(false);
    }
  }
  
  
  void checkCylinderCollision (ArrayList<PVector> obstaclePositions, float obstacleRadius) {
    for (PVector obstacle : obstaclePositions) {
      float dist = PVector.dist(new PVector(location.x, 0, location.z), new PVector(obstacle.x, 0, obstacle.z));
      if (dist < RADIUS + obstacleRadius) {
        // --- set position outside object to avoid bugs ---
        location = obstacle.copy().sub(obstacle.copy().sub(location).normalize().mult(obstacleRadius + RADIUS));
        //TODO check formula & effect correctness
        
        // --- handle velocity change ---
        PVector normal = new PVector(location.x, 0, location.z);
        normal.sub(new PVector(obstacle.x, 0, obstacle.z));
        normal.normalize();
        PVector V1 = new PVector(velocity.x, 0, velocity.z);
        PVector V2 = new PVector();
        V2.add(V1);
        normal.mult(-2*V1.dot(normal));
        V2.add(normal);
        velocity = V2.mult(BOUNCING_FACTOR);
        
        // --- Adapt Score ---
        changeScore(true);
      }
    }
  }
}