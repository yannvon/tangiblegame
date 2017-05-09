PImage img;
PImage imgHoughTest;


float discretizationStepsPhi = 0.06f;
float discretizationStepsR = 2.5f;
int minVotes=400;

void settings() {
  size(1600, 600);
}
void setup() {
  img = loadImage("board1.jpg");
  imgHoughTest = loadImage("hough_test.bmp");

  noLoop();
}
void draw() {
  background(color(0, 0, 0));
  image(imgHoughTest, 0, 0);
  hough(imgHoughTest);
  plotLines(imgHoughTest, hough(imgHoughTest));
}


PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    color c = img.pixels[i];
    int value = (minB <= brightness(c) && brightness(c) <= maxB &&
      minH <= hue(c) && hue(c) <= maxH &&
      minS <= saturation(c) && saturation(c) <= maxS) ? 255 : 0;
    result.pixels[i] = color (value, value, value);
  }
  return result;
}

PImage thresholdHue(PImage img, int tLow, int tHigh) {
  // create a new, initially transparent, ’result’ image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    float hue = hue(img.pixels[i]);
    if (hue >= tLow && hue <= tHigh) {
      result.pixels[i] = color(img.pixels[i]);
    } else {
      result.pixels[i] = color(0, 0, 0);
    }
  }
  return result;
}

PImage thresholdBrightness(PImage img, int threshold) {
  // create a new, initially transparent, ’result’ image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i]) >= threshold) {
      result.pixels[i] = color(255, 255, 255);
    } else {
      result.pixels[i] = color(0, 0, 0);
    }
  }
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}

PImage convolute(PImage img) {
  float[][] kernel = { { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  //kernel size
  int N = 3;
  //
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by normFactor
  // - set result.pixels[y * img.width + x] to this value
  for (int x = 1; x < img.width - 1; ++x) {
    for (int y = 1; y < img.height - 1; ++y) {
      float sum = 0.0;
      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          sum += brightness(img.pixels[x - N/2 + i + (y-N/2+j)*img.width]) * kernel[i][j];
        }
      }
      result.pixels[y * img.width + x] = color(sum/normFactor);
    }
  }
  return result;
}

PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 } };
  float[][] hKernel = {
    { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];
  // *************************************
  //kernel size
  int N = 3;
  for (int x = 1; x < img.width - 1; ++x) {
    for (int y = 1; y < img.height - 1; ++y) {
      float sumH = 0.0;
      float sumV = 0.0;
      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          sumH += brightness(img.pixels[x - N/2 + i + (y-N/2+j)*img.width]) * hKernel[i][j];
          sumV += brightness(img.pixels[x - N/2 + i + (y-N/2+j)*img.width]) * vKernel[i][j];
        }
      }
      float sum=sqrt(pow(sumH, 2) + pow(sumV, 2));
      if (sum>max)max = sum;
      buffer[y * img.width + x] = sum;
    }
  }
  // *************************************
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*255);
      result.pixels[y * img.width + x]=color(val);
    }
  }
  return result;
}

PImage pipeline(PImage img) {
  return scharr(thresholdBrightness(convolute(thresholdHSB(img, 50, 143, 135, 255, 50, 170)), 100));
}

ArrayList<PVector> hough(PImage edgeImg) {



  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);

  //The max radius is the image diagonal, but it can be also negative
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
    edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);

  // our accumulator
  int[] accumulator = new int[phiDim * rDim];

  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {

      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator: r += rDim / 2
        for (int phiN = 0; phiN < phiDim; phiN++) {

          float phi = phiN * discretizationStepsPhi;
          float r = (x * cos(phi) + y * sin(phi));

          r = r/discretizationStepsR;
          r += rDim / 2;

          //increment corresponding accumulator
          accumulator[phiN * rDim + (int) r] += 1;
        }
      }
    }
  }

  ArrayList<PVector> lines=new ArrayList<PVector>();
  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > minVotes) {

      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    }
  }



  PImage houghImg = createImage(rDim, phiDim, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }

  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(600, 600);
  houghImg.updatePixels();

  image(houghImg, houghImg.width, 0);

  return lines;
}

void plotLines(PImage edgeImg, ArrayList<PVector> lines) {
  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}