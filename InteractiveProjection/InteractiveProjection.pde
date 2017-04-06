void settings() {
  size(1000, 1000, P2D);
}
void setup () {
}

float scale = 1;
final float incRotation = 0.2;
final float incScale = 0.1;
final float minScale = 0.5;
final float maxScale = 5;
float angleX = 0;
float angleY = 0;
int lengthX = 100;
int lengthY = 150;
int lengthZ = 300;

void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, lengthX, lengthY, lengthZ);
  
  float[][] scaling = scaleMatrix(scale, scale, scale);
  float[][] translate = translationMatrix(width/2 - lengthX/2, height/2 - lengthY/2, 0);
  float[][] rotateX = rotateXMatrix(angleX);
  float[][] rotateY = rotateYMatrix(angleY);
  
  //apply all transforms
  input3DBox = transformBox(transformBox(transformBox(transformBox(input3DBox, 
  scaling), rotateX), rotateY), translate);
  
  //render
  projectBox(eye, input3DBox).render();
  }

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}
class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float normalize = 1 - p.z/eye.z;
  return new My2DPoint((p.x - eye.x)/normalize, (p.y -eye.y) / normalize);
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] array = new My2DPoint[8];
  for (int i = 0; i < 8; i++) {
    array[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(array);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {
    {1, 0, 0, 0}, 
    {0, cos(angle), sin(angle), 0}, 
    {0, -sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) {
  return(new float[][] {
    {cos(angle), 0, sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {-sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] {
    {cos(angle), -sin(angle), 0, 0}, 
    {sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {
    {x, 0, 0, 0}, 
    {0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {
    {1, 0, 0, x}, 
    {0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}
float[] matrixProduct(float[][] a, float[] b) {
  return(new float[] {
    a[0][0]* b[0] + a[0][1]* b[1] + a[0][2]* b[2] + a[0][3]* b[3], 
    a[1][0]* b[0] + a[1][1]* b[1] + a[1][2]* b[2] + a[1][3]* b[3], 
    a[2][0]* b[0] + a[2][1]* b[1] + a[2][2]* b[2] + a[2][3]* b[3], 
    a[3][0]* b[0] + a[3][1]* b[1] + a[3][2]* b[2] + a[3][3]* b[3]});
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] array = new My3DPoint[8];
  for (int i = 0; i < 8; i++) {
    float[] point = homogeneous3DPoint(box.p[i]);
    array[i] = euclidian3DPoint(matrixProduct(transformMatrix, point));
  }
  return new My3DBox(array);
}

// operate scaling
void mouseDragged() 
{
  if(mouseY < pmouseY) {
    scale = scale - incScale;
  } else {
    scale = scale + incScale;
  }
  if (scale < minScale) {
    scale = minScale;
  }
  
  if (scale > maxScale) {
    scale = maxScale;
  }
}
//operate x-axis
void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
      case UP: 
      angleX += incRotation;
      break;
      case DOWN:
      angleX -= incRotation;
      break;
      case LEFT:
      angleY += incRotation;
      break;
      case RIGHT:
      angleY -= incRotation;
      break;
    } 
  }
}