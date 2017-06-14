import processing.video.*;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

// --- OpenCV Imports ---
import gab.opencv.*;
OpenCV opencv;

// --- Camera or Grading video ---
// --- CHANGE THE ABSOLUTE PATH HERE ---
boolean grading = true;
String videoPath = "C:\\Users\\Yann\\Google Drive\\EPFL_Semestre4\\Introduction à l'informatique visuelle\\css211_game\\Game\\data\\testvideo.avi";

// --- Constants ---
final float discretizationStepsPhi = 0.06f;
final float discretizationStepsR = 2.5f;
final int minVotes = 100;
final int nlines = 5;
final int regionRadius = 14;
final float resizeFactor = 0.7;

// --- Variables ---
PImage img;

// --- Trig Optimisation ---
Trig t;

// --- Pose estimation ---
TwoDThreeD twoDThreeD;

// --- Camera ---
final int camera_width = grading? 800 : 600;
final int camera_height = grading? 600 : 480;

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
PGraphics game;

// --- Threshold Variables ---
int hueMin =53;
int hueMax = 149;
int brightnessMin = 55;
int brightnessMax = 220;
int saturationMin = 55;
int saturationMax = 255;

// --- Image processing PApplet ---
ImageProcessing imgproc;

void settings() {
  fullScreen(P3D);
}
void setup() {
  bg = loadImage("backgroundSky.jpg");
  opencv = new OpenCV(this, 100, 100);

  twoDThreeD = new TwoDThreeD(camera_width, camera_height, 15);
  t = new Trig();

  // --- game processing ----
  noStroke();
  //Load the Cylinder Shape and setup de surfaces
  loadCylinder();
  loadDroidShapes();
  setupSurfaces();
  game = createGraphics(width, height, P3D);
  
  //Create new mover and scrollbar
  ball = new Mover(new PVector(0, 0, 0));
  hs = new HScrollbar(S_HEIGHT_SMALL + S_WIDTH + 4 * MARGIN, height - 3 * MARGIN, 300, 20);

  // --- image processing ---
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
}


void draw() {
  // --- Most Game Elements ---
  drawGameSurface();
  displayGameSurface();

  // --- Scroll bar ---
  hs.update();
  //display actually draws it on a PGraphics
  hs.display();

 // --- Scoreboard Surfaces ---
  drawScoreBoardSurfaces();
  displayScoreBoardSurfaces();
  displayCamera(imgproc.quads);
}

void drawGameSurface() {
  game.beginDraw();
  //game.background(GAME_BACKGROUND_COLOR);
  game.background(bg);
  
  // --- Camera & Light settings ---
  //The values for the light have been set arbitrarily
  game.directionalLight(255, 255, 255, 0.3, 0.7, 0);
  game.ambientLight(102, 102, 102);

  if (!shiftDown) {
    // --- Display control info ---
    //fill(color(255, 0,0));
    String s = String.format("RotationX: %.5g  RotationZ = %.5g  Speed = %.2g", degrees(angleX), degrees(angleZ), speed/SPEED_START);
    game.text(s, 10, 20);

    //-- Drawing the plate (angle and speed given by user) ---
    game.translate(width/2, height/2, 0); 
    game.rotateX(angleX);
    game.rotateZ(angleZ);

    // --- Updating and drawing the ball ---
    game.pushMatrix();
    game.translate(0, -PLATE_SIZE_Y/2, 0);
    ball.update(angleZ, angleX, obstaclePositions, CYLINDER_BASE_SIZE);
    ball.checkEdges(PLATE_SIZE_X, PLATE_SIZE_Z);
    ball.display();

    // --- Drawing obstacles added by user ---
    drawObstacles();
    game.popMatrix();

    game.fill(PLATE_COLOR);
    game.box(PLATE_SIZE_X, PLATE_SIZE_Y, PLATE_SIZE_Z);
  } else {
    // --- Object adding mode ---  
    //The values for the light have been set arbitrarily here as well
    game.directionalLight(255, 255, 255, 0.5, 0.5, -0.5);
    game.translate(width/2, height/2, 0);
    game.rotateX(-PI/2);
    game.fill(PLATE_COLOR);
    game.box(PLATE_SIZE_X, PLATE_SIZE_Y, PLATE_SIZE_Z);
    ball.display();
    drawObstacles();
    drawObstacleUnderMouse();
  }
  game.endDraw();
}
void displayGameSurface() {
  image(game, 0, 0);
}