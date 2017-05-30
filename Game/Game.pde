// Milestone2 
//FIXME move imports where they belong !!
import processing.video.*;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

// --- OpenCV Imports ---
import gab.opencv.*;
OpenCV opencv;


// --- Constants ---
final float discretizationStepsPhi = 0.06f;
final float discretizationStepsR = 2.5f;
final int minVotes = 100;
final int nlines = 5;
final int regionRadius = 10;
final float resizeFactor = 0.7;

// --- Variables ---
PImage img;
PImage pipelined;

// --- Trig Optimisation ---
Trig t;

// --- Pose estimation ---
TwoDThreeD twoDThreeD;

// --- Camera ---
Capture cam;
final int camera_width = 640;
final int camera_height = 480;

// --- CONSTANTS ---
final float SPEED_START = 0.045;
final float PLATE_SIZE_X = 600;
final float PLATE_SIZE_Y = 20;
final float PLATE_SIZE_Z = 600;
final int OBJECT_COLOR = 0xFF008080;
final int COLOR_RED = 0xFFFF0000;
final int COLOR_GREEN = 0xFF008000;
final int PLATE_COLOR  = 0x8840E0D0;
final int GAME_BACKGROUND_COLOR = 240;

// --- VARIABLES ---
PImage bg;
boolean shiftDown = false;
float angleX = 0;
float angleZ = 0;
float speed = SPEED_START;
ArrayList<PVector> obstaclePositions = new ArrayList<PVector>();
Mover ball;
HScrollbar hs;
HScrollbar tHueMin;
HScrollbar tHueMax;
HScrollbar tSatMin;
HScrollbar tSatMax;
HScrollbar tBriMin;
HScrollbar tBriMax;
boolean setUpPhase = true;

// --- Threshold Variables ---
int hueMin = 50;
int hueMax = 143;
int brightnessMin = 40;
int brightnessMax = 225;
int saturationMin = 40;
int saturationMax = 220;

void settings() {
  fullScreen(P3D);
}
void setup() {
  bg = loadImage("backgroundSky.jpg");
  
  
  // --- setup camera ---
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  // --- image processing ---
  opencv = new OpenCV(this, 100, 100);
  //img = loadImage("board1.jpg");

  twoDThreeD = new TwoDThreeD(camera_width, camera_height, 0);
  t = new Trig();

  /*
  PVector rotation = computeRotation(findCorners(img));
   angleX = rotation.z;
   angleZ = rotation.x;
   */

  // --- game processing ----
  noStroke();
  //Load the Cylinder Shape and setup de surfaces
  loadCylinder();
  loadDroidShapes();
  setupSurfaces();

  //Create new mover and scrollbar
  ball = new Mover(new PVector(0, 0, 0));
  hs = new HScrollbar(S_HEIGHT_SMALL + S_WIDTH + 4 * MARGIN, height - 3 * MARGIN, 300, 20);
  tHueMin = new HScrollbar(1920 - camera_width, 10, camera_width, 20, hueMin);
  tHueMax = new HScrollbar(1920 - camera_width, 40, camera_width, 20, hueMax);
  tSatMin = new HScrollbar(1920 - camera_width, 350, camera_width, 20, saturationMin);
  tSatMax = new HScrollbar(1920 - camera_width, 380, camera_width, 20, saturationMax);
  tBriMin = new HScrollbar(1920 - camera_width, 410, camera_width, 20, brightnessMin);
  tBriMax = new HScrollbar(1920 - camera_width, 440, camera_width, 20, brightnessMax);
}


void draw() {
  // --- ATTENTION ON Fé LA CAMERA
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  List<PVector> quads = findCorners(img);
  if (quads.size() == 4) {
    PVector rotation = computeRotation(quads);
    angleX = rotation.x;
    angleZ = rotation.y;

    if (angleX < -PI/2) angleX += PI;
    else if (angleX > +PI/2) angleX -= PI;
    if (angleZ < -PI/2) angleZ += PI;
    else if (angleZ > PI/2) angleZ -=PI;
  }
  //jai fini

  //background(GAME_BACKGROUND_COLOR);
  background(bg);
  // --- Scoreboard Surfaces ---
  drawScoreBoardSurfaces();
  displayScoreBoardSurfaces();
  displayCamera(quads);

  // --- Scroll bar ---
  hs.update();
  hs.display();

  // --- Scroll bar ---
  if (setUpPhase) {
    tHueMin.update();
    tHueMin.display();
    tHueMax.update();
    tHueMax.display();
    tSatMin.update();
    tSatMin.display();
    tSatMax.update();
    tSatMax.display();
    tBriMin.update();
    tBriMin.display();
    tBriMax.update();
    tBriMax.display();
  }
  // --- update thresholds ---
  hueMin = (int) (255 * tHueMin.getPos());
  hueMax = (int) (255 * tHueMax.getPos());
  saturationMin = (int) (255 * tSatMin.getPos());
  saturationMax = (int) (255 * tSatMax.getPos());
  brightnessMin = (int) (255 * tBriMin.getPos());
  brightnessMax = (int) (255 * tBriMax.getPos());

  // --- Camera & Light settings ---
  //The values for the light have been set arbitrarily
  directionalLight(255, 255, 255, 0.3, 0.7, 0);
  ambientLight(102, 102, 102);

  if (!shiftDown) {
    // --- Display control info ---
    //fill(color(255, 0,0));
    String s = String.format("RotationX: %.5g  RotationZ = %.5g  Speed = %.2g", degrees(angleX), degrees(angleZ), speed/SPEED_START);
    text(s, 10, 20);

    //-- Drawing the plate (angle and speed given by user) ---
    translate(width/2, height/2, 0); 
    rotateX(angleX);
    rotateZ(angleZ);
    
    // --- Updating and drawing the ball ---
    pushMatrix();
    translate(0, -PLATE_SIZE_Y/2, 0);
    ball.update(angleZ, angleX, obstaclePositions, CYLINDER_BASE_SIZE);
    ball.checkEdges(PLATE_SIZE_X, PLATE_SIZE_Z);
    ball.display();

    // --- Drawing obstacles added by user ---
    drawObstacles();
    popMatrix();
    
    
    fill(PLATE_COLOR);
    box(PLATE_SIZE_X, PLATE_SIZE_Y, PLATE_SIZE_Z); 
  } else {
    // --- Object adding mode ---  
    //The values for the light have been set arbitrarily here as well
    directionalLight(255, 255, 255, 0.5, 0.5, -0.5);
    translate(width/2, height/2, 0);
    rotateX(-PI/2);
    fill(PLATE_COLOR);
    box(PLATE_SIZE_X, PLATE_SIZE_Y, PLATE_SIZE_Z);
    ball.display();
    drawObstacles();
    drawObstacleUnderMouse();
  }
}